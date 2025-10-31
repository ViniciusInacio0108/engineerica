import 'package:engineerica_app/features/tasks/data/datasource/task_local_datasource.dart';
import 'package:engineerica_app/features/tasks/data/repository/task_repository_impl.dart';
import 'package:engineerica_app/features/tasks/domain/repository/task_repository.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/create_task.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/edit_task.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/get_task_by_search_name_and_description.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/get_tasks_by_page.dart';
import 'package:engineerica_app/features/tasks/domain/usecases/remove_task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';

final sl = GetIt.instance;

Future<void> init() async {
  await Hive.deleteFromDisk();
  await Hive.openBox('tasks_box');

  sl.registerLazySingleton<TaskLocalDataSource>(
    () => TaskLocalDataSource(box: Hive.box('tasks_box')),
  );

  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepositoryImpl(localDataSource: sl()),
  );

  sl.registerLazySingleton(
    () => TaskBloc(
      createTaskUseCase: CreateTaskUseCase(repository: sl()),
      getTasksByPageUseCase: GetTasksByPage(repository: sl()),
      editTaskUseCase: EditTaskUseCase(repository: sl()),
      removeTaskUseCase: RemoveTaskUseCase(repository: sl()),
      getTaskBySearchNameAndDescription:
          GetTaskBySearchNameAndDescription(repository: sl()),
    ),
  );
}
