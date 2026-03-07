import 'dart:convert';
import 'dart:io';

import 'package:dartmark/src/orm_config.dart';

class OrmBenchmarkResult {
	final String framework;
	final int durationMs;
	final int exitCode;
	final String? version;
	final Map<String, dynamic> metrics;
	final Map<String, dynamic> environment;

	OrmBenchmarkResult({
		required this.framework,
		required this.durationMs,
		required this.exitCode,
		required this.version,
		required this.metrics,
		required this.environment,
	});

	Map<String, dynamic> toMap() => {
				'framework': framework,
				'durationMs': durationMs,
				'exitCode': exitCode,
				'version': version ?? 'unknown',
				...environment,
				...metrics,
			};
}

class OrmRunner {
	Future<OrmBenchmarkResult> run(OrmBenchmarkConfig config) async {
		await _build(config);

		final stopwatch = Stopwatch()..start();
		final result = await Process.run(
			config.run.command,
			config.run.args,
			workingDirectory: config.projectPath,
			environment: {
				...Platform.environment,
				...config.run.env,
			},
			runInShell: false,
		);
		stopwatch.stop();

		if (result.exitCode != 0) {
			throw StateError('ORM benchmark failed: ${result.stderr}');
		}

		return OrmBenchmarkResult(
			framework: config.framework,
			durationMs: stopwatch.elapsedMilliseconds,
			exitCode: result.exitCode,
			version: config.version,
			metrics: _parseMetrics(result.stdout as String),
			environment: _collectEnvironment(),
		);
	}

	Future<void> _build(OrmBenchmarkConfig config) async {
		final pubGet = await Process.run(
			'dart',
			['pub', 'get'],
			workingDirectory: config.projectPath,
		);

		if (pubGet.exitCode != 0) {
			throw StateError('Dependency resolution failed: ${pubGet.stderr}');
		}

		final build = await Process.run(
			config.build.command,
			config.build.args,
			workingDirectory: config.projectPath,
		);

		if (build.exitCode != 0) {
			throw StateError('Build failed: ${build.stderr}');
		}
	}

	Map<String, dynamic> _parseMetrics(String stdout) {
		final trimmed = stdout.trim();
		if (trimmed.isEmpty) {
			return const <String, dynamic>{};
		}

		try {
			final decoded = jsonDecode(trimmed);
			if (decoded is Map<String, dynamic>) {
				return decoded;
			}
		} catch (_) {
			// fallback below – likely multiple JSON lines
		}

		final lines = trimmed
				.split('\n')
				.map((line) => line.trim())
				.where((line) => line.isNotEmpty)
				.toList();

		final events = <Map<String, dynamic>>[];
		for (final line in lines) {
			try {
				final decoded = jsonDecode(line);
				if (decoded is Map<String, dynamic>) {
					events.add(decoded);
				}
			} catch (_) {
				// skip non-JSON lines
			}
		}

		if (events.isEmpty) {
			return {
				'output': trimmed,
			};
		}

		if (events.length == 1) {
			return events.first;
		}

		// Multiple JSON events – group by the 'name' field when present,
		// otherwise use a positional key.
		final merged = <String, dynamic>{};
		for (var i = 0; i < events.length; i++) {
			final event = events[i];
			final key = event['name'] as String? ?? 'event_$i';
			merged[key] = event;
		}
		return merged;
	}

	Map<String, dynamic> _collectEnvironment() {
		return {
			'cpu': Platform.environment['PROCESSOR_IDENTIFIER'] ?? 'unknown',
			'system': Platform.operatingSystemVersion,
			'memory': Platform.environment['MEMORY'] ?? 'unknown',
		};
	}
}
