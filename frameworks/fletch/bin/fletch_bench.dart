import 'dart:io';

import 'package:fletch/fletch.dart';

Future<void> main() async {
  final port = int.parse(Platform.environment['PORT'] ?? '8080');
  final host =
      Platform.environment['HOST'] ?? InternetAddress.loopbackIPv4.address;
  final app = Fletch(
    requestTimeout: null, // disable per-request Timer — no timeout infra in bench
  );

  app.get('/health', (req, res) => res.text('ok'));

  // Echo request payload back as JSON using Fletch body parsing + JSON response encoding.
  app.get('/api/echo', (req, res) async {
    final body = await req.body;
    res.json(body as Map<String, dynamic>);
  });

  await app.listen(port, address: InternetAddress(host));
  print('Server running on http://$host:$port');
}
