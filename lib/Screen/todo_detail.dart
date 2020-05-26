import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/Model/Todo.dart';
import 'package:fluttertodolist/Model/TodoItem.dart';
import 'package:fluttertodolist/db/DbHelper.dart';
import 'package:sqflite/sqflite.dart';

class TodoDetail extends StatefulWidget {

  final String appBarTitle;
  final Todo todo;

  TodoDetail(this.todo, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {

    return TodoDetailState(this.todo, this.appBarTitle);
  }
}

class TodoDetailState extends State<TodoDetail> {

  DbHelper databaseHelper = DbHelper();

  bool bEditMode;

  String appBarTitle;
  Todo todo;
  List<TodoItem> listItems;
  int countTodoItems = 0;
  List<Tag> listTags;

  TextEditingController titleController = TextEditingController();
  TextEditingController addItemController = TextEditingController();
  String strEndDate;

  TodoDetailState(this.todo, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    // Initialise les listes
    this.listItems = List<TodoItem>();
    this.listTags = List<Tag>();

    // Récupère les infos de la tâche
    titleController.text = todo.title;
    strEndDate = todo.endDate;
    listItems = todo.listItems;
    listTags = todo.listTags;

    // Mode édition pour gérer l'enregistrement dans la BD
    if(todo.numId == null) {
      bEditMode = false; // signifie que la tâche ne possède pas encore de donnée dans la BDD, donc les items ne peuvent pas être enregistré direct dans la BD
    }
    else{
      bEditMode = true;
      updateListItems();
    }

    return WillPopScope(

        onWillPop: () {
          // Write some code to control things, when user press Back navigation button in device navigationBar
          moveToLastScreen();
        },

        child: Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            leading: IconButton(icon: Icon(
                Icons.arrow_back),
                onPressed: () {
                  moveToLastScreen();
                }
            ),
          ),

          body: Column(
            children: <Widget>[
              // TITRE *****************
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: TextField(
                  controller: titleController,
                  style: textStyle,
                  onChanged: (value) {
                    debugPrint('Something changed in Title Text Field');
                    updateTitle();
                  },
                  decoration: InputDecoration(
                      labelText: 'Titre',
                      labelStyle: textStyle
                  ),
                ),
              ),

              // DATE DE FIN ****************
              Padding(
                padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Text(
                        "Date de fin : " + strEndDate
                    ),
                    RaisedButton(
                      child: Icon(Icons.date_range),
                      onPressed: () {
                        showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(DateTime.now().year),
                            lastDate: DateTime(DateTime.now().year + 10)
                        ).then((date) {
                          setState(() {
                            strEndDate = date.day.toString() + "-" + date.month.toString() + "-" + date.year.toString();
                            updateEndDate();
                          });
                        });
                      },
                    ),
                  ],
                ),
              ),

