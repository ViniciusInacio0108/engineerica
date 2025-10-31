import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';

abstract class TaskEvent {}

class CreateTaskEvent extends TaskEvent {
  TaskEntity task;
  CreateTaskEvent({
    required this.task,
  });
}

class UpdateTaskEvent extends TaskEvent {
  TaskEntity task;
  UpdateTaskEvent({
    required this.task,
  });
}

class RemoveTaskEvent extends TaskEvent {
  TaskEntity task;
  RemoveTaskEvent({
    required this.task,
  });
}

class FetchTaskEvent extends TaskEvent {
  int currentPage;
  FetchTaskEvent({
    required this.currentPage,
  });
}

class ChangeTaskStatusEvent extends TaskEvent {
  TaskEntity task;
  ChangeTaskStatusEvent({
    required this.task,
  });
}

class SearchTaskEvent extends TaskEvent {
  TaskEntity? task;
  String value;
  SearchTaskEvent({
    this.task,
    required this.value,
  });
}

class FilterTaskEvent extends TaskEvent {
  TaskEntity? task;
  TaskCompletionFilter filter;
  FilterTaskEvent({
    this.task,
    required this.filter,
  });
}

class SortTaskEvent extends TaskEvent {
  TaskEntity? task;
  TaskSorting sort;
  SortTaskEvent({
    this.task,
    required this.sort,
  });
}

class NextPageListEvent extends TaskEvent {
  TaskEntity? task;
  NextPageListEvent({
    this.task,
  });
}

class PreviousPageListEvent extends TaskEvent {
  TaskEntity? task;
  PreviousPageListEvent({
    this.task,
  });
}
