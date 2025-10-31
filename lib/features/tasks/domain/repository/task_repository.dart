import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:result_dart/result_dart.dart';

abstract class TaskRepository {
  Future<Result<List<TaskEntity>>> getTasksByPage(
    int page,
    int pageSize,
    String sorting,
    String filter,
  );
  Future<Result<List<TaskEntity>>> getTasksBySearchNameAndDescription(
    String search,
  );
  Future<Result<TaskEntity>> createTask(TaskEntity task);
  Future<Result<TaskEntity>> editTask(TaskEntity task);
  Future<Result<String>> removeTaskById(String id);
}
