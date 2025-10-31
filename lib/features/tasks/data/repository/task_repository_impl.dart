import 'package:engineerica_app/features/tasks/data/models/task.dart';
import 'package:result_dart/result_dart.dart';

import 'package:engineerica_app/features/tasks/data/datasource/task_local_datasource.dart';
import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final TaskLocalDataSource localDataSource;
  TaskRepositoryImpl({
    required this.localDataSource,
  });

  @override
  Future<Result<TaskEntity>> createTask(TaskEntity task) async {
    try {
      final newTask = TaskModel(
        id: task.id,
        name: task.name,
        description: task.description,
        createdAt: task.createdAt.toIso8601String(),
        status: task.mapStatusToString(),
      );

      await localDataSource.add(newTask.toJson());

      return Success(task);
    } catch (e) {
      return Failure(
        Exception('Error while creating task at repo: $e'),
      );
    }
  }

  @override
  Future<Result<TaskEntity>> editTask(TaskEntity task) async {
    try {
      final updatedTask = TaskModel(
        id: task.id,
        name: task.name,
        description: task.description,
        createdAt: task.createdAt.toIso8601String(),
        status: task.mapStatusToString(),
      );

      await localDataSource.add(updatedTask.toJson());

      return Success(task);
    } catch (e) {
      return Failure(
        Exception('Error while updating task at repo: $e'),
      );
    }
  }

  @override
  Future<Result<List<TaskEntity>>> getTasksByPage(
    int page,
    int pageSize,
    String sorting,
    String filter,
  ) async {
    try {
      final tasksModels = await localDataSource.fetchAllByPage(
        page: page,
        pageSize: pageSize,
        sorting: sorting,
        filter: filter,
      );

      final models = tasksModels.map(
        (task) => TaskModel.fromJson(task.cast<String, dynamic>()),
      );

      return Success(
        models
            .map(
              (taskModel) => TaskEntity(
                id: taskModel.id,
                name: taskModel.name,
                description: taskModel.description,
                createdAt: DateTime.parse(taskModel.createdAt),
                status: TaskStatus.values.byName(taskModel.status),
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Failure(Exception('Error while fetching tasks at repo: $e'));
    }
  }

  @override
  Future<Result<String>> removeTaskById(String id) async {
    try {
      await localDataSource.delete(id);
      return Success(id);
    } catch (e) {
      return Failure(Exception('Error while deleting task at repo: $e'));
    }
  }

  @override
  Future<Result<List<TaskEntity>>> getTasksBySearchNameAndDescription(
    String search,
  ) async {
    try {
      final tasksModels = await localDataSource.fetchAllBySearch(
        search: search,
      );

      final models = tasksModels.map(
        (task) => TaskModel.fromJson(task.cast<String, dynamic>()),
      );

      return Success(
        models
            .map(
              (taskModel) => TaskEntity(
                id: taskModel.id,
                name: taskModel.name,
                description: taskModel.description,
                createdAt: DateTime.parse(taskModel.createdAt),
                status: TaskStatus.values.byName(taskModel.status),
              ),
            )
            .toList(),
      );
    } catch (e) {
      return Failure(
          Exception('Error while fetching tasks by search at repo: $e'));
    }
  }
}
