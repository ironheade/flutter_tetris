import 'package:flutter/material.dart';

const List<List<int>> kAllPieces = [
  [-7, -6, -5, -4],
  [-17, -7, -6, -5],
  [-7, -6, -5, -15],
  [-17, -16, -7, -6],
  [-7, -6, -16, -15],
  [-7, -6, -16, -5],
  [-17, -16, -6, -5],
];

const List<List<List<int>>> kRotationSet = [
  [
    [-8, 1, 10, 19],
    [11, 0, -11, -22],
    [-11, 0, 11, 22],
    [8, -1, -10, -19]
  ],
  [
    [2, -9, 0, 9],
    [20, 11, 0, -11],
    [-2, 9, 0, -9],
    [-20, -11, 0, 11]
  ],
  [
    [-9, 0, 9, 20],
    [11, 0, -11, -2],
    [9, 0, -9, -20],
    [-11, 0, 11, 2]
  ],
  [
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0],
    [0, 0, 0, 0]
  ],
  [
    [-9, 0, 11, 20],
    [11, 0, 9, -2],
    [9, 0, -11, -20],
    [-11, 0, -9, 2]
  ],
  [
    [-9, 0, 11, 9],
    [11, 0, 9, -11],
    [9, 0, -11, -9],
    [-11, 0, -9, 11]
  ],
  [
    [2, 11, 0, 9],
    [20, 9, 0, -11],
    [-2, -11, 0, -9],
    [-20, -9, 0, 11]
  ],
];

const List<int> kLeftSide = [
  0,
  10,
  20,
  30,
  40,
  50,
  60,
  70,
  80,
  90,
  100,
  110,
  120,
  130,
  140,
  150,
  160,
  170,
  180,
  190
];
const List<int> kRightSide = [
  9,
  19,
  29,
  39,
  49,
  59,
  69,
  79,
  89,
  99,
  199,
  119,
  129,
  139,
  149,
  159,
  169,
  179,
  189,
  199
];
const List<int> kTopSide = [
  0,
  1,
  2,
  3,
  4,
  5,
  6,
  7,
  8,
  9,
];
const List<int> kBelowBottomSide = [
  200,
  201,
  202,
  203,
  204,
  205,
  206,
  207,
  208,
  209,
];

const List<Color> kColors = [
  Colors.cyan,
  Colors.blue,
  Colors.orange,
  Colors.yellow,
  Colors.green,
  Colors.purple,
  Colors.red
];

List<Color> kColorsDark = [
  Colors.cyan.shade800,
  Colors.blue.shade800,
  Colors.orange.shade800,
  Colors.yellow.shade800,
  Colors.green.shade800,
  Colors.purple.shade800,
  Colors.red.shade800
];

List<Color> kColorsLight = [
  Colors.cyan.shade200,
  Colors.blue.shade200,
  Colors.orange.shade200,
  Colors.yellow.shade200,
  Colors.green.shade200,
  Colors.purple.shade200,
  Colors.red.shade200
];

List<int> kPointTable = [40, 100, 300, 1200];

const int kTotalSquares = 200;
const int kWidthSquares = 10;
const int kTimeMSStart = 500;

Color kBackgroundColor = Colors.grey.shade800;
Color kBackgroundColorLight = Colors.grey.shade800;
Color kBackgroundColorDark = Colors.grey.shade800;

Color kCollectedPieces = Colors.teal;
Color kCollectedPiecesLight = Colors.teal.shade300;
Color kCollectedPiecesDark = Colors.teal.shade800;
