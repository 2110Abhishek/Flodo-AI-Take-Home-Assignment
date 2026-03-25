enum TaskStatus {
  todo('To-Do'),
  inProgress('In Progress'),
  done('Done');

  final String label;
  const TaskStatus(this.label);

  factory TaskStatus.fromString(String status) {
    return TaskStatus.values.firstWhere(
      (e) => e.label == status,
      orElse: () => TaskStatus.todo,
    );
  }
}

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskStatus status;
  final String? blockedById;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.status,
    this.blockedById,
  });

  Task copyWith({
    String? id,
    String? title,
    String? description,
    DateTime? dueDate,
    TaskStatus? status,
    String? blockedById,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      dueDate: dueDate ?? this.dueDate,
      status: status ?? this.status,
      blockedById: blockedById == '' ? null : (blockedById ?? this.blockedById),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'status': status.label,
      'blockedById': blockedById,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      dueDate: DateTime.parse(json['dueDate'] as String),
      status: TaskStatus.fromString(json['status'] as String),
      blockedById: json['blockedById'] as String?,
    );
  }
}
