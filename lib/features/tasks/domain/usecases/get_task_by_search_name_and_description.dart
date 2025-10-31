import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';
import 'package:result_dart/result_dart.dart';

class GetTaskBySearchNameAndDescription {
  final TaskRepository repository;
  GetTaskBySearchNameAndDescription({
    required this.repository,
  });

  Future<Result<List<TaskEntity>>> call({
    required String search,
  }) async {
    return await repository.getTasksBySearchNameAndDescription(
      search,
    );
  }
}
