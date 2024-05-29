// ignore_for_file: file_names
import 'package:hive/hive.dart';
import 'package:todo/service/hiveService.dart';

class TodoAdapter extends TypeAdapter<Todo> {
  @override
  final int typeId = 0;
  @override
  Todo read(BinaryReader reader) {
    return Todo(
        title: reader.readString(),
        description: reader.readString(),
        dateTime: DateTime.parse(reader.readString()),
        isComplited: reader.readBool());
  }

  @override
  void write(BinaryWriter writer, Todo obj) {
    writer.writeString(obj.title);
    writer.writeString(obj.description);
    writer.writeString(obj.dateTime.toIso8601String());
    writer.writeBool(obj.isComplited);
  }
}
