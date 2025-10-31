enum TaskStatus {
  COMPLETE,
  INCOMPLETE,
}

class TaskEntity {
  String id;
  String name;
  String description;
  DateTime createdAt;
  TaskStatus status;

  TaskEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.createdAt,
    required this.status,
  });

  String mapStatusToString() {
    switch (status) {
      case TaskStatus.COMPLETE:
        return 'COMPLETE';
      case TaskStatus.INCOMPLETE:
        return 'INCOMPLETE';
    }
  }

  TaskEntity copyWith({
    String? id,
    String? name,
    String? description,
    DateTime? createdAt,
    TaskStatus? status,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      status: status ?? this.status,
    );
  }
}
