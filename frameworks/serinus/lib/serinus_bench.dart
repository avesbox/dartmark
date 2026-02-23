import 'dart:io';

import 'package:serinus/serinus.dart';

import 'app_module.dart';

/// The bootstrap function is the entry point of the application.
/// It will be called by the `entrypoint` file in the bin directory.
/// 
/// This function creates a Serinus application using the [AppModule]
/// as the root module, and starts the server.
Future<void> bootstrap() async {
  final app = await serinus.createApplication(
    entrypoint: AppModule(),
    host: InternetAddress.loopbackIPv4.address,
    logLevels: {LogLevel.none}
  );
  await app.serve();
}
