// ignore_for_file: file_names, avoid_unnecessary_containers, no_leading_underscores_for_local_identifiers, unnecessary_import, unnecessary_null_comparison, unused_element, unused_import
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:intl/intl.dart';
import 'package:todo/main.dart';
import 'package:todo/service/hiveService.dart';

class HomeSreen extends StatefulWidget {
  const HomeSreen({super.key});

  @override
  State<HomeSreen> createState() => _HomeSreenState();
}

class _HomeSreenState extends State<HomeSreen> {
  late Future<Box<Todo>> _todoBoxFuture;
  late Box<Todo> todoBox;

  @override
  void initState() {
    _todoBoxFuture = _openBox();
    super.initState();
  }

  Future<Box<Todo>> _openBox() async {
    final todoBox = await Hive.openBox<Todo>("todo");
    return todoBox;
  }

  @override
  Widget build(BuildContext context) {
    Future<void> _refresh() async {
      return Future.delayed(Duration(seconds: 1));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 49, 116, 171),
        elevation: 0,
        foregroundColor: Colors.white,
        title: Center(child: Text("Keep note")),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder(
          builder: (context, AsyncSnapshot<Box<Todo>> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else {
              final todoBox = snapshot.data!;
              return ValueListenableBuilder(
                valueListenable: todoBox.listenable(),
                builder: (context, Box<Todo> box, _) {
                  return ListView.builder(
                    itemCount: box.length,
                    itemBuilder: ((context, index) {
                      Todo todo = box.getAt(index)!;
                      return Container(
                        margin: EdgeInsets.only(top: 20, left: 9, right: 9),
                        decoration: BoxDecoration(
                          color: todo.isComplited
                              ? const Color.fromARGB(255, 227, 220, 220)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Dismissible(
                          direction: DismissDirection.endToStart,
                          background: Container(
                            decoration: BoxDecoration(
                              color: Colors.redAccent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            alignment: Alignment.centerRight,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            setState(() {
                              todo.delete();
                            });
                          },
                          key: Key(todo.dateTime.toString()),
                          child: ListTile(
                            title: InkWell(
                              onTap: () {
                                _editTodoDialog(context, todo);
                              },
                              child: Text(todo.title),
                            ),
                            subtitle: Text(todo.description),
                            trailing: Text(
                              DateFormat.yMMMd().format(todo.dateTime),
                            ),
                            leading: Checkbox(
                              value: todo.isComplited,
                              onChanged: (value) {
                                setState(() {
                                  todo.isComplited = value!;
                                  todo.save();
                                });
                              },
                            ),
                          ),
                        ),
                      );
                    }),
                  );
                },
              );
            }
          },
          future: _todoBoxFuture,
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 49, 116, 171),
        onPressed: () {
          _addTodoDialog(context);
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _editTodoDialog(BuildContext context, Todo todo) {
    TextEditingController _editTitleController =
        TextEditingController(text: todo.title);
    TextEditingController _editDescriptionController =
        TextEditingController(text: todo.description);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _editTitleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextFormField(
                controller: _editDescriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                setState(() {
                  todo.title = _editTitleController.text;
                  todo.description = _editDescriptionController.text;
                  todo.save();
                });
              },
              child: Text("Save"),
            ),
          ],
        );
      },
    );
  }

  void _addTodoDialog(BuildContext context) {
    TextEditingController _titleController = TextEditingController();
    TextEditingController _descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Add task"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addTodo(
                  _titleController.text,
                  _descriptionController.text,
                );
              },
              child: Text("Add"),
            ),
          ],
        );
      },
    );
  }

  void _addTodo(String title, String description) async {
    if (title.isNotEmpty) {
      await _todoBoxFuture.then((box) {
        box.add(Todo(
          title: title,
          description: description,
          dateTime: DateTime.now(),
        ));
      });
      // Update the UI with the newly added task
      setState(() {});
    }
  }
}
