enum Status {
  aberto,
  emAndamento,
  concluido;

  static Status fromString(String value) {
    return Status.values.firstWhere(
      (e) => e.name == value,
    );
  }
}