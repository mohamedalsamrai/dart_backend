import 'package:my_server/packages/server_info.dart';

class Schema {
  static Future<void> createTable(String tableName, List<String> param) async {
    final db = await ServerInfo.connectToDatabase();
    try {
      await db.query('CREATE TABLE $tableName (${param.join(', ')});');
    } catch (e) {
      rethrow;
    } finally {
      db.close();
    }
  }
}