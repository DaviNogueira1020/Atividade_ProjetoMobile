import 'package:sqlite3/sqlite3.dart';

import '../database/database.dart';
import '../models/ticket.dart';

class TicketRepository {
  final Database _db = DatabaseConnection.instance;

  Future<int> create(Ticket ticket) async {
    final stmt = _db.prepare('''
      INSERT INTO chamados (
        titulo,
        descricao,
        categoria,
        prioridade,
        status,
        bairro,
        responsavel,
        data_abertura,
        created_at,
        updated_at
      )
      VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    ''');

    stmt.execute([
      ticket.title,
      ticket.description,
      ticket.category.name,
      ticket.priority.index,
      ticket.status.index,
      ticket.neighborhood,
      ticket.responsible,
      ticket.openedAt.millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
      DateTime.now().millisecondsSinceEpoch,
    ]);

    stmt.dispose();

    final result = _db.select(
      'SELECT last_insert_rowid() AS id',
    );

    return result.first['id'] as int;
  }

  Ticket? findById(int id) {
    final result = _db.select(
      '''
      SELECT *
      FROM chamados
      WHERE id = ?
      ''',
      [id],
    );

    if (result.isEmpty) {
      return null;
    }

    return _mapToTicket(result.first);
  }

  List<Ticket> findAll() {
    final result = _db.select('''
      SELECT *
      FROM chamados
      ORDER BY prioridade DESC,
              data_abertura DESC
    ''');

    return result
        .map(_mapToTicket)
        .toList();
  }

  Ticket? findByTitle(String title) {
    final result = _db.select(
      '''
      SELECT *
      FROM chamados
      WHERE titulo = ?
      ''',
      [title],
    );

    if (result.isEmpty) {
      return null;
    }

    return _mapToTicket(result.first);
  }

  Future<void> update(Ticket ticket) async {
    _db.execute(
      '''
      UPDATE chamados
      SET
        titulo = ?,
        descricao = ?,
        categoria = ?,
        prioridade = ?,
        status = ?,
        bairro = ?,
        responsavel = ?,
        updated_at = ?
      WHERE id = ?
      ''',
      [
        ticket.title,
        ticket.description,
        ticket.category.name,
        ticket.priority.index,
        ticket.status.index,
        ticket.neighborhood,
        ticket.responsible,
        DateTime.now().millisecondsSinceEpoch,
        ticket.id,
      ],
    );
  }

  Future<void> delete(int id) async {
    _db.execute(
      '''
      DELETE FROM chamados
      WHERE id = ?
      ''',
      [id],
    );
  }

  int countAll() {
    final result = _db.select(
      '''
      SELECT COUNT(*) AS total
      FROM chamados
      ''',
    );

    return result.first['total'] as int;
  }

  int countCritical() {
    final result = _db.select(
      '''
      SELECT COUNT(*) AS total
      FROM chamados
      WHERE prioridade = 3
      ''',
    );

    return result.first['total'] as int;
  }

  int countByStatus(int status) {
    final result = _db.select(
      '''
      SELECT COUNT(*) AS total
      FROM chamados
      WHERE status = ?
      ''',
      [status],
    );

    return result.first['total'] as int;
  }

  Ticket _mapToTicket(Row row) {
    return Ticket.fromMap({
      'id': row['id'],
      'title': row['titulo'],
      'description': row['descricao'],
      'category': row['categoria'],
      'priority': row['prioridade'],
      'status': row['status'],
      'neighborhood': row['bairro'],
      'responsible': row['responsavel'],
      'opened_at': row['data_abertura'],
    });
  }
}