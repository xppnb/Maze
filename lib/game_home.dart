import 'dart:async';

import 'package:flutter/material.dart';
import 'package:maze_game2/maze_game_model.dart';
import 'package:maze_game2/position.dart';
import 'package:maze_game2/random_queue.dart';

class GameHome extends StatefulWidget {
  const GameHome({Key key}) : super(key: key);

  @override
  _GameHomeState createState() => _GameHomeState();
}

enum Direction { left, right, up, down }

class _GameHomeState extends State<GameHome> {
  ///游戏行长度
  int gameRowSize = 15;

  ///游戏列长度
  int gameColumnSize = 15;

  ///格子大小
  int cellSize = 0;

  ///屏幕高度
  double screenHeight = 0;

  ///屏幕宽度
  double screenWidth = 0;

  ///迷宫游戏区域
  int gameHeight = 0;

  ///关卡数
  int level = 1;

  ///迷宫游戏数据层
  MazeGameModel model;

  ///x轴识别
  double moveX;

  ///y轴识别
  double moveY;

  ///手势移动初始化X轴
  double initMoveX;

  ///手势移动初始化Y轴
  double initMoveY;

  ///提示功能
  bool isTip = false;

  ///定时器
  Timer timer;

  ///计时时间
  int timeNum = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    model = new MazeGameModel(gameRowSize, gameColumnSize);

    //开始生成地图
    _createMap(model.getStartX(), model.getStartY() + 1);

