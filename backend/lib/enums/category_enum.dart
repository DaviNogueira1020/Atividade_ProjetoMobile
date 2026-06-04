enum Category {
  transito,
  iluminacao,
  saneamento,
  seguranca,
  limpezaUrbana,
  desastreNatural;

  static Category fromString(String value){
    try{
      return Category.values.firstWhere((e) => e.name == value);
    }catch (_){
      throw ArgumentError('Categoria inválida: $value',);
    }
  }
}