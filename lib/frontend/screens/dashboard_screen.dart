import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/chamado_model.dart';
import '../../providers/chamado_provider.dart';
import '../widgets/chamado_card.dart';
import '../widgets/status_card.dart';
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
                // Alerta se > 5 críticos
                if (provider.temAlerta)
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.corCritica.withOpacity(0.1),
                      border: Border.all(color: AppTheme.corCritica),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.warning,
                          color: AppTheme.corCritica,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Alerta: Muitos chamados críticos!',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.corCritica,
                                ),
                              ),
                              Text(
                                '${provider.totalChamadosCriticos} chamados críticos sem resolução',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.corTextoSecundario,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                // Cards de status
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      StatusCard(
                        titulo: 'Total',
                        valor: provider.totalChamados,
                        cor: AppTheme.corPrimaria,
                        icone: Icons.list,
                        onTap: () {
                          // Filtrar todos
                        },
                      ),
                      StatusCard(
                        titulo: 'Abertos',
                        valor: provider.totalChamadasAbertas,
                        cor: AppTheme.corAberto,
                        icone: Icons.open_in_new,
                        onTap: () {
                          // Filtrar abertos
                        },
                      ),
                      StatusCard(
                        titulo: 'Em Progresso',
                        valor: provider.totalChamadosEmProgresso,
                        cor: AppTheme.corEmProgresso,
                        icone: Icons.hourglass_top,
                        onTap: () {
                          // Filtrar em progresso
                        },
                      ),
                      StatusCard(
                        titulo: 'Críticos',
                        valor: provider.totalChamadosCriticos,
                        cor: AppTheme.corCritica,
                        icone: Icons.priority_high,
                        onTap: () {
                          // Filtrar críticos
                        },
                      ),
                    ],
                  ),
                ),

                // Lista de chamados ordenada
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'Chamados Recentes',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 12),
                if (provider.chamados.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        Icon(
                          Icons.inbox,
                          size: 64,
                          color: AppTheme.corBorda,
                        ),
                        const SizedBox(height: 16),
                        const Text('Nenhum chamado cadastrado'),
                      ],
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
                              builder: (context) => DetalhesScreen(
                                chamado: chamado,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.corPrimaria,
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const CadastroScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
