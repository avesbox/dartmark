import 'dart:io';

import 'package:dartmark/src/package.dart';
import 'package:yaml/yaml.dart';

class HttpBuildConfig {
  final String command;
  final List<String> args;

  HttpBuildConfig({required this.command, required this.args});

  factory HttpBuildConfig.fromYaml(YamlMap map) {
    return HttpBuildConfig(
      command: map['command'] as String,
      args: (map['args'] as YamlList?)?.cast<String>().toList() ?? const [],
    );
  }
}

class HttpRunConfig {
  final String command;
  final List<String> args;
  final Map<String, String> env;

  HttpRunConfig({
    required this.command,
    this.args = const [],
    this.env = const {},
  });

  factory HttpRunConfig.fromYaml(YamlMap map) {
    return HttpRunConfig(
      command: map['command'] as String,
      args: (map['args'] as YamlList?)?.cast<String>().toList() ?? const [],
      env: (map['env'] as YamlMap?)?.map((key, value) => MapEntry(key.toString(), value.toString())) ?? const {},
    );
  }
}

class HttpWaitForReadyConfig {
  final String path;
  final int timeoutSeconds;
  final int intervalMillis;

  HttpWaitForReadyConfig({
    required this.path,
    required this.timeoutSeconds,
    required this.intervalMillis,
  });

  factory HttpWaitForReadyConfig.fromYaml(YamlMap map) {
    return HttpWaitForReadyConfig(
      path: map['path'] as String? ?? '/health',
      timeoutSeconds: (map['timeoutSeconds'] as num?)?.toInt() ?? 10,
      intervalMillis: (map['intervalMillis'] as num?)?.toInt() ?? 200,
    );
  }
}

class HttpConfig {
  final String baseUrl;
  final String endpoint;
  final HttpWaitForReadyConfig waitForReady;

  HttpConfig({
    required this.baseUrl,
    required this.endpoint,
    required this.waitForReady,
  });

  factory HttpConfig.fromYaml(YamlMap map) {
    return HttpConfig(
      baseUrl: map['baseUrl'] as String,
      endpoint: map['endpoint'] as String,
      waitForReady: HttpWaitForReadyConfig.fromYaml((map['waitForReady'] as YamlMap?) ?? YamlMap()),
    );
  }
}

class HttpLoadConfig {
  final int warmupSeconds;
  final int durationSeconds;
  final int concurrency;
  final int connections;
  final int? requests;
  final int timeoutSeconds;
  final List<String> headers;
  final String? body;

  HttpLoadConfig({
    required this.warmupSeconds,
    required this.durationSeconds,
    required this.concurrency,
    required this.connections,
    required this.requests,
    required this.timeoutSeconds,
    required this.headers,
    required this.body,
  });

  factory HttpLoadConfig.fromYaml(YamlMap map) {
    return HttpLoadConfig(
      warmupSeconds: (map['warmupSeconds'] as num?)?.toInt() ?? 5,
      durationSeconds: (map['durationSeconds'] as num?)?.toInt() ?? 20,
      concurrency: (map['concurrency'] as num?)?.toInt() ?? 64,
      connections: (map['connections'] as num?)?.toInt() ?? 0,
      requests: (map['requests'] as num?)?.toInt(),
      timeoutSeconds: (map['timeoutSeconds'] as num?)?.toInt() ?? 5,
      headers: (map['headers'] as YamlList?)?.cast<String>().toList() ?? const [],
      body: map['body'] as String?,
    );
  }
}

class OhaConfig {
  final String binaryPath;
  final List<String> extraArgs;

  OhaConfig({required this.binaryPath, required this.extraArgs});

  factory OhaConfig.fromYaml(YamlMap map) {
    return OhaConfig(
      binaryPath: map['binaryPath'] as String? ?? '/usr/local/bin/oha',
      extraArgs: (map['extraArgs'] as YamlList?)?.cast<String>().toList() ?? const [],
    );
  }
}

class HttpBenchmarkConfig {
  final String framework;
  final String description;
  final String publisher;
  final String publisherUrl;
  final String repository;
  final String homepage;
  final String projectPath;
  final List<ConfigFeature> features;
  final HttpBuildConfig build;
  final HttpRunConfig run;
  final HttpConfig http;
  final HttpLoadConfig load;
  final OhaConfig oha;
  final String? version;

  HttpBenchmarkConfig({
    required this.framework,
    required this.projectPath,
    required this.description,
    required this.publisher,
    required this.publisherUrl,
    required this.repository,
    required this.homepage,
    required this.build,
    required this.run,
    required this.http,
    required this.load,
    required this.oha,
    this.features = const [],
    this.version,
  });

  factory HttpBenchmarkConfig.fromYaml(File file) {
    final content = file.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;
    return HttpBenchmarkConfig(
      framework: yaml['framework'] as String,
      projectPath: yaml['projectPath'] as String,
      description: yaml['description'] as String? ?? '',
      publisher: yaml['publisher'] as String? ?? '',
      publisherUrl: yaml['publisherUrl'] as String? ?? '',
      repository: yaml['repository'] as String? ?? '',
      homepage: yaml['homepage'] as String? ?? '',
      features: (yaml['features'] as YamlList? ?? const [])
          .map((f) => ConfigFeature(
                title: f['title'] as String,
                description: f['description'] as String,
              ))
          .toList(),
      build: HttpBuildConfig.fromYaml(yaml['build'] as YamlMap),
      run: HttpRunConfig.fromYaml(yaml['run'] as YamlMap),
      http: HttpConfig.fromYaml(yaml['http'] as YamlMap),
      load: HttpLoadConfig.fromYaml(yaml['load'] as YamlMap),
      oha: OhaConfig.fromYaml((yaml['oha'] as YamlMap?) ?? YamlMap()),
      version: yaml['version']?.toString(),
    );
  }
}
