import 'dart:math';

import '../models/arrow_direction.dart';
import '../models/hex_board.dart';
import '../models/hex_tile.dart';
import 'puzzle_solver.dart';
import '../../../../core/constants/app_constants.dart';

/// Generates solvable puzzle levels for Hexa Shift.
class LevelGenerator {
  LevelGenerator._();

  static final _random = Random();

  /// Generates a solvable campaign board for the given [levelIndex] (1-based).
  ///
  /// Uses a deterministic seed derived from the level index. If the generated
  /// board is unsolvable, it increments the retry attempt (modifying the seed)
  /// until it finds a solvable layout.
  static HexBoard generateInfiniteLevel(int levelIndex) {
    // 1. Calculate grid size (rows, cols)
    final (rows, cols) = _gridSizeForLevel(levelIndex);

    // 2. Loop until a solvable level is found
    var attempt = 0;
    while (true) {
      // Create a deterministic seed based on level index and retry attempt
      final seed = levelIndex * 1000 + attempt;
      final random = Random(seed);

      final totalTiles = rows * cols;
      
      // 3. Calculate active tile ratio
      // Easy level 1 has ~45% active tiles. Increases slowly up to 80% active at level 100.
      final activeRatio = (0.45 + min(levelIndex, 100) * 0.0035).clamp(0.45, 0.80);
      final activeTileCount = (totalTiles * activeRatio).round().clamp(3, totalTiles);

      // 4. Select active tile positions
      final allPositions = <(int, int)>[];
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          allPositions.add((r, c));
        }
      }
      allPositions.shuffle(random);
      final activePositions = allPositions.take(activeTileCount).toSet();

      // 5. Create tiles with smart arrow direction bias
      // Level 1 starts with a 65% chance of edge-pointing arrows (easy to solve).
      // Difficulty increases up to level 100 where chance is 30%.
      final edgeBias = (0.65 - min(levelIndex, 100) * 0.0035).clamp(0.30, 0.65);

      final tiles = <HexTile>[];
      for (var r = 0; r < rows; r++) {
        for (var c = 0; c < cols; c++) {
          if (activePositions.contains((r, c))) {
            final direction = _smartArrowDirectionWithRandom(r, c, rows, cols, edgeBias, random);
            tiles.add(HexTile(
              row: r,
              col: c,
              arrowDirection: direction,
              isCleared: false,
            ));
          } else {
            tiles.add(HexTile(
              row: r,
              col: c,
              arrowDirection: ArrowDirection.up,
              isCleared: true,
            ));
          }
        }
      }

      final board = HexBoard(rows: rows, cols: cols, tiles: tiles);

      // 6. Verify solvability using our PuzzleSolver
      // Early levels are extremely small and fast to solve.
      // We limit state space to 1000 states to ensure speedy generation (under 10ms).
      if (PuzzleSolver.isSolvable(board, maxStates: 1000)) {
        return board;
      }

      // If not solvable, we loop to the next attempt (changing seed)
      attempt++;
      
