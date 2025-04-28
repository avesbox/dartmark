import 'dart:convert';

import 'package:luthor/luthor.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';

final flatObjectSchema = l.schema({
  'number': l.number(),
  'negNumber': l.number(),
  'infiniteNumber': l.number(),
  'string': l.string(),
  'longString': l.string(),
  'boolean': l.boolean(),
});

final nestedObjectSchema = l.schema({
  'number': l.number(),
  'negNumber': l.number(),
  'infiniteNumber': l.number(),
  'string': l.string(),
  'longString': l.string(),
  'boolean': l.boolean(),
  'deeplyNested': l.schema({
    'foo': l.string(),
    'num': l.number(),
    'bool': l.boolean(),
  }),
});

final deeplyNestedObjectSchema = l.schema({
  'number': l.number(),
  'negNumber': l.number(),
  'infiniteNumber': l.number(),
  'string': l.string(),
  'longString': l.string(),
  'boolean': l.boolean(),
  'deeplyNested': l.schema({
    'foo': l.string(),
    'num': l.number(),
    'bool': l.boolean(),
    'deeplyNested2': l.schema({
      'foo2': l.string(),
      'num2': l.number(),
      'bool2': l.boolean(),
    }),
  }),
});

final flatArraySchema = l.list(
  validators: [
    l.schema({
      'number': l.number(),
      'negNumber': l.number(),
      'infiniteNumber': l.number(),
      'string': l.string(),
      'longString': l.string(),
      'boolean': l.boolean(),
    }),
  ],
);

final nestedArraySchema = l.list(
  validators: [
    l.schema({
      'number': l.number(),
      'negNumber': l.number(),
      'infiniteNumber': l.number(),
      'string': l.string(),
      'longString': l.string(),
      'boolean': l.boolean(),
      'deeplyNested': l.list(
        validators: [
          l.schema({'foo': l.string(), 'num': l.number(), 'bool': l.boolean()}),
        ],
      ),
    })
  ]
);

final deeplyNestedArraySchema = l.list(
  validators: [
    l.schema({
      'number': l.number(),
      'negNumber': l.number(),
      'infiniteNumber': l.number(),
      'string': l.string(),
      'longString': l.string(),
      'boolean': l.boolean(),
      'deeplyNested': l.list(
        validators: [
          l.schema({
            'foo': l.string(),
            'num': l.number(),
            'bool': l.boolean(),
            'deeplyNested2': l.list(
              validators: [
                l.schema({
                  'foo2': l.string(),
                  'num2': l.number(),
                  'bool2': l.boolean(),
                }),
              ],
            ),
          }),
        ],
      ),
    })
  ]
);

class LuthorBench extends Package {
  @override
  void parseFlatObject(Map<String, dynamic> json) {
    flatObjectSchema.validateSchema(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    nestedObjectSchema.validateSchema(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    deeplyNestedObjectSchema.validateSchema(json);
  }

  @override
  void parseFlatArray(List<Map<String, dynamic>> json) {
    flatArraySchema.validateValue(json);
  }

  @override
  void parseNestedArray(List<Map<String, dynamic>> json) {
    nestedArraySchema.validateValue(json);
  }

  @override
  void parseDeeplyNestedArray(List<Map<String, dynamic>> json) {
    deeplyNestedArraySchema.validateValue(json);
  }

  @override
  Future<void> run() async {
    final suite = Suite();
    suite.add(
      OpsBenchmarkBase(
        'flat_object',
        group: 'luthor',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'luthor',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'luthor',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'luthor',
        onRun: () async => parseFlatArray(flatArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'luthor',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'luthor',
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
  final luthor = LuthorBench();
  luthor.run();
}
