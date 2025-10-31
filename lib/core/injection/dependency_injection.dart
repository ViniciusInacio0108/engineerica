import './task_service_injection.dart' as taskDI;

Future<void> initAllDependecies() async {
  await taskDI.init();
}
