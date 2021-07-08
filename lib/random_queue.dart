import 'dart:collection';
import 'dart:math';

import 'package:maze_game2/position.dart';

///随机队列
class RandomQueue {
  LinkedList<Position> _queue;

  RandomQueue() {
    _queue = new LinkedList();
  }

  ///随机添加队列
  void addRandomQueue(Position position) {
    if (Random().nextInt(100) < 50) {
      //从头部添加
      _queue.addFirst(position);
    } else {
      //从尾部添加
      _queue.add(position);
    }
  }

  ///返回随机队列中的一个元素
  Position removeRandomQueue() {
    if (_queue.length == 0) {
      throw "数组为空";
    } else {
      if (Random().nextInt(100) < 50) {
        Position position = _queue.first;
        _queue.remove(position);
        return position;
      } else {
        Position position = _queue.last;
        _queue.remove(position);
        return position;
      }
    }
  }

  //返回随机队列元素数量
  int getSize() {
    return _queue.length;
  }

  //判断随机队列是否为空
  bool isEmpty() {
    return _queue.length == 0;
  }
}
