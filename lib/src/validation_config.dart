import 'dart:io';

import 'package:dartmark/src/package.dart';
import 'package:yaml/yaml.dart';

class ValidationConfig {

  final String name;
  final String? description;
  final String? publisher;
  final String? publisherUrl;
  final String? repository;
  final String? homepage;
  final List<ConfigFeature> features;

  ValidationConfig({
    required this.name,
    required this.description,
    required this.publisher,
    required this.publisherUrl,
    required this.repository,
    required this.homepage,
    required this.features,
  });

  factory ValidationConfig.fromYaml(File file) {
    final content = file.readAsStringSync();
    final yaml = loadYaml(content) as YamlMap;
    return ValidationConfig(
      name: yaml['name'] as String,
      description: yaml['description'] as String,
      publisher: yaml['publisher'] as String,
      publisherUrl: yaml['publisherUrl'] as String,
      repository: yaml['repository'] as String,
      homepage: yaml['homepage'] as String,
      features: (yaml['features'] as YamlList? ?? const [])
          .map((f) => ConfigFeature(
                title: f['title'] as String,
                description: f['description'] as String,
              ))
          .toList(),
    );
  }

}