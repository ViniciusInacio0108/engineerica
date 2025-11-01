import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SearchTasksWidget extends StatelessWidget {
  final TextEditingController searchController;
  const SearchTasksWidget({super.key, required this.searchController});

  void _onSearchDone(BuildContext context) {
    FocusScope.of(context).unfocus();
    context.read<TaskBloc>().add(
          SearchTaskEvent(value: searchController.text.trim()),
        );
  }

  void _onExcludeSearchPressed(BuildContext context) {
    FocusScope.of(context).unfocus();
    searchController.clear();
    context.read<TaskBloc>().add(
          FetchTaskEvent(currentPage: 1),
        );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: searchController,
      autofocus: false,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search tasks...',
        suffix: InkWell(
          onTap: () => _onExcludeSearchPressed(context),
          child: const Icon(
            Icons.close,
          ),
        ),
      ),
      textInputAction: TextInputAction.done,
      maxLines: 1,
      maxLength: 20,
      onEditingComplete: () => _onSearchDone(context),
    );
  }
}
