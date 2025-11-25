import 'dart:convert';

import 'package:zard/zard.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';

final flatObjectSchema = z.map({
  'number': z.int(),
  'negNumber': z.int(),
  'infiniteNumber': z.double(),
  'string': z.string(),
  'longString': z.string(),
  'boolean': z.bool(),
});

final nestedObjectSchema = z.map({
  'number': z.int(),
  'negNumber': z.int(),
  'infiniteNumber': z.double(),
  'string': z.string(),
  'longString': z.string(),
  'boolean': z.bool(),
  'deeplyNested': z.map({'foo': z.string(), 'num': z.int(), 'bool': z.bool()}),
});

final deeplyNestedObjectSchema = z.map({
  'number': z.int(),
  'negNumber': z.int(),
  'infiniteNumber': z.double(),
  'string': z.string(),
  'longString': z.string(),
  'boolean': z.bool(),
  'deeplyNested': z.map({
    'foo': z.string(),
    'num': z.int(),
    'bool': z.bool(),
    'deeplyNested2': z.map({
      'foo2': z.string(),
      'num2': z.int(),
      'bool2': z.bool(),
    }),
  }),
});

final flatArraySchema = z.list(
  z.map({
    'number': z.int(),
    'negNumber': z.int(),
    'infiniteNumber': z.double(),
    'string': z.string(),
    'longString': z.string(),
    'boolean': z.bool(),
  }),
);

final nestedArraySchema = z.list(
  z.map({
    'number': z.int(),
    'negNumber': z.int(),
    'infiniteNumber': z.double(),
    'string': z.string(),
    'longString': z.string(),
    'boolean': z.bool(),
    'deeplyNested': z.map({
      'foo': z.string(),
      'num': z.int(),
      'bool': z.bool(),
    }),
  }),
);

final deeplyNestedArraySchema = z.list(
  z.map({
    'number': z.int(),
    'negNumber': z.int(),
    'infiniteNumber': z.double(),
    'string': z.string(),
    'longString': z.string(),
    'boolean': z.bool(),
    'deeplyNested': z.map({
      'foo': z.string(),
      'num': z.int(),
      'bool': z.bool(),
      'deeplyNested2': z.map({
        'foo2': z.string(),
        'num2': z.int(),
        'bool2': z.bool(),
      }),
    }),
  }),
);

class ZardBench extends Package {
  @override
  void parseFlatObject(Map<String, dynamic> json) {
    flatObjectSchema.parse(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    nestedObjectSchema.parse(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    deeplyNestedObjectSchema.parse(json);
  }

  @override
  void parseFlatArray(List<Map<String, dynamic>> json) {
    flatArraySchema.parse(json);
  }

  @override
  void parseNestedArray(List<Map<String, dynamic>> json) {
    nestedArraySchema.parse(json);
  }

  @override
  void parseDeeplyNestedArray(List<Map<String, dynamic>> json) {
    deeplyNestedArraySchema.parse(json);
  }

  @override
  Future<void> run() async {
    final suite = Suite();
    suite.add(
      OpsBenchmarkBase(
        'flat_object',
        group: 'zard',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'zard',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'zard',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'zard',
        onRun: () async => parseFlatArray(flatArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'zard',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'zard',
        onRun: () async => parseDeeplyNestedArray(deeplyNestedArray),
      ),
    );
    final results = await suite.run();
    for (final result in results) {
      print(jsonEncode(result.toMap()));
    }
  }
}

void main() {
  final zard = ZardBench();
  zard.run();
}
