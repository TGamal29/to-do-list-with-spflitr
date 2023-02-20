import 'package:flutter/material.dart';
import 'package:todo_list/sqflite.dart';


void main(){
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: TodoList(),
  ));
}

class TodoList extends StatefulWidget {
  const TodoList({Key? key}) : super(key: key);

  @override
  State<TodoList> createState() => _TodoListState();
}

class _TodoListState extends State<TodoList> {

  final todoController = TextEditingController();
  bool flag = true;
  bool validated = true;
  String errorMessage = "";
  String todoAdded = "";
  String todoUpdate = "";
  var myTodos = [];
  List<Widget> listOfCards = [];
  final dbHelper = DatabaseHelper.instance;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(builder: (context,snap){
      if (snap.hasData == null) {
        return const Center(
          child: Text("NO Data"),
        );
      }  else{
        if (myTodos.length == 0 ) {
          return Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.purple,
              title: const Text("My Tasks"),
            ),
            floatingActionButton: FloatingActionButton(
              onPressed: (){
                  showAlertDialog("add task","add",true,0);
                },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.add),
            ),
            body: const Center(
              child: Text("No Tasks Available",style: TextStyle(
                fontSize: 25.0,
              ),),
            ),
          );
        }  else{
          return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.purple,
                title: const Text("My Tasks"),
              ),
              floatingActionButton: FloatingActionButton(
                onPressed: (){
                  showAlertDialog("add task","add",true,0);
                },
                backgroundColor: Colors.purple,
                child: const Icon(Icons.add),
              ),
              body: SingleChildScrollView(
                child: Column(
                  children: listOfCards,
                ),
              )
          );
        }
      }
    },future: query(),);
  }

  void showAlertDialog(String titleDialog , String text , bool flag,var id) {
    todoController.text = "";
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(builder: (context, setState) {
            return AlertDialog(
              title: Text(titleDialog),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    autofocus: true,
                    controller: todoController,
                    style: const TextStyle(fontSize: 15.0),
                    decoration: InputDecoration(
                      errorText: validated ? null : errorMessage,
                    ),
                    onChanged: (value) {
                      todoAdded = value;
                    },
                  ),
                  const SizedBox(height: 15,),
                  MaterialButton(
                      color: Colors.purple,
                      child:  Text(text, style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18.0
                      ),),
                      onPressed: () {
                        if (todoController.text.isEmpty) {
                          setState(() {
                            errorMessage = " Cannot be empty";
                            validated = false;
                          });
                        } else if (todoController.text.length > 100) {
                          setState(() {
                            errorMessage = " Too Many Characters";
                            validated = false;
                          });
                        } else if(flag) {
                          addTodo();
                        } else {
                          editTodo(id);
                        }
                      }
                  )
                ],
              ),

            );
          });
        });
  }

  void addTodo() async {
    Map<String, dynamic> todo = {
      DatabaseHelper.columnName: todoAdded,
    };
    final id = await dbHelper.insert(todo);
    print(id);
    Navigator.of(context, rootNavigator: true).pop();
    todoAdded = "";
    setState(() {
      validated = true;
      errorMessage = "";
    });
  }

  void editTodo(dynamic id ) async {
    Map<String,dynamic> row = {
      DatabaseHelper.columnName: todoAdded,  
    };
    
    await dbHelper.update(row,id);
    print(id);
    Navigator.of(context, rootNavigator: true).pop();

    todoAdded = "";
    setState(() {
      validated = true;
      errorMessage = "";
    });
    

  }

  Future<bool> query() async {
    myTodos = [];
    listOfCards=[];
    var listOfAllTodos = await dbHelper.queryAllTodos();
    listOfAllTodos?.forEach((task) {
      myTodos.add(task.toString());
      listOfCards.add(
        Card(
          elevation: 5.0,
          margin: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
          child: Container(
            padding: const EdgeInsets.all(5.0),
            child: ListTile(
              title: Text(task['todo'],
                style: const TextStyle(
                    fontSize: 18.0
                ),),

              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: (){
                      dbHelper.deleteTodo(task['id']);
                      print(task['id']);
                      print("Task Deleted");
                      setState(() {
                      });
                    },
                    icon: const Icon(Icons.delete,color: Colors.red,),
                  ),
                  IconButton(
                    onPressed: (){
                      var id = task['id'];
                      showAlertDialog('edit task', 'edit',false,id);
                      print(id);
                      setState(() {
                      });
                    },
                    icon: const Icon(Icons.edit,color: Colors.purple,),
                  ),
                ],
              ),

            ),
          ),
        ),
      );
    });
    return Future.value(true);
  }

}
