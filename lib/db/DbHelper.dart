import 'dart:io';

import 'package:fluttertodolist/Model/Todo.dart';
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

  // Table associative Tags - Todo
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

//		var result = await db.rawQuery('SELECT * FROM $todoTable order by $colTitle ASC');
    var result = await db.query(tableTodo);
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

  // Get the 'Map List' [ List<Map> ] and convert it to 'todo List' [ List<Todo> ]
  Future<List<Todo>> getTodoList() async {

    var todoMapList = await getTodoMapList(); // Get 'Map List' from database
    int count = todoMapList.length;         // Count the number of map entries in db table

    List<Todo> todoList = List<Todo>();
    // For loop to create a 'todo List' from a 'Map List'
    for (int i = 0; i < count; i++) {
      todoList.add(Todo.fromMap(todoMapList[i]));
    }

    return todoList;
  }
}