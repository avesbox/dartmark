import 'package:dartmark/src/executor.dart';

void main(List<String> arguments) {
  final Executor executor = Executor([
    'acanthis', 
    'luthor', 
    'ack', 
    'vine', 
    'zard', 
    'json_schema_builder', 
    'ez_validator'
  ]);
  executor.execute();
}
