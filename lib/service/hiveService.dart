// ignore_for_file: file_names
import 'package:hive/hive.dart';

@HiveType(typeId: 0)
class Todo extends HiveObject {
  @HiveField(0)
  late String title;
  @HiveField(1)
  late String description;
  @HiveField(2)
  late bool isComplited;
  @HiveField(3)
  late DateTime dateTime;
  Todo(
      {required this.title,
      required this.description,
      required this.dateTime,
      this.isComplited = false});
}