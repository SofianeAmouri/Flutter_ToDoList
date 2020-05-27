final String tableName = "tagtodo";
final String colId = 'id';
final String colFkTag = "fk_tag";
final String colFkTodo = "fk_todo";

class TagTodo {
  int _numId;
  int _numIdTag;
  int _numIdTodo;

  TagTodo(this._numIdTag, this._numIdTodo);

  int get numId => _numId;
  int get numIdTag => _numIdTag;
  int get numIdTodo => _numIdTodo;

  set numId(int value) {
    this._numId = value;
  }

  set numIdTag(int value) {
    this._numIdTag = value;
  }

  set numIdTodo(int value) {
    this._numIdTodo = value;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colFkTag: _numIdTag,
      colFkTodo: _numIdTodo
    };
    if (_numId != null) {
      map[colId] = _numId;
    }
    return map;
  }

  // Extract a Note object from a Map object
  TagTodo.fromMap(Map<String, dynamic> map) {
    this._numId = map[colId];
    this._numIdTag = map[colFkTag];
    this._numIdTodo = map[colFkTodo];
  }
}