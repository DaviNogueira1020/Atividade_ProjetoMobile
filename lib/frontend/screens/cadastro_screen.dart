// lib/frontend/screens/cadastro_screen.dart
// CORRIGIDO: import de custom_textfield aponta para ../widgets/ (frontend/widgets)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chamado_model.dart';
import '../../providers/chamado_provider.dart';
import '../widgets/custom_textfield.dart'; // CORRIGIDO: era ../../widgets/custom_textfield.dart
import '../core/validators.dart';
import '../core/app_theme.dart';

class CadastroScreen extends StatefulWidget {
  const CadastroScreen({Key? key}) : super(key: key);

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _bairroController;
  late TextEditingController _responsavelController;
  late TextEditingController _observacoesController;

  CategoriaChamado? _categoriaSelected;
  PrioridadeChamado? _prioridadeSelected;

  @override
  void initState() {
    super.initState();
    _tituloController = TextEditingController();
    _descricaoController = TextEditingController();
    _bairroController = TextEditingController();
    _responsavelController = TextEditingController();
    _observacoesController = TextEditingController();
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

      context.read<ChamadoProvider>().adicionarChamado(
        titulo: _tituloController.text,
        descricao: _descricaoController.text,
        categoria: _categoriaSelected!,
        prioridade: _prioridadeSelected!,
        bairro: _bairroController.text,
        responsavel: _responsavelController.text,
        observacoes: _observacoesController.text.isNotEmpty
            ? _observacoesController.text
            : null,
      ).then((erro) {
        if (!mounted) return;
        if (erro != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erro: $erro')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Chamado cadastrado com sucesso!')),
          );
          Navigator.of(context).pop();
        }
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
              CustomTextField(
                label: 'Título',
                hint: 'Ex: Buraco na rua',
                controller: _tituloController,
                validator: Validators.validarTitulo,
                prefixIcon: Icons.title,
              ),
              const SizedBox(height: 16),

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

              Text('Categoria', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<CategoriaChamado>(
                value: _categoriaSelected,
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
                    child: Text(categoria.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _categoriaSelected = value),
              ),
              const SizedBox(height: 16),

              Text('Prioridade', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              DropdownButtonFormField<PrioridadeChamado>(
                value: _prioridadeSelected,
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
                    child: Text(prioridade.label),
                  );
                }).toList(),
                onChanged: (value) => setState(() => _prioridadeSelected = value),
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Bairro',
                hint: 'Bairro onde ocorre o problema',
                controller: _bairroController,
                validator: Validators.validarBairro,
                prefixIcon: Icons.location_on,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Responsável',
                hint: 'Nome de quem está reportando',
                controller: _responsavelController,
                validator: Validators.validarResponsavel,
                prefixIcon: Icons.person,
              ),
              const SizedBox(height: 16),

              CustomTextField(
                label: 'Observações (Opcional)',
                hint: 'Informações adicionais',
                controller: _observacoesController,
                validator: Validators.validarObservacoes,
                maxLines: 3,
                prefixIcon: Icons.note,
              ),
              const SizedBox(height: 24),

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
