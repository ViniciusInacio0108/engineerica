import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FilterTasksPerStatusSegmentButtonsWidget extends StatelessWidget {
  final TextEditingController searchController;

  const FilterTasksPerStatusSegmentButtonsWidget(
      {super.key, required this.searchController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TaskBloc, TaskState>(
      builder: (context, state) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: SegmentedButton<TaskCompletionFilter>(
            showSelectedIcon: false,
            segments: const <ButtonSegment<TaskCompletionFilter>>[
              ButtonSegment<TaskCompletionFilter>(
                value: TaskCompletionFilter.ALL,
                label: Text('All'),
              ),
              ButtonSegment<TaskCompletionFilter>(
                value: TaskCompletionFilter.COMPLETE,
                label: Text('Complete'),
              ),
              ButtonSegment<TaskCompletionFilter>(
                value: TaskCompletionFilter.INCOMPLETE,
                label: Text(
                  'Incomplete',
                  maxLines: 1,
                ),
              ),
            ],
            selected: <TaskCompletionFilter>{state.filter},
            onSelectionChanged: (Set<TaskCompletionFilter> newSelection) {
              searchController.clear();
              context.read<TaskBloc>().add(FilterTaskEvent(
                    filter: newSelection.first,
                  ));
            },
          ),
        );
      },
    );
  }
}
