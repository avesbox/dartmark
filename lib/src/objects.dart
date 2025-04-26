final Map<String, dynamic> flatObject = {
  'number': 123,
  'negNumber': -123,
  'infiniteNumber': double.infinity,
  'string': 'Hello, World!',
  'longString': 'This is a long string that exceeds the normal length.',
  'boolean': true,
};

final Map<String, dynamic> nestedObject = {
  'number': 123,
  'negNumber': -123,
  'infiniteNumber': double.infinity,
  'string': 'Hello, World!',
  'longString': 'This is a long string that exceeds the normal length.',
  'boolean': true,
  'deeplyNested': {
    'foo': 'bar',
    'num': 456,
    'bool': false,
  },
};

final Map<String, dynamic> deeplyNestedObject = {
  'number': 123,
  'negNumber': -123,
  'infiniteNumber': double.infinity,
  'string': 'Hello, World!',
  'longString': 'This is a long string that exceeds the normal length.',
  'boolean': true,
  'deeplyNested': {
    'foo': 'bar',
    'num': 456,
    'bool': false,
    'deeplyNested2': {
      'foo2': 'baz',
      'num2': 789,
      'bool2': true,
    },
  },
};

final List<Map<String, dynamic>> flatArray = [
  {
    'number': 123,
    'negNumber': -123,
    'infiniteNumber': double.infinity,
    'string': 'Hello, World!',
    'longString': 'This is a long string that exceeds the normal length.',
    'boolean': true,
  },
  {
    'number': 456,
    'negNumber': -456,
    'infiniteNumber': double.infinity,
    'string': 'Goodbye, World!',
    'longString': 'This is another long string that exceeds the normal length.',
    'boolean': false,
  },
];

final List<Map<String, dynamic>> nestedArray = [
  {
    'number': 123,
    'negNumber': -123,
    'infiniteNumber': double.infinity,
    'string': 'Hello, World!',
    'longString': 'This is a long string that exceeds the normal length.',
    'boolean': true,
    'deeplyNested': [
      {
        'foo': 'bar',
        'num': 456,
        'bool': false,
      },
      {
        'foo': 'baz',
        'num': 789,
        'bool': true,
      },
    ],
  },
  {
    'number': 456,
    'negNumber': -456,
    'infiniteNumber': double.infinity,
    'string': 'Goodbye, World!',
    'longString': 'This is another long string that exceeds the normal length.',
    'boolean': false,
    'deeplyNested': [
      {
        'foo': 'qux',
        'num': 101112,
        'bool': true,
      },
      {
        'foo': 'quux',
        'num': 131415,
        'bool': false,
      },
    ],
  },
];

final List<Map<String, dynamic>> deeplyNestedArray = [
  {
    'number': 123,
    'negNumber': -123,
    'infiniteNumber': double.infinity,
    'string': 'Hello, World!',
    'longString': 'This is a long string that exceeds the normal length.',
    'boolean': true,
    'deeplyNested': [
      {
        'foo': 'bar',
        'num': 456,
        'bool': false,
        'deeplyNested2': [
          {
            'foo2': 'baz',
            'num2': 789,
            'bool2': true,
          },
          {
            'foo2': 'qux',
            'num2': 101112,
            'bool2': false,
          },
        ],
      },
      {
        'foo': 'quux',
        'num': 131415,
        'bool': true,
        'deeplyNested2': [
          {
            'foo2': 'corge',
            'num2': 161718,
            'bool2': false,
          },
          {
            'foo2': 'grault',
            'num2': 192021,
            'bool2': true,
          },
        ],
      },
    ],
  },
  {
    'number': 456,
    'negNumber': -456,
    'infiniteNumber': double.infinity,
    'string': 'Goodbye, World!',
    'longString': 'This is another long string that exceeds the normal length.',
    'boolean': false,
    'deeplyNested': [
      {
        'foo': 'qux',
        'num': 101112,
        'bool': true,
        'deeplyNested2': [
          {
            'foo2': 'quux',
            'num2': 131415,
            'bool2': false,
          },
          {
            'foo2': 'corge',
            'num2': 161718,
            'bool2': true,
          },
        ],
      },
      {
        'foo': 'grault',
        'num': 192021,
        'bool': false,
        'deeplyNested2': [
          {
            'foo2': 'garply',
            'num2': 222324,
            'bool2': true,
          },
          {
            'foo2': 'waldo',
            'num2': 252627,
            'bool2': false,
          },
        ],
      },
    ],
  },
];