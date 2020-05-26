final String tableName = "todoitem";
final String colId = 'id';
final String colFkTodo = "fk_todo";
final String colName = "name";
final String colIsCompleted = "isCompleted";

class TodoItem{
  int _numId;
  int _idTodo;
  String _name;
  bool _isCompleted;

  TodoItem(this._name);

  //TodoItem.withName(this._name);

  int get numId => _numId;
  int get idTodo => _idTodo;
  String get name => _name;
  bool get isCompleted => _isCompleted;

  set numId(int newNumId) {
    this._numId = newNumId;
  }

  set idTodo(int newIdTodo) {
    this._idTodo = newIdTodo;
  }

  set name(String newName) {
    this._name = newName;
  }

  set isCompleted(bool newIsCompleted) {
    this._isCompleted = newIsCompleted;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colFkTodo: _idTodo,
      colName: _name,
      colIsCompleted: _isCompleted
    };
    if (_numId != null) {
      map[colId] = _numId;
    }
    return map;
  }

  // Extract a Note object from a Map object
  TodoItem.fromMap(Map<String, dynamic> map) {
    this._numId = map[colId];
    this._idTodo = map[colFkTodo];
    this._name = map[colName];
    this._isCompleted = map[colIsCompleted];
  }
}