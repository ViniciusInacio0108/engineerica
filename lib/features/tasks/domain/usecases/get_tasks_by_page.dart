import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';
import 'package:result_dart/result_dart.dart';

class GetTasksByPage {
  final TaskRepository repository;
  GetTasksByPage({
    required this.repository,
  });

  Future<Result<List<TaskEntity>>> call({
    required int page,
    required String sorting,
    required String filter,
  }) async {
    const int pageSize = 5;
    return await repository.getTasksByPage(page, pageSize, sorting, filter);
  }
}
