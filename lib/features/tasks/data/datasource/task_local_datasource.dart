import 'package:hive_flutter/hive_flutter.dart';

class TaskLocalDataSource {
  TaskLocalDataSource({
    required this.box,
  });

  final Box box;

  Future<Map> add(Map task) async {
    await box.put(task['id'], task);
    return task;
  }

  Future<void> delete(String id) async => box.delete(id);

  Future<List<Map>> fetchAllByPage({
    required int page,
    required int pageSize,
    required String sorting,
    required String filter,
  }) async {
    final all = box.values
        .map((rawMap) => (rawMap as Map).cast<String, dynamic>())
        .toList();

    // doing it in memory cause hive does not have support
    _filterTasks(all, filter);
    _sortTasks(all, sorting);

    final start = (page - 1) * pageSize;
    if (start >= all.length) return [];
    final end = (start + pageSize).clamp(0, all.length);
    final tasksByPage = all.sublist(start, end);

    return tasksByPage;
  }

  Future<List<Map>> fetchAllBySearch({
    required String search,
  }) async {
    final all = box.values
        .map((rawMap) => (rawMap as Map).cast<String, dynamic>())
        .toList();

    // doing it in memory cause hive does not have support
    all.removeWhere(
      (task) => (!task['name'].contains(search) &&
          !task['description'].contains(search)),
    );

    return all;
  }

  Future<Map> update(Map task) async {
    await box.put(task['id'], task);
    return task;
  }

  void _filterTasks(List<Map<String, dynamic>> tasks, String filter) {
    switch (filter) {
      case 'ALL':
        break;
      case 'COMPLETE':
        tasks.removeWhere(
          (task) => task['status'] != 'COMPLETE',
        );
        break;
      case 'INCOMPLETE':
        tasks.removeWhere(
          (task) => task['status'] != 'INCOMPLETE',
        );
        break;
      default:
        throw Exception('Not mapped filtering');
    }
  }

  void _sortTasks(List<Map<String, dynamic>> tasks, String sort) {
    switch (sort) {
      case 'MOST_RECENT':
        tasks.sort((a, b) => b['createdAt'].compareTo(a['createdAt']));
        break;
      case 'LEAST_RECENT':
        tasks.sort((a, b) => a['createdAt'].compareTo(b['createdAt']));
        break;
      case 'A_TO_Z':
        tasks.sort((a, b) => a['name'].compareTo(b['name']));
        break;
      case 'Z_TO_A':
        tasks.sort((a, b) => b['name'].compareTo(a['name']));
        break;
      case 'COMPLETE_FIRST':
        tasks.sort((a, b) => a['status'] == 'INCOMPLETE' ? 1 : -1);
        break;
      case 'INCOMPLETE_FIRST':
        tasks.sort((a, b) => a['status'] == 'COMPLETE' ? 1 : -1);
        break;
      default:
        throw Exception('Not mapped sorting');
    }
  }
}
