import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/Model/TagTodo.dart';
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
  List<Tag> listAllTags;

  TextEditingController titleController = TextEditingController();
  TextEditingController addItemController = TextEditingController();
  String strEndDate;

  TodoDetailState(this.todo, this.appBarTitle);

  @override
  Widget build(BuildContext context) {

    TextStyle textStyle = Theme.of(context).textTheme.title;

    // Initialise les listes
    this.listAllTags = List<Tag>();
    _uploadListTags();

    // Récupère les infos de la tâche
    titleController.text = todo.title;
    strEndDate = todo.endDate;

    // Mode édition pour gérer l'enregistrement dans la BD
    if(todo.numId == null) {
      bEditMode = false; // signifie que la tâche ne possède pas encore de donnée dans la BDD, donc les items ne peuvent pas être enregistré direct dans la BD
    }
    else{
      bEditMode = true;
      _updateListTags();
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
            actions: <Widget>[

              // action button pour récupérer une photo de la gallerie
              IconButton(
                icon: Icon(Icons.add_a_photo),
                onPressed: () {

                },
              ),
              // action button pour les libellés
              IconButton(
                icon: Icon(Icons.label_outline),
                onPressed: () {
                  _showSelectTags();
                },
              ),
            ],
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
                                //updateListItems();
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

  // ListView qui permet d'afficher la listes des tâches (items)
  ListView getListViewItems(){
    return ListView.builder(
      itemCount: this.todo.listItems.length,
      itemBuilder: (BuildContext context, int position) {
        return Card(
          color: Colors.white,
          elevation: 2.0,
          child: ListTile(
            leading: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
            title: Text(this.todo.listItems[position].name,
                style: TextStyle(fontWeight: FontWeight.bold)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                GestureDetector(
                  child: Icon(Icons.edit, color: Theme.of(context).primaryColor),
                  onTap: () {
                    // Bouton pour la modification
                  },
                ),
                GestureDetector(
                  child: Icon(Icons.delete,color: Colors.red),
                  onTap: () {
                    _deleteTodoItem(context, this.todo.listItems[position], position);
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

      if(!bEditMode && this.todo.listItems.length != 0){
        // récupère la tâche que l'on vient de créer pour avoir l'ID
        Todo todoDB = await databaseHelper.getTodoByTitle(todo.title);
        
        // Permet d'ajouter la liste des tâches à faire dans la BD
        for(int i = 0; i < this.todo.listItems.length; i++){
          this.todo.listItems[i].idTodo = todoDB.numId;
          int resItems = await databaseHelper.insertTodoItem(this.todo.listItems[i]);
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

  // Méthode qui permet de supprimer un item (une tâche à faire)
  void _deleteTodoItem(BuildContext context, TodoItem todoItem, int pos) async {
    if(bEditMode){
      int result = await databaseHelper.deleteTodoItem(todoItem.numId);
      if (result != 0) {
        _showSnackBar(context, 'Item supprimé avec succès');
      }
    }
    setState(() {
      this.todo.listItems.removeAt(pos);
    });
    //updateListItems();
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
    setState(() {
      todo.listItems.add(todoItem);
    });
  }

  // Méthode qui permet de récupérer la liste de tous les tags
  void _uploadListTags(){
    // Récupère tous les tags existants
    final Future<Database> dbFuture = databaseHelper.initDatabase();
    dbFuture.then((database) {
      Future<List<Tag>> tagsListFuture = databaseHelper.getTagsList();
      tagsListFuture.then((tagList) {
        this.listAllTags = tagList;
      });
    });
  }

  // Méthode qui permet d'initialiser les tags qui ont deja été sélectionné
  void _updateListTags() {
    // Permet de mettre le mode sélection sur les tags qui sont présent dans la tâche
    for(int i = 0; i < this.todo.listTags.length; i++){
      for(int y = 0; y < this.listAllTags.length; i++) {
        if(this.listAllTags[y].libelle == this.todo.listTags[i].libelle){
          this.listAllTags[y].isSelected = true;
        } else {
          this.listAllTags[y].isSelected = false;
        }
      }
    }
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

  void _showSelectTags() {
    //uploadListTags();
    AlertDialog alertDialog = AlertDialog(
      title: Text("Libellés"),
      content: setupAlertDialogTag(),
    );
    showDialog(
        context: context,
        builder: (_) => alertDialog
    );
  }

  Widget setupAlertDialogTag() {
    return Container(
      height: 300.0, // Change as per your requirement
      width: 300.0, // Change as per your requirement
      child: ListView.builder(
        itemCount: this.listAllTags.length,
        itemBuilder: (BuildContext context, int position) {
          return new TagTodoDetail(tag: this.listAllTags[position], todo: this.todo, bEditMode: this.bEditMode);
        },
      ),
    );
  }
}

class TagTodoDetail extends StatefulWidget {
  final Tag tag;
  final Todo todo;
  final bool bEditMode;

  @override
  TagTodoState createState() => TagTodoState(tag, todo, bEditMode);
  TagTodoDetail({Key key, @required this.tag, this.todo, this.bEditMode}) : super(key: key);

}

class TagTodoState extends State<TagTodoDetail> {
  final Tag tag;
  final Todo todo;
  final bool bEditMode;

  DbHelper databaseHelper = DbHelper();

  TagTodoState(this.tag, this.todo, this.bEditMode);

  @override
  Widget build(BuildContext context) {

    setState(() {
      for(int i = 0; i < this.todo.listTags.length; i++){
        if(this.todo.listTags[i].libelle == tag.libelle){
          tag.isSelected = true;
        }
      }
    });


    return _getContent();
  }

  _getContent() {
    return Card(
      color: this.tag.isSelected ? Colors.white60 : Colors.white,
      elevation: 2.0,
      child: ListTile(
        leading: Icon(Icons.chevron_right, color: Theme.of(context).primaryColor),
        title: Text(this.tag.libelle,
            style: TextStyle(fontWeight: FontWeight.bold)),
        onTap: () {
          debugPrint("CARD TAG PRESSED");
          setState(() {
            if(this.tag.isSelected) {
              _deleteTagTodo();
            }
            else {
              _insertTagTodo();
            }
          });
        },
      ),
    );
  }



  _updateTagTodo(Tag tag){

  }

  _insertTagTodo() async {
    if(bEditMode){
      int result = await databaseHelper.insertTagTodo(new TagTodo(this.tag.numId, this.todo.numId));
      if(result != 0) {
        debugPrint("INSERT TAG TODO");
      }
    }
    setState(() {
      this.tag.isSelected = true;
      this.todo.listTags.add(this.tag);
    });
  }

  _deleteTagTodo() async {
    if(bEditMode) {
      int result = await databaseHelper.deleteTagTodo(tag.numId, todo.numId);
      if(result != 0) {
        debugPrint("DELETE TAG TODO");
      }
    }
    setState(() {
      this.tag.isSelected = false;
      for(int i = 0;i<this.todo.listTags.length;i++){
        if(this.todo.listTags[i].libelle == this.tag.libelle){
          this.todo.listTags.removeAt(i);
          break;
        }
      }
    });
  }

}