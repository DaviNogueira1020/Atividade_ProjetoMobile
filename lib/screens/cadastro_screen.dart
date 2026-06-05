import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../ai/gemini_service.dart';
import '../models/chamado_model.dart';
import '../providers/chamado_provider.dart';
import '../widgets/custom_textfield.dart';
import '../core/validators.dart';
import '../core/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final GeminiService _geminiService = GeminiService();
  static const String _prefixoPrazoIa = 'Prazo estimado (IA): ';
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _bairroController;
  late TextEditingController _responsavelController;
  late TextEditingController _observacoesController;

  CategoriaChamado? _categoriaSelected;
  PrioridadeChamado? _prioridadeSelected;
  StatusChamado _statusSelected = StatusChamado.aberto;
  bool _gerandoSugestaoIa = false;
  bool _prioridadePreenchidaPorIa = false;
  String? _prazoEstimadoIa;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _descricaoController = TextEditingController();
    _bairroController = TextEditingController();
    _responsavelController = TextEditingController();
    _observacoesController = TextEditingController();
  }

  Future<void> _sugerirComIa() async {
    if (_tituloController.text.trim().isEmpty ||
        _descricaoController.text.trim().isEmpty ||
        _bairroController.text.trim().isEmpty ||
        _categoriaSelected == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Preencha titulo, descricao, bairro e categoria para usar IA.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _gerandoSugestaoIa = true;
    });

    try {
      final sugestao = await _geminiService.gerarSugestaoParaChamado(
        titulo: _tituloController.text.trim(),
        descricao: _descricaoController.text.trim(),
        categoria: _categoriaSelected!.name,
        bairro: _bairroController.text.trim(),
      );
      final prioridadeSugerida = _extrairPrioridadeSugerida(sugestao);
      final prazoEstimado = _extrairPrazoEstimado(sugestao);

      if (!mounted) {
        return;
      }

      setState(() {
        _adicionarSugestaoNasObservacoes(sugestao);
        _aplicarPrioridadeSugerida(prioridadeSugerida);
        _aplicarPrazoNasObservacoes(prazoEstimado);
      });

      var mensagem = 'Sugestao da IA adicionada em observacoes.';
      if (prioridadeSugerida != null && prazoEstimado != null) {
        mensagem = 'IA aplicada: prioridade e prazo estimado preenchidos.';
      } else if (prioridadeSugerida != null) {
        mensagem = 'IA aplicada: prioridade preenchida automaticamente.';
      } else if (prazoEstimado != null) {
        mensagem = 'IA aplicada: prazo estimado registrado em observacoes.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(mensagem),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao consultar IA: $e')),
      );
    } finally {
      if (mounted) {
        setState(() {
          _gerandoSugestaoIa = false;
        });
      }
    }
  }

  void _aplicarPrioridadeSugerida(PrioridadeChamado? prioridade) {
    if (prioridade != null) {
      _prioridadeSelected = prioridade;
      _prioridadePreenchidaPorIa = true;
      return;
    }

    _prioridadePreenchidaPorIa = false;
  }

  void _adicionarSugestaoNasObservacoes(String sugestao) {
    final textoAtual = _observacoesController.text.trim();
    final blocoIa = 'Sugestao IA:\n$sugestao';

    if (textoAtual.isEmpty) {
      _observacoesController.text = blocoIa;
      return;
    }

    _observacoesController.text = '$textoAtual\n\n$blocoIa';
  }

  void _aplicarPrazoNasObservacoes(String? prazoEstimado) {
    if (prazoEstimado == null || prazoEstimado.trim().isEmpty) {
      _atualizarIndicadorPrazoIaPorObservacoes();
      return;
    }

    final textoAtual = _observacoesController.text.trim();
    final linhas = textoAtual.isEmpty ? <String>[] : textoAtual.split('\n');
    final novaLinhaPrazo = '$_prefixoPrazoIa$prazoEstimado';

    final indiceExistente = linhas.indexWhere(
      (linha) => linha.trimLeft().startsWith(_prefixoPrazoIa),
    );

    if (indiceExistente >= 0) {
      linhas[indiceExistente] = novaLinhaPrazo;
    } else {
      if (linhas.isNotEmpty && linhas.last.trim().isNotEmpty) {
        linhas.add('');
      }
      linhas.add(novaLinhaPrazo);
    }

    _observacoesController.text = linhas.join('\n').trim();
    _atualizarIndicadorPrazoIaPorObservacoes();
  }

  void _atualizarIndicadorPrazoIaPorObservacoes([String? texto]) {
    final conteudo = texto ?? _observacoesController.text;
    _prazoEstimadoIa = _extrairPrazoIaDasObservacoes(conteudo);
  }

  String? _extrairPrazoIaDasObservacoes(String texto) {
    if (texto.trim().isEmpty) {
      return null;
    }

    final linhas = texto.split('\n');
    for (final linha in linhas) {
      final limpa = linha.trimLeft();
      if (limpa.startsWith(_prefixoPrazoIa)) {
        final prazo = limpa.substring(_prefixoPrazoIa.length).trim();
        return prazo.isEmpty ? null : prazo;
      }
    }

    return null;
  }

  String? _extrairPrazoEstimado(String texto) {
    if (texto.trim().isEmpty) {
      return null;
    }

    final padraoPrazo = RegExp(
      r'prazo\s*estimado\s*[:\-]?\s*(.+)$',
      multiLine: true,
      caseSensitive: false,
    );
    final matchPrazo = padraoPrazo.firstMatch(texto);
    if (matchPrazo != null) {
      final valor = _limparTrechoExtraido(matchPrazo.group(1));
      if (valor != null) {
        return valor;
      }
    }

    final padraoItemTres = RegExp(
      r'^\s*3[\)\.:\-]\s*(.+)$',
      multiLine: true,
      caseSensitive: false,
    );
    final matchItemTres = padraoItemTres.firstMatch(texto);
    if (matchItemTres != null) {
      final linhaItem = (matchItemTres.group(1) ?? '').replaceFirst(
        RegExp(r'^prazo\s*estimado\s*[:\-]?\s*', caseSensitive: false),
        '',
      );
      return _limparTrechoExtraido(linhaItem);
    }

    return null;
  }

  String? _limparTrechoExtraido(String? trecho) {
    if (trecho == null) {
      return null;
    }

    final limpo = trecho
        .replaceAll(RegExp(r'^[\-\*\s]+'), '')
        .replaceAll('**', '')
        .trim();

    if (limpo.isEmpty) {
      return null;
    }

    return limpo;
  }

  String _textoPrioridade(PrioridadeChamado prioridade) {
    switch (prioridade) {
      case PrioridadeChamado.baixa:
        return 'Baixa';
      case PrioridadeChamado.media:
        return 'Media';
      case PrioridadeChamado.alta:
        return 'Alta';
      case PrioridadeChamado.critica:
        return 'Critica';
    }
  }

  PrioridadeChamado? _extrairPrioridadeSugerida(String texto) {
    if (texto.trim().isEmpty) {
      return null;
    }

    final normalizado = _normalizarTexto(texto);

    final padraoRotulo = RegExp(
      r'prioridade\s*sugerida\s*[:\-]\s*(baixa|media|alta|critica)\b',
      multiLine: true,
    );
    final matchRotulo = padraoRotulo.firstMatch(normalizado);
    if (matchRotulo != null) {
      return _mapearPrioridade(matchRotulo.group(1));
    }

    final padraoItemUm = RegExp(
      r'^\s*1[\)\.:\-]\s*(?:prioridade\s*sugerida\s*[:\-]?\s*)?(baixa|media|alta|critica)\b',
      multiLine: true,
    );
    final matchItemUm = padraoItemUm.firstMatch(normalizado);
    if (matchItemUm != null) {
      return _mapearPrioridade(matchItemUm.group(1));
    }

    final padraoPrimeiraLinha = RegExp(
      r'^\s*(baixa|media|alta|critica)\b',
      multiLine: true,
    );
    final matchPrimeiraLinha = padraoPrimeiraLinha.firstMatch(normalizado);
    if (matchPrimeiraLinha != null) {
      return _mapearPrioridade(matchPrimeiraLinha.group(1));
    }

    final limiteFallback =
        normalizado.length > 220 ? normalizado.substring(0, 220) : normalizado;
    return _buscarPrioridadePorPalavra(limiteFallback);
  }

  PrioridadeChamado? _mapearPrioridade(String? valor) {
    switch (valor) {
      case 'baixa':
        return PrioridadeChamado.baixa;
      case 'media':
        return PrioridadeChamado.media;
      case 'alta':
        return PrioridadeChamado.alta;
      case 'critica':
        return PrioridadeChamado.critica;
      default:
        return null;
    }
  }

  PrioridadeChamado? _buscarPrioridadePorPalavra(String texto) {
    final tokens = <String, PrioridadeChamado>{
      'critica': PrioridadeChamado.critica,
      'alta': PrioridadeChamado.alta,
      'media': PrioridadeChamado.media,
      'baixa': PrioridadeChamado.baixa,
    };

    for (final entry in tokens.entries) {
      final padrao = RegExp('\\b${entry.key}\\b');
      if (padrao.hasMatch(texto)) {
        return entry.value;
      }
    }

    return null;
  }

  String _normalizarTexto(String valor) {
    const mapaAcentos = <String, String>{
      'á': 'a',
      'à': 'a',
      'â': 'a',
      'ã': 'a',
      'é': 'e',
      'ê': 'e',
      'í': 'i',
      'ó': 'o',
      'ô': 'o',
      'õ': 'o',
      'ú': 'u',
      'ç': 'c',
    };

    final lower = valor.toLowerCase();
    final buffer = StringBuffer();

    for (final rune in lower.runes) {
      final char = String.fromCharCode(rune);
      buffer.write(mapaAcentos[char] ?? char);
    }

    return buffer.toString();
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _bairroController.dispose();
    _responsavelController.dispose();
    _observacoesController.dispose();
    super.dispose();
  }

  void _salvarChamado() {
    if (_formKey.currentState!.validate()) {
      if (_categoriaSelected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma categoria')),
        );
        return;
      }
      if (_prioridadeSelected == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selecione uma prioridade')),
        );
        return;
      }

      final chamado = ChamadoModel(
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        categoria: _categoriaSelected!,
        prioridade: _prioridadeSelected!,
        bairro: _bairroController.text,
        responsavel: _responsavelController.text,
        dataCriacao: DateTime.now(),
        status: _statusSelected,
        observacoes: _observacoesController.text.isEmpty ? null : _observacoesController.text,
      );

      context.read<ChamadoProvider>().adicionarChamado(chamado).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Chamado cadastrado com sucesso!')),
        );
        Navigator.of(context).pop();
      }).catchError((e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro: $e')),
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Chamado'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título
              CustomTextField(
                label: 'Título',
                hint: 'Ex: Buraco na rua',
                controller: _tituloController,
                validator: Validators.validarTitulo,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),

              // Descrição
              CustomTextField(
                label: 'Descrição',
                hint: 'Descreva o problema com detalhes',
                controller: _descricaoController,
                validator: Validators.validarDescricao,
                maxLines: 4,
                minLines: 3,
                prefixIcon: Icons.description,
              ),
              const SizedBox(height: 16),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _gerandoSugestaoIa ? null : _sugerirComIa,
                  icon: _gerandoSugestaoIa
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.auto_awesome),
                  label: Text(
                    _gerandoSugestaoIa
                        ? 'Gerando sugestao da IA...'
                        : 'Sugerir com IA',
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Categoria
              Text(
                'Categoria',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoriaChamado>(
                initialValue: _categoriaSelected,
                decoration: InputDecoration(
                  hintText: 'Selecione uma categoria',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.category),
                ),
                items: CategoriaChamado.values.map((categoria) {
                  return DropdownMenuItem(
                    value: categoria,
                    child: Text(ChamadoModel(
                      titulo: '',
                      descricao: '',
                      categoria: categoria,
                      prioridade: PrioridadeChamado.baixa,
                      bairro: '',
                      responsavel: '',
                      dataCriacao: DateTime.now(),
                      status: StatusChamado.aberto,
                    ).categoriaTexto),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _categoriaSelected = value;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Prioridade
              Text(
                'Prioridade',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<PrioridadeChamado>(
                initialValue: _prioridadeSelected,
                decoration: InputDecoration(
                  hintText: 'Selecione a prioridade',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.priority_high),
                ),
                items: PrioridadeChamado.values.map((prioridade) {
                  return DropdownMenuItem(
                    value: prioridade,
                    child: Text(ChamadoModel(
                      titulo: '',
                      descricao: '',
                      categoria: CategoriaChamado.outro,
                      prioridade: prioridade,
                      bairro: '',
                      responsavel: '',
                      dataCriacao: DateTime.now(),
                      status: StatusChamado.aberto,
                    ).prioridadeTexto),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _prioridadeSelected = value;
                    _prioridadePreenchidaPorIa = false;
                  });
                },
              ),
              if (_prioridadePreenchidaPorIa && _prioridadeSelected != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.corSecundaria.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.corSecundaria.withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        size: 18,
                        color: AppTheme.corSecundaria,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prioridade sugerida pela IA: ${_textoPrioridade(_prioridadeSelected!)}',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.corSecundaria,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),

              // Bairro
              CustomTextField(
                label: 'Bairro',
                hint: 'Bairro onde ocorre o problema',
                controller: _bairroController,
                validator: Validators.validarBairro,
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              // Responsável
              CustomTextField(
                label: 'Responsável',
                hint: 'Nome de quem está reportando',
                controller: _responsavelController,
                validator: Validators.validarResponsavel,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Observações
              CustomTextField(
                label: 'Observações (Opcional)',
                hint: 'Informações adicionais',
                controller: _observacoesController,
                validator: Validators.validarObservacoes,
                maxLines: 3,
                prefixIcon: Icons.note,
                onChanged: (value) {
                  setState(() {
                    _atualizarIndicadorPrazoIaPorObservacoes(value);
                  });
                },
              ),
              if (_prazoEstimadoIa != null) ...[
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.corPrimaria.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.corPrimaria.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 18,
                        color: AppTheme.corPrimaria,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Prazo estimado pela IA: $_prazoEstimadoIa',
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.corPrimaria,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),

              // Botões
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _salvarChamado,
                      child: const Text('Salvar Chamado'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
