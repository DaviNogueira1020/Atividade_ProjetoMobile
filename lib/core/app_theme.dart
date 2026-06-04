import 'package:flutter/material.dart';

class AppTheme {
  // Cores principais
  static const Color corPrimaria = Color(0xFF2E7D32); // Verde
  static const Color corSecundaria = Color(0xFF1976D2); // Azul
  static const Color corAcento = Color(0xFFD32F2F); // Vermelho
  static const Color corCritica = Color(0xFFB71C1C); // Vermelho escuro
  
  // Cores neutras
  static const Color corFundo = Color(0xFFFAFAFA);
  static const Color corSuperficie = Color(0xFFFFFFFF);
  static const Color corBorda = Color(0xFFE0E0E0);
  static const Color corTextoTitulo = Color(0xFF212121);
  static const Color corTextoSecundario = Color(0xFF757575);
  static const Color corTextoDisabled = Color(0xFFBDBDBD);

  // Cores para status
  static const Color corAberto = Color(0xFF2E7D32); // Verde
  static const Color corEmProgresso = Color(0xFF1976D2); // Azul
  static const Color corAguardando = Color(0xFFF57C00); // Laranja
  static const Color corConcluido = Color(0xFF388E3C); // Verde escuro
  
  // Cores para prioridade
  static const Color corBaixa = Color(0xFF4CAF50); // Verde claro
  static const Color corMedia = Color(0xFFFFC107); // Amarelo
  static const Color corAlta = Color(0xFFFF9800); // Laranja
  
  // Material 3 Theme
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: corPrimaria,
        secondary: corSecundaria,
        tertiary: corAcento,
        surface: corSuperficie,
        background: corFundo,
        error: corAcento,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: corPrimaria,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: corPrimaria,
          side: const BorderSide(color: corPrimaria),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corBorda),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corBorda),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corPrimaria, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: corAcento),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        hintStyle: const TextStyle(color: corTextoDisabled),
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: corBorda, width: 1),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: corTextoTitulo,
        ),
        displayMedium: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: corTextoTitulo,
        ),
        displaySmall: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: corTextoTitulo,
        ),
        headlineSmall: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: corTextoTitulo,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: corTextoTitulo,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: corTextoTitulo,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: corTextoTitulo,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: corTextoTitulo,
        ),
        bodySmall: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: corTextoSecundario,
        ),
      ),
    );
  }

  // Funções auxiliares para cores de status
  static Color getCorStatus(StatusChamado status) {
    switch (status) {
      case StatusChamado.aberto:
        return corAberto;
      case StatusChamado.emProgresso:
        return corEmProgresso;
      case StatusChamado.aguardando:
        return corAguardando;
      case StatusChamado.concluido:
        return corConcluido;
    }
  }

  static Color getCorPrioridade(PrioridadeChamado prioridade) {
    switch (prioridade) {
      case PrioridadeChamado.baixa:
        return corBaixa;
      case PrioridadeChamado.media:
        return corMedia;
      case PrioridadeChamado.alta:
        return corAlta;
      case PrioridadeChamado.critica:
        return corCritica;
    }
  }
}

// Enums importados para simplificar
import '../models/chamado_model.dart';
