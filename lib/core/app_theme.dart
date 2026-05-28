// lib/core/app_theme.dart
//
// ⚠️  O import do model foi movido para o TOPO do arquivo.
//     No código original estava no final, o que causa erro de compilação.

import 'package:flutter/material.dart';
import '../models/chamado_model.dart';

class AppTheme {
  AppTheme._();

  // ── Cores principais ───────────────────────────────────────────────────────
  static const Color corPrimaria          = Color(0xFF2E7D32);
  static const Color corSecundaria        = Color(0xFF1976D2);
  static const Color corAcento           = Color(0xFFD32F2F);
  static const Color corCritica          = Color(0xFFB71C1C);

  // ── Cores neutras ──────────────────────────────────────────────────────────
  static const Color corFundo            = Color(0xFFFAFAFA);
  static const Color corSuperficie       = Color(0xFFFFFFFF);
  static const Color corBorda            = Color(0xFFE0E0E0);
  static const Color corTextoTitulo      = Color(0xFF212121);
  static const Color corTextoSecundario  = Color(0xFF757575);
  static const Color corTextoDisabled    = Color(0xFFBDBDBD);

  // ── Cores por status ───────────────────────────────────────────────────────
  static const Color corAberto      = Color(0xFF2E7D32);
  static const Color corEmAndamento = Color(0xFF1976D2);
  static const Color corConcluido   = Color(0xFF388E3C);

  // ── Cores por prioridade ───────────────────────────────────────────────────
  static const Color corBaixa = Color(0xFF4CAF50);
  static const Color corMedia = Color(0xFFFFC107);
  static const Color corAlta  = Color(0xFFFF9800);

  // ── Tema claro ─────────────────────────────────────────────────────────────
  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary:    corPrimaria,
          secondary:  corSecundaria,
          tertiary:   corAcento,
          surface:    corSuperficie,
          error:      corAcento,
        ),
        appBarTheme: const AppBarTheme(
          elevation:       0,
          backgroundColor: corPrimaria,
          foregroundColor: Colors.white,
          centerTitle:     true,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: corPrimaria,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: corPrimaria,
            side: const BorderSide(color: corPrimaria),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled:    true,
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
            side: const BorderSide(color: corBorda),
          ),
        ),
        textTheme: const TextTheme(
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: corTextoTitulo),
          titleLarge:    TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: corTextoTitulo),
          titleMedium:   TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: corTextoTitulo),
          bodyLarge:     TextStyle(fontSize: 16, color: corTextoTitulo),
          bodyMedium:    TextStyle(fontSize: 14, color: corTextoTitulo),
          bodySmall:     TextStyle(fontSize: 12, color: corTextoSecundario),
        ),
      );

  // ── Tema escuro (dark mode extra) ──────────────────────────────────────────
  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor:  corPrimaria,
          brightness: Brightness.dark,
        ),
      );

  // ── Helpers de cor ─────────────────────────────────────────────────────────

  static Color getCorStatus(StatusChamado status) {
    switch (status) {
      case StatusChamado.aberto:      return corAberto;
      case StatusChamado.emAndamento: return corEmAndamento;
      case StatusChamado.concluido:   return corConcluido;
    }
  }

  static Color getCorPrioridade(PrioridadeChamado prioridade) {
    switch (prioridade) {
      case PrioridadeChamado.baixa:   return corBaixa;
      case PrioridadeChamado.media:   return corMedia;
      case PrioridadeChamado.alta:    return corAlta;
      case PrioridadeChamado.critica: return corCritica;
    }
  }
}
