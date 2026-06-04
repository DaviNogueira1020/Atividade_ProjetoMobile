import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
<<<<<<< HEAD
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
=======
import 'providers/chamado_provider.dart';
import 'core/app_theme.dart';
import 'screens/dashboard_screen.dart';
>>>>>>> 4016823b5398158317e1478e68eb9cbb0282ada3

void main() {
  runApp(
    ChangeNotifierProvider(
<<<<<<< HEAD
      create: (context) => ChamadoProvider()..initDB(),
      child: const MeuApp(),
=======
      create: (context) => ChamadoProvider(),
      child: const MyApp(),
>>>>>>> 4016823b5398158317e1478e68eb9cbb0282ada3
    ),
  );
}

<<<<<<< HEAD
class MeuApp extends StatelessWidget {
  const MeuApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Escuta o provider para mudar o tema em tempo real
    final themeMode = context.watch<ChamadoProvider>().themeMode;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Zeladoria App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
      darkTheme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: Colors.blue),
      themeMode: themeMode,
      home: const DashboardScreen(),
    );
  }
}

// ==========================================
// MODELO
// ==========================================
class Chamado {
  int? id;
  String titulo, descricao, categoria, prioridade, bairro, responsavel, status;
  DateTime data;

  Chamado({
    this.id,
    required this.titulo,
    required this.descricao,
    required this.categoria,
    required this.prioridade,
    required this.bairro,
    required this.responsavel,
    required this.status,
    required this.data,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'titulo': titulo,
        'descricao': descricao,
        'categoria': categoria,
        'prioridade': prioridade,
        'bairro': bairro,
        'responsavel': responsavel,
        'status': status,
        'data': data.toIso8601String(),
      };

  factory Chamado.fromMap(Map<String, dynamic> map) => Chamado(
        id: map['id'],
        titulo: map['titulo'],
        descricao: map['descricao'],
        categoria: map['categoria'],
        prioridade: map['prioridade'],
        bairro: map['bairro'],
        responsavel: map['responsavel'],
        status: map['status'],
        data: DateTime.parse(map['data']),
      );

  String get tempoAberto {
    final diff = DateTime.now().difference(data);
    if (diff.inDays > 0) return '${diff.inDays}d atrás';
    if (diff.inHours > 0) return '${diff.inHours}h atrás';
    return '${diff.inMinutes}m atrás';
  }
}

// ==========================================
// PROVIDER & LOGICA
// ==========================================
class ChamadoProvider extends ChangeNotifier {
  Database? _db;
  List<Chamado> _chamados = [];
  ThemeMode _themeMode = ThemeMode.system;

  List<Chamado> get chamados => _chamados;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  Future<void> initDB() async {
    final path = join(await getDatabasesPath(), 'chamados_v2.db');
    _db = await openDatabase(path, version: 1, onCreate: (db, version) {
      db.execute(
          '''CREATE TABLE chamados(id INTEGER PRIMARY KEY AUTOINCREMENT, titulo TEXT, 
      descricao TEXT, categoria TEXT, prioridade TEXT, bairro TEXT, responsavel TEXT, status TEXT, data TEXT)''');
    });
    await carregarChamados();
  }

  Future<void> carregarChamados() async {
    final List<Map<String, dynamic>> maps = await _db!.query('chamados');
    _chamados = maps.map((m) => Chamado.fromMap(m)).toList();
    _chamados
        .sort((a, b) => _peso(b.prioridade).compareTo(_peso(a.prioridade)));
    notifyListeners();
  }

  int _peso(String p) =>
      {'crítica': 4, 'alta': 3, 'média': 2, 'baixa': 1}[p] ?? 0;

  Future<void> adicionarChamado(Chamado c) async {
    await _db!.insert('chamados', c.toMap());
    await carregarChamados();
  }

  bool tituloExiste(String t) =>
      _chamados.any((c) => c.titulo.toLowerCase() == t.toLowerCase());

  // Dados para Estatísticas
  Map<String, int> get statsStatus {
    var map = {"aberto": 0, "em andamento": 0, "concluído": 0};
    for (var c in _chamados) {
      map[c.status] = (map[c.status] ?? 0) + 1;
    }
    return map;
  }

