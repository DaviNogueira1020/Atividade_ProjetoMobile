// lib/database/database_helper.dart
//
// Schema alinhado ao databasedoc.md:
//   - prioridade  → INTEGER (0-3)  ORDER BY prioridade DESC coloca crítica no topo
//   - status      → INTEGER (0-2)
//   - categoria   → TEXT ("transito", "limpeza_urbana" …)
//   - datas       → INTEGER epoch millis
//   - UNIQUE(titulo) já no banco + índices de performance

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/chamado_model.dart';

class DatabaseHelper {
  // Singleton
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  // ── Inicialização ──────────────────────────────────────────────────────────

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = join(await getDatabasesPath(), 'sos_cidade.db');
    return openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Tabela principal
    await db.execute('''
      CREATE TABLE IF NOT EXISTS chamados (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo        TEXT    NOT NULL,
        descricao     TEXT    NOT NULL,
        categoria     TEXT    NOT NULL,
        prioridade    INTEGER NOT NULL,
        status        INTEGER NOT NULL,
        bairro        TEXT    NOT NULL,
        responsavel   TEXT    NOT NULL,
        data_abertura INTEGER NOT NULL,
        created_at    INTEGER NOT NULL,
        updated_at    INTEGER NOT NULL,

        CONSTRAINT uq_chamados_titulo UNIQUE (titulo)
      )
    ''');

    // Índices de performance (conforme databasedoc.md §5)
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_chamados_status ON chamados(status)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_chamados_prioridade ON chamados(prioridade)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_chamados_bairro ON chamados(bairro)');
    await db.execute(
        'CREATE INDEX IF NOT EXISTS idx_chamados_data_abertura ON chamados(data_abertura)');
  }

  // Para futuras migrações (ex: adicionar coluna foto na versão 2)
  Future<void> _onUpgrade(Database db, int oldV, int newV) async {
    // if (oldV < 2) await db.execute('ALTER TABLE chamados ADD COLUMN foto TEXT');
  }

  // ── CREATE ─────────────────────────────────────────────────────────────────

  /// Retorna o id gerado. Lança DatabaseException se título já existe.
  Future<int> inserirChamado(ChamadoModel chamado) async {
    final db = await database;
    return db.insert(
      'chamados',
      chamado.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort, // aborta se título duplicar
    );
  }

  // ── READ ───────────────────────────────────────────────────────────────────

  Future<ChamadoModel?> obterChamado(int id) async {
    final db = await database;
    final rows =
        await db.query('chamados', where: 'id = ?', whereArgs: [id], limit: 1);
    return rows.isEmpty ? null : ChamadoModel.fromMap(rows.first);
  }

  /// Lista ordenada: prioridade DESC (crítica no topo), depois data_abertura DESC
  Future<List<ChamadoModel>> obterTodosChamados() async {
    final db = await database;
    final rows = await db.query(
      'chamados',
      orderBy: 'prioridade DESC, data_abertura DESC',
    );
    return rows.map(ChamadoModel.fromMap).toList();
  }

  Future<List<ChamadoModel>> obterChamadosPorStatus(StatusChamado status) async {
    final db = await database;
    final rows = await db.query(
      'chamados',
      where: 'status = ?',
      whereArgs: [status.index],
      orderBy: 'prioridade DESC, data_abertura DESC',
    );
    return rows.map(ChamadoModel.fromMap).toList();
  }

  Future<List<ChamadoModel>> obterChamadosPorBairro(String bairro) async {
    final db = await database;
    final rows = await db.query(
      'chamados',
      where: 'bairro = ?',
      whereArgs: [bairro],
      orderBy: 'prioridade DESC, data_abertura DESC',
    );
    return rows.map(ChamadoModel.fromMap).toList();
  }

  /// Busca em título e descrição (conforme databasedoc.md §6.6)
  Future<List<ChamadoModel>> buscar(String termo) async {
    if (termo.trim().isEmpty) return obterTodosChamados();
    final db = await database;
    final q = '%$termo%';
    final rows = await db.query(
      'chamados',
      where: 'titulo LIKE ? OR descricao LIKE ?',
      whereArgs: [q, q],
      orderBy: 'prioridade DESC, data_abertura DESC',
    );
    return rows.map(ChamadoModel.fromMap).toList();
  }

  // ── UPDATE ─────────────────────────────────────────────────────────────────

  Future<int> atualizarChamado(ChamadoModel chamado) async {
    final db = await database;
    return db.update(
      'chamados',
      chamado.toMap(),
      where: 'id = ?',
      whereArgs: [chamado.id],
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // ── DELETE ─────────────────────────────────────────────────────────────────

  Future<int> deletarChamado(int id) async {
    final db = await database;
    return db.delete('chamados', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> limparTabela() async {
    final db = await database;
    await db.delete('chamados');
  }

  // ── CONTADORES (Dashboard) ─────────────────────────────────────────────────

  Future<int> contarChamados() async {
    final db = await database;
    final r = await db.rawQuery('SELECT COUNT(*) AS n FROM chamados');
    return Sqflite.firstIntValue(r) ?? 0;
  }

  Future<int> contarPorStatus(StatusChamado status) async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM chamados WHERE status = ?',
      [status.index],
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// Críticos = prioridade 3, independente de status
  /// (conforme databasedoc.md §6.4: WHERE prioridade = 3)
  Future<int> contarCriticos() async {
    final db = await database;
    final r = await db.rawQuery(
      'SELECT COUNT(*) AS n FROM chamados WHERE prioridade = ?',
      [PrioridadeChamado.critica.index], // = 3
    );
    return Sqflite.firstIntValue(r) ?? 0;
  }

  /// Verifica se já existe outro chamado com o mesmo título (case-insensitive)
  /// ignorandoId: passa o id do chamado que está sendo editado
  Future<bool> tituloJaExiste(String titulo, {int? ignorandoId}) async {
    final db = await database;
    String where = 'LOWER(titulo) = LOWER(?)';
    List<Object> args = [titulo];

    if (ignorandoId != null) {
      where += ' AND id != ?';
      args.add(ignorandoId);
    }

    final r = await db.query('chamados',
        columns: ['id'], where: where, whereArgs: args, limit: 1);
    return r.isNotEmpty;
  }

  // ── MISC ───────────────────────────────────────────────────────────────────

  Future<void> fecharBancoDados() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}
