import 'dart:convert';
import 'package:my_server/packages/server_info.dart';
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
      final dbConnection = await ServerInfo.connectToDatabase();
      try {
        final results =
            await dbConnection.query('SELECT id, name, email FROM user');
        final users = results
            .map((row) => {'id': row[0], 'name': row[1], 'email': row[2]})
            .toList();

        return Response.ok(jsonEncode(users),
            headers: {'Content-Type': 'application/json'});
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      } finally {
        await dbConnection.close();
      }
    });

    router.post('/add-user', (Request request) async {
      final payload = await request.readAsString();
      final data = jsonDecode(payload) as Map<String, dynamic>;

      final name = data['name'];
      final email = data['email'];
      final password = data['password'];

      if (name == null || email == null || password == null) {
        return Response.badRequest(body: 'الاسم أو البريد الإلكتروني مفقود.');
      }

      final dbConnection = await ServerInfo.connectToDatabase();
      try {
        await dbConnection.query(
          'INSERT INTO user (name, email, password) VALUES (?, ?, ?)',
          [name, email, password],
        );

        return Response.ok('تم إضافة المستخدم بنجاح.');
      } catch (e) {
        return Response.internalServerError(body: 'Error: $e');
      } finally {
        await dbConnection.close();
      }
    });
  }

 
}
