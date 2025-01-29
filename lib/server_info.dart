import 'package:dotenv/dotenv.dart';
import 'package:my_server/routes/routes.dart';
import 'package:mysql1/mysql1.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf/shelf.dart';

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
  static final _env = DotEnv(includePlatformEnvironment: true)..load();
  static final _sqlPort = _env["Sql_Port"];
  static final _host = _env["Host"];
  static final _user = _env["User"];
  static final _password = _env["Password"];
  static final _database = _env["Database"];
  static final _serverPort = _env["Server_Port"];

  static Future<MySqlConnection> connectToDatabase() async {
    final settings = ConnectionSettings(
      host: _host!,
      port: int.parse(_sqlPort!),
      user: _user,
      password: _password,
      db: _database,
    );
    return await MySqlConnection.connect(settings);
  }
 static Future<void> runServer() async {
    Routes.call();
    final handler = Cascade().add(Routes.indexRoute).add(Routes.router).handler;

    final server =
        await io.serve(handler, _host!, int.parse(_serverPort!));
    print('🚀 Server running on http://${server.address.host}:${server.port}');
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
