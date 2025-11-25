import 'dart:convert';

import 'package:acanthis/acanthis.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';


final flatObjectSchema = object({
  'number': number(),
  'negNumber': number().negative(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
});

final nestedObjectSchema = object({
  'number': number(),
  'negNumber': number(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
  'deeplyNested': object({
    'foo': string(),
    'num': number(),
    'bool': boolean(),
  }),
});

final deeplyNestedObjectSchema = object({
  'number': number(),
  'negNumber': number(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
  'deeplyNested': object({
    'foo': string(),
    'num': number(),
    'bool': boolean(),
    'deeplyNested2': object({
      'foo2': string(),
      'num2': number(),
      'bool2': boolean(),
    }),
  }),
});

final flatArraySchema = object({
  'number': number(),
  'negNumber': number(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
}).list();

final nestedArraySchema = object({
  'number': number(),
  'negNumber': number(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
  'deeplyNested': object({
    'foo': string(),
    'num': number(),
    'bool': boolean(),
  }).list(),
}).list();

final deeplyNestedArraySchema = object({
  'number': number(),
  'negNumber': number(),
  'infiniteNumber': number(),
  'string': string(),
  'longString': string(),
  'boolean': boolean(),
  'deeplyNested': object({
    'foo': string(),
    'num': number(),
    'bool': boolean(),
    'deeplyNested2': object({
      'foo2': string(),
      'num2': number(),
      'bool2': boolean(),
    }).list(),
  }).list(),
}).list();

class AcanthisBench extends Package {
  
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
        group: 'acanthis',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'acanthis',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'acanthis',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'acanthis',
        onRun: () async => parseFlatArray(flatArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'acanthis',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'acanthis',
        onRun: () async => parseDeeplyNestedArray(deeplyNestedArray),
      ),
    );
    final results = await suite.run();
    for(final result in results) {
      print(jsonEncode(result.toMap()));
    }
  }
 
}

void main() {
  final acanthis = AcanthisBench();
  acanthis.run();
}