import 'dart:convert';

import 'package:my_server/app/models/user.dart';
import 'package:my_server/packages/server_info.dart';
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
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    } finally {
      await dbConnection.close();
    }
  }

  static Future<Response> add(Request request) async {
    final payload = await request.readAsString();
    final Map<String, dynamic> data =
        jsonDecode(payload) as Map<String, dynamic>;
    if (data['email'] == null ||
        data['name'] == null ||
        data['password'] == null) {
      return Response.badRequest(
          body: 'الاسم أو البريد الإلكتروني أو كلمة المرور مفقود.');
    }
    final dbConnection = await ServerInfo.connectToDatabase();
    try {
      addRow(table: "user", elements: {
        "email": data['email'] as String,
        "name": data['name'] as String,
        "password": data['password'] as String
      });

      return Response.ok('تم إضافة المستخدم بنجاح.');
    } catch (e) {
      return Response.internalServerError(body: 'Error: $e');
    } finally {
      await dbConnection.close();
    }
  }
}

Future<void> addRow(
    {required String table, required Map<String, String> elements}) async {
  try {
    final dbConnection = await ServerInfo.connectToDatabase();
    dbConnection.query(
        "INSERT INTO $table (${elements.keys.join(', ')}) VALUES (${List.filled(elements.keys.length, '?').join(", ")})",
        elements.values.toList());
  } catch (e) {
    rethrow;
  }
}
