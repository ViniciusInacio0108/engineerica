import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';
import 'package:result_dart/result_dart.dart';

class RemoveTaskUseCase {
  final TaskRepository repository;
  RemoveTaskUseCase({
    required this.repository,
  });

  Future<Result<String>> call(String id) async {
    return await repository.removeTaskById(id);
  }
}
