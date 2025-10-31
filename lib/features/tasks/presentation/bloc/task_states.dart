import 'package:engineerica_app/features/tasks/domain/entities/task.dart';

enum TaskCompletionFilter {
  ALL,
  COMPLETE,
  INCOMPLETE,
}

enum TaskSorting {
  MOST_RECENT,
  LEAST_RECENT,
  A_TO_Z,
  Z_TO_A,
  COMPLETE_FIRST,
  INCOMPLETE_FIRST,
}

abstract class TaskState {
  List<TaskEntity> tasks;
  TaskCompletionFilter filter;
  TaskSorting sorting;
  int currentPage;
  TaskState({
    required this.tasks,
    required this.filter,
    required this.sorting,
    required this.currentPage,
  });
}

class InitialTaskState extends TaskState {
  InitialTaskState()
      : super(
          tasks: [],
          filter: TaskCompletionFilter.ALL,
          sorting: TaskSorting.MOST_RECENT,
          currentPage: 1,
        );
}

class LoadingTaskState extends TaskState {
  LoadingTaskState(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}

class LoadedTaskState extends TaskState {
  LoadedTaskState(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}

class FetchErrorTaskState extends TaskState {
  FetchErrorTaskState(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}

class ErrorCreatingTaskState extends TaskState {
  ErrorCreatingTaskState(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}

class ErrorUpdatingTaskState extends TaskState {
  ErrorUpdatingTaskState(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}

class ErrorWhileChangingTaskStatus extends TaskState {
  ErrorWhileChangingTaskStatus(
      {required super.tasks,
      required super.filter,
      required super.sorting,
      required super.currentPage});
}
