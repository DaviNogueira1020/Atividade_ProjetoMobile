import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  late TextEditingController _tituloController;
  late TextEditingController _descricaoController;
  late TextEditingController _bairroController;
  late TextEditingController _responsavelController;
  late TextEditingController _observacoesController;

  CategoriaChamado? _categoriaSelected;
  PrioridadeChamado? _prioridadeSelected;
  StatusChamado _statusSelected = StatusChamado.aberto;

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

              // Categoria
              Text(
                'Categoria',
                style: Theme.of(context).textTheme.titleMedium,
              ),
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
                  });
                },
              ),
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
              ),
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
