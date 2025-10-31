import 'package:freezed_annotation/freezed_annotation.dart';

part 'task.freezed.dart';
part 'task.g.dart';

@freezed
abstract class TaskModel with _$TaskModel {
  const factory TaskModel({
    required String id,
    required String name,
    required String description,
    required String createdAt,
    required String status,
  }) = _TaskModel;

  factory TaskModel.fromJson(Map<String, Object?> json) =>
      _$TaskModelFromJson(json);
}
