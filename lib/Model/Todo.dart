import 'package:fluttertodolist/Model/Tag.dart';
import 'package:fluttertodolist/Model/TodoItem.dart';

final String tableName = "todo";
final String colId = 'id';
final String colTitle = "title";
final String colEndDate = "endDate";
final String colImgPath = "imgPath";
final String colBgColor = "bgColor";

class Todo {
  int _numId;
  String _title;
  String _endDate;
  String _imgPath;
  String _color;
  List<TodoItem> _listItems;
  List<Tag> _listTags;

  //Todo();

  Todo(this._title, this._endDate);

  Todo.withId(this._numId, this._title, this._endDate);

  int get numId => _numId;
  String get title => _title;
  String get endDate => _endDate;
  String get imgPath => _imgPath;
  String get color => _color;
  List<TodoItem> get listItems => _listItems;
  List<Tag> get listTags => _listTags;

  set numId(int newNumId) {
    this._numId = newNumId;
  }

  set title(String newTitle) {
    this._title = newTitle;
  }

  set endDate(String newEndDate) {
    this._endDate = newEndDate;
  }

  set imgPath(String newImgPath) {
    this._imgPath = newImgPath;
  }

  set color(String newColor) {
    this._color = newColor;
  }

  set listItems(List<TodoItem> newListItems) {
    this._listItems = newListItems;
  }

  set listTags(List<Tag> newListTags) {
    this._listTags = newListTags;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: _title,
      colEndDate: _endDate,
      colImgPath: _imgPath,
      colBgColor: _color
    };
    if (_numId != null) {
      map[colId] = _numId;
    }
    return map;
  }

  // Extract a Note object from a Map object
  Todo.fromMap(Map<String, dynamic> map) {
    this._numId = map[colId];
    this._title = map[colTitle];
    this._endDate = map[colEndDate];
    this._imgPath = map[colImgPath];
    this._color = map[colBgColor];
  }
}