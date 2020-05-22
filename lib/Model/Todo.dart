final String tableName = "todo";
final String colId = '_id';
final String colTitle = "title";
final String colEndDate = "endDate";
final String colImgPath = "imgPath";
final String colBgColor = "color";

class Todo {
  int id;
  String title;
  String endDate;
  String imgPath;
  String color;

  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colTitle: title,
      colEndDate: endDate,
      colImgPath: imgPath,
      colBgColor: color
    };
    if (id != null) {
      map[colId] = id;
    }
    return map;
  }

  Todo();

  Todo.fromMap(Map<String, dynamic> map) {
    id = map[colId];
    title = map[colTitle];
    endDate = map[colEndDate];
    imgPath = map[colImgPath];
    color = map[colBgColor];
  }
}