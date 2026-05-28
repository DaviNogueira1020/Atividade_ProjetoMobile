// lib/providers/chamado_provider.dart
//
// Regras de negócio implementadas aqui:
//   ✅ Críticos + alta prioridade no topo (ORDER BY no banco, replicado na ordenação local)
//   ✅ Alerta visual quando > 5 críticos
//   ✅ Título não pode repetir (valida antes de inserir)
//   ✅ Descrição e bairro não podem ser vazios
//   ✅ Chamado concluído não pode ser editado
//   ✅ Tempo desde abertura calculado no model (não armazenado)

import 'package:flutter/foundation.dart';
import '../models/chamado_model.dart';
import '../database/database_helper.dart';

class ChamadoProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();

  // ── Estado ──────────────────────────────────────────────────────────────────
  List<ChamadoModel> _chamados = [];
  bool _carregando = false;
  String? _erro;

  // Contadores do dashboard
  int _totalChamados       = 0;
  int _totalAbertos        = 0;
  int _totalEmAndamento    = 0;
  int _totalConcluidos     = 0;
  int _totalCriticos       = 0;

  // ── Getters ─────────────────────────────────────────────────────────────────
  List<ChamadoModel> get chamados    => List.unmodifiable(_chamados);
  bool               get carregando  => _carregando;
  String?            get erro        => _erro;
  int get totalChamados              => _totalChamados;
  int get totalAbertos               => _totalAbertos;
  int get totalEmAndamento           => _totalEmAndamento;
  int get totalConcluidos            => _totalConcluidos;
  int get totalCriticos              => _totalCriticos;

  /// Alerta visual: mais de 5 críticos (conforme requisito)
  bool get temAlertaCriticos => _totalCriticos > 5;

  /// Lista já ordenada: crítica > alta > média > baixa, depois data desc
  List<ChamadoModel> get chamadosOrdenados {
    final lista = [..._chamados];
    lista.sort((a, b) {
      final cmp = b.prioridade.index.compareTo(a.prioridade.index);
      if (cmp != 0) return cmp;
      return b.dataAbertura.compareTo(a.dataAbertura);
    });
    return lista;
  }

  // ── Carregamento ────────────────────────────────────────────────────────────

  Future<void> carregarDados() async {
    _setCarregando(true);
    try {
      _chamados = await _db.obterTodosChamados();
      await _atualizarContadores();
      _erro = null;
    } catch (e) {
      _erro = 'Erro ao carregar dados: $e';
    } finally {
      _setCarregando(false);
    }
  }

  // ── Adicionar ───────────────────────────────────────────────────────────────

  /// Retorna null em caso de sucesso, ou a mensagem de erro.
  Future<String?> adicionarChamado({
    required String titulo,
    required String descricao,
    required CategoriaChamado categoria,
    required PrioridadeChamado prioridade,
    required String bairro,
    required String responsavel,
  }) async {
    // Validações
    final erroValidacao = _validar(
      titulo: titulo,
      descricao: descricao,
      bairro: bairro,
      responsavel: responsavel,
    );
    if (erroValidacao != null) return erroValidacao;

    // Regra: título único
    if (await _db.tituloJaExiste(titulo.trim())) {
      return 'Já existe um chamado com este título.';
    }

    final agora = DateTime.now();
    final chamado = ChamadoModel(
      titulo:       titulo.trim(),
      descricao:    descricao.trim(),
      categoria:    categoria,
      prioridade:   prioridade,
      status:       StatusChamado.aberto,
      bairro:       bairro.trim(),
      responsavel:  responsavel.trim(),
      dataAbertura: agora,
      createdAt:    agora,
      updatedAt:    agora,
    );

    try {
      final id = await _db.inserirChamado(chamado);
      _chamados.add(chamado.copyWith(id: id));
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao salvar chamado: $e';
    }
  }

  // ── Atualizar ───────────────────────────────────────────────────────────────

  Future<String?> atualizarChamado({
    required ChamadoModel original,
    required String titulo,
    required String descricao,
    required CategoriaChamado categoria,
    required PrioridadeChamado prioridade,
    required StatusChamado status,
    required String bairro,
    required String responsavel,
  }) async {
    // Regra: concluído não pode ser editado
    if (original.isConcluido) {
      return 'Chamados concluídos não podem ser editados.';
    }

    final erroValidacao = _validar(
      titulo: titulo,
      descricao: descricao,
      bairro: bairro,
      responsavel: responsavel,
    );
    if (erroValidacao != null) return erroValidacao;

    // Regra: título único (ignorando o próprio chamado)
    if (await _db.tituloJaExiste(titulo.trim(), ignorandoId: original.id)) {
      return 'Já existe um chamado com este título.';
    }

    final atualizado = original.copyWith(
      titulo:      titulo.trim(),
      descricao:   descricao.trim(),
      categoria:   categoria,
      prioridade:  prioridade,
      status:      status,
      bairro:      bairro.trim(),
      responsavel: responsavel.trim(),
      updatedAt:   DateTime.now(),
    );

    try {
      await _db.atualizarChamado(atualizado);
      final idx = _chamados.indexWhere((c) => c.id == original.id);
      if (idx != -1) _chamados[idx] = atualizado;
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao atualizar chamado: $e';
    }
  }

  /// Atalho para mudar só o status
  Future<String?> atualizarStatus(int id, StatusChamado novoStatus) async {
    final chamado = _chamados.firstWhere((c) => c.id == id,
        orElse: () => throw StateError('Chamado não encontrado'));

    // Regra: concluído não pode ser editado
    if (chamado.isConcluido) {
      return 'Chamados concluídos não podem ter o status alterado.';
    }

    return atualizarChamado(
      original:    chamado,
      titulo:      chamado.titulo,
      descricao:   chamado.descricao,
      categoria:   chamado.categoria,
      prioridade:  chamado.prioridade,
      status:      novoStatus,
      bairro:      chamado.bairro,
      responsavel: chamado.responsavel,
    );
  }

  // ── Deletar ─────────────────────────────────────────────────────────────────

  Future<String?> deletarChamado(int id) async {
    try {
      await _db.deletarChamado(id);
      _chamados.removeWhere((c) => c.id == id);
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
      return null;
    } catch (e) {
      return 'Erro ao deletar: $e';
    }
  }

  // ── Filtros (em memória — rápidos para protótipo) ────────────────────────────

  List<ChamadoModel> filtrarPorCategoria(CategoriaChamado categoria) =>
      _chamados.where((c) => c.categoria == categoria).toList();

  List<ChamadoModel> filtrarPorBairro(String bairro) => _chamados
      .where((c) => c.bairro.toLowerCase().contains(bairro.toLowerCase()))
      .toList();

  List<ChamadoModel> filtrarPorStatus(StatusChamado status) =>
      _chamados.where((c) => c.status == status).toList();

  List<ChamadoModel> buscar(String termo) {
    if (termo.trim().isEmpty) return chamadosOrdenados;
    final t = termo.toLowerCase();
    return _chamados
        .where((c) =>
            c.titulo.toLowerCase().contains(t) ||
            c.descricao.toLowerCase().contains(t) ||
            c.bairro.toLowerCase().contains(t))
        .toList();
  }

  // ── Helpers privados ────────────────────────────────────────────────────────

  String? _validar({
    required String titulo,
    required String descricao,
    required String bairro,
    required String responsavel,
  }) {
    if (titulo.trim().isEmpty)      return 'O título é obrigatório.';
    if (descricao.trim().isEmpty)   return 'A descrição não pode estar vazia.';
    if (bairro.trim().isEmpty)      return 'O bairro é obrigatório.';
    if (responsavel.trim().isEmpty) return 'O responsável é obrigatório.';
    return null;
  }

  Future<void> _atualizarContadores() async {
    _totalChamados    = await _db.contarChamados();
    _totalAbertos     = await _db.contarPorStatus(StatusChamado.aberto);
    _totalEmAndamento = await _db.contarPorStatus(StatusChamado.emAndamento);
    _totalConcluidos  = await _db.contarPorStatus(StatusChamado.concluido);
    _totalCriticos    = await _db.contarCriticos();
  }

  void _setCarregando(bool v) {
    _carregando = v;
    notifyListeners();
  }
}
