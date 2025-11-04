import 'package:flutter/material.dart';

void main() {
  runApp(const TodoApp());
}

class TodoApp extends StatelessWidget {
  const TodoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'To-Do List',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TodoListScreen(),
    );
  }
}

class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});
}

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  bool _showOnlyCompleted = false;

  List<Task> get _filteredTasks {
    if (_showOnlyCompleted) {
      return _tasks.where((task) => task.completed).toList();
    }
    return _tasks;
  }

  void _addTask() async {
    final newTaskTitle = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (context) => const AddTaskScreen()),
    );

    if (newTaskTitle != null && newTaskTitle.isNotEmpty) {
      setState(() {
        _tasks.add(Task(title: newTaskTitle));
      });
    }
  }

  void _toggleTaskCompletion(int index, bool? value) {
    setState(() {
      _filteredTasks[index].completed = value ?? false;
    });
  }

  void _toggleFilter() {
    setState(() {
      _showOnlyCompleted = !_showOnlyCompleted;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        actions: [
          TextButton(
            onPressed: _toggleFilter,
            child: Text(
              _showOnlyCompleted ? 'Mostra Tutti' : 'Mostra Completati',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredTasks.length,
        itemBuilder: (context, index) {
          final task = _filteredTasks[index];
          return CheckboxListTile(
            title: Text(
              task.title,
              style: TextStyle(
                decoration: task.completed
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            value: task.completed,
            onChanged: (bool? value) {
              _toggleTaskCompletion(index, value);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        tooltip: 'Add Task',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final TextEditingController _textFieldController = TextEditingController();

  void _submitTask() {
    Navigator.of(context).pop(_textFieldController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _textFieldController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Task',
                hintText: 'Cosa devi fare?',
              ),
              onSubmitted: (_) => _submitTask(),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: _submitTask, child: const Text('Add')),
          ],
        ),
      ),
    );
  }
}
