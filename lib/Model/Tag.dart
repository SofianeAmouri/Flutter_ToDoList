final String tableName = "tags";
final String colId = 'id';
final String colLibelle = 'libelle';

class Tag {
  int _numId;
  String _libelle;
  bool _isSelected;

  Tag(this._libelle);

  int get numId => _numId;
  String get libelle => _libelle;
  bool get isSelected => _isSelected;

  set libelle(String value) {
    this._libelle = value;
  }

  set isSelected(bool value) {
    this._isSelected = value;
  }

  set numId(int value) {
    this._numId = value;
  }

  // Convert a Note object into a Map object
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      colLibelle: _libelle
    };
    if (_numId != null) {
      map[colId] = _numId;
    }
    return map;
  }

  // Extract a Note object from a Map object
  Tag.fromMap(Map<String, dynamic> map) {
    this._numId = map[colId];
    this._libelle = map[colLibelle];
  }
}