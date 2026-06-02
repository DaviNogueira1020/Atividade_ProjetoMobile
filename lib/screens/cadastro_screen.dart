import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/chamado_model.dart';
import '../providers/chamado_provider.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  final _bairroController = TextEditingController();

  CategoriaChamado? _categoriaSelecionada;
  PrioridadeChamado _prioridadeSelecionada = PrioridadeChamado.media;
  String? _responsavelSelecionado;
  bool _formEnviado = false;
  bool _salvando = false;

  static const _background = Color(0xFFF5F7F8);
  static const _dark = Color(0xFF303841);
  static const _teal = Color(0xFF4E8B8E);
  static const _tealSoft = Color(0xFFE8F4F5);
  static const _orange = Color(0xFFFF5722);
  static const _border = Color(0xFFD0D5DB);
  static const _muted = Color(0xFF7A8A96);

  static const _responsaveis = [
    'Secretaria de Obras',
    'Secretaria de Saude',
    'Secretaria de Seguranca',
    'Secretaria de Meio Ambiente',
    'Defesa Civil',
    'SAMU',
    'Companhia de Saneamento',
  ];

  @override
  void dispose() {
    _tituloController.dispose();
    _descricaoController.dispose();
    _bairroController.dispose();
    super.dispose();
  }

  Future<void> _salvarChamado() async {
    setState(() => _formEnviado = true);

    final formValido = _formKey.currentState?.validate() ?? false;
    final selecoesValidas =
        _categoriaSelecionada != null && _responsavelSelecionado != null;

    if (!formValido || !selecoesValidas) {
      _mostrarErro('Preencha todos os campos obrigatorios.');
      return;
    }

    setState(() => _salvando = true);

    final erro = await context.read<ChamadoProvider>().adicionarChamado(
      titulo: _tituloController.text,
      descricao: _descricaoController.text,
      categoria: _categoriaSelecionada!,
      prioridade: _prioridadeSelecionada,
      bairro: _bairroController.text,
      responsavel: _responsavelSelecionado!,
    );

    if (!mounted) return;

    setState(() => _salvando = false);

    if (erro != null) {
      _mostrarErro(erro);
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chamado cadastrado com sucesso!')),
    );
    Navigator.of(context).pop();
  }

  void _mostrarErro(String mensagem) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning_amber_rounded, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(child: Text(mensagem)),
          ],
        ),
        backgroundColor: _orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  String? _validarTitulo(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Titulo nao pode estar vazio';
    if (texto.length < 5) return 'Titulo muito curto';
    return null;
  }

  String? _validarDescricao(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Descricao nao pode estar vazia';
    if (texto.length < 10) return 'Descricao muito curta';
    return null;
  }

  String? _validarBairro(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Bairro nao pode estar vazio';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _background,
      body: Column(
        children: [
          _Header(onBack: () => Navigator.of(context).pop()),
          Container(height: 4, color: _teal),
          Expanded(
            child: Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 120),
                children: [
                  _buildCriticoAlert(),
                  _buildSectionLabel('Identificacao'),
                  _buildTituloField(),
                  const SizedBox(height: 14),
                  _buildDescricaoField(),
                  _buildDivider(),
                  _buildSectionLabel('Categorizacao'),
                  _buildCategoriaGrid(),
                  if (_formEnviado && _categoriaSelecionada == null)
                    _buildInlineError('Selecione uma categoria'),
                  const SizedBox(height: 16),
                  _buildPrioridadeChips(),
                  const SizedBox(height: 16),
                  _buildStatusInfo(),
                  _buildDivider(),
                  _buildSectionLabel('Localizacao e responsavel'),
                  _buildBairroField(),
                  const SizedBox(height: 14),
                  _buildResponsavelDropdown(),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _buildSaveButton(),
    );
  }

  Widget _buildCriticoAlert() {
    if (_prioridadeSelecionada != PrioridadeChamado.critica) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0EB),
        border: Border.all(color: const Color(0xFFFFB39A)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.priority_high_rounded, color: _orange, size: 20),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Chamados criticos sao destacados no dashboard.',
              style: TextStyle(
                color: Color(0xFFB84000),
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTituloField() {
    final valido = _tituloController.text.trim().length >= 5;

    return _FieldBlock(
      label: 'Titulo',
      child: TextFormField(
        controller: _tituloController,
        onChanged: (_) => setState(() {}),
        validator: _validarTitulo,
        autovalidateMode: _formEnviado
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        decoration: _inputDecoration(
          hint: 'Ex: Buraco na Av. Principal',
          suffix: valido
              ? const Icon(Icons.check_circle_outline, color: _teal, size: 18)
              : null,
        ),
      ),
    );
  }

  Widget _buildDescricaoField() {
    return _FieldBlock(
      label: 'Descricao',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _descricaoController,
            onChanged: (_) => setState(() {}),
            validator: _validarDescricao,
            autovalidateMode: _formEnviado
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            maxLines: 4,
            maxLength: 500,
            decoration: _inputDecoration(
              hint: 'Descreva o problema com detalhes...',
            ),
          ),
          const Text(
            'Informe local, risco e qualquer detalhe util para a equipe.',
            style: TextStyle(color: _muted, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildBairroField() {
    return _FieldBlock(
      label: 'Bairro',
      child: TextFormField(
        controller: _bairroController,
        onChanged: (_) => setState(() {}),
        validator: _validarBairro,
        autovalidateMode: _formEnviado
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        decoration: _inputDecoration(hint: 'Ex: Centro, Jardim America...'),
      ),
    );
  }

  Widget _buildCategoriaGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      childAspectRatio: 3.05,
      children: CategoriaChamado.values.map((categoria) {
        final selecionada = _categoriaSelecionada == categoria;

        return InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _categoriaSelecionada = categoria),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: selecionada ? _tealSoft : Colors.white,
              border: Border.all(
                color: selecionada ? _teal : _border,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: selecionada ? _teal : const Color(0xFFEEF1F4),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _categoriaIcon(categoria),
                    size: 16,
                    color: selecionada ? Colors.white : _dark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    categoria.label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selecionada ? _teal : _dark,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPrioridadeChips() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFieldLabel('Prioridade'),
        const SizedBox(height: 4),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: PrioridadeChamado.values.map((prioridade) {
            final selecionada = _prioridadeSelecionada == prioridade;
            final cor = _priorityColor(prioridade);

            return ChoiceChip(
              label: Text(prioridade.label),
              selected: selecionada,
              onSelected: (_) {
                setState(() => _prioridadeSelecionada = prioridade);
              },
              selectedColor: cor,
              backgroundColor: _priorityBackground(prioridade),
              side: BorderSide(color: cor, width: selecionada ? 2 : 1),
              labelStyle: TextStyle(
                color: selecionada ? Colors.white : cor,
                fontWeight: FontWeight.w700,
              ),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildStatusInfo() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE6F1FB),
        border: Border.all(color: const Color(0xFF85B7EB)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Row(
        children: [
          Icon(Icons.radio_button_checked, color: Color(0xFF185FA5), size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Status inicial: Aberto',
              style: TextStyle(
                color: Color(0xFF185FA5),
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsavelDropdown() {
    return _FieldBlock(
      label: 'Responsavel',
      child: DropdownButtonFormField<String>(
        initialValue: _responsavelSelecionado,
        isExpanded: true,
        hint: const Text(
          'Selecione o responsavel',
          style: TextStyle(color: Color(0xFFB0BCC5), fontSize: 14),
        ),
        decoration: _inputDecoration(hint: ''),
        validator: (value) => value == null ? 'Selecione o responsavel' : null,
        autovalidateMode: _formEnviado
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        onChanged: (value) {
          setState(() => _responsavelSelecionado = value);
        },
        items: _responsaveis
            .map(
              (responsavel) => DropdownMenuItem(
                value: responsavel,
                child: Text(responsavel),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildSaveButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: ElevatedButton(
          onPressed: _salvando ? null : _salvarChamado,
          style: ElevatedButton.styleFrom(
            backgroundColor: _dark,
            foregroundColor: Colors.white,
            disabledBackgroundColor: _dark.withValues(alpha: 0.65),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: _salvando
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.4,
                    color: Colors.white,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_rounded, size: 21),
                    SizedBox(width: 10),
                    Text(
                      'Salvar Chamado',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: _teal,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: _dark,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            width: 5,
            height: 5,
            decoration: const BoxDecoration(
              color: _orange,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInlineError(String message) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        children: [
          const Icon(Icons.error_outline, size: 14, color: _orange),
          const SizedBox(width: 4),
          Text(
            message,
            style: const TextStyle(
              color: _orange,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(vertical: 18),
      color: const Color(0xFFE5EAEE),
    );
  }

  InputDecoration _inputDecoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFFB0BCC5), fontSize: 14),
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _orange, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _orange, width: 2),
      ),
      errorStyle: const TextStyle(
        color: _orange,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  IconData _categoriaIcon(CategoriaChamado categoria) {
    switch (categoria) {
      case CategoriaChamado.transito:
        return Icons.traffic_rounded;
      case CategoriaChamado.iluminacao:
        return Icons.lightbulb_outline_rounded;
      case CategoriaChamado.saneamento:
        return Icons.water_drop_outlined;
      case CategoriaChamado.seguranca:
        return Icons.shield_outlined;
      case CategoriaChamado.limpezaUrbana:
        return Icons.cleaning_services_outlined;
      case CategoriaChamado.desastreNatural:
        return Icons.crisis_alert_rounded;
    }
  }

  Color _priorityColor(PrioridadeChamado prioridade) {
    switch (prioridade) {
      case PrioridadeChamado.baixa:
        return const Color(0xFF3A7D44);
      case PrioridadeChamado.media:
        return const Color(0xFF7A6000);
      case PrioridadeChamado.alta:
        return const Color(0xFFB85000);
      case PrioridadeChamado.critica:
        return _orange;
    }
  }

  Color _priorityBackground(PrioridadeChamado prioridade) {
    switch (prioridade) {
      case PrioridadeChamado.baixa:
        return const Color(0xFFEAF5EC);
      case PrioridadeChamado.media:
        return const Color(0xFFFEF9E2);
      case PrioridadeChamado.alta:
        return const Color(0xFFFFF3E8);
      case PrioridadeChamado.critica:
        return const Color(0xFFFFF0EB);
    }
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onBack;

  const _Header({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _CadastroScreenState._dark,
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 16,
        left: 16,
        right: 16,
      ),
      child: Row(
        children: [
          InkWell(
            onTap: onBack,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Colors.white,
                size: 17,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Novo Chamado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Preencha os dados para acionar a equipe certa',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  final String label;
  final Widget child;

  const _FieldBlock({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: _CadastroScreenState._dark,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Container(
                width: 5,
                height: 5,
                decoration: const BoxDecoration(
                  color: _CadastroScreenState._orange,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
        ),
        child,
      ],
    );
  }
}
