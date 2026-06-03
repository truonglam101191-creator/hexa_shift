import 'package:flutter_test/flutter_test.dart';
import 'package:hexa_shift/features/gameplay/domain/logic/level_generator.dart';
import 'package:hexa_shift/features/gameplay/domain/logic/puzzle_solver.dart';
import 'package:hexa_shift/features/gameplay/domain/models/arrow_direction.dart';
import 'package:hexa_shift/features/gameplay/domain/models/hex_board.dart';
import 'package:hexa_shift/features/gameplay/domain/models/hex_tile.dart';

void main() {
  group('PuzzleSolver Tests', () {
    test('Tutorial level is solvable', () {
      final board = LevelGenerator.tutorialLevel();
      final solvable = PuzzleSolver.isSolvable(board);
      expect(solvable, isTrue);
    });

    test('A complex board returns false if state limit is exceeded', () {
      final board = LevelGenerator.tutorialLevel();
      // The tutorial level requires more than 2 state explorations to solve.
      // Setting maxStates to 2 should force the solver to return false.
      final solvable = PuzzleSolver.isSolvable(board, maxStates: 2);
      expect(solvable, isFalse);
    });
  });

  group('LevelGenerator Campaign Tests', () {
    test('Generate level 1: small and solvable', () {
      final stopwatch = Stopwatch()..start();
      final board = LevelGenerator.generateInfiniteLevel(1);
      stopwatch.stop();

      expect(board.rows, equals(3));
      expect(board.cols, equals(3));
      expect(PuzzleSolver.isSolvable(board), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100)); // Should generate very quickly
    });

    test('Generate level 5: 4x4 and solvable', () {
      final stopwatch = Stopwatch()..start();
      final board = LevelGenerator.generateInfiniteLevel(5);
      stopwatch.stop();

      expect(board.rows, equals(4));
      expect(board.cols, equals(4));
      expect(PuzzleSolver.isSolvable(board), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(200));
    });

    test('Generate level 15: 5x5 and solvable', () {
      final stopwatch = Stopwatch()..start();
      final board = LevelGenerator.generateInfiniteLevel(15);
      stopwatch.stop();

      expect(board.rows, equals(5));
      expect(board.cols, equals(5));
      expect(PuzzleSolver.isSolvable(board), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });

  group('3D Projection Math Tests', () {
    test('Inverse projection restores original flat coordinate', () {
      const double tiltCos = 0.866;
      const double tiltSin = 0.500;
      const double z = 12.0;
      final originalPoint = Offset(100.0, 150.0);

      // Project: y' = y * cos - z * sin
      final projectedY = originalPoint.dy * tiltCos - z * tiltSin;
      final projectedPoint = Offset(originalPoint.dx, projectedY);

      // Inverse Project: y = (y' + z * sin) / cos
      final restoredY = (projectedPoint.dy + z * tiltSin) / tiltCos;
      final restoredPoint = Offset(projectedPoint.dx, restoredY);

      expect(restoredPoint.dx, closeTo(originalPoint.dx, 0.001));
      expect(restoredPoint.dy, closeTo(originalPoint.dy, 0.001));
    });
  });
}
