import 'dart:convert';

import 'package:loxia/loxia.dart';
import 'package:loxia_bench/loxia_bench.dart';

Future<void> main() async {
  final ds = DataSource(
    InMemoryDataSourceOptions(
      entities: [User.entity],
      synchronize: true,
    ),
  );

  await ds.init();

  final users = ds.getRepository<User>();
  final insertStats = await _measure('insert', () async {
    for (var i = 0; i < 10000; i++) {
      await users.insert(
        UserInsertDto(name: 'User $i')
      );
    }
  });
  print(jsonEncode(insertStats));

  final readStats = await _measure('read', () async {
    await users.findBy();
  });
  print(jsonEncode(readStats));

  final updateStats = await _measure('update', () async {
    for (int i = 0; i < 10000; i++) {
      await users.update(
        UserUpdateDto(name: 'Updated User $i'),
        where: UserQuery((q) => q.id.equals(i + 1)),
      );
    }
  });
  print(jsonEncode(updateStats));
}

/// Helper function to run a warmup, measure execution, and return standard JSON
Future<Map<String, dynamic>> _measure(String name, Future<void> Function() action) async {

  // Measurement phase
  const int iterations = 10;
  final watch = Stopwatch()..start();
  
  for (var i = 0; i < iterations; i++) {
    await action();
  }
  
  watch.stop();
  final avgTimeMs = watch.elapsedMilliseconds / iterations;
  
  return {
    'name': name,
    'avgTimeMs': avgTimeMs,
    'iterations': iterations,
    'totalTimeMs': watch.elapsedMilliseconds,
  };
}