import 'dart:convert';

import 'package:json_schema_builder/json_schema_builder.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';


final flatObjectSchema = S.object(
  required: ['number', 'negNumber', 'infiniteNumber', 'string', 'longString', 'boolean'],
  properties: {
    'number': S.integer(),
    'negNumber': S.integer(),
    'infiniteNumber': S.number(),
    'string': S.string(),
    'longString': S.string(),
    'boolean': S.boolean(),
  },
);

final nestedObjectSchema = S.object(
  properties: {
  'number': S.integer(),
  'negNumber': S.integer(),
  'infiniteNumber': S.number(),
  'string': S.string(),
  'longString': S.string(),
  'boolean': S.boolean(),
  'deeplyNested': S.object(
    properties: {
    'foo': S.string(),
    'num': S.integer(),
    'bool': S.boolean(),
  }
  ),
});

final deeplyNestedObjectSchema = S.object(
  properties: {
  'number': S.integer(),
  'negNumber': S.integer(),
  'infiniteNumber': S.number(),
  'string': S.string(),
  'longString': S.string(),
  'boolean': S.boolean(),
  'deeplyNested': S.object(
    properties: {
    'foo': S.string(),
    'num': S.integer(),
    'bool': S.boolean(),
    'deeplyNested2': S.object(
      properties: {
      'foo2': S.string(),
      'num2': S.integer(),
      'bool2': S.boolean(),
    }),
  }),
});

final flatArraySchema = S.list(
  items: S.object(properties: {
    'number': S.integer(),
    'negNumber': S.integer(),
    'infiniteNumber': S.number(),
    'string': S.string(),
    'longString': S.string(),
    'boolean': S.boolean(),
  }),
);

final nestedArraySchema = S.list(
  items: S.object(properties: {
    'number': S.integer(),
    'negNumber': S.integer(),
    'infiniteNumber': S.number(),
    'string': S.string(),
    'longString': S.string(),
    'boolean': S.boolean(),
    'deeplyNested': S.list(
      items: S.object(properties: {'foo': S.string(), 'num': S.integer(), 'bool': S.boolean()}),
    ),
  }),
);

final deeplyNestedArraySchema = S.list(
  items: S.object(properties: {
    'number': S.integer(),
    'negNumber': S.integer(),
    'infiniteNumber': S.number(),
    'string': S.string(),
    'longString': S.string(),
    'boolean': S.boolean(),
    'deeplyNested': S.list(
      items: S.object(properties: {
        'foo': S.string(),
        'num': S.integer(),
        'bool': S.boolean(),
        'deeplyNested2': S.list(
          items: S.object(properties: {
            'foo2': S.string(),
            'num2': S.integer(),
            'bool2': S.boolean(),
          }),
        ),
      }),
    ),
  }),
);


class JsonSchemaBuilderBench extends Package {
  @override
  void parseFlatObject(Map<String, dynamic> json) {
    flatObjectSchema.validate(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    nestedObjectSchema.validate(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    deeplyNestedObjectSchema.validate(json);
  }

  @override
  void parseFlatArray(List<Map<String, dynamic>> json) {
    flatArraySchema.validate(json);
  }

  @override
  void parseNestedArray(List<Map<String, dynamic>> json) {
    nestedArraySchema.validate(json);
  }

  @override
  void parseDeeplyNestedArray(List<Map<String, dynamic>> json) {
    deeplyNestedArraySchema.validate(json);
  }

  @override
  Future<void> run() async {
    final suite = Suite();
    suite.add(
      OpsBenchmarkBase(
        'flat_object',
        group: 'json_schema_builder',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'json_schema_builder',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'json_schema_builder',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'json_schema_builder',
        onRun: () async => parseFlatArray(flatArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'json_schema_builder',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'json_schema_builder',
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
  final ack = JsonSchemaBuilderBench();
  ack.run();
}
