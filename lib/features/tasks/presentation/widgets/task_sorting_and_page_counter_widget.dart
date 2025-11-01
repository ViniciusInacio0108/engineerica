import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskSortingAndPageCounterWidget extends StatelessWidget {
  const TaskSortingAndPageCounterWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final blocTask = context.read<TaskBloc>();

    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        final taskCounter = state.tasks.length;

        return state.tasks.isEmpty
            ? const SizedBox.shrink()
            : Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      'You have $taskCounter task(s)',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  MenuAnchor(
                    builder: (context, controller, _) {
                      return FilledButton.tonalIcon(
                        onPressed: () {
                          controller.isOpen
                              ? controller.close()
                              : controller.open();
                        },
                        icon: const Icon(Icons.sort),
                        label: Text(state.sorting.name),
                      );
                    },
                    menuChildren: TaskSorting.values.map(
                      (option) {
                        return MenuItemButton(
                          onPressed: () => blocTask.add(
                            SortTaskEvent(sort: option),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(option.name),
                              if (option == state.sorting)
                                Icon(Icons.check,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                            ],
                          ),
                        );
                      },
                    ).toList(),
                  ),
                ],
              );
      },
    );
  }
}
