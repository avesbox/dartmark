import 'dart:io';
import 'package:netto/netto.dart';

Future<void> main(List<String> arguments) async {
  final app = Netto()
    ..get('/health', (ctx) => ctx.response.string("ok"))
    ..get('/api/echo', (ctx) async {
      final body = await ctx.request.body.json();
      return ctx.response.json(body);
    });

  final port = int.parse(Platform.environment['PORT'] ?? '8080');

  await app.serve(InternetAddress.anyIPv4, port);
}
