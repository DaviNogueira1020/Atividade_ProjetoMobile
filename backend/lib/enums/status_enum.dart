enum Status {
  aberto,
  emAndamento,
  concluido;

  static Status fromString(String value) {
    try{
      return Status.values.firstWhere((e) => e.name == value);
    }catch (_){
      throw ArgumentError('Status inválido: $value',);
    }
  }
}