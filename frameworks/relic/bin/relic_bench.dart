import 'dart:convert';
import 'dart:io';
import 'package:relic/relic.dart';

Future<void> main(List<String> arguments) async {
  final app = RelicApp()..get(
      '/health', (req) => Response.ok(body: Body.fromString('ok')))..post(
      '/api/echo',
      (req) => Response.ok(
        body: Body.fromString(jsonEncode({
          'message': 'Hello, World!',
          'dateTime': DateTime.now().toIso8601String(),
        })
      ),
    ));
  await app.serve(port: int.parse(Platform.environment['PORT'] ?? '8080'));
}
