enum Priority {
  baixa,
  media,
  alta,
  critica;

  static Priority fromString(String value) {
    return Priority.values.firstWhere(
      (e) => e.name == value,
    );
  }
}