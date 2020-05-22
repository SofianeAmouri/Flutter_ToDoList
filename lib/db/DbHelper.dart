import 'package:sqflite/sqflite.dart';

class DbHelper{

  //static DbHelper dbHelper;
  //static Database database;

  // Table TODO
  static String TABLE_TODO = "todo";
  static String COL_TITLE = "title";
  static String COL_ENDDATE = "endDate";
  static String COL_IMG = "imgPath";
  static String COL_BGCOLOR = "color";

  // Table TodoItem
  static String TABLE_TODOITEM = "todoitem";
  static String COL_FK_TODO = "fk_todo";
  static String COL_NAME = "name";
  static String COL_ISCOMPLETED = "isCompleted";

  // Table Tags
  static String TABLE_TAGS = "tags";
  static String COL_LIBELLE = "libelle";

  // Table associative Tags - Todo
  static String TABLE_TAGTODO = "tagtodo";
  static String COL_FK_TAG = "fk_tag";
  //static String COL_FK_TODO = "fk_todo";


  // Création de la requête SQL pour créer la table ToDo
  static final String CREATE_TODO =
      "CREATE TABLE " + TABLE_TODO + " (" +
          "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
          COL_TITLE + " TEXT NOT NULL UNIQUE," +
          COL_ENDDATE + " DATE," +
          COL_IMG + " TEXT," +
          COL_BGCOLOR + " INTEGER " +
          ")";

  // Création de la requête SQL pour créer la table ToDoItem
  static final String CREATE_TODO_ITEM =
      "CREATE TABLE " + TABLE_TODOITEM + " (" +
          "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
          COL_NAME + " TEXT," +
          COL_ISCOMPLETED + " INTEGER," +
          COL_FK_TODO + " INTEGER NOT NULL," +
          "UNIQUE(" + COL_FK_TODO + ", " + COL_NAME + ")" +
          ")";

  // Création de la requête SQL pour créer la table ToDoItem
  static final String CREATE_TAGS =
      "CREATE TABLE " + TABLE_TAGS + " (" +
          "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
          COL_LIBELLE + " TEXT NOT NULL UNIQUE" + ")";

  // Création de la requête SQL pour créer la table TagTodo (pour les liens entre les deux tables)
  static final String CREATE_TAG_TODO =
      "CREATE TABLE " + TABLE_TAGTODO + " (" +
          "ID INTEGER PRIMARY KEY AUTOINCREMENT," +
          COL_FK_TAG + " INTEGER NOT NULL," +
          COL_FK_TODO + " INTEGER NOT NULL," +
          "UNIQUE(" + COL_FK_TAG + ", " + COL_FK_TODO + ")" +
          ")";

  static Database _db;

  static int get _version => 1;

  static Future<void> init() async {

    if (_db != null) { return; }

    try {
      String _path = await getDatabasesPath() + 'todolist.db';
      _db = await openDatabase(_path, version: _version, onCreate: onCreate);
    }
    catch(ex) {
      print(ex);
    }
  }

  static void onCreate(Database db, int version) async {
    await db.execute(CREATE_TODO);
    await db.execute(CREATE_TODO_ITEM);
    await db.execute(CREATE_TAGS);
    await db.execute(CREATE_TAG_TODO);
  }


//  static Future<List<Map<String, dynamic>>> query(String table) async => _db.query(table);

//  static Future<int> insert(String table, Model model) async =>
//      await _db.insert(table, model.toMap());
//
//  static Future<int> update(String table, Model model) async =>
//      await _db.update(table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);
//
//  static Future<int> delete(String table, Model model) async =>
//      await _db.delete(table, where: 'id = ?', whereArgs: [model.id]);


}