import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/create_task.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/edit_task.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/get_task_by_search_name_and_description.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/get_tasks_by_page.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/remove_task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskBloc extends Bloc<TaskEvent, TaskState> {
  final GetTasksByPage getTasksByPageUseCase;
  final GetTaskBySearchNameAndDescription getTaskBySearchNameAndDescription;
  final CreateTaskUseCase createTaskUseCase;
  final EditTaskUseCase editTaskUseCase;
  final RemoveTaskUseCase removeTaskUseCase;

  // CHANGE TO MAP FOR IMPROVED PERFORMANCE
  final List<TaskEntity> _allTasks = [];

  TaskBloc({
    required this.getTasksByPageUseCase,
    required this.createTaskUseCase,
    required this.editTaskUseCase,
    required this.removeTaskUseCase,
    required this.getTaskBySearchNameAndDescription,
  }) : super(InitialTaskState()) {
    // FetchData
    on<FetchTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: state.filter,
          sorting: state.sorting,
          currentPage: 1,
        ));

        final tasksResult = await getTasksByPageUseCase.call(
          page: event.currentPage,
          sorting: state.sorting.name,
          filter: state.filter.name,
        );
        // delay for loading purposes
        await Future.delayed(const Duration(seconds: 1));

        tasksResult.fold(
          (success) {
            if (success.isEmpty) {
              emit(InitialTaskState());
            } else {
              _allTasks.clear();
              _allTasks.addAll(success);
              add(SortTaskEvent(sort: state.sorting));
              emit(LoadedTaskState(
                tasks: success,
                filter: state.filter,
                sorting: state.sorting,
                currentPage: event.currentPage,
              ));
            }
          },
          (failure) => emit(FetchErrorTaskState(
            tasks: state.tasks,
            filter: state.filter,
            sorting: state.sorting,
            currentPage: state.currentPage,
          )),
        );
      },
    );
    // Create task
    on<CreateTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: state.filter,
          sorting: state.sorting,
          currentPage: state.currentPage,
        ));
        final newTask = event.task;
        final result = await createTaskUseCase.call(newTask);

        result.fold(
          (success) {
            state.tasks.add(newTask);
            emit(LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
          (failure) {
            emit(ErrorCreatingTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
        );
      },
    );
    // Update task
    on<UpdateTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: state.filter,
          sorting: state.sorting,
          currentPage: state.currentPage,
        ));
        final result = await editTaskUseCase.call(event.task);

        result.fold(
          (success) {
            // doing in memory because Hive is no SQL
            final taskIndex =
                state.tasks.indexWhere((task) => task.id == event.task.id);
            state.tasks[taskIndex] = event.task;
            emit(LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
          (failure) {
            emit(ErrorUpdatingTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
        );
      },
    );
    // Delete task
    on<RemoveTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: state.filter,
          sorting: state.sorting,
          currentPage: state.currentPage,
        ));
        final result = await removeTaskUseCase.call(event.task.id);

        result.fold(
          (success) {
            state.tasks.removeWhere((task) => task.id == event.task.id);
            emit(LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
          (failure) {
            emit(LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
        );
      },
    );
    // Change task status
    on<ChangeTaskStatusEvent>(
      (event, emit) async {
        final newStatus = event.task.status == TaskStatus.COMPLETE
            ? TaskStatus.INCOMPLETE
            : TaskStatus.COMPLETE;

        final updatedTask = event.task.copyWith(status: newStatus);

        // doing in memory because Hive is no SQL
        final taskIndex =
            state.tasks.indexWhere((task) => task.id == event.task.id);

        state.tasks[taskIndex] = updatedTask;

        if (state.filter != TaskCompletionFilter.ALL) {
          state.tasks.removeAt(taskIndex);
        }

        emit(
          LoadedTaskState(
            tasks: state.tasks,
            filter: state.filter,
            sorting: state.sorting,
            currentPage: state.currentPage,
          ),
        );

        final result = await editTaskUseCase.call(updatedTask);

        result.fold(
          (success) {},
          (failure) {
            // is case any errors occurs while updating the task status async
            state.tasks[taskIndex] = event.task;
            emit(ErrorWhileChangingTaskStatus(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            ));
          },
        );
      },
    );
    // On search event
    on<SearchTaskEvent>(
      (event, emit) async {
        emit(
          LoadingTaskState(
            tasks: state.tasks,
            filter: state.filter,
            sorting: state.sorting,
            currentPage: state.currentPage,
          ),
        );

        final searchResult =
            await getTaskBySearchNameAndDescription.call(search: event.value);

        searchResult.fold(
          (success) {
            emit(
              LoadedTaskState(
                tasks: success,
                filter: state.filter,
                sorting: state.sorting,
                currentPage: 1,
              ),
            );
          },
          (failure) {
            LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            );
          },
        );
      },
    );
    // Filter task event
    on<FilterTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: event.filter,
          sorting: state.sorting,
          currentPage: state.currentPage,
        ));

        final filterResult = await getTasksByPageUseCase.call(
          page: state.currentPage,
          filter: event.filter.name,
          sorting: state.sorting.name,
        );

        filterResult.fold(
          (success) {
            emit(
              LoadedTaskState(
                tasks: success,
                filter: event.filter,
                sorting: state.sorting,
                currentPage: state.currentPage,
              ),
            );
          },
          (failure) {
            LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            );
          },
        );
      },
    );
    // Sort tasks
    on<SortTaskEvent>(
      (event, emit) async {
        emit(LoadingTaskState(
          tasks: state.tasks,
          filter: state.filter,
          sorting: state.sorting,
          currentPage: state.currentPage,
        ));

        final sortingResult = await getTasksByPageUseCase.call(
          page: state.currentPage,
          filter: state.filter.name,
          sorting: event.sort.name,
        );

        sortingResult.fold(
          (success) {
            emit(
              LoadedTaskState(
                tasks: success,
                filter: state.filter,
                sorting: event.sort,
                currentPage: state.currentPage,
              ),
            );
          },
          (failure) {
            LoadedTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage,
            );
          },
        );
      },
    );
    // next page
    on<NextPageListEvent>(
      (event, emit) async {
        emit(
          LoadingTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage),
        );

        final currentPage = state.currentPage;
        final nextPage = currentPage + 1;

        final result = await getTasksByPageUseCase.call(
          page: nextPage,
          sorting: state.sorting.name,
          filter: state.filter.name,
        );

        result.fold(
          (success) {
            if (success.isEmpty) {
              emit(
                LoadedTaskState(
                    tasks: state.tasks,
                    filter: state.filter,
                    sorting: state.sorting,
                    currentPage: state.currentPage),
              );
            } else {
              _allTasks.clear();
              _allTasks.addAll(success);
              emit(
                LoadedTaskState(
                  tasks: _allTasks,
                  filter: state.filter,
                  sorting: state.sorting,
                  currentPage: nextPage,
                ),
              );
            }
          },
          (failure) {
            emit(
              LoadedTaskState(
                  tasks: state.tasks,
                  filter: state.filter,
                  sorting: state.sorting,
                  currentPage: state.currentPage),
            );
          },
        );
      },
    );
    // previous page
    on<PreviousPageListEvent>(
      (event, emit) async {
        emit(
          LoadingTaskState(
              tasks: state.tasks,
              filter: state.filter,
              sorting: state.sorting,
              currentPage: state.currentPage),
        );

        final currentPage = state.currentPage;
        final previousPage = currentPage == 1 ? 1 : currentPage - 1;

        final result = await getTasksByPageUseCase.call(
          page: previousPage,
          sorting: state.sorting.name,
          filter: state.filter.name,
        );

        result.fold(
          (success) {
            _allTasks.clear();
            _allTasks.addAll(success);
            emit(
              LoadedTaskState(
                tasks: _allTasks,
                filter: state.filter,
                sorting: state.sorting,
                currentPage: previousPage,
              ),
            );
          },
          (failure) {
            emit(
              LoadedTaskState(
                  tasks: state.tasks,
                  filter: state.filter,
                  sorting: state.sorting,
                  currentPage: state.currentPage),
            );
          },
        );
      },
    );
  }

  bool _isCurrentFilterValidToTaskStatus(
      TaskStatus taskStatus, TaskCompletionFilter filter) {
    switch (filter) {
      case TaskCompletionFilter.ALL:
        return true;
      case TaskCompletionFilter.COMPLETE:
        return taskStatus == TaskStatus.COMPLETE;
      case TaskCompletionFilter.INCOMPLETE:
        return taskStatus == TaskStatus.INCOMPLETE;
    }
  }
}
