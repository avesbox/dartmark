import 'dart:convert';
import 'dart:io';
import 'package:relic/relic.dart';

Future<void> main(List<String> arguments) async {
  final app = RelicApp()..get(
      '/health', (req) => Response.ok(body: Body.fromString('ok')))..get(
      '/api/echo',
      (req) async {
        final jsonBody = await req.readAsString();
        final body = jsonDecode(jsonBody.isEmpty ? '{}' : jsonBody);
        return Response.ok(body: Body.fromString(jsonEncode(body)));
      }
    );
  await app.serve(port: int.parse(Platform.environment['PORT'] ?? '8080'));
}
