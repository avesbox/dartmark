import 'dart:convert';
import 'dart:io';

import 'package:dartmark/src/http_config.dart';

class HttpBenchmarkResult {
  final String framework;
  final double rps;
  final double p50;
  final double p95;
  final double p99;
  final double latency;
  final double stability;
  final int errors;
  final int concurrency;
  final int durationSeconds;
  final int? requests;
  final String? version;
  final Map<String, dynamic> environment;
  final String endpoint;

  HttpBenchmarkResult({
    required this.framework,
    required this.rps,
    required this.p50,
    required this.p95,
    required this.p99,
    required this.latency,
    required this.stability,
    required this.errors,
    required this.concurrency,
    required this.durationSeconds,
    required this.requests,
    required this.version,
    required this.environment,
    required this.endpoint,
  });

  Map<String, dynamic> toMap() => {
        'framework': framework,
        'endpoint': endpoint,
        'rps': rps,
        'p50': p50,
        'p95': p95,
        'p99': p99,
        'latency': latency,
        'stability': stability,
        'errors': errors,
        'concurrency': concurrency,
        'durationSeconds': durationSeconds,
        'requests': requests,
        'version': version ?? 'unknown',
        ...environment,
      };
}

class HttpRunner {
  Future<HttpBenchmarkResult> run(HttpBenchmarkConfig config) async {
    await _build(config);
    final server = await _startServer(config);
    try {
      await _waitForReady(config);
      await _warmup(config);
      final result = await _execute(config);
      _stopServer(server);
      return result;
    } finally {
      _stopServer(server);
    }
  }

  Future<void> _build(HttpBenchmarkConfig config) async {
    final pubGet = await Process.run(
      'dart',
      ['pub', 'get'],
      workingDirectory: config.projectPath,
    );

    if (pubGet.exitCode != 0) {
      throw StateError('Dependency resolution failed: ${pubGet.stderr}');
    }

    final result = await Process.run(
      config.build.command,
      config.build.args,
      workingDirectory: config.projectPath,
    );
    if (result.exitCode != 0) {
      throw StateError('Build failed: ${result.stderr}');
    }
  }

  Future<Process> _startServer(HttpBenchmarkConfig config) async {
    final executablePath = File(
      '${config.projectPath}/${config.run.command}'.replaceAll('/', Platform.pathSeparator),
    ).absolute.path;

    if (!File(executablePath).existsSync()) {
      throw StateError('Server executable not found at: $executablePath');
    }

    final process = await Process.start(
      executablePath,
      config.run.args,
      workingDirectory: config.projectPath,
      environment: {
        ...Platform.environment,
        ...config.run.env,
      },
      mode: ProcessStartMode.detachedWithStdio,
    );
    return process;
  }

  Future<void> _waitForReady(HttpBenchmarkConfig config) async {
    final uri = Uri.parse('${config.http.baseUrl}${config.http.waitForReady.path}');
    final timeout = Duration(seconds: config.http.waitForReady.timeoutSeconds);
    final interval = Duration(milliseconds: config.http.waitForReady.intervalMillis);
    final started = DateTime.now();
    while (DateTime.now().difference(started) < timeout) {
      try {
        final request = await HttpClient().getUrl(uri);
        final response = await request.close();
        if (response.statusCode >= 200 && response.statusCode < 500) {
          return;
        }
      } catch (_) {
      }
      await Future.delayed(interval);
    }
    throw StateError('Server at ${uri.toString()} not ready within ${timeout.inSeconds}s');
  }

  Future<void> _warmup(HttpBenchmarkConfig config) async {
    if (config.load.warmupSeconds <= 0) {
      return;
    }
    await _runOha(
      config,
      durationSeconds: config.load.warmupSeconds,
      label: 'warmup',
    );
  }

