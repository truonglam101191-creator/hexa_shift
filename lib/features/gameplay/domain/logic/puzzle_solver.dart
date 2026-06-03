import '../models/hex_board.dart';
import '../models/hex_tile.dart';
import 'move_engine.dart';

/// A backtracking solver that verifies whether a [HexBoard] is solvable.
class PuzzleSolver {
  PuzzleSolver._();

  /// Returns true if the board has a sequence of moves that clears all tiles.
  ///
  /// To ensure fast generation, it limits the search to a maximum state budget.
  static bool isSolvable(HexBoard board, {int maxStates = 1500}) {
    final visited = <HexBoard>{};
    return _solve(board, visited, maxStates);
  }

  static bool _solve(HexBoard board, Set<HexBoard> visited, int maxStates) {
    // If the board is already completely cleared, it's solved!
    if (board.isCleared()) {
      return true;
    }

    // Safety limit on number of unique states explored. If the puzzle
    // requires exploring more than [maxStates], we consider it too complex
    // (or potentially unsolvable/extremely difficult) and return false.
    if (visited.length >= maxStates) {
      return false;
    }

    // Skip if we've already checked this board layout.
    if (!visited.add(board)) {
      return false;
    }

    // Get all valid moves from the current state.
    // In Hexa Shift, any active (non-cleared) tile can be activated.
    final validMoves = MoveEngine.getValidMoves(board);
    if (validMoves.isEmpty) {
      return false;
    }

    // Heuristic: sort valid moves to prioritize actions that immediately
    // clear a tile or slide it into empty space. This quickly reduces
    // board size and finds solutions faster.
    final sortedMoves = List<HexTile>.from(validMoves)..sort((a, b) {
      final aEasy = _isImmediateClearOrSlide(board, a);
      final bEasy = _isImmediateClearOrSlide(board, b);
      if (aEasy && !bEasy) return -1;
      if (!aEasy && bEasy) return 1;
      return 0;
    });

    for (final tile in sortedMoves) {
      final result = MoveEngine.executeMove(board, tile);
      if (_solve(result.board, visited, maxStates)) {
        return true;
      }
    }

    return false;
  }

  /// Helper to determine if a tile move results in immediate clearance or sliding.
  static bool _isImmediateClearOrSlide(HexBoard board, HexTile tile) {
    final isOddCol = tile.col % 2 == 1;
    final (dRow, dCol) = tile.arrowDirection.neighborOffset(isOddCol);
    final destRow = tile.row + dRow;
    final destCol = tile.col + dCol;

    if (!board.isInBounds(destRow, destCol)) {
      return true; // clears immediately (off-board)
    }
    final destTile = board.getTile(destRow, destCol);
    if (destTile == null || destTile.isCleared) {
      return true; // slides and clears immediately
    }
    return false; // bumps another tile (rotates it)
  }
}
