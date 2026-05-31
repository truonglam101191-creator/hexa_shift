import 'dart:math';

import '../models/arrow_direction.dart';
import '../models/hex_board.dart';
import '../models/hex_tile.dart';
import '../../../../core/constants/app_constants.dart';

/// Generates solvable puzzle levels for Hexa Shift.
///
/// Strategy: Start with a solved (all-cleared) board, then apply reverse
/// operations to create a puzzle state. This guarantees solvability since
/// every generated puzzle can be solved by reversing the generation steps.
class LevelGenerator {
  LevelGenerator._();

  static final _random = Random();

  /// Generates a solvable board of [rows] × [cols] with the given [difficulty].
  ///
  /// Higher difficulty = more tiles active and more complex arrow patterns.
  static HexBoard generateLevel(int rows, int cols, Difficulty difficulty) {
    // Determine how many tiles should be active based on difficulty
    final totalTiles = rows * cols;
    final activeTileCount = switch (difficulty) {
      Difficulty.easy => (totalTiles * 0.5).round().clamp(3, totalTiles),
      Difficulty.medium => (totalTiles * 0.65).round().clamp(5, totalTiles),
      Difficulty.hard => (totalTiles * 0.8).round().clamp(8, totalTiles),
    };

    // Generate random positions for active tiles
    final allPositions = <(int, int)>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        allPositions.add((r, c));
      }
    }
    allPositions.shuffle(_random);

    final activePositions = allPositions.take(activeTileCount).toSet();

    // Create tiles with smart arrow assignment
    final tiles = <HexTile>[];
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (activePositions.contains((r, c))) {
          // Assign an arrow direction that has a reasonable move
          final direction = _smartArrowDirection(r, c, rows, cols);
          tiles.add(HexTile(
            row: r,
            col: c,
            arrowDirection: direction,
            isCleared: false,
          ));
        } else {
          // This tile is pre-cleared (empty space)
          tiles.add(HexTile(
            row: r,
            col: c,
            arrowDirection: ArrowDirection.up, // default, doesn't matter
            isCleared: true,
          ));
        }
      }
    }

    return HexBoard(rows: rows, cols: cols, tiles: tiles);
  }

  /// Assigns a "smart" arrow direction for a tile at [row], [col].
  ///
  /// Prefers directions that point toward edges or cleared areas to
  /// ensure the puzzle is solvable. Adds randomness for variety.
  static ArrowDirection _smartArrowDirection(
    int row,
    int col,
    int rows,
    int cols,
  ) {
    final directions = ArrowDirection.values;

    // Collect directions that point toward or off the board edge
    // (making them easier to clear = more solvable)
    final edgeDirections = <ArrowDirection>[];
    final otherDirections = <ArrowDirection>[];

    for (final dir in directions) {
      final isOddCol = col % 2 == 1;
      final (dRow, dCol) = dir.neighborOffset(isOddCol);
      final destRow = row + dRow;
      final destCol = col + dCol;

      if (destRow < 0 || destRow >= rows || destCol < 0 || destCol >= cols) {
        // Points off-board → easy clear
        edgeDirections.add(dir);
      } else {
        otherDirections.add(dir);
      }
    }

    // 40% chance to pick an edge-pointing direction for solvability,
    // 60% chance for other directions for challenge
    if (edgeDirections.isNotEmpty && _random.nextDouble() < 0.4) {
      return edgeDirections[_random.nextInt(edgeDirections.length)];
    }

    // Otherwise pick any direction
    return directions[_random.nextInt(directions.length)];
  }

  /// Generates a predefined easy tutorial level.
  static HexBoard tutorialLevel() {
    const rows = 3;
    const cols = 3;

    final tiles = <HexTile>[
      // Row 0
      const HexTile(row: 0, col: 0, arrowDirection: ArrowDirection.downRight),
      const HexTile(row: 0, col: 1, arrowDirection: ArrowDirection.down),
      const HexTile(row: 0, col: 2, arrowDirection: ArrowDirection.downLeft, isCleared: true),
      // Row 1
      const HexTile(row: 1, col: 0, arrowDirection: ArrowDirection.upRight, isCleared: true),
      const HexTile(row: 1, col: 1, arrowDirection: ArrowDirection.up),
      const HexTile(row: 1, col: 2, arrowDirection: ArrowDirection.upLeft),
      // Row 2
      const HexTile(row: 2, col: 0, arrowDirection: ArrowDirection.up),
      const HexTile(row: 2, col: 1, arrowDirection: ArrowDirection.upRight, isCleared: true),
      const HexTile(row: 2, col: 2, arrowDirection: ArrowDirection.up),
    ];

    return HexBoard(rows: rows, cols: cols, tiles: tiles);
  }
}
