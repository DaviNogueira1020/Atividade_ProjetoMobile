// lib/main.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/chamado_provider.dart';
import 'frontend/core/app_theme.dart';
import 'frontend/screens/dashboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      // Cria o provider e já dispara o carregamento inicial do banco
      create: (context) => ChamadoProvider()..carregarDados(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SOS Cidade',
      debugShowCheckedModeBanner: false,
      theme:      AppTheme.lightTheme,
      darkTheme:  AppTheme.darkTheme,
      themeMode:  ThemeMode.system, // respeita preferência do sistema
      home: const DashboardScreen(),
    );
  }
}
