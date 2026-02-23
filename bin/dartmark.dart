import 'dart:io';

import 'package:dartmark/src/executor.dart';

void main(List<String> arguments) {
  final httpConfigs = _discoverHttpConfigs();
  final validationConfigs = _discoverValidationConfigs();
  final Executor executor = Executor(
    // validationConfigs: validationConfigs,
    httpConfigs: httpConfigs,
  );
  executor.execute();
}

List<String> _discoverHttpConfigs() {
  final configsDir = Directory('configs/http');
  if (!configsDir.existsSync()) {
    return const [];
  }
  final files = configsDir.listSync();
  final configs = <String>[];
  if (files.isEmpty) {
    print('No HTTP benchmark configurations found in ${configsDir.path}.');
    return const [];
  }
  for (final file in files) {
    if (file is File && file.path.toLowerCase().endsWith('.yaml')) {
      configs.add(file.path);
    }
  }
  print('Discovered ${configs.length} HTTP benchmark configuration(s) in ${configsDir.path}.');
  return configs;
}

List<String> _discoverValidationConfigs() {
  final configsDir = Directory('configs/validation');
  if (!configsDir.existsSync()) {
    return const [];
  }
  final files = configsDir.listSync();
  final configs = <String>[];
  if (files.isEmpty) {
    print('No validation benchmark configurations found in ${configsDir.path}.');
    return const [];
  }
  for (final file in files) {
    if (file is File && file.path.toLowerCase().endsWith('.yaml')) {
      configs.add(file.path);
    }
  }
  print('Discovered ${configs.length} validation benchmark configuration(s) in ${configsDir.path}.');
  return configs;
}
