import 'dart:collection';

///位置类（实体类）
class Position extends LinkedListEntry<Position> {
  int _x, _y;
  Position _prePosition;

  Position(int x, int y, {Position prePostion = null}) {
    this._x = x;
    this._y = y;
    this._prePosition = prePostion;
  }

  ///返回X坐标
  int getX() {
    return _x;
  }

  ///返回Y坐标
  int getY() {
    return _y;
  }

  ///返回上一个位置
  Position getPrePosition() {
    return _prePosition;
  }
}