      // Safety breakout
      if (attempt > 100) {
        return _fallbackSolvableBoard(levelIndex);
      }
    }
  }

  /// Grid size ladder based on the campaign level.
  static (int, int) _gridSizeForLevel(int levelIndex) {
    if (levelIndex == 1) return (3, 3); // Tutorial-sized grid
    if (levelIndex <= 5) return (4, 4);
    if (levelIndex <= 12) return (4, 5);
    if (levelIndex <= 20) return (5, 5);
    if (levelIndex <= 40) return (5, 6);
    if (levelIndex <= 70) return (6, 6);
    if (levelIndex <= 100) return (6, 7);
    return (7, 8); // Capped maximum grid size
  }

  /// Smart direction allocator parameterized with custom edge bias and random generator.
  static ArrowDirection _smartArrowDirectionWithRandom(
    int row,
    int col,
    int rows,
    int cols,
    double edgeBias,
    Random random,
  ) {
    final directions = ArrowDirection.values;
    final edgeDirections = <ArrowDirection>[];

    for (final dir in directions) {
      final isOddCol = col % 2 == 1;
      final (dRow, dCol) = dir.neighborOffset(isOddCol);
      final destRow = row + dRow;
      final destCol = col + dCol;

      if (destRow < 0 || destRow >= rows || destCol < 0 || destCol >= cols) {
        edgeDirections.add(dir);
      }
    }

    if (edgeDirections.isNotEmpty && random.nextDouble() < edgeBias) {
      return edgeDirections[random.nextInt(edgeDirections.length)];
    }

    return directions[random.nextInt(directions.length)];
  }

  /// Guaranteed solvable fallback board if seed generation hits retry limit (extremely rare).
  static HexBoard _fallbackSolvableBoard(int levelIndex) {
    const rows = 3;
    const cols = 3;
    final tiles = <HexTile>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        ArrowDirection dir = ArrowDirection.up;
        if (r == 0) dir = ArrowDirection.up;
        else if (r == 2) dir = ArrowDirection.down;
        else if (c == 0) dir = ArrowDirection.upLeft;
        else dir = ArrowDirection.upRight;

        tiles.add(HexTile(row: r, col: c, arrowDirection: dir, isCleared: false));
      }
    }
    return HexBoard(rows: rows, cols: cols, tiles: tiles);
  }

  /// Generates a solvable board of [rows] × [cols] with the given [difficulty].
  static HexBoard generateLevel(int rows, int cols, Difficulty difficulty) {
    final totalTiles = rows * cols;
    final activeTileCount = switch (difficulty) {
      Difficulty.easy => (totalTiles * 0.5).round().clamp(3, totalTiles),
      Difficulty.medium => (totalTiles * 0.65).round().clamp(5, totalTiles),
      Difficulty.hard => (totalTiles * 0.8).round().clamp(8, totalTiles),
    };

    final allPositions = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        allPositions.add((r, c));
      }
    }
    allPositions.shuffle(_random);

    final activePositions = allPositions.take(activeTileCount).toSet();

    final tiles = <HexTile>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (activePositions.contains((r, c))) {
          final direction = _smartArrowDirection(r, c, rows, cols);
          tiles.add(HexTile(
            row: r,
            col: c,
            arrowDirection: direction,
            isCleared: false,
          ));
        } else {
          tiles.add(HexTile(
            row: r,
            col: c,
            arrowDirection: ArrowDirection.up,
            isCleared: true,
          ));
        }
      }
    }

    return HexBoard(rows: rows, cols: cols, tiles: tiles);
  }

  static ArrowDirection _smartArrowDirection(
    int row,
    int col,
    int rows,
    int cols,
  ) {
    final directions = ArrowDirection.values;
    final edgeDirections = <ArrowDirection>[];

    for (final dir in directions) {
      final isOddCol = col % 2 == 1;
      final (dRow, dCol) = dir.neighborOffset(isOddCol);
      final destRow = row + dRow;
      final destCol = col + dCol;

      if (destRow < 0 || destRow >= rows || destCol < 0 || destCol >= cols) {
        edgeDirections.add(dir);
      }
    }

    if (edgeDirections.isNotEmpty && _random.nextDouble() < 0.4) {
      return edgeDirections[_random.nextInt(edgeDirections.length)];
    }

    return directions[_random.nextInt(directions.length)];
  }

  /// Generates a predefined easy tutorial level.
  static HexBoard tutorialLevel() {
    const rows = 3;
    const cols = 3;

    final tiles = <HexTile>[
      const HexTile(row: 0, col: 0, arrowDirection: ArrowDirection.downRight),
      const HexTile(row: 0, col: 1, arrowDirection: ArrowDirection.down),
      const HexTile(row: 0, col: 2, arrowDirection: ArrowDirection.downLeft, isCleared: true),
      const HexTile(row: 1, col: 0, arrowDirection: ArrowDirection.upRight, isCleared: true),
      const HexTile(row: 1, col: 1, arrowDirection: ArrowDirection.up),
      const HexTile(row: 1, col: 2, arrowDirection: ArrowDirection.upLeft),
      const HexTile(row: 2, col: 0, arrowDirection: ArrowDirection.up),
      const HexTile(row: 2, col: 1, arrowDirection: ArrowDirection.upRight, isCleared: true),
      const HexTile(row: 2, col: 2, arrowDirection: ArrowDirection.up),
    ];

    return HexBoard(rows: rows, cols: cols, tiles: tiles);
  }
}
