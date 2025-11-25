import 'dart:convert';

import 'package:ez_validator/ez_validator.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';

final flatObjectSchema = EzSchema.shape({
  'number': EzValidator<int>(),
  'negNumber': EzValidator<int>(),
  'infiniteNumber': EzValidator<double>(),
  'string': EzValidator<String>(),
  'longString': EzValidator<String>(),
  'boolean': EzValidator<bool>(),
});

final nestedObjectSchema = EzSchema.shape({
  'number': EzValidator<int>(),
  'negNumber': EzValidator<int>(),
  'infiniteNumber': EzValidator<double>(),
  'string': EzValidator<String>(),
  'longString': EzValidator<String>(),
  'boolean': EzValidator<bool>(),
  'deeplyNested': EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
    'foo': EzValidator<String>(),
    'num': EzValidator<int>(),
    'bool': EzValidator<bool>(),
  })),
});

final deeplyNestedObjectSchema = EzSchema.shape({
  'number': EzValidator<int>(),
  'negNumber': EzValidator<int>(),
  'infiniteNumber': EzValidator<double>(),
  'string': EzValidator<String>(),
  'longString': EzValidator<String>(),
  'boolean': EzValidator<bool>(),
  'deeplyNested': EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
    'foo': EzValidator<String>(),
    'num': EzValidator<int>(),
    'bool': EzValidator<bool>(),
    'deeplyNested2': EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
      'foo2': EzValidator<String>(),
      'num2': EzValidator<int>(),
      'bool2': EzValidator<bool>(),
    }),),
  }),),
});

final flatArraySchema = EzValidator<Map<String, dynamic>>().arrayOf(
  EzValidator<Map<String,dynamic>>().schema(EzSchema.shape({
    'number': EzValidator<int>(),
    'negNumber': EzValidator<int>(),
    'infiniteNumber': EzValidator<double>(),
    'string': EzValidator<String>(),
    'longString': EzValidator<String>(),
    'boolean': EzValidator<bool>(),
  }),)
);

final nestedArraySchema = EzValidator<Map<String, dynamic>>().arrayOf(
  EzValidator<Map<String,dynamic>>().schema(EzSchema.shape({
    'number': EzValidator<int>(),
    'negNumber': EzValidator<int>(),
    'infiniteNumber': EzValidator<double>(),
    'string': EzValidator<String>(),
    'longString': EzValidator<String>(),
    'boolean': EzValidator<bool>(),
    'deeplyNested': EzValidator<List<Map<String, dynamic>>>().arrayOf(
      EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
        'foo': EzValidator<String>(),
        'num': EzValidator<int>(),
        'bool': EzValidator<bool>(),
      }),),
    ),
  }),)
);

final deeplyNestedArraySchema = EzValidator<List<Map<String, dynamic>>>().arrayOf(
  EzValidator<Map<String,dynamic>>().schema(EzSchema.shape({
    'number': EzValidator<int>(),
    'negNumber': EzValidator<int>(),
    'infiniteNumber': EzValidator<double>(),
    'string': EzValidator<String>(),
    'longString': EzValidator<String>(),
    'boolean': EzValidator<bool>(),
    'deeplyNested': EzValidator<List<Map<String, dynamic>>>().arrayOf(
      EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
        'foo': EzValidator<String>(),
        'num': EzValidator<int>(),
        'bool': EzValidator<bool>(),
        'deeplyNested2': EzValidator<List<Map<String, dynamic>>>().arrayOf(
          EzValidator<Map<String, dynamic>>().schema(EzSchema.shape({
            'foo2': EzValidator<String>(),
            'num2': EzValidator<int>(),
            'bool2': EzValidator<bool>(),
          }),
        )),
      }),
    )),
  }),
));


class EzValidatorBench extends Package {
  @override
  void parseFlatObject(Map<String, dynamic> json) {
    flatObjectSchema.validateSync(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    nestedObjectSchema.validateSync(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    deeplyNestedObjectSchema.validateSync(json);
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
        group: 'ez_validator',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'ez_validator',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'ez_validator',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'ez_validator',
        onRun: () async => parseFlatArray(flatArray),
        warningMessage: "The benchmark results for 'flat_array' may be less reliable due to the different validation method used. All the other benchmarks from 'ez_validator' use 'validateSync', while this one uses 'validate'",
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'ez_validator',
        onRun: () async => parseNestedArray(nestedArray),
        warningMessage: "The benchmark results for 'nested_array' may be less reliable due to the different validation method used. All the other benchmarks from 'ez_validator' use 'validateSync', while this one uses 'validate'",
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'ez_validator',
        onRun: () async => parseDeeplyNestedArray(deeplyNestedArray),
        warningMessage: "The benchmark results for 'deeply_nested_array' may be less reliable due to the different validation method used. All the other benchmarks from 'ez_validator' use 'validateSync', while this one uses 'validate'",
      ),
    );
    final results = await suite.run();
    for (final result in results) {
      print(jsonEncode(result.toMap()));
    }
  }
}

void main() {
  final ezValidator = EzValidatorBench();
  ezValidator.run();
}
