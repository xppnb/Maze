import 'dart:math';

///迷宫游戏数据层
class MazeGameModel {
  ///迷宫行数
  int _gameRowSize;

  ///迷宫列数
  int _gameColumnSize;

  ///迷宫入口坐标
  int _startX;
  int _startY;

  ///迷宫出口坐标
  int _endX;
  int _endY;

  ///玩家坐标
  int playerX;
  int playerY;

  static final int MAP_ROAD = 1; //1代表路

  static final int MAP_WALL = 0; //0代表墙

  ///游戏方向，总共有四个方向。(向上，向左，向右，向下)
  List<List<int>> direction = [
    [-1, 0],
    [0, -1],
    [0, 1],
    [1, 0]
  ];

  ///设置路径是否被访问过
  List<List<bool>> visitedList;

  ///设置迷宫地图
  List<List<int>> mazeList;

  ///解迷宫路径
  List<List<bool>> pathList;

  MazeGameModel(int gameRowSize, int gameColumnSize) {
    if (gameRowSize % 2 == 0 || gameColumnSize == 0) {
      throw "迷宫行数和列数不能为偶数";
    }

    this._gameRowSize = gameRowSize;
    this._gameColumnSize = gameColumnSize;

    //迷宫的起点
    _startX = 1;
    _startY = 0;

    //迷宫的终点
    _endX = gameRowSize - 2;
    _endY = gameColumnSize - 1;

    //初始化玩家坐标
    playerX = _startX;
    playerY = _startY;

    mazeList = new List<List<int>>();
    visitedList = new List<List<bool>>();
    pathList = new List<List<bool>>();

    //初始化迷宫遍历的方向（上、左、右、下）顺序（迷宫趋势）
    //随机遍历顺序，提高迷宫生成的随机性（共12种可能性）
    List.generate(direction.length, (index) {
      int random = Random().nextInt(direction.length);
      List<int> temp = direction[random];
      direction[random] = direction[index];
      direction[index] = temp;
    });

    //初始化迷宫地图
    List.generate(gameRowSize, (i) {
      List<bool> tempVisited = new List();
      List<int> tempMazeList = new List();
      List<bool> tempPath = new List();
      List.generate(gameColumnSize, (j) {
        //行和列为基数都设置为路，否则设置为墙
        if (i % 2 == 1 && j % 2 == 1) {
          tempMazeList.add(1); //设置为路
        } else {
          tempMazeList.add(0); //设置为墙
        }
        //初始化访问，所有都没有访问过
        tempVisited.add(false);
        tempPath.add(false);
      });
      visitedList.add(tempVisited);
      mazeList.add(tempMazeList);
      pathList.add(tempPath);
    });

    //初始化迷宫的起点和终点
    mazeList[_startX][_startY] = 1;
    mazeList[_endX][_endY] = 1;
  }

  ///获取迷宫行数
  int getGameRowSize() {
    return _gameRowSize;
  }

  ///获取迷宫列数
  int getGameColumnSize() {
    return _gameColumnSize;
  }

  ///获取迷宫的起点的X坐标
  int getStartX() {
    return _startX;
  }

  ///获取迷宫的起点的Y坐标
  int getStartY() {
    return _startY;
  }

  ///获取迷宫的终点的X坐标
  int getEndX() {
    return _endX;
  }

  ///获取迷宫的终点的Y坐标
  int getEndY() {
    return _endY;
  }

  ///用来判断mazeList[i][j]是否在地图内
  bool isInMap(int i, int j) {
    return i >= 0 && i < _gameRowSize && j >= 0 && j < _gameColumnSize;
  }
}
