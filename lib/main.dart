import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> main() async {
  //Initialize Firebase
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  runApp(const MyApp());
}

//firebase에 입력해둔 값을 class로 선언한다.
class Todo {
  String title;
  bool isDone;

  Todo(this.title, {this.isDone = false});
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'todo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _todoController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _todoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('What is your next step?'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _todoController,
                ),
              ),
              ElevatedButton(
                onPressed: () => _addTodo(Todo(_todoController.text)),
                child: Text('Add your day'),
              ),
            ],
          ),
          StreamBuilder(
            stream: FirebaseFirestore.instance.collection('todo').snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              final documents = snapshot.data?.docs;
              return Expanded(
                child: ListView(
                  children: documents!.map((doc) => _buildItem(doc)).toList(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildItem(DocumentSnapshot snapshot) {
    final todo = Todo(snapshot['title'], isDone: snapshot['isDone']);
    return ListTile(
      title: Text(
        todo.title,
        style: todo.isDone ? TextStyle(fontSize: 10) : null,
      ),
      trailing: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () => _deleteTodo(snapshot),
      ),
      onTap: () => _toggleTodo(snapshot),
    );
  }

  void _addTodo(Todo todo) {
    setState(() {
      FirebaseFirestore.instance
          .collection('todo')
          .add({'title': todo.title, 'isDone': todo.isDone});
    });
  }

  void _deleteTodo(DocumentSnapshot snapshot) {
    setState(() {
      FirebaseFirestore.instance.collection('todo').doc(snapshot.id).delete();
    });
  }

  void _toggleTodo(DocumentSnapshot snapshot) {
    FirebaseFirestore.instance
        .collection('todo')
        .doc(snapshot.id)
        .update({'isDone': !snapshot['isDone']});
  }
}