  Map<String, int> get statsCategoria {
    var map = <String, int>{};
    for (var c in _chamados) {
      map[c.categoria] = (map[c.categoria] ?? 0) + 1;
    }
    return map;
  }
}

// ==========================================
// TELA 1: DASHBOARD
// ==========================================
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ChamadoProvider>();
    final criticos = p.chamados.where((c) => c.prioridade == 'crítica').length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Zeladoria Cidadã'),
        actions: [
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () => Navigator.push(context,
                MaterialPageRoute(builder: (_) => const StatsScreen())),
          ),
          IconButton(
            icon: Icon(p.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            onPressed: () => p.toggleTheme(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (criticos > 5)
            Container(
                color: Colors.red,
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                child: const Text('ALERTA: +5 CHAMADOS CRÍTICOS!',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center)),
          Expanded(
            child: ListView.builder(
              itemCount: p.chamados.length,
              itemBuilder: (context, i) {
                final c = p.chamados[i];
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ListTile(
                    leading: Icon(_getIcon(c.categoria),
                        color: _getPriorityColor(c.prioridade)),
                    title: Text(c.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle:
                        Text('${c.bairro} - ${c.status}\n${c.tempoAberto}'),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
            context, MaterialPageRoute(builder: (_) => const CadastroScreen())),
        child: const Icon(Icons.add),
      ),
    );
  }

  IconData _getIcon(String cat) {
    if (cat == 'trânsito') return Icons.traffic;
    if (cat == 'limpeza urbana') return Icons.delete_outline;
    if (cat == 'saneamento') return Icons.water_drop;
    return Icons.info_outline;
  }

  Color _getPriorityColor(String p) {
    if (p == 'crítica') return Colors.red;
    if (p == 'alta') return Colors.orange;
    return Colors.blue;
  }
}

// ==========================================
// TELA 2: ESTATÍSTICAS (Graficos Manuais)
// ==========================================
class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final p = context.watch<ChamadoProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Estatísticas')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text('Chamados por Status',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...p.statsStatus.entries.map((e) =>
                _buildBar(e.key, e.value, p.chamados.length, Colors.blue)),
            const Divider(height: 40),
            const Text('Chamados por Categoria',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...p.statsCategoria.entries.map((e) =>
                _buildBar(e.key, e.value, p.chamados.length, Colors.green)),
          ],
        ),
      ),
    );
  }

  Widget _buildBar(String label, int value, int total, Color color) {
    double perc = total > 0 ? value / total : 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$label: $value'),
          Stack(
            children: [
              Container(
                  height: 12,
                  width: double.infinity,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(5))),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 12, width: (perc * 300), // Largura proporcional
                decoration: BoxDecoration(
                    color: color, borderRadius: BorderRadius.circular(5)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================
// TELA 3: CADASTRO
// ==========================================
class CadastroScreen extends StatefulWidget {
  const CadastroScreen({super.key});
  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _t = TextEditingController(),
      _d = TextEditingController(),
      _b = TextEditingController(),
      _r = TextEditingController();
  String _cat = 'trânsito', _pri = 'baixa', _sta = 'aberto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Novo Chamado')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
                controller: _t,
                decoration: const InputDecoration(labelText: 'Título'),
                validator: (v) => v!.isEmpty
                    ? 'Vazio'
                    : (context.read<ChamadoProvider>().tituloExiste(v)
                        ? 'Já existe'
                        : null)),
            TextFormField(
                controller: _d,
                decoration: const InputDecoration(labelText: 'Descrição'),
                validator: (v) => v!.isEmpty ? 'Vazio' : null),
            TextFormField(
                controller: _b,
                decoration: const InputDecoration(labelText: 'Bairro'),
                validator: (v) => v!.isEmpty ? 'Vazio' : null),
            TextFormField(
                controller: _r,
                decoration: const InputDecoration(labelText: 'Responsável'),
                validator: (v) => v!.isEmpty ? 'Vazio' : null),
            DropdownButtonFormField(
                value: _cat,
                items: [
                  'trânsito',
                  'iluminação',
                  'saneamento',
                  'segurança',
                  'limpeza urbana',
                  'desastre natural'
                ]
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _cat = v!),
            DropdownButtonFormField(
                value: _pri,
                items: ['baixa', 'média', 'alta', 'crítica']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _pri = v!),
            DropdownButtonFormField(
                value: _sta,
                items: ['aberto', 'em andamento', 'concluído']
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) => _sta = v!),
            const SizedBox(height: 20),
            ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<ChamadoProvider>().adicionarChamado(Chamado(
                        titulo: _t.text,
                        descricao: _d.text,
                        categoria: _cat,
                        prioridade: _pri,
                        bairro: _b.text,
                        responsavel: _r.text,
                        status: _sta,
                        data: DateTime.now()));
                    Navigator.pop(context);
                  }
                },
                child: const Text('Salvar'))
          ],
        ),
      ),
=======
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Cidade',
      theme: AppTheme.lightTheme,
      home: const DashboardScreen(),
      debugShowCheckedModeBanner: false,
>>>>>>> 4016823b5398158317e1478e68eb9cbb0282ada3
    );
  }
}
