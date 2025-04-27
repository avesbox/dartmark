import 'package:dartmark/src/executor.dart';

void main(List<String> arguments) {
  final Executor executor = Executor([
    'acanthis',
    'vine',
  ]);
  executor.execute();
}
