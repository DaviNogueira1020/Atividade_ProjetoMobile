import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chamado_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() {
    return _instance;
  }

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'sos_cidade.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE chamados (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT NOT NULL UNIQUE,
        descricao TEXT NOT NULL,
        categoria INTEGER NOT NULL,
        prioridade INTEGER NOT NULL,
        bairro TEXT NOT NULL,
        responsavel TEXT NOT NULL,
        dataCriacao TEXT NOT NULL,
        dataResolucao TEXT,
        status INTEGER NOT NULL,
        observacoes TEXT
      )
    ''');
  }

  // CREATE
  Future<int> inserirChamado(ChamadoModel chamado) async {
    Database db = await database;
    return await db.insert(
      'chamados',
      chamado.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // READ - Um chamado
  Future<ChamadoModel?> obterChamado(int id) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chamados',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return ChamadoModel.fromMap(maps.first);
    }
    return null;
  }

  // READ - Todos os chamados
  Future<List<ChamadoModel>> obterTodosChamados() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query('chamados');
    return List.generate(
      maps.length,
      (i) => ChamadoModel.fromMap(maps[i]),
    );
  }

  // READ - Chamados por status
  Future<List<ChamadoModel>> obterChamadosPorStatus(int status) async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chamados',
      where: 'status = ?',
      whereArgs: [status],
    );
    return List.generate(
      maps.length,
      (i) => ChamadoModel.fromMap(maps[i]),
    );
  }

  // READ - Chamados críticos
  Future<List<ChamadoModel>> obterChamadosCriticos() async {
    Database db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'chamados',
      where: 'prioridade = ?',
      whereArgs: [PrioridadeChamado.critica.index],
      orderBy: 'dataCriacao DESC',
    );
    return List.generate(
      maps.length,
      (i) => ChamadoModel.fromMap(maps[i]),
    );
  }

  // UPDATE
  Future<int> atualizarChamado(ChamadoModel chamado) async {
    Database db = await database;
    return await db.update(
      'chamados',
      chamado.toMap(),
      where: 'id = ?',
      whereArgs: [chamado.id],
    );
  }

  // DELETE
  Future<int> deletarChamado(int id) async {
    Database db = await database;
    return await db.delete(
      'chamados',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // DELETE - Limpar tudo
  Future<void> limparTabela() async {
    Database db = await database;
    await db.delete('chamados');
  }

  // Contadores para dashboard
  Future<int> contarChamados() async {
    Database db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM chamados');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> contarChamadosPorStatus(int status) async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chamados WHERE status = ?',
      [status],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<int> contarChamadosCriticos() async {
    Database db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM chamados WHERE prioridade = ? AND status != ?',
      [PrioridadeChamado.critica.index, StatusChamado.concluido.index],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  // Fechar database
  Future<void> fecharBancoDados() async {
    Database db = await database;
    await db.close();
  }
}
