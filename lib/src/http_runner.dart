import 'dart:convert';
import 'dart:io';

import 'package:dartmark/src/http_config.dart';


class HttpBenchmarkResult {
  final String framework;
  final int coldStartMs;
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
  final int size;
  final double cpuUtilization;
  final double throughput;
  final int memoryUsedBytes;

  HttpBenchmarkResult({
    required this.framework,
    required this.coldStartMs,
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
    required this.memoryUsedBytes,
    required this.size,
    required this.cpuUtilization,
    required this.throughput,
  });

  Map<String, dynamic> toMap() => {
        'framework': framework,
        'endpoint': endpoint,
        'coldStartMs': coldStartMs,
        'rps': rps,
        'p50': p50,
        'p95': p95,
        'p99': p99,
        'latency': latency,
        'stability': stability,
        'errors': errors,
        'concurrency': concurrency,
        'durationSeconds': durationSeconds,
        'cpuUtilization': cpuUtilization,
        'requests': requests,
        'version': version ?? 'unknown',
        'throughput': throughput,
        'memoryUsedBytes': memoryUsedBytes,
        'size': size,
        ...environment,
      };
}

class HttpRunner {
  Future<HttpBenchmarkResult> run(HttpBenchmarkConfig config) async {
    final buildSize = await _build(config);
    final coldStartWatch = Stopwatch()..start();
    final server = await _startServer(config);
    try {
      final coldStartMs = await _waitForReady(config, coldStartWatch);
      await _warmup(config);
      return await _execute(config, coldStartMs, server.pid, buildSize);
    } finally {
      await _stopServer(server, config);
    }
  }

  Future<int> _build(HttpBenchmarkConfig config) async {
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
    final compiledFile = File('${config.projectPath}/${config.run.command}'.replaceAll('/', Platform.pathSeparator));
    if (!compiledFile.existsSync()) {
      throw StateError('Expected compiled server executable not found at: ${compiledFile.path}');
    }
    return compiledFile.length();
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

    process.stdout.listen((_) {});
    process.stderr.listen((_) {});

    return process;
  }

