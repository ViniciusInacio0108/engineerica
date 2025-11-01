import 'package:engineerica_app/core/routing/routes.dart';
import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
import 'package:engineerica_app/features/tasks/presentation/widgets/filter_tasks_per_status_segment_buttons_widget.dart';
import 'package:engineerica_app/features/tasks/presentation/widgets/search_tasks_widget.dart';
import 'package:engineerica_app/features/tasks/presentation/widgets/task_sorting_and_page_counter_widget.dart';
import 'package:engineerica_app/features/tasks/presentation/widgets/tasks_page_selector_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TaskListPage extends StatelessWidget {
  const TaskListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _TaskListView();
  }
}

class _TaskListView extends StatefulWidget {
  const _TaskListView();

  @override
  State<_TaskListView> createState() => _TaskListViewState();
}

class _TaskListViewState extends State<_TaskListView> {
  late final TextEditingController _searchController;

  void _onClickAddTaskButton(TaskBloc blocTask) {
    blocTask.add(FilterTaskEvent(filter: TaskCompletionFilter.ALL));

    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.pushNamed(context, MyRoutes.FORM_TASK_SCREEN);
  }

  Future<void> _onTapTaskItem(TaskEntity currentTask) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Navigator.pushNamed(
      context,
      MyRoutes.FORM_TASK_SCREEN,
      arguments: currentTask,
    );
  }

  Future<void> _onTapCheckboxTaskItem(
      TaskBloc blocTask, TaskEntity currentTask) async {
    blocTask.add(
      ChangeTaskStatusEvent(
        task: currentTask,
      ),
    );
  }

  Future<void> _onPressedDeleteButton(
      TaskBloc blocTask, TaskEntity currentTask) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete task?'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (ok == true) {
      blocTask.add(
        RemoveTaskEvent(task: currentTask),
      );
    }
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => context.read<TaskBloc>().add(
            FetchTaskEvent(currentPage: 1),
          ),
    );
    _searchController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocTask = context.read<TaskBloc>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Tasks'),
      ),
      body: BlocConsumer<TaskBloc, TaskState>(listener: (context, state) {
        if (state is ErrorWhileChangingTaskStatus) {
          const snackBar = SnackBar(
            content: Text(
                'Somethig went wrong while updating your task! Please try again.'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        }
      }, builder: (context, state) {
        final list = state.tasks;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(
              left: 24,
              right: 24,
            ),
            child: Column(
              children: [
                SearchTasksWidget(
                  searchController: _searchController,
                ),
                FilterTasksPerStatusSegmentButtonsWidget(
                  searchController: _searchController,
                ),
                const TaskSortingAndPageCounterWidget(),
                if (state is LoadingTaskState)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                else if (state is InitialTaskState)
                  const Expanded(
                    child: Center(child: Text('No tasks yet')),
                  )
                else if (state is FetchErrorTaskState)
                  const Expanded(
                    child: Center(child: Text('Error Fetching')),
                  )
                else if (list.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No tasks yet')),
                  )
                else
                  Expanded(
                    child: ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final currentTask = list[index];
                        final isTaskCompleted =
                            currentTask.status == TaskStatus.COMPLETE;
                        return InkWell(
                          onTap: () async => await _onTapTaskItem(currentTask),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              decoration: BoxDecoration(
                                color: isTaskCompleted
                                    ? Colors.greenAccent.withOpacity(0.2)
                                    : null,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: Checkbox(
                                  value: isTaskCompleted,
                                  onChanged: (value) async =>
                                      await _onTapCheckboxTaskItem(
                                          blocTask, currentTask),
                                ),
                                title: Text(currentTask.name,
                                    style: TextStyle(
                                        decoration: isTaskCompleted
                                            ? TextDecoration.lineThrough
                                            : null)),
                                subtitle: currentTask.description.isNotEmpty
                                    ? Text(currentTask.description)
                                    : null,
                                trailing: IconButton(
                                  onPressed: () async =>
                                      await _onPressedDeleteButton(
                                          blocTask, currentTask),
                                  icon: Icon(
                                    Icons.delete,
                                    color: Theme.of(context).colorScheme.error,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const TasksPageSelectorWidget(),
                ElevatedButton(
                  onPressed: () => _onClickAddTaskButton(blocTask),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  child: const Text('Add task'),
                ),
                const SizedBox(height: 12)
              ],
            ),
          ),
        );
      }),
    );
  }
}
