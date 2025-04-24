import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqlite_api.dart';
import 'package:path/path.dart' as path;

Future<Database> getDatabase() async {
  final dbPath = await sql.getDatabasesPath();
  final db = await sql.openDatabase(
    path.join(dbPath, 'data.db'),
    onCreate: (db, version) async {
      final dbRes = await db.execute(
        'CREATE TABLE tokens(access_token TEXT, refresh_token TEXT)',
      );
      await db.execute('insert into tokens values (\'\',\'\')');
      return dbRes;
    },
    version: 1,
  );
  return db;
}
