import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'constants.dart';
import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

/*
Todos:
- increse speed upon points
- store Scores locally
*/

void main() {
  //await Hive.initFlutter();
  runApp(const Tetris());
}

class Tetris extends StatelessWidget {
  const Tetris({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        body: GameArea(),
      ),
    );
  }
}

class GameArea extends StatefulWidget {
  const GameArea({super.key});

  @override
  State<GameArea> createState() => _GameAreaState();
}

class _GameAreaState extends State<GameArea> {
  final myController = TextEditingController();
  List<Map> highScores = [
    {
      "name": "AAA",
      "score": 0,
    }
  ];
  int currentForm = 0;
  int nextForm = Random().nextInt(kAllPieces.length);
  List<int> newPiece = kAllPieces[0];
  List<int> takenSquares = [];
  bool speed = false;
  bool gameOverScreenVisible = false;
  int points = 0;
  bool game = false;
  bool textFieldEnabled = true;
  bool startButtonVisible = true;
  double tabXPosition = 0;
  int rotationState = 0;

  int kTimeMSUpdate = kTimeMSStart;

  late Timer _timer;
  String name = "";

  void startGame() {
    setState(() {
      points = 0;
      kTimeMSUpdate = kTimeMSStart;
      takenSquares = [];
    });
    const duration = Duration(milliseconds: kTimeMSStart);
    setTimer(duration);
  }

  void changeTimer(int time) {
    _timer.cancel();
    setTimer(Duration(milliseconds: time));
  }

