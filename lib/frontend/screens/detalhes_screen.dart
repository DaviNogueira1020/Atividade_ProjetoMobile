import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chamado_model.dart';
import '../../providers/chamado_provider.dart';
import '../core/app_theme.dart';
import '../widgets/custom_textfield.dart';
import '../core/validators.dart';

class DetalhesScreen extends StatefulWidget {
  final ChamadoModel chamado;

  const DetalhesScreen({
    Key? key,
    required this.chamado,
  }) : super(key: key);

  @override
  State<DetalhesScreen> createState() => _DetalhesScreenState();
}

class _DetalhesScreenState extends State<DetalhesScreen> {
  late ChamadoModel _chamado;
  bool _editando = false;
  late TextEditingController _observacoesController;

  @override
  void initState() {
    super.initState();
    _chamado = widget.chamado;
    _observacoesController = TextEditingController(
      text: _chamado.observacoes ?? '',
    );
  }

  @override
  void dispose() {
    _observacoesController.dispose();
    super.dispose();
  }

  void _alterarStatus(StatusChamado novoStatus) {
    if (_chamado.isConcluido) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Chamados concluídos não podem ser alterados')),
      );
      return;
    }

    context.read<ChamadoProvider>().atualizarStatus(_chamado.id!, novoStatus).then((_) {
      // Recarregar dados
      final provider = context.read<ChamadoProvider>();
      _chamado = provider.chamados.firstWhere(
        (c) => c.id == _chamado.id,
        orElse: () => _chamado,
      );
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Status atualizado')),
      );
    });
  }

  void _atualizarObservacoes() {
    final observacoes = _observacoesController.text.isEmpty 
        ? null 
        : _observacoesController.text;
    
    context.read<ChamadoProvider>().atualizarChamado(
      original: _chamado,
      titulo: _chamado.titulo,
      descricao: _chamado.descricao,
      categoria: _chamado.categoria,
      prioridade: _chamado.prioridade,
      status: _chamado.status,
      bairro: _chamado.bairro,
      responsavel: _chamado.responsavel,
      observacoes: observacoes,
    ).then((_) {
      final provider = context.read<ChamadoProvider>();
      _chamado = provider.chamados.firstWhere(
        (c) => c.id == _chamado.id,
        orElse: () => _chamado,
      );
      setState(() {
        _editando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Observações atualizadas')),
      );
    });
  }

  void _deletarChamado() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar exclusão'),
        content: const Text('Tem certeza que deseja deletar este chamado?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<ChamadoProvider>().deletarChamado(_chamado.id!).then((_) {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Chamado deletado')),
                );
              });
            },
            child: const Text('Deletar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detalhes do Chamado'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _deletarChamado,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho com título e ícone crítico
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _chamado.titulo,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _chamado.dataCriacaoFormatada,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_chamado.isCritico)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.corCritica,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Text(
                      'CRÍTICO',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Status e Prioridade
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Status',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.getCorStatus(_chamado.status),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _chamado.statusTexto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Prioridade',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppTheme.getCorPrioridade(_chamado.prioridade),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          _chamado.prioridadeTexto,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Informações
            _infoRow('Categoria', _chamado.categoriaTexto),
            _infoRow('Bairro', _chamado.bairro),
            _infoRow('Responsável', _chamado.responsavel),
            _infoRow('Dias em aberto', '${_chamado.diasEmAberto} dias'),
            const SizedBox(height: 24),

            // Descrição
            Text(
              'Descrição',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.corBorda),
              ),
              child: Text(
                _chamado.descricao,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            const SizedBox(height: 24),

            // Observações
            Text(
              'Observações',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            if (_editando)
              Column(
                children: [
                  CustomTextField(
                    label: 'Observações',
                    controller: _observacoesController,
                    validator: Validators.validarObservacoes,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () {
                            setState(() {
                              _editando = false;
                              _observacoesController.text = _chamado.observacoes ?? '';
                            });
                          },
                          child: const Text('Cancelar'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _atualizarObservacoes,
                          child: const Text('Salvar'),
                        ),
                      ),
                    ],
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.corBorda),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        _chamado.observacoes ?? 'Sem observações',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _chamado.observacoes != null 
                              ? AppTheme.corTextoTitulo 
                              : AppTheme.corTextoDisabled,
                        ),
                      ),
                    ),
                    if (!_chamado.isConcluido)
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          setState(() {
                            _editando = true;
                          });
                        },
                      ),
                  ],
                ),
              ),
            const SizedBox(height: 24),

            // Botões de ação
            if (!_chamado.isConcluido)
              Column(
                children: [
                  if (_chamado.status != StatusChamado.emAndamento)
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: const Text('Iniciar'),
                        onPressed: () => _alterarStatus(StatusChamado.emAndamento),
                      ),
                    ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Concluir'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.corConcluido,
                      ),
                      onPressed: () => _alterarStatus(StatusChamado.concluido),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppTheme.corTextoSecundario,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppTheme.corTextoTitulo,
              fontWeight: FontWeight.w500,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
