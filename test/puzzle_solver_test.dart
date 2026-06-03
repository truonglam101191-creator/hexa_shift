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
}
