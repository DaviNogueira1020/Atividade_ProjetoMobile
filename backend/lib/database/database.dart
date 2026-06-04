import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:sqlite3/sqlite3.dart';

class DatabaseConnection {
  static Database? _database;

  static Database get instance{
    _database ??= _openDatabase();
    return _database!;
  }

  static Database _openDatabase(){
    final dbPath = p.join(
      Directory.current.path,
      'sos_cidade.db',
    );

    final database = sqlite3.open(dbPath);

    _createTables(database);

    return database;
  }

  static void close(){
    _database?.dispose();
    _database = null;
  }

  static void _createTables(Database db){
  db.execute('''
    CREATE TABLE IF NOT EXISTS chamados (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      titulo TEXT NOT NULL UNIQUE,
      descricao TEXT NOT NULL,
      categoria TEXT NOT NULL,
      prioridade INTEGER NOT NULL,
      status INTEGER NOT NULL,
      bairro TEXT NOT NULL,
      responsavel TEXT NOT NULL,
      data_abertura INTEGER NOT NULL,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    );
  ''');

  db.execute('''
  CREATE INDEX IF NOT EXISTS idx_chamados_status
  ON chamados(status);
''');

db.execute('''
  CREATE INDEX IF NOT EXISTS idx_chamados_prioridade
  ON chamados(prioridade);
''');

db.execute('''
  CREATE INDEX IF NOT EXISTS idx_chamados_bairro
  ON chamados(bairro);
''');

db.execute('''
  CREATE INDEX IF NOT EXISTS idx_chamados_data_abertura
  ON chamados(data_abertura);
''');
}
}