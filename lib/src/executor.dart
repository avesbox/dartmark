import 'dart:convert';
import 'dart:io';

import 'package:dartmark/src/validation_config.dart';
import 'package:yaml/yaml.dart';

import 'package:dartmark/src/http_config.dart';
import 'package:dartmark/src/http_runner.dart';
import 'package:dartmark/src/orm_config.dart';
import 'package:dartmark/src/orm_runner.dart';

class Executor {
  final List<String> validationConfigs;
  final List<String> httpConfigs;
  final List<String> ormConfigs;

  Executor({
    this.validationConfigs = const [],
    this.httpConfigs = const [],
    this.ormConfigs = const [],
  });

  Future<void> execute() async {
    if (validationConfigs.isNotEmpty) {
      await _runValidation();
    }
    if (httpConfigs.isNotEmpty) {
      await _runHttp();
    }
    if (ormConfigs.isNotEmpty) {
      await _runOrm();
    }
  }

  Future<void> _runOrm() async {
    // Requires an OrmRunner similar to HttpRunner
    final runner = OrmRunner(); 
    final List<Map<String, dynamic>> results = [];
    final File file = File('docs/data/results-orm.json');
    
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    final libraries = <Map<String, Object?>>[];
    
    for (final path in ormConfigs) {
      final configFile = File(path);
      if (!configFile.existsSync()) {
        print('ORM config not found at $path, skipping');
        continue;
      }
      
      // Requires an OrmBenchmarkConfig similar to HttpBenchmarkConfig
      final config = OrmBenchmarkConfig.fromYaml(configFile); 
      
      libraries.add({
        'framework': config.framework, // or config.name depending on your setup
        'version': config.version ?? 'unknown',
        'description': config.description,
        'publisher': config.publisher,
        'publisherUrl': config.publisherUrl,
        'repository': config.repository,
        'homepage': config.homepage,
        'features': config.features.map((f) => {
          'title': f.title,
          'description': f.description,
        }).toList(),
      });
      
      print('Starting ORM benchmarks for ${config.framework}...');
      try {
        final result = await runner.run(config);
        results.add(result.toMap());
        print('ORM benchmarks for ${config.framework} completed successfully.');
      } catch (e) {
        print('Error running ORM benchmarks for ${config.framework}: $e');
        rethrow;
      }
    }
    
    print('All ORM benchmarks completed.');
    file.writeAsStringSync(jsonEncode({
      'results': results,
      'date': DateTime.now().toIso8601String(),
      'dart': Platform.version,
      'packages': libraries,
      'id': 'orm'
    }));
  }

  Future<void> _runValidation() async {
    final List<Map<String, dynamic>> results = [];
    final File file = File('docs/data/results.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
    final packages = <ValidationConfig>[];
    file.createSync(recursive: true);
    final dependencies = File('pubspec.yaml').readAsStringSync();
    YamlMap yaml = loadYaml(dependencies);
    final pubspec = yaml.nodes['dependencies']?.value;
    for (var path in validationConfigs) {
      final configFile = File(path);
      if (!configFile.existsSync()) {
        print('Validation config not found at $path, skipping');
        continue;
      }
      final config = ValidationConfig.fromYaml(configFile);
      packages.add(config);
      print('Starting benchmarks for ${config.name}...');
      final compile = await Process.run(
        'dart',
        ['compile', 'exe', 'lib/src/${config.name}.dart', '-o', 'bin/${config.name}.exe'],
      );
      if (compile.exitCode != 0) {
        print('Error compiling ${config.name}: ${compile.stderr}');
        continue;
      }
      final benchProcess = await Process.run('bin/${config.name}.exe', []);
      if (benchProcess.exitCode != 0) {
        print('Error running benchmarks for ${config.name}: ${benchProcess.stderr}');
        continue;
      }
      File('bin/${config.name}.exe').deleteSync();
      print('Benchmarks for ${config.name} completed successfully.');
      final data = benchProcess.stdout;
      final lines = data.split('\n');
      for (var line in lines) {
        if (line.isNotEmpty) {
          final result = jsonDecode(line);
          results.add(result);
        }
      }
    }
    final mappedResults = [];
    for (final result in results) {
      final hasPackageAlready = mappedResults.any((r) => r['package'] == result['group']);
      if (!hasPackageAlready) { 
        final packageResults = results.where((r) => r['group'] == result['group']).toList();
        mappedResults.add({
          'package': result['group'],
          'benchmarks': [
            for (final r in packageResults)
              {
                "name": r['name'],
                "warningMessage": r['warningMessage'],
                "avgScore": r['avgScore'],
                "avgScorePerSecond": r['avgScorePerSecond'],
                "stdDevPercentage": r['stdDevPercentage'],
                "stdDev": r['stdDev'],
                "best": r['best'],
                "differenceFromBest": r['differenceFromBest'],
                "worst": r['worst'],
                "avgTime": r['avgTime'],
                "minTime": r['minTime'],
                "maxTime": r['maxTime'],
                "p75Time": r['p75Time'],
                "p95Time": r['p95Time'],
                "p99Time": r['p99Time'],
                "p999Time": r['p999Time'],
              }
          ],
          'version': pubspec[result['group']]?.toString() ?? 'unknown',
        });
      }
    }
    file.writeAsStringSync(jsonEncode({
      'results': mappedResults,
      'date': DateTime.now().toIso8601String(),
      'cpu': results.map((e) => e['cpu']).toSet().firstOrNull,
      'memory': results.map((e) => e['memory']).toSet().firstOrNull,
      'system': results.map((e) => e['system']).toSet().firstOrNull,
      'dart': Platform.version,
      'packages': [
        for (final p in packages)
          {
            'name': p.name,
            'version': pubspec[p.name]?.toString() ?? 'unknown',
            'description': p.description,
            'publisher': p.publisher,
            'publisherUrl': p.publisherUrl,
            'repository': p.repository,
            'homepage': p.homepage,
            'features': [
              for (final f in p.features)
                {
                  'title': f.title,
                  'description': f.description,
                }
            ],
          }
      ],
      'id': 'validation'
    }));
  }

  Future<void> _runHttp() async {
    final runner = HttpRunner();
    final List<Map<String, dynamic>> results = [];
    final File file = File('docs/data/results-http.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    final libriaries = <Map<String, Object?>>[];
    for (final path in httpConfigs) {
      final configFile = File(path);
      if (!configFile.existsSync()) {
        print('HTTP config not found at $path, skipping');
        continue;
      }
      final config = HttpBenchmarkConfig.fromYaml(configFile);
      libriaries.add({
        'framework': config.framework,
        'version': config.version ?? 'unknown',
        'description': config.description,
        'publisher': config.publisher,
        'publisherUrl': config.publisherUrl,
        'repository': config.repository,
        'homepage': config.homepage,
        'features': config.features.map((f) => {
          'title': f.title,
          'description': f.description,
        }).toList(),
      });
      print('Starting HTTP benchmarks for ${config.framework}...');
      try {
        final result = await runner.run(config);
        results.add(result.toMap());
        print('HTTP benchmarks for ${config.framework} completed successfully.');
      } catch (e) {
        print('Error running HTTP benchmarks for ${config.framework}: $e');
        rethrow;
      }
    }
    print('All HTTP benchmarks completed.');
    file.writeAsStringSync(jsonEncode({
      'results': results,
      'date': DateTime.now().toIso8601String(),
      'dart': Platform.version,
      'packages': libriaries,
      'id': 'http'
    }));
  }
}