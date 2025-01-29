import 'dart:convert';
import 'package:my_server/app/exceptions/response_exception.dart';
import 'package:my_server/packages/schema.dart';
import 'package:my_server/packages/server_info.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf.dart';

class UserController {
  static Future<Response> index(Request request) async {
    final dbConnection = await ServerInfo.connectToDatabase();
    try {
      final results =
          await dbConnection.query('SELECT id, name, email FROM user');
      final users = results
          .map((row) => {'id': row[0], 'name': row[1], 'email': row[2]})
          .toList();

      return Response.ok(jsonEncode(users),
          headers: {'Content-Type': 'application/json'});
    } on MySqlException catch (e) {
      return ResponseException.mysqlException(e);
    } catch (e) {
      return ResponseException.exception(e);
    } finally {
      await dbConnection.close();
    }
  }

  static Future<Response> add(Request request) async {
    try {
      final payload = await request.readAsString();
      final Map<String, dynamic> data =
          jsonDecode(payload) as Map<String, dynamic>;
      if (data['email'] == null ||
          data['name'] == null ||
          data['password'] == null) {
        return Response.badRequest(
            body: jsonEncode({
              'error': 'الاسم أو البريد الإلكتروني أو كلمة المرور مفقود.',
            }),
            headers: {'Content-Type': 'application/json'});
      }

      final dbConnection = await ServerInfo.connectToDatabase();
      try {
        await Schema.addRow(table: "user", elements: {
          "email": data['email'] as String,
          "name": data['name'] as String,
          "password": data['password'] as String
        });

        return Response.ok(jsonEncode({'message': 'تم إضافة المستخدم بنجاح.'}),
            headers: {'Content-Type': 'application/json'});
      } on MySqlException catch (e) {
        return ResponseException.mysqlException(e);
      } finally {
        await dbConnection.close();
      }
    } catch (e) {
      return ResponseException.exception(e);
    }
  }
}
