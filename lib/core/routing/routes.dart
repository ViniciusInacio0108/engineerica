import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/presentation/screens/form_task_screen.dart';
import 'package:engineerica_app/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:flutter/widgets.dart';

class MyRoutes {
  static const TASKS_SCREEN = '/';
  static const FORM_TASK_SCREEN = '/form-task';

  final Map<String, Widget Function(BuildContext)> routes = {
    TASKS_SCREEN: (context) => const TaskListPage(),
    FORM_TASK_SCREEN: (context) {
      final task = ModalRoute.of(context)!.settings.arguments as TaskEntity?;

      return FormTasksScreen(task: task);
    },
  };
}
