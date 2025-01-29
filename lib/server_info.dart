import 'package:dotenv/dotenv.dart';
import 'package:mysql1/mysql1.dart';

class Pram {
  Pram(this.name) : value = name;
  String name;
  String value;
  Pram type(String type) {
    value = "$value $type";
    return this;
  }

  Pram key() {
    value = "$value AUTO_INCREMENT PRIMARY KEY";
    return this;
  }
}

class ServerInfo {
  static final env = DotEnv(includePlatformEnvironment: true)..load();
  static final sqlPort = env["Sql_Port"];
  static final host = env["Host"];
  static final user = env["User"];
  static final password = env["Password"];
  static final database = env["Database"];
  static final serverPort = env["Server_Port"];

  static Future<MySqlConnection> connectToDatabase() async {
    final settings = ConnectionSettings(
      host: host!,
      port: int.parse(sqlPort!),
      user: user,
      password: password,
      db: database,
    );
    return await MySqlConnection.connect(settings);
  }

  static Future<void> createTable(String tableName, List<String> param) async {
    final db = await connectToDatabase();
    try {
      await db.query('CREATE TABLE $tableName (${param.join(', ')});');
    } catch (e) {
      rethrow;
    } finally {
      db.close();
    }
  }
}
