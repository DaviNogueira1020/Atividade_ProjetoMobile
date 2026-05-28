// lib/core/validators.dart
//
// Validações de formulário usadas nas Screens.
// As regras de negócio (título único, concluído não edita) ficam no Provider.

class Validators {
  Validators._();

  static String? validarTitulo(String? value) {
    if (value == null || value.trim().isEmpty) return 'Título é obrigatório.';
    if (value.trim().length < 5)  return 'Título deve ter no mínimo 5 caracteres.';
    if (value.trim().length > 100) return 'Título deve ter no máximo 100 caracteres.';
    return null;
  }

  static String? validarDescricao(String? value) {
    if (value == null || value.trim().isEmpty) return 'Descrição é obrigatória.';
    if (value.trim().length < 10) return 'Descrição deve ter no mínimo 10 caracteres.';
    if (value.trim().length > 500) return 'Descrição deve ter no máximo 500 caracteres.';
    return null;
  }

  static String? validarBairro(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bairro é obrigatório.';
    if (value.trim().length < 2)  return 'Bairro deve ter no mínimo 2 caracteres.';
    if (value.trim().length > 50) return 'Bairro deve ter no máximo 50 caracteres.';
    return null;
  }

  static String? validarResponsavel(String? value) {
    if (value == null || value.trim().isEmpty) return 'Responsável é obrigatório.';
    if (value.trim().length < 3)  return 'Nome deve ter no mínimo 3 caracteres.';
    if (value.trim().length > 50) return 'Nome deve ter no máximo 50 caracteres.';
    return null;
  }

  static String? validarObservacoes(String? value) {
    if (value != null && value.trim().length > 300) {
      return 'Observações deve ter no máximo 300 caracteres.';
    }
    return null;
  }
}
