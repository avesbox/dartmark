import 'dart:io';

import 'package:dartmark/src/package.dart';
import 'package:yaml/yaml.dart';

class OrmBuildConfig {
	final String command;
	final List<String> args;

	OrmBuildConfig({required this.command, required this.args});

	factory OrmBuildConfig.fromYaml(YamlMap map) {
		return OrmBuildConfig(
			command: map['command'] as String,
			args: (map['args'] as YamlList?)?.cast<String>().toList() ?? const [],
		);
	}
}

class OrmRunConfig {
	final String command;
	final List<String> args;
	final Map<String, String> env;

	OrmRunConfig({
		required this.command,
		this.args = const [],
		this.env = const {},
	});

	factory OrmRunConfig.fromYaml(YamlMap map) {
		return OrmRunConfig(
			command: map['command'] as String,
			args: (map['args'] as YamlList?)?.cast<String>().toList() ?? const [],
			env: (map['env'] as YamlMap?)
							?.map((key, value) => MapEntry(key.toString(), value.toString())) ??
					const {},
		);
	}
}

class OrmBenchmarkConfig {
	final String framework;
	final String description;
	final String publisher;
	final String publisherUrl;
	final String repository;
	final String homepage;
	final String projectPath;
	final List<ConfigFeature> features;
	final OrmBuildConfig build;
	final OrmRunConfig run;
	final String? version;

	OrmBenchmarkConfig({
		required this.framework,
		required this.projectPath,
		required this.description,
		required this.publisher,
		required this.publisherUrl,
		required this.repository,
		required this.homepage,
		required this.features,
		required this.build,
		required this.run,
		this.version,
	});

	factory OrmBenchmarkConfig.fromYaml(File file) {
		final content = file.readAsStringSync();
		final yaml = loadYaml(content) as YamlMap;
		return OrmBenchmarkConfig(
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
			build: OrmBuildConfig.fromYaml(yaml['build'] as YamlMap),
			run: OrmRunConfig.fromYaml(yaml['run'] as YamlMap),
			version: yaml['version']?.toString(),
		);
	}
}
