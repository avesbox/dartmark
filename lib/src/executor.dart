import 'dart:convert';
import 'dart:io';

import 'package:yaml/yaml.dart';

class Executor {

  final List<String> packages;

  Executor(this.packages);

  Future<void> execute() async {
    final List<Map<String, dynamic>> results = [];
    final File file = File('docs/data/results.json');
    if (file.existsSync()) {
      file.deleteSync();
    }
    file.createSync(recursive: true);
    final dependencies = File('pubspec.yaml').readAsStringSync();
    YamlMap yaml = loadYaml(dependencies);
    final pubspec = yaml.nodes['dependencies']?.value;
    for (var package in packages) {
      print('Starting benchmarks for $package...');
      final compile = await Process.run('dart', ['compile', 'exe', 'lib/src/$package.dart', '-o', 'bin/$package.exe']);
      if (compile.exitCode != 0) {
        print('Error compiling $package: ${compile.stderr}');
        continue;
      }
      final benchProcess = await Process.run('bin/$package.exe', []);
      if (benchProcess.exitCode != 0) {
        print('Error running benchmarks for $package: ${benchProcess.stderr}');
        continue;
      }
      File('bin/$package.exe').deleteSync();
      print('Benchmarks for $package completed successfully.');
      final data = benchProcess.stdout;
      final lines = data.split('\n');
      for (var line in lines) {
        if (line.isNotEmpty) {
          final result = jsonDecode(line);
          result['version'] = pubspec[package]?.toString() ?? 'unknown';
          results.add(result);
        }
      }
    }
    file.writeAsStringSync(jsonEncode({
      'results': results,
      'date': DateTime.now().toIso8601String(),
      'cpu': results.map((e) => e['cpu']).toSet().firstOrNull,
      'memory': results.map((e) => e['memory']).toSet().firstOrNull,
      'system': results.map((e) => e['system']).toSet().firstOrNull,
      'dart': Platform.version,
    }));
  }

}