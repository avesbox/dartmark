import 'dart:convert';
import 'dart:io';

import 'package:dart_frog/dart_frog.dart';

Future<void> main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host = Platform.environment['HOST'] ?? InternetAddress.loopbackIPv4.address;
  final server = await serve(_echoRequest, host, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _echoRequest(RequestContext context) async {
  if (context.request.url.path == 'health') {
    return Response(body: 'ok');
  }

  final jsonBody = await context.request.body();
  final body = jsonDecode(jsonBody.isEmpty ? '{}' : jsonBody);
  return Response.json(body: body, headers: {
    'Content-Type': 'application/json',
  });
}
