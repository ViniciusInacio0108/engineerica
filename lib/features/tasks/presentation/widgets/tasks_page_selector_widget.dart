import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TasksPageSelectorWidget extends StatelessWidget {
  const TasksPageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final blocTask = context.read<TaskBloc>();

    return BlocBuilder<TaskBloc, TaskState>(builder: (context, state) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              blocTask.add(
                PreviousPageListEvent(),
              );
            },
            icon: const Icon(Icons.navigate_before),
          ),
          Text('Page ${blocTask.state.currentPage}'),
          IconButton(
            onPressed: () {
              blocTask.add(
                NextPageListEvent(),
              );
            },
            icon: const Icon(Icons.navigate_next),
          ),
        ],
      );
    });
  }
}
