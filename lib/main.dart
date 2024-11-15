import 'package:flutter/material.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: "lib/.env");

  var keyApplicationId = dotenv.env['B4A_APPLICATION_ID'];
  var keyClientKey = dotenv.env['B4A_CLIENT_KEY'];
  const keyParseServerUrl = 'https://parseapi.back4app.com';

  await Parse().initialize(keyApplicationId!, keyParseServerUrl,
      clientKey: keyClientKey, autoSendSessionId: true);

  runApp(const MaterialApp(home: TodoApp()));
}

class TodoApp extends StatefulWidget {
  const TodoApp({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _TodoAppState createState() => _TodoAppState();
}

class _TodoAppState extends State<TodoApp> {
  List<ParseObject> tasks = [];
  TextEditingController taskController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getTodo();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          primaryColor: const Color.fromARGB(255, 255, 255, 255),
          hintColor: const Color.fromARGB(255, 156, 245, 96),
          scaffoldBackgroundColor: const Color.fromARGB(255, 255, 255, 255),
          appBarTheme:
              AppBarTheme(backgroundColor: Color.fromARGB(255, 255, 197, 38))),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('QuickTask'),
        ),
        body: Container(
          decoration: BoxDecoration(
            border: Border.all(color: const Color.fromARGB(255, 255, 255, 255)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildTaskInput(),
              const SizedBox(height: 20),
              Expanded(child: _buildTaskList()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTaskInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: taskController,
              decoration: InputDecoration(
                hintText: 'Task',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: dueDateController,
              decoration: InputDecoration(
                hintText: 'Due Date',
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: addTodo,
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all<Color>(Colors.green),
                foregroundColor: WidgetStateProperty.all<Color>(Colors.white)),
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskList() {
    return ListView.builder(
      itemCount: tasks.length,
      itemBuilder: (context, index) {
        final varTodo = tasks[index];
        final varTitle = varTodo.get('title') ?? '';
        final varDueDate = varTodo.get('dueDate') ?? '';
        bool done = varTodo.get<bool>('done') ?? false;

        return ListTile(
          title: Row(
            children: [
              Checkbox(
                value: done,
                onChanged: (newValue) {
                  updateTodo(index, newValue!, varTitle, varDueDate);
                },
              ),
              Expanded(child: Text(varTitle)),
              Expanded(child: Text(varDueDate)),
            ],
          ),
          trailing: IconButton(
            icon:
                const Icon(Icons.delete, color: Color.fromARGB(255, 255, 0, 0)),
            onPressed: () {
              deleteTodo(index, varTodo.objectId!);
            },
          ),
        );
      },
    );
  }

  Future<void> addTodo() async {
    String task = taskController.text.trim();
    String dueDate = dueDateController.text.trim();
    if (task.isNotEmpty && dueDate.isNotEmpty) {
      var todo = ParseObject('Todo')
        ..set('title', task)
        ..set('dueDate', dueDate)
        ..set('done', false);

      var response = await todo.save();

      if (response.success) {
        setState(() {
          tasks.add(todo);
        });
        taskController.clear();
        dueDateController.clear();
      } else {
        // Handle error
      }
    }
  }

  Future<void> updateTodo(
      int index, bool done, String varTitle, String varDueDate) async {
    final varTodo = tasks[index];
    final String id = varTodo.objectId.toString();

    var todo = ParseObject('Todo')
      ..objectId = id
      ..set('title', varTitle)
      ..set('dueDate', varDueDate)
      ..set('done', done);

    var response = await todo.save();

    if (response.success) {
      setState(() {
        tasks[index] = todo;
      });
    } else {
      // Handle error
    }
  }

  Future<void> getTodo() async {
    var queryBuilder = QueryBuilder<ParseObject>(ParseObject('Todo'));
    var apiResponse = await queryBuilder.query();

    if (apiResponse.success && apiResponse.results != null) {
      setState(() {
        tasks = apiResponse.results as List<ParseObject>;
      });
    } else {
      // Handle error
    }
  }

  Future<void> deleteTodo(int index, String id) async {
    var todo = ParseObject('Todo')..objectId = id;
    var response = await todo.delete();

    if (response.success) {
      setState(() {
        tasks.removeAt(index);
      });
    } else {
      // Handle error
    }
  }
}
