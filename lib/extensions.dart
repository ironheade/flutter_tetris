import 'package:tetris/constants.dart';
import 'package:collection/collection.dart';

enum Direction {
  left,
  right,
}

extension Move on Direction {
  int Function(int) get move =>
      this == Direction.left ? (int e) => e - 1 : (int e) => e + 1;

  List<int> get side => this == Direction.left ? kLeftSide : kRightSide;
}

extension Collision on Iterable<int> {
  Iterable<int> move(Direction d) => map(d.move);

  bool collides(Iterable<int> other) {
    for (var p1 in this) {
      for (var p2 in other) {
        if (p1 == p2) return true;
      }
    }
    return false;
  }

  List<int> moveIfValid(Iterable<int> taken, Direction d) =>
      (!(collides(d.side) || move(d).collides(taken)) ? move(d) : this)
          .toList();

  Iterable<int> rotated(int formIndex, int rotationIndex) {
    return mapIndexed((index, element) =>
        element += kRotationSet[formIndex][rotationIndex][index]).toList();
  }

  bool rotationIsValid(Iterable<int> taken) => !(collides(taken) ||
      collides(kBelowBottomSide) ||
      collides(kLeftSide) ||
      collides(kRightSide));
}
