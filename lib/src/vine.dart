import 'dart:convert';

import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';
import 'package:vine/vine.dart';

class VineBench extends Pacakge {
  final parseFlatObjectValidator = vine.compile(
    vine.object({
      'number': vine.number().positive(),
      'negNumber': vine.number().negative(),
      'infiniteNumber': vine.number(),
      'string': vine.string(),
      'longString': vine.string(),
      'boolean': vine.boolean(),
    }),
  );

  final parseNestedObjectValidator = vine.compile(
    vine.object({
      'number': vine.number().positive(),
      'negNumber': vine.number().negative(),
      'infiniteNumber': vine.number(),
      'string': vine.string(),
      'longString': vine.string(),
      'boolean': vine.boolean(),
      'deeplyNested': vine.object({
        'foo': vine.string(),
        'num': vine.number(),
        'bool': vine.boolean(),
      }),
    }),
  );

  final parseDeeplyNestedObjectValidator = vine.compile(
    vine.object({
      'number': vine.number().positive(),
      'negNumber': vine.number().negative(),
      'infiniteNumber': vine.number(),
      'string': vine.string(),
      'longString': vine.string(),
      'boolean': vine.boolean(),
      'deeplyNested': vine.object({
        'foo': vine.string(),
        'num': vine.number(),
        'bool': vine.boolean(),
        'deeplyNested2': vine.object({
          'foo2': vine.string(),
          'num2': vine.number(),
          'bool2': vine.boolean(),
        }),
      }),
    }),
  );

  final parseFlatArrayValidator = vine.compile(
    vine.array(
      vine.object({
        'number': vine.number().positive(),
        'negNumber': vine.number().negative(),
        'infiniteNumber': vine.number(),
        'string': vine.string(),
        'longString': vine.string(),
        'boolean': vine.boolean(),
      }),
    ),
  );

  final parseNestedArrayValidator = vine.compile(
    vine.array(
      vine.object({
        'number': vine.number().positive(),
        'negNumber': vine.number().negative(),
        'infiniteNumber': vine.number(),
        'string': vine.string(),
        'longString': vine.string(),
        'boolean': vine.boolean(),
        'deeplyNested': vine.array(
          vine.object({'foo': vine.string(), 'num': vine.number(), 'bool': vine.boolean()}),
        ),
      }),
    ),
  );

  final parseDeeplyNestedArrayValidator = vine.compile(
    vine.array(
      vine.object({
        'number': vine.number().positive(),
        'negNumber': vine.number().negative(),
        'infiniteNumber': vine.number(),
        'string': vine.string(),
        'longString': vine.string(),
        'boolean': vine.boolean(),
        'deeplyNested': vine.array(
          vine.object({
            'foo': vine.string(),
            'num': vine.number(),
            'bool': vine.boolean(),
            'deeplyNested2': vine.array(
              vine.object({'foo2': vine.string(), 'num2': vine.number(), 'bool2': vine.boolean()}),
            ),
          }),
        ),
      }),
    ),
  );

  @override
  void parseFlatObject(Map<String, dynamic> json) {
    parseFlatObjectValidator.validate(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    parseNestedObjectValidator.validate(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    parseDeeplyNestedObjectValidator.validate(json);
  }

  @override
  void parseFlatArray(List<Map<String, dynamic>> json) {
    parseFlatArrayValidator.validate(json);
  }

  @override
  void parseNestedArray(List<Map<String, dynamic>> json) {
    parseNestedArrayValidator.validate(json);
  }

  @override
  void parseDeeplyNestedArray(List<Map<String, dynamic>> json) {
    parseDeeplyNestedArrayValidator.validate(json);
  }

  @override
  Future<void> run() async {
    final suite = Suite();
    suite.add(
      OpsBenchmarkBase(
        'flat_object',
        group: 'vine',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'vine',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'vine',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase('flat_array', group: 'vine', onRun: () async => parseFlatArray(flatArray)),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'vine',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'vine',
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
  final vine = VineBench();
  vine.run();
}
