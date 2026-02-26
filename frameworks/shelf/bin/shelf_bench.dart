import 'dart:convert';
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

  final jsonBody = await request.readAsString();
  final body = jsonDecode(jsonBody.isEmpty ? '{}' : jsonBody);
  return Response.ok(jsonEncode(body), headers: {
    'Content-Type': 'application/json',
  });
}