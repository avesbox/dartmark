import 'dart:convert';

import 'package:ack/ack.dart';
import 'package:tyto/tyto.dart';
import 'package:dartmark/src/objects.dart';
import 'package:dartmark/src/package.dart';

final flatObjectSchema = Ack.object({
  'number': Ack.int,
  'negNumber': Ack.int,
  'infiniteNumber': Ack.double,
  'string': Ack.string,
  'longString': Ack.string,
  'boolean': Ack.boolean,
});

final nestedObjectSchema = Ack.object({
  'number': Ack.int,
  'negNumber': Ack.int,
  'infiniteNumber': Ack.double,
  'string': Ack.string,
  'longString': Ack.string,
  'boolean': Ack.boolean,
  'deeplyNested': Ack.object({
    'foo': Ack.string,
    'num': Ack.int,
    'bool': Ack.boolean,
  }),
});

final deeplyNestedObjectSchema = Ack.object({
  'number': Ack.int,
  'negNumber': Ack.int,
  'infiniteNumber': Ack.double,
  'string': Ack.string,
  'longString': Ack.string,
  'boolean': Ack.boolean,
  'deeplyNested': Ack.object({
    'foo': Ack.string,
    'num': Ack.int,
    'bool': Ack.boolean,
    'deeplyNested2': Ack.object({
      'foo2': Ack.string,
      'num2': Ack.int,
      'bool2': Ack.boolean,
    }),
  }),
});

final flatArraySchema = Ack.list(
  Ack.object({
    'number': Ack.int,
    'negNumber': Ack.int,
    'infiniteNumber': Ack.double,
    'string': Ack.string,
    'longString': Ack.string,
    'boolean': Ack.boolean,
  }),
);

final nestedArraySchema = Ack.list(
  Ack.object({
    'number': Ack.int,
    'negNumber': Ack.int,
    'infiniteNumber': Ack.double,
    'string': Ack.string,
    'longString': Ack.string,
    'boolean': Ack.boolean,
    'deeplyNested': Ack.list(
      Ack.object({'foo': Ack.string, 'num': Ack.int, 'bool': Ack.boolean}),
    ),
  }),
);

final deeplyNestedArraySchema = Ack.list(
  Ack.object({
    'number': Ack.int,
    'negNumber': Ack.int,
    'infiniteNumber': Ack.double,
    'string': Ack.string,
    'longString': Ack.string,
    'boolean': Ack.boolean,
    'deeplyNested': Ack.list(
      Ack.object({
        'foo': Ack.string,
        'num': Ack.int,
        'bool': Ack.boolean,
        'deeplyNested2': Ack.list(
          Ack.object({
            'foo2': Ack.string,
            'num2': Ack.int,
            'bool2': Ack.boolean,
          }),
        ),
      }),
    ),
  }),
);


class AckBench extends Package {
  @override
  void parseFlatObject(Map<String, dynamic> json) {
    flatObjectSchema.validateValue(json);
  }

  @override
  void parseNestedObject(Map<String, dynamic> json) {
    nestedObjectSchema.validateValue(json);
  }

  @override
  void parseDeeplyNestedObject(Map<String, dynamic> json) {
    deeplyNestedObjectSchema.validateValue(json);
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
        group: 'ack',
        onRun: () async => parseFlatObject(flatObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_object',
        group: 'ack',
        onRun: () async => parseNestedObject(nestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_object',
        group: 'ack',
        onRun: () async => parseDeeplyNestedObject(deeplyNestedObject),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'flat_array',
        group: 'ack',
        onRun: () async => parseFlatArray(flatArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'nested_array',
        group: 'ack',
        onRun: () async => parseNestedArray(nestedArray),
      ),
    );
    suite.add(
      OpsBenchmarkBase(
        'deeply_nested_array',
        group: 'ack',
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
  final ack = AckBench();
  ack.run();
}
