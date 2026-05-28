import 'package:intl/intl.dart';

enum StatusChamado {
  aberto,
  emProgresso,
  aguardando,
  concluido,
}

enum PrioridadeChamado {
  baixa,
  media,
  alta,
  critica,
}

enum CategoriaChamado {
  asfalto,
  iluminacao,
  drenagem,
  calçada,
  manutenção,
  outro,
}

class ChamadoModel {
  final int? id;
  final String titulo;
  final String descricao;
  final CategoriaChamado categoria;
  final PrioridadeChamado prioridade;
  final String bairro;
  final String responsavel;
  final DateTime dataCriacao;
  final DateTime? dataResolucao;
  final StatusChamado status;
  final String? observacoes;

  ChamadoModel({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.dataCriacao,
    this.dataResolucao,
    required this.status,
    this.observacoes,
  });

  // Getters para auxiliar nas regras de negócio
  bool get isConcluido => status == StatusChamado.concluido;
  bool get isCritico => prioridade == PrioridadeChamado.critica;
  
  int get diasEmAberto {
    return DateTime.now().difference(dataCriacao).inDays;
  }

  String get statusTexto {
    switch (status) {
      case StatusChamado.aberto:
        return 'Aberto';
      case StatusChamado.emProgresso:
        return 'Em Progresso';
      case StatusChamado.aguardando:
        return 'Aguardando';
      case StatusChamado.concluido:
        return 'Concluído';
    }
  }

  String get prioridadeTexto {
    switch (prioridade) {
      case PrioridadeChamado.baixa:
        return 'Baixa';
      case PrioridadeChamado.media:
        return 'Média';
      case PrioridadeChamado.alta:
        return 'Alta';
      case PrioridadeChamado.critica:
        return 'Crítica';
    }
  }

  String get categoriaTexto {
    switch (categoria) {
      case CategoriaChamado.asfalto:
        return 'Asfalto';
      case CategoriaChamado.iluminacao:
        return 'Iluminação';
      case CategoriaChamado.drenagem:
        return 'Drenagem';
      case CategoriaChamado.calçada:
        return 'Calçada';
      case CategoriaChamado.manutenção:
        return 'Manutenção';
      case CategoriaChamado.outro:
        return 'Outro';
    }
  }

  String get dataCriacaoFormatada {
    return DateFormat('dd/MM/yyyy HH:mm').format(dataCriacao);
  }

  // Converter para JSON para salvamento
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'titulo': titulo,
      'descricao': descricao,
      'categoria': categoria.index,
      'prioridade': prioridade.index,
      'bairro': bairro,
      'responsavel': responsavel,
      'dataCriacao': dataCriacao.toIso8601String(),
      'dataResolucao': dataResolucao?.toIso8601String(),
      'status': status.index,
      'observacoes': observacoes,
    };
  }

  // Converter do JSON
  factory ChamadoModel.fromMap(Map<String, dynamic> map) {
    return ChamadoModel(
      id: map['id'] as int?,
      titulo: map['titulo'] as String,
      descricao: map['descricao'] as String,
      categoria: CategoriaChamado.values[map['categoria'] as int],
      prioridade: PrioridadeChamado.values[map['prioridade'] as int],
      bairro: map['bairro'] as String,
      responsavel: map['responsavel'] as String,
      dataCriacao: DateTime.parse(map['dataCriacao'] as String),
      dataResolucao: map['dataResolucao'] != null
          ? DateTime.parse(map['dataResolucao'] as String)
          : null,
      status: StatusChamado.values[map['status'] as int],
      observacoes: map['observacoes'] as String?,
    );
  }

  // Copy with para edições
  ChamadoModel copyWith({
    int? id,
    String? titulo,
    String? descricao,
    CategoriaChamado? categoria,
    PrioridadeChamado? prioridade,
    String? bairro,
    String? responsavel,
    DateTime? dataCriacao,
    DateTime? dataResolucao,
    StatusChamado? status,
    String? observacoes,
  }) {
    return ChamadoModel(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descricao: descricao ?? this.descricao,
      categoria: categoria ?? this.categoria,
      prioridade: prioridade ?? this.prioridade,
      bairro: bairro ?? this.bairro,
      responsavel: responsavel ?? this.responsavel,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      dataResolucao: dataResolucao ?? this.dataResolucao,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
    );
  }

  @override
  String toString() => 'ChamadoModel(id: $id, titulo: $titulo, status: $statusTexto)';
}
