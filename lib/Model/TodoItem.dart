final String tableName = "todoitem";
final String colId = '_id';
final String colFkTodo = "fk_todo";
final String colName = "name";
final String colIsCompleted = "isCompleted";

class TodoItem{
  int id;
  int fkTodo;
  String name;
  bool isCompleted;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colFkTodo: fkTodo,
      colName: name,
      colIsCompleted: isCompleted
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  TodoItem();

  TodoItem.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    fkTodo = map[colFkTodo];
    name = map[colName];
    isCompleted = map[colIsCompleted];
  }
}