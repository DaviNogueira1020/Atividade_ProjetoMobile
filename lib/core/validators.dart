class Validators {
  // Valida titulo (não pode repetir é verificado no banco)
  static String? validarTitulo(String? value) {
    if (value == null || value.isEmpty) {
      return 'Título é obrigatório';
    }
    if (value.length < 5) {
      return 'Título deve ter no mínimo 5 caracteres';
    }
    if (value.length > 100) {
      return 'Título deve ter no máximo 100 caracteres';
    }
    return null;
  }

  // Valida descrição (obrigatória)
  static String? validarDescricao(String? value) {
    if (value == null || value.isEmpty) {
      return 'Descrição é obrigatória';
    }
    if (value.length < 10) {
      return 'Descrição deve ter no mínimo 10 caracteres';
    }
    if (value.length > 500) {
      return 'Descrição deve ter no máximo 500 caracteres';
    }
    return null;
  }

  // Valida bairro (obrigatório)
  static String? validarBairro(String? value) {
    if (value == null || value.isEmpty) {
      return 'Bairro é obrigatório';
    }
    if (value.length < 2) {
      return 'Bairro deve ter no mínimo 2 caracteres';
    }
    if (value.length > 50) {
      return 'Bairro deve ter no máximo 50 caracteres';
    }
    return null;
  }

  // Valida responsável
  static String? validarResponsavel(String? value) {
    if (value == null || value.isEmpty) {
      return 'Responsável é obrigatório';
    }
    if (value.length < 3) {
      return 'Nome deve ter no mínimo 3 caracteres';
    }
    if (value.length > 50) {
      return 'Nome deve ter no máximo 50 caracteres';
    }
    return null;
  }

  // Valida observações (opcional)
  static String? validarObservacoes(String? value) {
    if (value != null && value.isNotEmpty) {
      if (value.length > 300) {
        return 'Observações deve ter no máximo 300 caracteres';
      }
    }
    return null;
  }

  // Verifica se título já existe
  static bool verificarTituloUnico(String titulo, List<String> titulosExistentes) {
    return !titulosExistentes.contains(titulo);
  }

  // Valida email simples
  static String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    final emailRegex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  // Valida telefone
  static String? validarTelefone(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Opcional
    }
    final telefonoRegex = RegExp(r'^\d{10,11}$');
    if (!telefonoRegex.hasMatch(value.replaceAll(RegExp(r'[^\d]'), ''))) {
      return 'Telefone inválido';
    }
    return null;
  }
}
