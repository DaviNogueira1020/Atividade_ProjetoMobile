enum Priority {
  baixa,
  media,
  alta,
  critica;

  static Priority fromString(String value) {
    try{
      return Priority.values.firstWhere((e) => e.name == value);
    }catch (_){
      throw ArgumentError('Prioridade inválida: $value',);
    }
  }
}