    //开始定时器
    setTimer(level);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    screenWidth = size.width;
    screenHeight = size.height;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("迷宫游戏"),
            Text("第$level关 (${gameRowSize}x$gameColumnSize)")
          ],
        ),
      ),
      body: GestureDetector(
        onHorizontalDragStart: (DragStartDetails startDetails) {
          initMoveX = startDetails.localPosition.dx;
        },
        onHorizontalDragUpdate: (DragUpdateDetails updateDetails) {
          moveX = updateDetails.localPosition.dx;
        },
        onHorizontalDragEnd: (DragEndDetails details) {
          initMoveX - moveX > 0 ? print('左边') : print('右边');
          if (initMoveX - moveX > 0) {
            playerMove(Direction.left);
          } else {
            playerMove(Direction.right);
          }
        },
        onVerticalDragStart: (DragStartDetails startDetails) {
          initMoveY = startDetails.localPosition.dy;
        },
        onVerticalDragUpdate: (DragUpdateDetails details) {
          moveY = details.localPosition.dy;
        },
        onVerticalDragEnd: (DragEndDetails details) {
          initMoveY - moveY > 0 ? print('上面') : print('下面');
          if (initMoveY - moveY > 0) {
            playerMove(Direction.up);
          } else {
            playerMove(Direction.down);
          }
        },
        child: ListView(
          physics: NeverScrollableScrollPhysics(),
          children: [gameBoard(), solveBoard()],
        ),
      ),
    );
  }

  ///游戏区域
  Widget gameBoard() {
    //游戏区域根据手机适配
    gameHeight = screenWidth.floor();
    //每一个小方块的长度和宽度(屏幕长度 / 每一列的长度)
    cellSize = screenWidth.floor() ~/ gameRowSize;

    List<Row> rowList = [];
    List.generate(model.mazeList.length, (i) {
      List<Container> columnList = [];
      List.generate(model.mazeList[i].length, (j) {
        columnList.add(Container(
          width: cellSize.toDouble(),
          height: cellSize.toDouble(),
          color: model.mazeList[i][j] == 0
              ? Colors.black
              : (model.playerX == i && model.playerY == j)
                  ? Colors.blue
                  : (model.getEndX() == i && model.getEndY() == j)
                      ? Colors.red
                      : model.pathList[i][j] ? Colors.orange : Colors.white,
        ));
      });

      rowList.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: columnList,
      ));
    });

    return GestureDetector(
      onHorizontalDragStart: (DragStartDetails startDetails) {
        initMoveX = startDetails.localPosition.dx;
      },
      onHorizontalDragUpdate: (DragUpdateDetails updateDetails) {
        moveX = updateDetails.localPosition.dx;
      },
      onHorizontalDragEnd: (DragEndDetails details) {
        initMoveX - moveX > 0 ? print('左边') : print('右边');
        if (initMoveX - moveX > 0) {
          playerMove(Direction.left);
        } else {
          playerMove(Direction.right);
        }
      },
      onVerticalDragStart: (DragStartDetails startDetails) {
        initMoveY = startDetails.localPosition.dy;
      },
      onVerticalDragUpdate: (DragUpdateDetails details) {
        moveY = details.localPosition.dy;
      },
      onVerticalDragEnd: (DragEndDetails details) {
        initMoveY - moveY > 0 ? print('上面') : print('下面');
        if (initMoveY - moveY > 0) {
          playerMove(Direction.up);
        } else {
          playerMove(Direction.down);
        }
      },
      child: Container(
        width: gameHeight.toDouble(),
        height: gameHeight.toDouble(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: rowList,
        ),
      ),
    );
  }

  ///解迷宫区域
  Widget solveBoard() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Builder(
            builder: (BuildContext context) {
              return Container(
                width: screenWidth * 0.2,
                height: screenWidth * 0.1,
                child: RaisedButton(
                  color: Colors.green,
                  onPressed: () {
                    if (!isTip) {
                      isTip = true;
                      List.generate(model.getGameRowSize(), (i) {
                        List.generate(model.getGameColumnSize(), (j) {
                          model.visitedList[i][j] = false;
                        });
                      });
                      //开始解迷宫
                      solvedMaze(model.getStartX(), model.getStartY());

                      Future.delayed(Duration(milliseconds: 2000), () {
                        setModelCleanPath();
                      });
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                        content: Text(
                          "提示一关只能用一次哦",
                        ),
                        duration: Duration(milliseconds: 3000),
                        action: SnackBarAction(
                            label: "确定",
                            textColor: Colors.white,
                            onPressed: () {
                              Scaffold.of(context).hideCurrentSnackBar();
                            }),
                        backgroundColor: Colors.black,
                      ));
                    }
                  },
                  child: Text(
                    "提示",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              );
            },
          ),
          Container(
            width: screenWidth * 0.2,
            height: screenWidth * 0.1,
            child: RaisedButton(
              onPressed: () {
                timer.cancel();
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        content: Text("游戏暂停中"),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                setTimer(level, getTimeNum: timeNum);
                                Navigator.of(context).maybePop();
                              },
                              child: Text("继续游戏"))
                        ],
                      );
                    });
              },
              child: Text("暂停"),
            ),
          ),
          Container(
            width: screenWidth * 0.25,
            height: screenWidth * 0.1,
            child: RaisedButton(
              onPressed: () {
                showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (BuildContext context) {
                      timer.cancel();
                      return AlertDialog(
                        content: Text("确定重新开始吗"),
                        actions: [
                          FlatButton(
                              onPressed: () {
                                Navigator.of(context).maybePop();
                                setTimer(level, getTimeNum: timeNum);
                              },
                              child: Text("继续游戏")),
                          FlatButton(
                              onPressed: () {
                                reStart(context);
                              },
                              child: Text("确定"))
                        ],
                      );
                    });
              },
              child: Text("重新开始"),
            ),
          ),
          Container(
              width: screenWidth * 0.2,
              child: RichText(
                  text: TextSpan(
                      style: TextStyle(
                          color: Colors.red,
                          fontSize: 15,
                          fontWeight: FontWeight.bold),
                      children: [
                    TextSpan(
                      text: "剩余",
                    ),
                    TextSpan(text: "$timeNum", style: TextStyle(fontSize: 23)),
                    TextSpan(text: "秒")
                  ]))),
        ],
      ),
    );
  }

  void _createMap(int startX, int startY) {
    RandomQueue randomQueue = new RandomQueue();

    //设置起点
    Position start = new Position(startX, startY);

    //入队
    randomQueue.addRandomQueue(start);

    //设置起点已经被访问过
    model.visitedList[startX][startY] = true;

    while (randomQueue.getSize() != 0) {
      //出队
      Position curPosition = randomQueue.removeRandomQueue();
      //对上、下、左、右四个方向进行遍历，并获得一个新位置
      List.generate(4, (i) {
        int newX = curPosition.getX() + model.direction[i][0] * 2;
        int newY = curPosition.getY() + model.direction[i][1] * 2;

        //如果新位置在地图范围内且该位置没有被访问过
        if (model.isInMap(newX, newY) && !model.visitedList[newX][newY]) {
          //入队
          randomQueue.addRandomQueue(
              new Position(newX, newY, prePostion: curPosition));
          //设置该位置被访问过
          model.visitedList[newX][newY] = true;
          //设置该位置为路
          setWithRoad(curPosition.getX() + model.direction[i][0],
              curPosition.getY() + model.direction[i][1]);
        }
      });
    }
  }

  ///设置为路
  void setWithRoad(int x, int y) {
    setState(() {
      model.mazeList[x][y] = MazeGameModel.MAP_ROAD;
    });
  }

  ///用户移动
  void playerMove(Direction direction) {
    switch (direction) {
      case Direction.left:
        if (model.isInMap(model.playerX, model.playerY - 1) &&
            model.mazeList[model.playerX][model.playerY - 1] ==
                MazeGameModel.MAP_ROAD) {
          model.playerY--;
        }
        break;
      case Direction.right:
        if (model.isInMap(model.playerX, model.playerY + 1) &&
            model.mazeList[model.playerX][model.playerY + 1] ==
                MazeGameModel.MAP_ROAD) {
          model.playerY++;
        }
        break;
      case Direction.up:
        if (model.isInMap(model.playerX - 1, model.playerY) &&
            model.mazeList[model.playerX - 1][model.playerY] ==
                MazeGameModel.MAP_ROAD) {
          model.playerX--;
        }
        break;
      case Direction.down:
        if (model.isInMap(model.playerX + 1, model.playerY) &&
            model.mazeList[model.playerX + 1][model.playerY] ==
                MazeGameModel.MAP_ROAD) {
          model.playerX++;
        }
        break;
    }
    setState(() {});

    if (model.playerX == model.getEndX() && model.playerY == model.getEndY()) {
      timer.cancel();
      if (level == 20) {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("你真的太牛逼了！能玩到第20关!"),
                actions: [
                  FlatButton(
                      onPressed: () {
                        reStartWithNewMap(context);
                      },
                      child: Text("再次挑战第20关(不同的地图)!"))
                ],
              );
            });
      } else {
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("恭喜挑战成功"),
                actions: [
                  FlatButton(
                      onPressed: () {
                        nextLevel(context);
                      },
                      child: Text("进入下一关"))
                ],
              );
            });
      }
    }
  }

  ///下一关
  void nextLevel(BuildContext context) {
    setState(() {
      timer.cancel();
      level++;
      model.playerX = model.getStartX();
      model.playerY = model.getStartY();
      isTip = false;
    });
    model = new MazeGameModel(
        gameRowSize = gameRowSize + 4, gameColumnSize = gameColumnSize + 4);
    _createMap(model.getStartX(), model.getStartY() + 1);
    setTimer(level);
    Navigator.of(context).maybePop();
  }

  ///重新开始一局（新地图）
  void reStartWithNewMap(BuildContext context) {
    setState(() {
      timer.cancel();
      model.playerX = model.getStartX();
      model.playerY = model.getStartY();
      model = new MazeGameModel(gameRowSize, gameColumnSize);
      _createMap(model.playerX, model.playerY + 1);
      setTimer(level);
      isTip = false;
      Navigator.maybePop(context);
    });
  }

  ///重新开始
  void reStart(BuildContext context) {
    setState(() {
      timer.cancel();
      model.playerX = model.getStartX();
      model.playerY = model.getStartY();
      isTip = false;
      setTimer(level);
      Navigator.maybePop(context);
    });
  }

  //自动解迷宫（提示功能）
  //从起点位置开始（使用递归的方式）求解迷宫，如果求解成功则返回true,否则返回false
  bool solvedMaze(int x, int y) {
    if (!model.isInMap(x, y)) {
      throw "坐标越界";
    }

    //设置已经访问
    model.visitedList[x][y] = true;

    //设置为正确的路径
    setModelWithPath(x, y, true);

    //如果该位置为终点位置，则返回true
    if (x == model.getEndX() && y == model.getEndY()) {
      return true;
    }

    //对四个方向进行遍历，并获取一个新的位置

    for (int i = 0; i < 4; i++) {
      int newX = x + model.direction[i][0];
      int newY = y + model.direction[i][1];

      //如果该位置在地图范围内，且该位置为路，且该位置没有被访问过，则继续从该点开始递归求解
      if (model.isInMap(newX, newY) &&
          model.mazeList[newX][newY] == MazeGameModel.MAP_ROAD &&
          !model.visitedList[newX][newY]) {
        if (solvedMaze(newX, newY)) {
          return true;
        }
      }
    }

    //如果该位置不是正确的路径，则将该位置设置为非正确路径所途径的位置
    setModelWithPath(x, y, false);
    return false;
  }

  ///设置正确的路径
  setModelWithPath(int x, int y, bool isPath) {
    setState(() {
      if (model.isInMap(x, y)) {
        model.pathList[x][y] = isPath;
      }
    });
  }

  ///消除路径
  setModelCleanPath() {
    setState(() {
      List.generate(
          model.getGameRowSize(),
          (i) => List.generate(
              model.getGameColumnSize(), (j) => model.pathList[i][j] = false));
    });
  }

  void setTimer(int level, {int getTimeNum}) {
    if (getTimeNum == null) {
      timeNum = 20 + (level - 1) * 10;
    } else {
      timeNum = getTimeNum;
    }
    timer = new Timer.periodic(Duration(milliseconds: 1000), (val) {
      if (timeNum <= 0) {
        timer.cancel();
        showDialog(
            barrierDismissible: false,
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                content: Text("游戏时间超时，闯关失败"),
                actions: [
                  FlatButton(
                    child: Text("重新挑战本关"),
                    onPressed: () {
                      reStart(context);
                    },
                  ),
                ],
              );
            });
      } else {
        setState(() {
          timeNum--;
        });
      }
    });
  }
}
