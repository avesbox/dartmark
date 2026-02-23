import 'package:serinus/serinus.dart';

class AppController extends Controller {

  AppController(): super('/'){
    onStatic(Route.get('/health'), 'ok');
    on(Route.get('/api/echo'), _echo);
  }

  Future<Map<String, dynamic>> _echo(RequestContext<Map<String, dynamic>> context) async {
    return context.body;
  }

}