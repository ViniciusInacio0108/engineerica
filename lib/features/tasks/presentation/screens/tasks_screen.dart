import 'package:engineerica_app/core/routing/routes.dart';
import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_states.dart';
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
  final _searchController = TextEditingController();

  void _onSearchDone() {
    FocusScope.of(context).unfocus();
    context.read<TaskBloc>().add(
          SearchTaskEvent(value: _searchController.text.trim()),
        );
  }

  void _onExcludeSearchPressed() {
    FocusScope.of(context).unfocus();
    _searchController.clear();
    context.read<TaskBloc>().add(
          FetchTaskEvent(currentPage: 1),
        );
  }

  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback(
      (timeStamp) => context.read<TaskBloc>().add(
            FetchTaskEvent(currentPage: 1),
          ),
    );
    super.initState();
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
        final taskCounter = state.tasks.length;
        final list = state.tasks;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(top: 24, left: 24, right: 24),
            child: Column(
              children: [
                TextFormField(
                  controller: _searchController,
                  autofocus: false,
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.search),
                    hintText: 'Search tasks...',
                    suffix: InkWell(
                      onTap: () => _onExcludeSearchPressed(),
                      child: const Icon(
                        Icons.close,
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  maxLines: 1,
                  maxLength: 20,
                  onEditingComplete: _onSearchDone,
                ),
                Padding(
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
                    onSelectionChanged:
                        (Set<TaskCompletionFilter> newSelection) {
                      _searchController.clear();
                      blocTask.add(FilterTaskEvent(
                        filter: newSelection.first,
                      ));
                    },
                  ),
                ),
                if (state.tasks.isEmpty)
                  const SizedBox.shrink()
                else
                  Row(
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
                        menuChildren: TaskSorting.values.map((option) {
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
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
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
                    child: Center(child: Text('Error Fethcing')),
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
                          onTap: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            await Navigator.pushNamed(
                              context,
                              MyRoutes.FORM_TASK_SCREEN,
                              arguments: currentTask,
                            );
                          },
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
                                    onChanged: (_) async {
                                      blocTask.add(
                                        ChangeTaskStatusEvent(
                                          task: currentTask,
                                        ),
                                      );
                                    }),
                                title: Text(currentTask.name,
                                    style: TextStyle(
                                        decoration: isTaskCompleted
                                            ? TextDecoration.lineThrough
                                            : null)),
                                subtitle: currentTask.description.isNotEmpty
                                    ? Text(currentTask.description)
                                    : null,
                                trailing: IconButton(
                                  onPressed: () async {
                                    final ok = await showDialog<bool>(
                                      context: context,
                                      builder: (_) => AlertDialog(
                                        title: const Text('Delete task?'),
                                        content: const Text(
                                            'Are you sure you want to delete this task?'),
                                        actions: [
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Cancel')),
                                          TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text('Delete')),
                                        ],
                                      ),
                                    );
                                    if (ok == true) {
                                      blocTask.add(
                                        RemoveTaskEvent(task: currentTask),
                                      );
                                    }
                                  },
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
                Row(
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
                ),
                ElevatedButton(
                    onPressed: () {
                      blocTask.add(
                          FilterTaskEvent(filter: TaskCompletionFilter.ALL));

                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.pushNamed(context, MyRoutes.FORM_TASK_SCREEN);
                    },
                    child: const Text('Add task')),
              ],
            ),
          ),
        );
      }),
    );
  }
}
