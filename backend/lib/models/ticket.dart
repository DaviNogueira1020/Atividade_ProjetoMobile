import '../enums/category_enum.dart';
import '../enums/priority_enum.dart';
import '../enums/status_enum.dart';

class Ticket{
  final int? id;
  final String title;
  final String description;
  final Category category;
  final Priority priority;
  final String neighborhood;
  final String responsible;
  final DateTime openedAt;
  final Status status;

  const Ticket({
    this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.priority,
    required this.neighborhood,
    required this.responsible,
    required this.openedAt,
    required this.status,
  });

  Ticket copyWith({
    int? id,
    String? title,
    String? description,
    Category? category,
    Priority? priority,
    String? neighborhood,
    String? responsible,
    DateTime? openedAt,
    Status? status,
  }){
    return Ticket(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      neighborhood: neighborhood ?? this.neighborhood,
      responsible: responsible ?? this.responsible,
      openedAt: openedAt ?? this.openedAt,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toMap(){
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.index,
      'neighborhood': neighborhood,
      'responsible': responsible,
      'opened_at': openedAt.millisecondsSinceEpoch,
      'status': status.index,
    };
  }

  factory Ticket.fromMap(Map<String, dynamic> map){
    return Ticket(
      id: map['id'] as int?,
      title: map['title'] as String,
      description: map['description'] as String,
      category: Category.fromString(
        map['category'] as String,
      ),
      priority: Priority.values.firstWhere(
        (p) => p.index == (map['priority'] as num).toInt(),
      ),
      neighborhood: map['neighborhood'] as String,
      responsible: map['responsible'] as String,
      openedAt: DateTime.fromMillisecondsSinceEpoch(
        (map['opened_at'] as num).toInt(),
      ),
      status: Status.values.firstWhere(
        (s) => s.index == (map['status'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toJson(){
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category.name,
      'priority': priority.name,
      'neighborhood': neighborhood,
      'responsible': responsible,
      'openedAt': openedAt.toIso8601String(),
      'status': status.name,
    };
  }

  factory Ticket.fromJson(Map<String, dynamic> json){
    return Ticket(
      id: json['id'] as int?,
      title: json['title'] as String,
      description: json['description'] as String,
      category: Category.fromString(
        json['category'] as String,
      ),
      priority: Priority.fromString(
        json['priority'] as String,
      ),
      neighborhood:
        json['neighborhood'] as String,
      responsible:
        json['responsible'] as String,
      openedAt: DateTime.parse(
        json['openedAt'] as String,
      ),
      status: Status.fromString(
        json['status'] as String,
      ),
    );
  }

  Duration get elapsedTime{
    return DateTime.now().difference(openedAt);
  }
}