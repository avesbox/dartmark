import 'dart:convert';
import 'dart:io';

Future<void> main(List<String> args) async {
  final port = int.parse(Platform.environment['PORT'] ?? '8081');
  final server = await HttpServer.bind(InternetAddress.loopbackIPv4, port);
  print('listening on $port');

  await for (final request in server) {
    if (request.uri.path == '/health') {
      request.response
        ..statusCode = HttpStatus.ok
        ..write('ok');
      await request.response.close();
      continue;
    }

    // Echo JSON body
    final body = await utf8.decoder.bind(request).join();
    request.response
      ..statusCode = HttpStatus.ok
      ..headers.contentType = ContentType.json
      ..write(body.isEmpty ? '{}' : body);
    await request.response.close();
  }
}