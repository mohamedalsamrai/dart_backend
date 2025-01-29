import 'package:my_server/packages/pram.dart';
import 'package:my_server/packages/server_info.dart';
import 'package:mysql1/mysql1.dart';

class Schema {
  static Future<void> createTable(String tableName, List<Pram> param) async {
    final db = await ServerInfo.connectToDatabase();
    try {
      await db.query('CREATE TABLE $tableName (${param.map((p)=>p.value).toList().join(', ')});');
    } catch (e) {
      rethrow;
    } finally {
      db.close();
    }
  }

  static Future<void> addRow(
    {required String table, required Map<String, String> elements}) async {
  final dbConnection = await ServerInfo.connectToDatabase();
  try {
    await dbConnection.query(
      "INSERT INTO $table (${elements.keys.join(', ')}) VALUES (${List.filled(elements.keys.length, '?').join(", ")})",
      elements.values.toList(),
    );
  } on MySqlException {
    rethrow;
  } finally {
    await dbConnection.close();
  }
}
}