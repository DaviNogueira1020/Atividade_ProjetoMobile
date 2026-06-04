import 'package:flutter/foundation.dart';
import '../models/chamado_model.dart';
import '../database/database_helper.dart';

class ChamadoProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper();
  
  List<ChamadoModel> _chamados = [];
  int _totalChamados = 0;
  int _totalChamadasAbertas = 0;
  int _totalChamadosEmProgresso = 0;
  int _totalChamadosCriticos = 0;
  bool _carregando = false;
  String? _erro;

  // Getters
  List<ChamadoModel> get chamados => _chamados;
  int get totalChamados => _totalChamados;
  int get totalChamadasAbertas => _totalChamadasAbertas;
  int get totalChamadosEmProgresso => _totalChamadosEmProgresso;
  int get totalChamadosCriticos => _totalChamadosCriticos;
  bool get carregando => _carregando;
  String? get erro => _erro;

  // Chamados ordenados por prioridade e status
  List<ChamadoModel> get chamadosOrdenados {
    final sorted = [..._chamados];
    sorted.sort((a, b) {
      // Críticos no topo
      if (a.isCritico && !b.isCritico) return -1;
      if (!a.isCritico && b.isCritico) return 1;
      
      // Depois alta prioridade
      if (a.prioridade.index < b.prioridade.index) return -1;
      if (a.prioridade.index > b.prioridade.index) return 1;
      
      // Depois por data (mais recentes no topo)
      return b.dataCriacao.compareTo(a.dataCriacao);
    });
    return sorted;
  }

  // Apenas chamados críticos
  List<ChamadoModel> get chamadosCriticos {
    return _chamados.where((c) => c.isCritico && !c.isConcluido).toList();
  }

  // Carrega todos os dados
  Future<void> carregarDados() async {
    _carregando = true;
    _erro = null;
    notifyListeners();

    try {
      _chamados = await _db.obterTodosChamados();
      _totalChamados = await _db.contarChamados();
      _totalChamadasAbertas = await _db.contarChamadosPorStatus(StatusChamado.aberto.index);
      _totalChamadosEmProgresso = await _db.contarChamadosPorStatus(StatusChamado.emProgresso.index);
      _totalChamadosCriticos = await _db.contarChamadosCriticos();
      _carregando = false;
    } catch (e) {
      _erro = 'Erro ao carregar dados: $e';
      _carregando = false;
    }
    notifyListeners();
  }

  // Adiciona novo chamado
  Future<void> adicionarChamado(ChamadoModel chamado) async {
    try {
      final id = await _db.inserirChamado(chamado);
      final novoChamado = chamado.copyWith(id: id);
      _chamados.add(novoChamado);
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao adicionar chamado: $e';
      notifyListeners();
    }
  }

  // Atualiza um chamado
  Future<void> atualizarChamado(ChamadoModel chamado) async {
    try {
      await _db.atualizarChamado(chamado);
      final index = _chamados.indexWhere((c) => c.id == chamado.id);
      if (index != -1) {
        _chamados[index] = chamado;
      }
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao atualizar chamado: $e';
      notifyListeners();
    }
  }

  // Deleta um chamado
  Future<void> deletarChamado(int id) async {
    try {
      await _db.deletarChamado(id);
      _chamados.removeWhere((c) => c.id == id);
      await _atualizarContadores();
      _erro = null;
      notifyListeners();
    } catch (e) {
      _erro = 'Erro ao deletar chamado: $e';
      notifyListeners();
    }
  }

  // Atualiza status de um chamado
  Future<void> atualizarStatus(int id, StatusChamado novoStatus) async {
    try {
      final index = _chamados.indexWhere((c) => c.id == id);
      if (index != -1) {
        final chamado = _chamados[index];
        
        // Regra: não edita concluído
        if (chamado.isConcluido && novoStatus != StatusChamado.concluido) {
          _erro = 'Chamados concluídos não podem ser alterados';
          notifyListeners();
          return;
        }

        final dataResolucao = novoStatus == StatusChamado.concluido ? DateTime.now() : null;
        final chamadoAtualizado = chamado.copyWith(
          status: novoStatus,
          dataResolucao: dataResolucao,
        );
        
        await _db.atualizarChamado(chamadoAtualizado);
        _chamados[index] = chamadoAtualizado;
        await _atualizarContadores();
        _erro = null;
        notifyListeners();
      }
    } catch (e) {
      _erro = 'Erro ao atualizar status: $e';
      notifyListeners();
    }
  }

  // Filtra por categoria
  List<ChamadoModel> filtrarPorCategoria(CategoriaChamado categoria) {
    return _chamados.where((c) => c.categoria == categoria).toList();
  }

  // Filtra por bairro
  List<ChamadoModel> filtrarPorBairro(String bairro) {
    return _chamados.where((c) => c.bairro.toLowerCase().contains(bairro.toLowerCase())).toList();
  }

  // Busca por título ou descrição
  List<ChamadoModel> buscar(String termo) {
    final termoBuscaLower = termo.toLowerCase();
    return _chamados.where((c) =>
      c.titulo.toLowerCase().contains(termoBuscaLower) ||
      c.descricao.toLowerCase().contains(termoBuscaLower)
    ).toList();
  }

  // Atualiza contadores do dashboard
  Future<void> _atualizarContadores() async {
    _totalChamados = await _db.contarChamados();
    _totalChamadasAbertas = await _db.contarChamadosPorStatus(StatusChamado.aberto.index);
    _totalChamadosEmProgresso = await _db.contarChamadosPorStatus(StatusChamado.emProgresso.index);
    _totalChamadosCriticos = await _db.contarChamadosCriticos();
  }

  // Alerta: mais de 5 críticos
  bool get temAlerta => _totalChamadosCriticos > 5;
}
