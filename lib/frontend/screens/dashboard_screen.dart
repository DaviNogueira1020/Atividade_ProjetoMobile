// lib/frontend/screens/dashboard_screen.dart
// CORRIGIDO: imports de widgets apontam para ../widgets/ (frontend/widgets)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chamado_model.dart';
import '../../providers/chamado_provider.dart';
import '../widgets/chamado_card.dart';   // CORRIGIDO: era ../../widgets/chamado_card.dart
import '../widgets/status_card.dart';   // CORRIGIDO: era ../../widgets/status_card.dart
import '../core/app_theme.dart';
import 'cadastro_screen.dart';
import 'detalhes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
      () => context.read<ChamadoProvider>().carregarDados(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SOS Cidade'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChamadoProvider>().carregarDados();
            },
          ),
        ],
      ),
      body: Consumer<ChamadoProvider>(
        builder: (context, provider, _) {
          if (provider.carregando) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Alerta de críticos
                if (provider.temAlertaCriticos)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.corCritica,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.white),
                        const SizedBox(width: 8),
                        Text(
                          'Atenção: ${provider.totalChamadosCriticos} chamados críticos!',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                // Cards de status
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.4,
                    children: [
                      StatusCard(
                        titulo: 'Total',
                        valor: provider.totalChamados,
                        cor: AppTheme.corSecundaria,
                        icone: Icons.list_alt,
                      ),
                      StatusCard(
                        titulo: 'Abertos',
                        valor: provider.totalAbertos,
                        cor: AppTheme.corAberto,
                        icone: Icons.folder_open,
                      ),
                      StatusCard(
                        titulo: 'Em Andamento',
                        valor: provider.totalEmAndamento,
                        cor: AppTheme.corEmAndamento,
                        icone: Icons.autorenew,
                      ),
                      StatusCard(
                        titulo: 'Concluídos',
                        valor: provider.totalConcluidos,
                        cor: AppTheme.corConcluido,
                        icone: Icons.check_circle,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // Lista de chamados
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chamados Recentes',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),

                if (provider.chamadosOrdenados.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Nenhum chamado cadastrado.'),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: provider.chamadosOrdenados.length,
                    itemBuilder: (context, index) {
                      final chamado = provider.chamadosOrdenados[index];
                      return ChamadoCard(
                        chamado: chamado,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => DetalhesScreen(chamado: chamado),
                            ),
                          );
                        },
                      );
                    },
                  ),

                const SizedBox(height: 80),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const CadastroScreen()),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Novo Chamado'),
      ),
    );
  }
}