  Timer setTimer(Duration duration) {
    return _timer = Timer.periodic(duration, (timer) {
      if (speed) {
        changeTimer(kTimeMSUpdate ~/ 5);
      } else {
        changeTimer(kTimeMSUpdate);
      }

      setState(() {
        //check for movement and move the Tetris piece a row down
        List<int> tempPiece = [];
        tempPiece = newPiece.map((e) => e += 10).toList();
        //if space below piece is free set the piece to space below
        if (tempPiece.reduce(max) < 200 &&
            !({...tempPiece}.intersection({...takenSquares}).isNotEmpty)) {
          newPiece = tempPiece;
        } else {
          setState(() {
            //add Tetris Piece to the taken pieces
            takenSquares = List.from(takenSquares)..addAll(newPiece);
            //check if top side has been reached, in this case game over
            if (({...kTopSide}.intersection({...takenSquares}).isNotEmpty)) {
              _timer.cancel();
              gameOverScreenVisible = true;
              game = false;
            }
            rotationState = 0;
            //check for full lines
            List<int> squaresToBeDeleted = [];
            for (var takenSquare in takenSquares) {
              if (takenSquare % 10 == 0) {
                List<int> consecutiveList = [
                  takenSquare,
                  takenSquare + 1,
                  takenSquare + 2,
                  takenSquare + 3,
                  takenSquare + 4,
                  takenSquare + 5,
                  takenSquare + 6,
                  takenSquare + 7,
                  takenSquare + 8,
                  takenSquare + 9,
                ];

                if ({...consecutiveList}
                        .intersection({...takenSquares}).length ==
                    10) {
                  squaresToBeDeleted = List.from(squaresToBeDeleted)
                    ..addAll(consecutiveList);
                }
              }
            }
            if (squaresToBeDeleted.isNotEmpty) {
              List<int> tempSquares = takenSquares
                  .toSet()
                  .difference(squaresToBeDeleted.toSet())
                  .toList()
                  .toList();

              for (int i = 0; i < tempSquares.length; i++) {
                if (tempSquares[i] < squaresToBeDeleted.min) {
                  tempSquares[i] = tempSquares[i] + squaresToBeDeleted.length;
                }
              }
              setState(() {
                points +=
                    kPointTable[(squaresToBeDeleted.length / 10 - 1).toInt()];

                kTimeMSUpdate > kTimeMSMinimum
                    ? kTimeMSUpdate -= squaresToBeDeleted.length ~/ 10 * 4
                    : kTimeMSUpdate = kTimeMSMinimum;
                changeTimer(kTimeMSUpdate);
                takenSquares = tempSquares;
              });
            }

            //create random new Piece
            int randomNumber = Random().nextInt(kAllPieces.length);

            newPiece = kAllPieces[nextForm];
            currentForm = nextForm;
            nextForm = randomNumber;
          });
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.8,
                child: GestureDetector(
                  onTapDown: (details) {
                    setState(() {
                      speed = true;
                      tabXPosition = details.globalPosition.dx;
                    });
                  },
                  onVerticalDragUpdate: (details) {
                    details.delta.dy > 0
                        ? setState(() {
                            speed = true;
                          })
                        : Null;
                  },
                  onVerticalDragEnd: ((details) {
                    setState(() {
                      speed = false;
                      //if the swipe has been upwards: rotate the piece and add one to the rotation State
                      if (details.primaryVelocity! < 0) {
                        List<int> tempPiece = newPiece
                            .mapIndexed((index, element) => element +=
                                kRotationSet[currentForm][rotationState][index])
                            .toList();
                        //check if rotation would collide with existing pieces
                        //check if rotation would go over the side, overlap with left and right side at the same time means overlap
                        if (!({...tempPiece}
                                .intersection({...takenSquares}).isNotEmpty) &&
                            !({
                              ...tempPiece
                            }.intersection({...kBelowBottomSide}).isNotEmpty) &&
                            !(({...tempPiece}
                                    .intersection({...kLeftSide}).isNotEmpty) &&
                                ({
                                  ...tempPiece
                                }.intersection({...kRightSide}).isNotEmpty))) {
                          newPiece = tempPiece;
                          rotationState != 3
                              ? rotationState += 1
                              : rotationState = 0;
                        }
                      }
                    });
                  }),
                  onTapUp: (details) {
                    setState(() {
                      speed = false;
                    });
                  },
                  //tapping left and right of center to move the piece
                  onTap: () {
                    game
                        ? setState(() {
                            tabXPosition <
                                    MediaQuery.of(context).size.width * 0.4
                                ? !({...newPiece}.intersection(
                                            {...kLeftSide}).isNotEmpty) &&
                                        !({...newPiece.map((e) => e -= 1)}
                                            .intersection(
                                                {...takenSquares}).isNotEmpty)
                                    ? newPiece =
                                        newPiece.map((e) => e -= 1).toList()
                                    : Null //go left
                                : !({...newPiece}.intersection(
                                            {...kRightSide}).isNotEmpty) &&
                                        !({...newPiece.map((e) => e += 1)}
                                            .intersection(
                                                {...takenSquares}).isNotEmpty)
                                    ? newPiece =
                                        newPiece.map((e) => e += 1).toList()
                                    : Null; //go right
                          })
                        : Null;
                  },
                  child: GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: kTotalSquares,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: kWidthSquares,
                    ),
                    itemBuilder: ((context, index) {
                      return square(
                        currentForm: currentForm,
                        takenSquares: takenSquares,
                        index: index,
                        firstPiece: newPiece,
                      );
                    }),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        blackBox(
                          child: Text(
                            points.toString(),
                            style: TextStyle(
                              fontFamily: 'Orbitron',
                              fontSize: 10,
                            ),
                          ),
                        ),
                        SizedBox(height: 5),
                        blackBox(
                          height: 70,
                          child: game
                              ? Image.asset("images/piece_$nextForm.png")
                              : Text(""),
                        ),

                        SizedBox(height: 5),
                        blackBox(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              for (var highScore in highScores)
                                Text(
                                    "${highScore["name"]}\n${highScore["score"].toString()}\n",
                                    style: TextStyle(
                                        fontSize: 10, fontFamily: 'Orbitron'))
                            ],
                          ),
                        ),
                        //highScores
                      ],
                    ),
                    Visibility(
                      visible: startButtonVisible,
                      child: GestureDetector(
                        onTap: () {
                          game
                              ? Null
                              : setState(() {
                                  game = true;
                                  startButtonVisible = false;
                                });
                          startGame();
                        },
                        child: Icon(
                          Icons.play_arrow,
                          size: 40,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
        Visibility(
          visible: gameOverScreenVisible,
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: MediaQuery.of(context).size.width * 0.6,
                width: MediaQuery.of(context).size.width * 0.8,
                decoration: BoxDecoration(
                  color: Colors.black,
                  border: Border.all(
                    color: Colors.white,
                    width: 5,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "GAME OVER",
                      style: TextStyle(fontSize: 30, fontFamily: 'Orbitron'),
                    ),
                    Text(
                      points.toString(),
                      style: TextStyle(fontSize: 20, fontFamily: 'Orbitron'),
                    ),
                    TextField(
                      enabled: name.length != 3,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r"[a-zA-Z]")),
                        UpperCaseTextFormatter()
                      ],
                      cursorColor: Colors.transparent,
                      controller: myController,
                      onChanged: (value) {
                        setState(() {
                          name = value.toUpperCase();
                          //myController.text = value.toUpperCase();
                          value.length == 3
                              ? addHighScore(
                                  newName: value.toUpperCase(),
                                  newScore: points)
                              : null;
                        });
                      },
                      textAlign: TextAlign.center,
                      maxLength: 3,
                      style: TextStyle(
                        fontSize: 30,
                        fontFamily: 'Orbitron',
                        color: name.length == 3 ? Colors.grey : Colors.white,
                      ),
                      decoration: const InputDecoration(
                        counterText: "",
                        border: InputBorder.none,
                        hintText: 'AAA',
                        hintStyle:
                            TextStyle(fontSize: 30, fontFamily: 'Orbitron'),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        name.length == 3
                            ? setState(() {
                                gameOverScreenVisible = false;
                                game = true;
                                name = "";
                                myController.text = "";
                                startGame();
                              })
                            : Null;
                      },
                      child: Icon(
                        Icons.replay,
                        size: 40,
                        color: name.length == 3
                            ? Colors.white
                            : Colors.grey.shade600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void addHighScore({required String newName, required int newScore}) {
    return setState(() {
      highScores.add({
        "name": newName,
        "score": newScore,
      });
      highScores.sort((b, a) => a["score"].compareTo(b["score"]));
      if (highScores.length > 5) {
        highScores.removeAt(5);
      }
    });
  }
}

class blackBox extends StatelessWidget {
  Widget child;
  double? height;
  blackBox({required this.child, this.height});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(3),
      child: Container(
          padding: EdgeInsets.all(8),
          width: 50,
          height: height,
          decoration: BoxDecoration(color: Colors.black),
          child: child),
    );
  }
}

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    return TextEditingValue(
      text: newValue.text.toUpperCase(),
      selection: newValue.selection,
    );
  }
}

class square extends StatelessWidget {
  int index;
  List firstPiece;
  List takenSquares;
  int currentForm;

  square({
    required this.index,
    required this.firstPiece,
    required this.takenSquares,
    required this.currentForm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(3),
        child: Container(
          decoration: BoxDecoration(
            color: firstPiece.contains(index)
                ? kColorsDark[currentForm]
                : takenSquares.contains(index)
                    ? kCollectedPiecesDark
                    : kBackgroundColorDark,
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(3),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: firstPiece.contains(index)
                          ? ([kColorsLight[currentForm], kColors[currentForm]])
                          : takenSquares.contains(index)
                              ? ([kCollectedPiecesLight, kCollectedPieces])
                              : ([kBackgroundColorLight, kBackgroundColor]),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MyWidget extends StatelessWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
