import 'package:flutter/material.dart';

class Task {
  String title;
  bool completed;

  Task({required this.title, this.completed = false});
}

enum FilterState { all, completed, incomplete }

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  final List<Task> _tasks = [];
  FilterState _currentFilter = FilterState.all;

  List<Task> get _filteredTasks {
    switch (_currentFilter) {
      case FilterState.completed:
        return _tasks.where((task) => task.completed).toList();
      case FilterState.incomplete:
        return _tasks.where((task) => !task.completed).toList();
      case FilterState.all:
      default:
        return _tasks;
    }
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
      final task = _filteredTasks[index];
      task.completed = value ?? false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My To-Do List'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(kToolbarHeight),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
            child: SegmentedButton<FilterState>(
              segments: const <ButtonSegment<FilterState>>[
                ButtonSegment<FilterState>(
                  value: FilterState.all,
                  label: Text('Tutti'),
                  icon: Icon(Icons.list),
                ),
                ButtonSegment<FilterState>(
                  value: FilterState.completed,
                  label: Text('Completati'),
                  icon: Icon(Icons.check_box),
                ),
                ButtonSegment<FilterState>(
                  value: FilterState.incomplete,
                  label: Text('Da Fare'),
                  icon: Icon(Icons.check_box_outline_blank),
                ),
              ],
              selected: <FilterState>{_currentFilter},
              onSelectionChanged: (Set<FilterState> newSelection) {
                setState(() {
                  _currentFilter = newSelection.first;
                });
              },
            ),
          ),
        ),
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
