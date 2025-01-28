import 'dart:convert';
import 'package:my_server/server_info.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_static/shelf_static.dart';

void main() async {
  final router = Router();

  router.get('/users', (Request request) async {
    final dbConnection = await ServerInfo.connectToDatabase();
    try {
      final results =
          await dbConnection.query('SELECT id, name, email FROM users');
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

    if (name == null || email == null) {
      return Response.badRequest(body: 'الاسم أو البريد الإلكتروني مفقود.');
    }

    final dbConnection = await ServerInfo.connectToDatabase();
    try {
      await dbConnection.query(
        'INSERT INTO users (name, email) VALUES (?, ?)',
        [name, email],
      );

      return Response.ok('تم إضافة المستخدم بنجاح.');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    } finally {
      await dbConnection.close();
    }
  });

  final staticHandler = createStaticHandler(
    'public',
    defaultDocument: 'index.html',
  );

  final handler = Cascade().add(staticHandler).add(router).handler;

  final server = await io.serve(
      handler, ServerInfo.host!, int.parse(ServerInfo.serverPort!));
  print('🚀 Server running on http://${server.address.host}:${server.port}');
}
