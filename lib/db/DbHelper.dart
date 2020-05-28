import 'dart:io';

import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/Model/TagTodo.dart';
import 'package:fluttertodolist/Model/Todo.dart';
import 'package:fluttertodolist/Model/TodoItem.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class DbHelper{

  static String colId = "id";

  // Table TODO
  static String tableTodo = "todo";
  static String colTitle = "title";
  static String colEndDate = "endDate";
  static String colImgPath = "imgPath";
  static String colBgColor = "bgColor";

  // Table TodoItem
  static String tableTodoItem = "todoitem";
  static String colFkTodo = "fk_todo";
  static String colName = "name";
  static String colIsCompleted = "isCompleted";

  // Table Tags
  static String tableTags = "tags";
  static String colLibelle = "libelle";

  // Table associative Tag_Todo
  static String tableTagTodo = "tagtodo";
  static String colFkTag = "fk_tag";
  //static String COL_FK_TODO = "fk_todo";


  // Création de la requête SQL pour créer la table ToDo
  static final String createTodo =
      "CREATE TABLE " + tableTodo + " (" +
          colId + " INTEGER PRIMARY KEY AUTOINCREMENT," +
          colTitle + " TEXT NOT NULL UNIQUE," +
          colEndDate + " DATE," +
          colImgPath + " TEXT," +
          colBgColor + " INTEGER " +
          ")";

  // Création de la requête SQL pour créer la table ToDoItem
  static final String createTodoItem =
      "CREATE TABLE " + tableTodoItem + " (" +
          colId + " INTEGER PRIMARY KEY AUTOINCREMENT," +
          colName + " TEXT," +
          colIsCompleted + " INTEGER," +
          colFkTodo + " INTEGER NOT NULL," +
          "UNIQUE(" + colFkTodo + ", " + colName + ")" +
          ")";

  // Création de la requête SQL pour créer la table ToDoItem
  static final String createTags =
      "CREATE TABLE " + tableTags + " (" +
          colId + " INTEGER PRIMARY KEY AUTOINCREMENT," +
          colLibelle + " TEXT NOT NULL UNIQUE" + ")";

  // Création de la requête SQL pour créer la table TagTodo (pour les liens entre les deux tables)
  static final String createTagTodo =
      "CREATE TABLE " + tableTagTodo + " (" +
          colId + " INTEGER PRIMARY KEY AUTOINCREMENT," +
          colFkTag + " INTEGER NOT NULL," +
          colFkTodo + " INTEGER NOT NULL," +
          "UNIQUE(" + colFkTag + ", " + colFkTodo + ")" +
          ")";

  static DbHelper _dbHelper; // Singletin DatabaseHelper
  static Database _db; // Singletin Database

  DbHelper._createInstance(); // Named constructor to create instance of DatabaseHelper

  factory DbHelper() {
    if(_dbHelper == null) {
      _dbHelper = DbHelper._createInstance(); // This is executed only once, singleton object
    }
    return _dbHelper;
  }

  Future<Database> get database async {

    if (_db == null) {
      _db = await initDatabase();
    }
    return _db;
  }

  Future<Database> initDatabase() async {
    // Get the directory path for both Android and iOS to store database.
    Directory directory = await getApplicationDocumentsDirectory();
    String path = directory.path + 'todolist.db';

    // Open/create the database at a given path
    var todolistDatabase = await openDatabase(path, version: 1, onCreate: _createDb);
    return todolistDatabase;
  }

  void _createDb(Database db, int newVersion) async {
    await db.execute(createTodo);
    await db.execute(createTodoItem);
    await db.execute(createTags);
    await db.execute(createTagTodo);
  }


  /* ***********************************************
  *  *****             TABLE TODO              *****
  *  ***********************************************/

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTodoMapList() async {
    Database db = await this.database;

		var result = await db.rawQuery('SELECT * FROM $tableTodo order by $colId ASC');
    //var result = await db.query(tableTodo);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTodoMap(String title) async {
    Database db = await this.database;

		var result = await db.rawQuery('SELECT * FROM $tableTodo WHERE $colTitle = $title');
//    var result = await db.query(tableTodo);
    return result;
  }

  // Insert Operation: Insert a todo object to database
  Future<int> insertTodo(Todo todo) async {
    Database db = await this.database;
    var result = await db.insert(tableTodo, todo.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateTodo(Todo todo) async {
    var db = await this.database;
    var result = await db.update(tableTodo, todo.toMap(), where: '$colId = ?', whereArgs: [todo.numId]);
    return result;
  }


  // Delete Operation: Delete a todo object from database
  Future<int> deleteTodo(int id) async {
    var db = await this.database;
    int resTodoItem = await db.rawDelete('DELETE FROM $tableTodoItem WHERE $colFkTodo = $id'); // supprime tous les items liés à la tâche
    int resTagTodo = await db.rawDelete('DELETE FROM $tableTagTodo WHERE $colFkTodo = $id'); // supprime tous les tags liés à la tâche
    int result = await db.rawDelete('DELETE FROM $tableTodo WHERE $colId = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCount() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tableTodo');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Récupère une tâche grâce à son nom
  Future<Todo> getTodoByTitle(String title) async {
    var todoMapList = await getTodoMapList();
    int count = todoMapList.length;

    Todo todo = Todo.fromMap(todoMapList.last);

    return todo;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<Todo>> getTodoList() async {

    var todoMapList = await getTodoMapList(); // Get 'Map List' from database
    int count = todoMapList.length;         // Count the number of map entries in db table

    List<Todo> todoList = List<Todo>();
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromMap(todoMapList[i]));
      todoList[i].listItems = await getTodoItemList(todoList[i].numId); // ajoute la liste des tâches à faire pour chaque tâche
      todoList[i].listTags = await getTagTodoList(todoList[i].numId); // ajoute la liste des tags liés à la tâche
    }

    return todoList;
  }

  /* ***********************************************
   *  *****             TABLE TAG              *****
   *  ***********************************************/

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTagMapList() async {
    Database db = await this.database;

//		var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');
    var result = await db.query(tableTags);
    return result;
  }

  Future<List<Map<String, dynamic>>> getTagMap(int id) async {
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $tableTags WHERE $colId = $id');
//    var result = await db.query(tableTodo);
    return result;
  }

  // Insert Operation: Insert a tag object to database
  Future<int> insertTag(Tag tag) async {
    Database db = await this.database;
    var result = await db.insert(tableTags, tag.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateTag(Tag tag) async {
    var db = await this.database;
    var result = await db.update(tableTags, tag.toMap(), where: '$colId = ?', whereArgs: [tag.numId]);
    return result;
  }


  // Delete Operation: Delete a todo object from database
  Future<int> deleteTag(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tableTags WHERE $colId = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCountTags() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tableTags');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<Tag>> getTagsList() async {

    var tagMapList = await getTagMapList(); // Get 'Map List' from database
    int count = tagMapList.length;         // Count the number of map entries in db table

    List<Tag> tagList = List<Tag>();
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      tagList.add(Tag.fromMap(tagMapList[i]));
    }

    return tagList;
  }

  // Récupère une tâche grâce à son nom
  Future<Tag> getTagByID(int id) async {
    var tagMapList = await getTagMap(id);
    int count = tagMapList.length;

    Tag tag = Tag.fromMap(tagMapList.last);

    return tag;
  }

  /* ***********************************************
   *  *****             TABLE TODOITEM              *****
   *  ***********************************************/

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTodoItemMapList(int idTodo) async {
    Database db = await this.database;

		var result = await db.rawQuery('SELECT * FROM $tableTodoItem WHERE $colFkTodo = $idTodo ORDER BY $colId ASC');
    //var result = await db.query(tableTodoItem);
    return result;
  }

  // Insert Operation: Insert a tag object to database
  Future<int> insertTodoItem(TodoItem todoItem) async {
    Database db = await this.database;
    var result = await db.insert(tableTodoItem, todoItem.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateTodoItem(TodoItem todoItem) async {
    var db = await this.database;
    var result = await db.update(tableTodoItem, todoItem.toMap(), where: '$colId = ?', whereArgs: [todoItem.numId]);
    return result;
  }


  // Delete Operation: Delete a todo object from database
  Future<int> deleteTodoItem(int id) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tableTodoItem WHERE $colId = $id');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCountTodoItem() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tableTodoItem');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<TodoItem>> getTodoItemList(int idTodo) async {

    var todoItemMapList = await getTodoItemMapList(idTodo); // Get 'Map List' from database
    int count = todoItemMapList.length;         // Count the number of map entries in db table

    List<TodoItem> todoItemList = List<TodoItem>();
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoItemList.add(TodoItem.fromMap(todoItemMapList[i]));
    }

    return todoItemList;
  }

  /* ***********************************************
   *  *****             TABLE TagTodo              *****
   *  ***********************************************/

  // Fetch Operation: Get all todo objects from database
  Future<List<Map<String, dynamic>>> getTagTodoMapList(int idTodo) async {
    Database db = await this.database;

    var result = await db.rawQuery('SELECT * FROM $tableTagTodo WHERE $colFkTodo = $idTodo');
    //var result = await db.query(tableTodoItem);
    return result;
  }

  // Insert Operation: Insert a tag object to database
  Future<int> insertTagTodo(TagTodo tagTodo) async {
    Database db = await this.database;
    var result = await db.insert(tableTagTodo, tagTodo.toMap());
    return result;
  }

  // Update Operation: Update a todo object and save it to database
  Future<int> updateTagTodo(TagTodo tagTodo) async {
    var db = await this.database;
    var result = await db.update(tableTagTodo, tagTodo.toMap(), where: '$colId = ?', whereArgs: [tagTodo.numId]);
    return result;
  }


  // Delete Operation: Delete a todo object from database
  Future<int> deleteTagTodo(int idTag, int idTodo) async {
    var db = await this.database;
    int result = await db.rawDelete('DELETE FROM $tableTagTodo WHERE $colFkTag = $idTag AND $colFkTodo = $idTodo');
    return result;
  }

  // Get number of todo objects in database
  Future<int> getCountTagTodo() async {
    Database db = await this.database;
    List<Map<String, dynamic>> x = await db.rawQuery('SELECT COUNT (*) from $tableTagTodo');
    int result = Sqflite.firstIntValue(x);
    return result;
  }

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<Tag>> getTagTodoList(int idTodo) async {

    var tagTodoMapList = await getTagTodoMapList(idTodo);
    int count = tagTodoMapList.length;

    List<TagTodo> tagTodoList = List<TagTodo>();
    List<Tag> tagList = List<Tag>();

    for (int i = 0; i < count; i++) {
      tagTodoList.add(TagTodo.fromMap(tagTodoMapList[i]));

      // Récupère le tag grâce a l'id du lien entre tag et tâche
      Tag tagMap = await getTagByID(tagTodoList[i].numIdTag);
      tagList.add(tagMap);
    }

    return tagList;
  }
}