              // AJOUT DES ÉlÉMENTS ****************
              Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0, left: 10.0, right: 10.0),
                  child: TextField(
                    controller: addItemController,
                    style: textStyle,
                    decoration: InputDecoration(
                        labelText: 'Ajouter un élément...',
                        labelStyle: textStyle,
                        suffixIcon: IconButton(
                            icon: Icon(Icons.add),
                            onPressed: (){
                              // Ajoute l'item dans la liste si la longueur du texte est plus grand que 0
                              if(addItemController.text.length > 0) {
                                _addTodoItem(context, new TodoItem(addItemController.text));
                                addItemController.clear();
                                updateListItems();
                              }
                            }
                        )
                    ),
                  )
              ),

              // LISTE DES ELEMENTS ********************
                Expanded(
                    child: getListViewItems()
                ),

              // BOUTONS SAUVEGARDER ET SUPPRIMER *********************
              Padding(
                padding: EdgeInsets.only(top: 15.0, bottom: 10.0, left: 10.0, right: 10.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: RaisedButton(
                        color: Theme.of(context).primaryColor,
                        textColor: Colors.white,
                        child: Text(
                          'Sauvegarder',
                          textScaleFactor: 1.5,
                        ),
                        onPressed: () {
                          setState(() {
                            debugPrint("Save button clicked");
                            _save();
                          });
                        },
                      ),
                    ),

//                    Container(width: 5.0,),

//                    Expanded(
//                      child: RaisedButton(
//                        color: Theme.of(context).primaryColor,
//                        textColor: Colors.white,
//                        child: Text(
//                          'Supprimer',
//                          textScaleFactor: 1.5,
//                        ),
//                        onPressed: () {
//                          setState(() {
//                            debugPrint("Delete button clicked");
//                            _delete();
//                          });
//                        },
//                      ),
//                    ),
                  ],
                ),
              ),
            ],
          )
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  // Met à jour le titre d'une tâche
  void updateTitle(){
    todo.title = titleController.text;
  }

  // Met à jour la date de fin d'une tâche
  void updateEndDate() {
    todo.endDate = strEndDate;
  }

  // Met à jour la liste des tâches à faire
  void updateListItems() {
    setState(() {
      this.listItems = todo.listItems;
    });
  }

  ListView getListViewItems(){
    return ListView.builder(
      itemCount: listItems.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            title: Text(this.listItems[position].name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  onTap: () {
                    //_deleteTodoItem(context, listItems[position], position);
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.delete,color: Colors.red),
                  onTap: () {
                    _deleteTodoItem(context, listItems[position], position);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Save data to database
  void _save() async {
    if (titleController.text.length > 0) {
      moveToLastScreen();

      int result;
      if (todo.numId != null) {  // Case 1: Update operation
        result = await databaseHelper.updateTodo(todo);
      } else { // Case 2: Insert Operation
        result = await databaseHelper.insertTodo(todo);
      }

      if(!bEditMode && this.listItems.length != 0){
        // récupère la tâche que l'on vient de créer pour avoir l'ID
        Todo todoDB = await databaseHelper.getTodoByTitle(todo.title);
        
        // Permet d'ajouter la liste des tâches à faire dans la BD
        for(int i = 0; i < this.listItems.length; i++){
          this.listItems[i].idTodo = todoDB.numId;
          int resItems = await databaseHelper.insertTodoItem(this.listItems[i]);
        }
      }

      if (result != 0) {  // Success
        _showAlertDialog('Status', 'Todo Saved Successfully');
      } else {  // Failure
        _showAlertDialog('Status', 'Problem Saving Todo');
      }
    } else {
      _showAlertDialog("Status", "Veuillez saisir au minimum le titre pour sauvegarder.");
    }
  }

  void _delete() async {
    moveToLastScreen();

    if (todo.numId == null) {
      _showAlertDialog('Status', 'No Todo was deleted');
      return;
    }

    int result = await databaseHelper.deleteTodo(todo.numId);
    if (result != 0) {
      _showAlertDialog('Status', 'Todo Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Todo');
    }
  }

  // Méthode qui permet de supprimer un item (une tâche à faire)
  void _deleteTodoItem(BuildContext context, TodoItem todoItem, int pos) async {
    if(bEditMode){
      int result = await databaseHelper.deleteTodoItem(todoItem.numId);
      if (result != 0) {
        _showSnackBar(context, 'Item supprimé avec succès');
      }
    }
    this.listItems.removeAt(pos);
    updateListItems();
  }

  // Méthode qui permet d'ajouter un item (tâche à faire)
  void _addTodoItem(BuildContext context, TodoItem todoItem) async {
    todoItem.isCompleted = 0;

    if(bEditMode){
      todoItem.idTodo = todo.numId;
      int result = await databaseHelper.insertTodoItem(todoItem);
      if (result != 0) {
        //_showSnackBar(context, 'Item ajouté avec succès');
      }
    }
    todo.listItems.add(todoItem);
    updateListItems();
  }

  void _showSnackBar(BuildContext context, String message) {
    final snackBar = SnackBar(content: Text(message));
    Scaffold.of(context).showSnackBar(snackBar);
  }

  void _showAlertDialog(String title, String message) {

    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }
}