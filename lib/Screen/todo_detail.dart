import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/Model/Todo.dart';
import 'package:fluttertodolist/Model/TodoItem.dart';
import 'package:fluttertodolist/db/DbHelper.dart';

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

  DbHelper helper = DbHelper();

  String appBarTitle;
  Todo todo;
  List<TodoItem> listItems;
  List<Tag> listTags;

  TextEditingController titleController = TextEditingController();
  TextEditingController addItemController = TextEditingController();
  String strEndDate;

  TodoDetailState(this.todo, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    listItems = List<TodoItem>();
    listTags = List<Tag>();

    titleController.text = todo.title;
    strEndDate = todo.endDate;
    listItems = todo.listItems;
    listTags = todo.listTags;

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

          body: Padding(
            padding: EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
            child: ListView(
              children: <Widget>[

                // TITRE ***********
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
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

                // DATE DE FIN ************
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
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

                // AJOUT DES ÉlÉMENTS ************
                Padding(
                  padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
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
                                
                              }
                                // updateListViewItems()
                            }
                        )
                    ),
                  ),
                ),

                // LISTE DES ELEMENTS **************

                // BOUTONS SAUVEGARDER ET SUPPRIMER
                Padding(
                  padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
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

                      Container(width: 5.0,),

                      Expanded(
                        child: RaisedButton(
                          color: Theme.of(context).primaryColor,
                          textColor: Colors.white,
                          child: Text(
                            'Supprimer',
                            textScaleFactor: 1.5,
                          ),
                          onPressed: () {
                            setState(() {
                              debugPrint("Delete button clicked");
                              _delete();
                            });
                          },
                        ),
                      ),

                    ],
                  ),
                ),


              ],
            ),
          ),

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
  void updateListItems(){

  }

  ListView getListViewItems(){
    return ListView.builder(
      itemCount: 0,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: CircleAvatar(
                backgroundColor: Colors.amber
            ),
            title: Text(this.listItems[position].name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.delete,color: Colors.red,),
                  onTap: () {

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

    moveToLastScreen();

    int result;
    if (todo.numId != null) {  // Case 1: Update operation
      result = await helper.updateTodo(todo);
    } else { // Case 2: Insert Operation
      result = await helper.insertTodo(todo);
    }

    if (result != 0) {  // Success
      _showAlertDialog('Status', 'Todo Saved Successfully');
    } else {  // Failure
      _showAlertDialog('Status', 'Problem Saving Todo');
    }

  }

  void _delete() async {

    moveToLastScreen();

    if (todo.numId == null) {
      _showAlertDialog('Status', 'No Todo was deleted');
      return;
    }

    int result = await helper.deleteTodo(todo.numId);
    if (result != 0) {
      _showAlertDialog('Status', 'Todo Deleted Successfully');
    } else {
      _showAlertDialog('Status', 'Error Occured while Deleting Todo');
    }
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