  Future<int> _waitForReady(HttpBenchmarkConfig config, Stopwatch coldStartWatch) async {
    final uri = Uri.parse('${config.http.baseUrl}${config.http.waitForReady.path}');
    final timeout = Duration(seconds: config.http.waitForReady.timeoutSeconds);
    final interval = Duration(milliseconds: config.http.waitForReady.intervalMillis);
    final started = DateTime.now();
    final client = HttpClient();
    try {
      while (DateTime.now().difference(started) < timeout) {
        try {
          final request = await client.getUrl(uri);
          final response = await request.close();
          if (response.statusCode >= 200 && response.statusCode < 500) {
            await response.drain();
            coldStartWatch.stop();
            return coldStartWatch.elapsedMilliseconds;
          }
        } catch (_) {
        }
        await Future.delayed(interval);
      }
      throw StateError('Server did not become ready within ${timeout.inSeconds} seconds.');
    } finally {
      client.close();
    }
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

  Future<HttpBenchmarkResult> _execute(HttpBenchmarkConfig config, int coldStartMs, int serverPid, int buildSize) async {
    final cpuBefore = await _getProcessCpuTicks(serverPid);
    final wallBefore = DateTime.now();

    final output = await _runOha(
      config,
      durationSeconds: config.load.durationSeconds,
      requests: config.load.requests,
      label: 'main',
    );

    final cpuAfter = await _getProcessCpuTicks(serverPid);
    final wallAfter = DateTime.now();

    final parsed = _parseOhaOutput(output.stdout, output.stderr, output.exitCode);
    final environment = _collectEnvironment();
    final memoryUsedBytes = await _getProcessMemoryBytes(serverPid);

    final wallElapsedMs = wallAfter.difference(wallBefore).inMilliseconds;
    double cpuUtilization = 0.0;
    if (cpuBefore != null && cpuAfter != null && wallElapsedMs > 0) {
      final cpuMs = cpuAfter - cpuBefore;
      final normalizedWallMs = wallElapsedMs * Platform.numberOfProcessors;
      cpuUtilization = (cpuMs / normalizedWallMs) * 100.0;
    }
    cpuUtilization = cpuUtilization.clamp(0, 100).toDouble();

    return HttpBenchmarkResult(
      framework: config.framework,
      endpoint: '${config.http.baseUrl}${config.http.endpoint}',
      coldStartMs: coldStartMs,
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
      memoryUsedBytes: memoryUsedBytes,
      size: buildSize,
      throughput: parsed.throughput,
      cpuUtilization: double.parse(cpuUtilization.toStringAsFixed(2)),
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

  Future<void> _stopServer(Process process, HttpBenchmarkConfig config) async {
    try {
      await _signalProcessTree(process.pid, force: false);
      await process.exitCode.timeout(const Duration(seconds: 3));
    } catch (_) {
      try {
        await _signalProcessTree(process.pid, force: true);
        await process.exitCode.timeout(const Duration(seconds: 2));
      } catch (_) {
        // best effort
      }
    }
  }

  Future<void> _signalProcessTree(int pid, {required bool force}) async {
    if (Platform.isWindows) {
      final args = <String>['/PID', '$pid', '/T'];
      if (force) {
        args.add('/F');
      }
      await Process.run('taskkill', args);
      return;
    }

    final childSignal = force ? '-KILL' : '-TERM';
    final parentSignal = force ? ProcessSignal.sigkill : ProcessSignal.sigterm;

    try {
      await Process.run('pkill', [childSignal, '-P', '$pid']);
    } catch (_) {
      // pkill may not be available; continue with parent signal
    }

    Process.killPid(pid, parentSignal);
  }

  /// Returns total CPU time (user + system) in milliseconds for [pid],
  /// or null if it cannot be determined.
  Future<double?> _getProcessCpuTicks(int pid) async {
    // Linux / Docker: read /proc/<pid>/stat
    final statFile = File('/proc/$pid/stat');
    if (statFile.existsSync()) {
      try {
        final contents = await statFile.readAsString();
        // Fields after the comm (which may contain spaces/parens):
        // Index 0 = pid, 1 = (comm), 2 = state, ..., 13 = utime, 14 = stime
        final closeParen = contents.lastIndexOf(')');
        if (closeParen != -1) {
          final fields = contents.substring(closeParen + 2).trim().split(' ');
          // fields[11] = utime (index 13 in full stat), fields[12] = stime (index 14)
          if (fields.length > 12) {
            final utime = int.tryParse(fields[11]);
            final stime = int.tryParse(fields[12]);
            if (utime != null && stime != null) {
              // Convert clock ticks to milliseconds (clock ticks = sysconf(_SC_CLK_TCK), typically 100)
              return (utime + stime) * (1000 / 100);
            }
          }
        }
      } catch (_) {}
    }

    // macOS / fallback: ps reports cumulative CPU time as [[dd-]hh:]mm:ss.ss
    try {
      final result = await Process.run('ps', ['-o', 'cputime=', '-p', '$pid']);
      if (result.exitCode == 0) {
        final raw = (result.stdout as String).trim();
        return _parsePsCpuTime(raw);
      }
    } catch (_) {}
    return null;
  }

  /// Parses ps cputime format [[dd-]hh:]mm:ss[.ss] into milliseconds.
  double? _parsePsCpuTime(String raw) {
    if (raw.isEmpty) return null;
    double days = 0;
    var rest = raw;

    // Handle dd- prefix
    if (rest.contains('-')) {
      final parts = rest.split('-');
      days = double.tryParse(parts[0]) ?? 0;
      rest = parts[1];
    }

    final segments = rest.split(':');
    if (segments.length < 2) return null;

    double hours = 0;
    double minutes = 0;
    double seconds = 0;

    if (segments.length == 3) {
      hours = double.tryParse(segments[0]) ?? 0;
      minutes = double.tryParse(segments[1]) ?? 0;
      seconds = double.tryParse(segments[2]) ?? 0;
    } else {
      minutes = double.tryParse(segments[0]) ?? 0;
      seconds = double.tryParse(segments[1]) ?? 0;
    }

    return ((days * 86400) + (hours * 3600) + (minutes * 60) + seconds) * 1000;
  }

  Future<int> _getProcessMemoryBytes(int pid) async {
    if (Platform.isWindows) {
      final result = await Process.run(
        'tasklist', ['/FI', 'PID eq $pid', '/FO', 'CSV', '/NH'],
      );
      if (result.exitCode == 0) {
        final line = (result.stdout as String).trim();
        final parts = line.split(',');
        if (parts.length >= 5) {
          final memStr = parts[4]
              .replaceAll('"', '')
              .replaceAll(' K', '')
              .replaceAll(',', '')
              .trim();
          final kb = int.tryParse(memStr);
          if (kb != null) return kb * 1024;
        }
      }
      return 0;
    }

    // Linux: read from /proc (works in Docker without ps)
    final statmFile = File('/proc/$pid/statm');
    if (statmFile.existsSync()) {
      try {
        final contents = await statmFile.readAsString();
        final parts = contents.trim().split(' ');
        if (parts.length >= 2) {
          final residentPages = int.tryParse(parts[1]);
          if (residentPages != null) {
            // Each page is typically 4096 bytes
            return residentPages * 4096;
          }
        }
      } catch (_) {}
    }

    // macOS / fallback: use ps
    try {
      final result = await Process.run('ps', ['-o', 'rss=', '-p', '$pid']);
      if (result.exitCode == 0) {
        final rssKb = int.tryParse((result.stdout as String).trim());
        if (rssKb != null) return rssKb * 1024;
      }
    } catch (_) {}
    return 0;
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
    final throughput = summary['sizePerSec'] as num;
    final latencies = json['latencyPercentiles'] as Map<String, dynamic>;
    p50 = latencies['p50'];
    p95 = latencies['p95'];
    p99 = latencies['p99'];
    double averageLatency = summary['average'];
    if (p50 == null || p95 == null || p99 == null) {
      throw StateError('Unable to parse oha output.');
    }
    final scDistribution = json['statusCodeDistribution'] as Map<String, dynamic>;
    for (final entry in scDistribution.entries) {
      final code = entry.key;
      final count = entry.value as int;
      if (code.startsWith('2') || code.startsWith('3')) {
        continue;
      }
      errors += count;
    }

    return _OhaParsed(
      rps: rps,
      p50: p50,
      p95: p95,
      latency: averageLatency,
      stability: p99/p95,
      p99: p99,
      errors: errors,
      throughput: throughput.toDouble()
    );
  }


  Map<String, dynamic> _collectEnvironment() {
    return {
      'cpu': Platform.environment['PROCESSOR_IDENTIFIER'] ?? 'unknown',
      'logicalProcessors': Platform.numberOfProcessors,
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
  final double throughput;

  _OhaParsed({
    required this.rps,
    required this.p50,
    required this.p95,
    required this.p99,
    required this.latency,
    required this.stability,
    required this.errors,
    required this.throughput,
  });
}
