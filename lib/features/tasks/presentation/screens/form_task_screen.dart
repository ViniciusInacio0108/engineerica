import 'package:engineerica_app/features/tasks/domain/entities/task.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_bloc.dart';
import 'package:engineerica_app/features/tasks/presentation/bloc/task_events.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

class FormTasksScreen extends StatefulWidget {
  final TaskEntity? task;
  const FormTasksScreen({super.key, this.task});

  @override
  State<FormTasksScreen> createState() => _FormTasksScreenState();
}

class _FormTasksScreenState extends State<FormTasksScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.task?.name ?? '');
    _descCtrl = TextEditingController(text: widget.task?.description ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) {
      const snackBar = SnackBar(
        content:
            Text('Somethig went worng! Please check the form and try again.'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    final name = _nameCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (widget.task == null) {
      final task = TaskEntity(
        id: const Uuid().v4(),
        name: name,
        description: desc,
        createdAt: DateTime.now(),
        status: TaskStatus.INCOMPLETE,
      );
      context.read<TaskBloc>().add(
            CreateTaskEvent(task: task),
          );
    } else {
      final updatedTask = widget.task!.copyWith(
        name: name,
        description: desc,
      );
      context.read<TaskBloc>().add(
            UpdateTaskEvent(task: updatedTask),
          );
    }
    Navigator.of(context).pop();
  }

  String? _validateNameForm(String? value) {
    return (value == null || value.trim().isEmpty) ? 'Name is required' : null;
  }

  String? _validateDescriptionForm(String? value) {
    if (value == null) return null;

    return (value.length > 1000)
        ? 'Description limit of 1000 characters has been reached.'
        : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'Short title',
                ),
                textInputAction: TextInputAction.next,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: _validateNameForm,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _descCtrl,
                  textInputAction: TextInputAction.done,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  decoration: const InputDecoration(
                      labelText: 'Description', alignLabelWithHint: true),
                  validator: _validateDescriptionForm,
                  maxLines: null,
                  minLines: 4,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