  Future<HttpBenchmarkResult> _execute(HttpBenchmarkConfig config) async {
    final output = await _runOha(
      config,
      durationSeconds: config.load.durationSeconds,
      requests: config.load.requests,
      label: 'main',
    );

    final parsed = _parseOhaOutput(output.stdout, output.stderr, output.exitCode);
    final environment = _collectEnvironment();

    return HttpBenchmarkResult(
      framework: config.framework,
      endpoint: '${config.http.baseUrl}${config.http.endpoint}',
      rps: parsed.rps,
      p50: parsed.p50 * 1000,
      p95: parsed.p95 * 1000,
      p99: parsed.p99 * 1000,
      errors: parsed.errors,
      latency: parsed.latency * 1000,
      stability: parsed.stability,
      concurrency: config.load.concurrency,
      durationSeconds: config.load.durationSeconds,
      requests: config.load.requests,
      version: config.version,
      environment: environment,
    );
  }

  Future<_OhaRunResult> _runOha(
    HttpBenchmarkConfig config, {
    required int durationSeconds,
    int? requests,
    required String label,
  }) async {
    final args = <String>[];
    if (requests != null && requests > 0) {
      args.addAll(['-n', '$requests']);
    } else {
      args.addAll(['-z', '${durationSeconds}s']);
    }
    args.addAll(['-c', '${config.load.concurrency}']);
    if (config.load.connections > 0) {
      args.addAll(['-r', '${config.load.connections}']);
    }
    if (config.load.timeoutSeconds > 0) {
      args.addAll(['-t', '${config.load.timeoutSeconds}s']);
    }
    for (final header in config.load.headers) {
      args.addAll(['-H', header]);
    }
    if (config.load.body != null) {
      args.addAll(['-d', config.load.body!]);
    }
    args.add('--no-tui');
    args.addAll(config.oha.extraArgs);
    final url = '${config.http.baseUrl}${config.http.endpoint}';
    args.add(url);

    ProcessResult result = await Process.run(
      config.oha.binaryPath,
      [...args, '--output-format', 'json'],
      runInShell: false,
      workingDirectory: config.projectPath,
    );

    if (
        result.exitCode != 0 &&
        (result.stderr as String).contains("unexpected argument '--output-format'")) {
      result = await Process.run(
        config.oha.binaryPath,
        [...args, '--json'],
        runInShell: false,
        workingDirectory: config.projectPath,
      );
    }

    if (result.exitCode != 0) {
      throw StateError('oha $label run failed: ${result.stderr}');
    }
    return _OhaRunResult(result.stdout as String, result.stderr as String, result.exitCode);
  }

  void _stopServer(Process process) {
    try {
      process.kill(ProcessSignal.sigterm);
    } catch (_) {
      // best effort
    }
  }

  _OhaParsed _parseOhaOutput(String stdout, String stderr, int exitCode) {
    double? rps;
    double? p50;
    double? p95;
    double? p99;
    int errors = 0;
    final json = jsonDecode(stdout) as Map<String, dynamic>;
    final summary = json['summary'] as Map<String, dynamic>;
    rps = (summary['requestsPerSec'] as num).toDouble();
    final latencies = json['latencyPercentiles'] as Map<String, dynamic>;
    p50 = latencies['p50'];
    p95 = latencies['p95'];
    p99 = latencies['p99'];
    final requests = json['rps'];
    final stddev = requests['stddev'];
    double averageLatency = summary['average'];
    if (p50 == null || p95 == null || p99 == null) {
      throw StateError('Unable to parse oha output.');
    }

    return _OhaParsed(
      rps: rps,
      p50: p50,
      p95: p95,
      latency: averageLatency,
      stability: (stddev / rps) * 100,
      p99: p99,
      errors: errors,
    );
  }


  Map<String, dynamic> _collectEnvironment() {
    return {
      'cpu': Platform.environment['PROCESSOR_IDENTIFIER'] ?? 'unknown',
      'system': Platform.operatingSystemVersion,
      'memory': Platform.environment['MEMORY'] ?? 'unknown',
    };
  }
}

class _OhaRunResult {
  final String stdout;
  final String stderr;
  final int exitCode;

  _OhaRunResult(this.stdout, this.stderr, this.exitCode);
}

class _OhaParsed {
  final double rps;
  final double p50;
  final double p95;
  final double p99;
  final double latency;
  final double stability;
  final int errors;

  _OhaParsed({
    required this.rps,
    required this.p50,
    required this.p95,
    required this.p99,
    required this.latency,
    required this.stability,
    required this.errors,
  });
}
