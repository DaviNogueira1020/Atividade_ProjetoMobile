// lib/models/chamado_model.dart
//
// ⚠️  ATENÇÃO AO TIME:
//   - Prioridade e Status são INTEGER no banco (conforme databasedoc.md).
//   - Categoria é TEXT no banco (ex: "transito", "limpeza_urbana").
//   - Datas são epoch millis INTEGER (DateTime.millisecondsSinceEpoch).
//   - Título tem UNIQUE constraint no banco → não deixar duplicar aqui.

import 'package:intl/intl.dart';

// ─── Enums ────────────────────────────────────────────────────────────────────

/// Status armazenado como INTEGER no banco: 0 = aberto, 1 = emAndamento, 2 = concluido
enum StatusChamado {
  aberto,       // 0
  emAndamento,  // 1
  concluido;    // 2

  String get label {
    switch (this) {
      case StatusChamado.aberto:      return 'Aberto';
      case StatusChamado.emAndamento: return 'Em Andamento';
      case StatusChamado.concluido:   return 'Concluído';
    }
  }
}

/// Prioridade armazenada como INTEGER: 0 = baixa … 3 = critica
/// ORDER BY prioridade DESC coloca crítica no topo.
enum PrioridadeChamado {
  baixa,   // 0
  media,   // 1
  alta,    // 2
  critica; // 3

  String get label {
    switch (this) {
      case PrioridadeChamado.baixa:   return 'Baixa';
      case PrioridadeChamado.media:   return 'Média';
      case PrioridadeChamado.alta:    return 'Alta';
      case PrioridadeChamado.critica: return 'Crítica';
    }
  }
}

/// Categoria armazenada como TEXT (ex: "transito") — conforme databasedoc.md
enum CategoriaChamado {
  transito,       // "transito"
  iluminacao,     // "iluminacao"
  saneamento,     // "saneamento"
  seguranca,      // "seguranca"
  limpezaUrbana,  // "limpeza_urbana"
  desastreNatural; // "desastre_natural"

  /// Valor gravado no banco (TEXT)
  String get dbValue {
    switch (this) {
      case CategoriaChamado.transito:        return 'transito';
      case CategoriaChamado.iluminacao:      return 'iluminacao';
      case CategoriaChamado.saneamento:      return 'saneamento';
      case CategoriaChamado.seguranca:       return 'seguranca';
      case CategoriaChamado.limpezaUrbana:   return 'limpeza_urbana';
      case CategoriaChamado.desastreNatural: return 'desastre_natural';
    }
  }

  String get label {
    switch (this) {
      case CategoriaChamado.transito:        return 'Trânsito';
      case CategoriaChamado.iluminacao:      return 'Iluminação';
      case CategoriaChamado.saneamento:      return 'Saneamento';
      case CategoriaChamado.seguranca:       return 'Segurança';
      case CategoriaChamado.limpezaUrbana:   return 'Limpeza Urbana';
      case CategoriaChamado.desastreNatural: return 'Desastre Natural';
    }
  }

  static CategoriaChamado fromDbValue(String value) {
    return CategoriaChamado.values.firstWhere((e) => e.dbValue == value);
  }
}

// ─── Model ────────────────────────────────────────────────────────────────────

class ChamadoModel {
  final int? id;
  final String titulo;
  final String descricao;
  final CategoriaChamado categoria;
  final PrioridadeChamado prioridade;
  final StatusChamado status;
  final String bairro;
  final String responsavel;
  final DateTime dataAbertura; // = data_abertura no banco (epoch millis)
  final DateTime createdAt;
  final DateTime updatedAt;

  const ChamadoModel({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.status,
    required this.bairro,
    required this.responsavel,
    required this.dataAbertura,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Getters auxiliares ─────────────────────────────────────────────────────

  bool get isConcluido => status == StatusChamado.concluido;
  bool get isCritico   => prioridade == PrioridadeChamado.critica;
  bool get isAltaOuCritica =>
      prioridade == PrioridadeChamado.alta ||
      prioridade == PrioridadeChamado.critica;

  /// Tempo decorrido desde a abertura — calculado em runtime, nunca armazenado
  Duration get tempoAberto => DateTime.now().difference(dataAbertura);

  String get tempoAbertFormatado {
    final d = tempoAberto;
    if (d.inDays > 0)  return '${d.inDays}d ${d.inHours.remainder(24)}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes.remainder(60)}min';
    return '${d.inMinutes}min';
  }

  String get dataAberturaFormatada =>
      DateFormat('dd/MM/yyyy HH:mm').format(dataAbertura);

  // ── Serialização ───────────────────────────────────────────────────────────

  /// Para gravar no SQLite
  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'titulo':        titulo,
        'descricao':     descricao,
        'categoria':     categoria.dbValue,          // TEXT
        'prioridade':    prioridade.index,            // INTEGER 0-3
        'status':        status.index,                // INTEGER 0-2
        'bairro':        bairro,
        'responsavel':   responsavel,
        'data_abertura': dataAbertura.millisecondsSinceEpoch,
        'created_at':    createdAt.millisecondsSinceEpoch,
        'updated_at':    updatedAt.millisecondsSinceEpoch,
      };

  /// Para ler do SQLite
  factory ChamadoModel.fromMap(Map<String, dynamic> map) => ChamadoModel(
        id:           map['id'] as int?,
        titulo:       map['titulo'] as String,
        descricao:    map['descricao'] as String,
        categoria:    CategoriaChamado.fromDbValue(map['categoria'] as String),
        prioridade:   PrioridadeChamado.values[map['prioridade'] as int],
        status:       StatusChamado.values[map['status'] as int],
        bairro:       map['bairro'] as String,
        responsavel:  map['responsavel'] as String,
        dataAbertura: DateTime.fromMillisecondsSinceEpoch(map['data_abertura'] as int),
        createdAt:    DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
        updatedAt:    DateTime.fromMillisecondsSinceEpoch(map['updated_at'] as int),
      );

  /// Para edições parciais
  ChamadoModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    CategoriaChamado? categoria,
    PrioridadeChamado? prioridade,
    StatusChamado? status,
    String? bairro,
    String? responsavel,
    DateTime? dataAbertura,
    DateTime? updatedAt,
  }) =>
      ChamadoModel(
        id:           id ?? this.id,
        titulo:       titulo ?? this.titulo,
        descricao:    descricao ?? this.descricao,
        categoria:    categoria ?? this.categoria,
        prioridade:   prioridade ?? this.prioridade,
        status:       status ?? this.status,
        bairro:       bairro ?? this.bairro,
        responsavel:  responsavel ?? this.responsavel,
        dataAbertura: dataAbertura ?? this.dataAbertura,
        createdAt:    createdAt,
        updatedAt:    updatedAt ?? DateTime.now(),
      );

  @override
  String toString() =>
      'ChamadoModel(id: $id, titulo: "$titulo", status: ${status.label})';
}
