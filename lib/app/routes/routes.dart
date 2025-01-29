import 'package:my_server/app/Controllers/user_controller.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

class Routes {
  static final router = Router();
  static final indexRoute = createStaticHandler(
    'public',
    defaultDocument: 'index.html',
  );

  static Future<void> call() async {
    router.get('/users', (Request request) async {
      return UserController.index(request);
    });

    router.post('/add-user', (Request request) async {
      return UserController.add(request);
    });
  }
}
