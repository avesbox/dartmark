import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart';


Future<void> main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host = Platform.environment['HOST'] ?? InternetAddress.loopbackIPv4.address;
  final server = await serve(_echoRequest, host, port);
  print('Serving at http://${server.address.host}:${server.port}');
}

Future<Response> _echoRequest(Request request) async {
  if (request.url.path == 'health') {
    return Response.ok('ok');
  }

  final body = await request.readAsString();
  return Response.ok(body.isEmpty ? '{}' : body, headers: {
    'Content-Type': 'application/json',
  });
}