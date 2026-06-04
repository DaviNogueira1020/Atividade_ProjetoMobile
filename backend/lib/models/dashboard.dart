class Dashboard {
  final int total;
  final int open;
  final int inProgress;
  final int completed;
  final int critical;
  final bool hasAlert;

  const Dashboard({
    required this.total,
    required this.open,
    required this.inProgress,
    required this.completed,
    required this.critical,
    required this.hasAlert,
  });

  Map<String, dynamic> toJson(){
    return {
      'total': total,
      'open': open,
      'inProgress': inProgress,
      'completed': completed,
      'critical': critical,
      'hasAlert': hasAlert,
    };
  }
}