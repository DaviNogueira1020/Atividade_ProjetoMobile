enum Category {
  transito,
  iluminacao,
  saneamento,
  seguranca,
  limpezaUrbana,
  desastreNatural;

  static Category fromString(String value) {
    return Category.values.firstWhere(
      (e) => e.name == value,
    );
  }
}