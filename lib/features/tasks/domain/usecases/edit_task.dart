import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';
import 'package:result_dart/result_dart.dart';

class EditTaskUseCase {
  final TaskRepository repository;
  EditTaskUseCase({
    required this.repository,
  });

  Future<Result<TaskEntity>> call(TaskEntity task) async {
    return await repository.editTask(task);
  }
}
