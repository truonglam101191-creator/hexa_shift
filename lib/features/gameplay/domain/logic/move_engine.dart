import '../models/arrow_direction.dart';
import '../models/game_state.dart';
import '../models/hex_board.dart';
import '../models/hex_tile.dart';

/// Result of executing a move on the board.
class MoveResult {
  const MoveResult({
    required this.board,
    required this.events,
  });

  /// The updated board after the move and all chain reactions.
  final HexBoard board;

  /// Ordered list of events for animation playback.
  final List<MoveEvent> events;
}

/// Core game logic engine — pure functions, no UI dependencies.
///
/// Handles tile movement, chain reactions, and valid-move computation.
class MoveEngine {
  const MoveEngine._();

  /// Executes a move for the given [tile] on the [board].
  ///
  /// Returns a [MoveResult] with the new board state and animation events.
  ///
  /// Movement rules:
  /// 1. Tile moves one step along its arrow direction.
  /// 2. If destination is **off-board** → tile is cleared.
  /// 3. If destination is **already cleared** → tile moves there and is cleared.
  /// 4. If destination is **occupied** → the occupying tile's arrow rotates
  ///    clockwise (bump), and the moving tile stays put. If the bumped tile
  ///    now points to empty/off-board, a chain reaction triggers.
  static MoveResult executeMove(HexBoard board, HexTile tile) {
    if (tile.isCleared) {
      return MoveResult(board: board, events: []);
    }

    final events = <MoveEvent>[];
    var currentBoard = board;

    // Compute destination based on arrow direction
    final isOddCol = tile.col % 2 == 1;
    final (dRow, dCol) = tile.arrowDirection.neighborOffset(isOddCol);
    final destRow = tile.row + dRow;
    final destCol = tile.col + dCol;

    // Case 1: Destination is off-board → clear the tile
    if (!currentBoard.isInBounds(destRow, destCol)) {
      events.add(TileMoved(
        fromRow: tile.row,
        fromCol: tile.col,
        toRow: destRow,
        toCol: destCol,
      ));
      events.add(TileCleared(row: tile.row, col: tile.col));

      currentBoard = currentBoard.updateTile(
        tile.copyWith(isCleared: true),
      );
      return MoveResult(board: currentBoard, events: events);
    }

    final destTile = currentBoard.getTile(destRow, destCol);

    // Case 2: Destination tile is already cleared → move and clear
    if (destTile != null && destTile.isCleared) {
      events.add(TileMoved(
        fromRow: tile.row,
        fromCol: tile.col,
        toRow: destRow,
        toCol: destCol,
      ));
      events.add(TileCleared(row: tile.row, col: tile.col));

      currentBoard = currentBoard.updateTile(
        tile.copyWith(isCleared: true),
      );
      return MoveResult(board: currentBoard, events: events);
    }

    // Case 3: Destination is occupied → bump (rotate the target's arrow)
    if (destTile != null && !destTile.isCleared) {
      final newDirection = destTile.arrowDirection.rotateClockwise();

      events.add(TileRotated(
        row: destRow,
        col: destCol,
        newDirection: newDirection.name,
      ));

      final rotatedTile = destTile.copyWith(arrowDirection: newDirection);
      currentBoard = currentBoard.updateTile(rotatedTile);

      // Check for chain reaction: if the bumped tile now points to
      // empty/off-board, auto-move it
      currentBoard = _processChainReaction(
        currentBoard,
        rotatedTile,
        events,
      );

      return MoveResult(board: currentBoard, events: events);
    }

    // Fallback (shouldn't happen in normal play)
    return MoveResult(board: currentBoard, events: events);
  }

  /// Recursively processes chain reactions after a tile is bumped/rotated.
  ///
  /// If the rotated tile now points to empty space or off-board,
  /// it automatically moves (and may trigger further chain reactions).
  static HexBoard _processChainReaction(
    HexBoard board,
    HexTile tile,
    List<MoveEvent> events, {
    int depth = 0,
  }) {
    // Guard against infinite loops (max chain depth)
    if (depth > 50 || tile.isCleared) return board;

    final isOddCol = tile.col % 2 == 1;
    final (dRow, dCol) = tile.arrowDirection.neighborOffset(isOddCol);
    final destRow = tile.row + dRow;
    final destCol = tile.col + dCol;

    // If destination is off-board → chain clear
    if (!board.isInBounds(destRow, destCol)) {
      events.add(TileMoved(
        fromRow: tile.row,
        fromCol: tile.col,
        toRow: destRow,
        toCol: destCol,
      ));
      events.add(TileCleared(row: tile.row, col: tile.col));
      return board.updateTile(tile.copyWith(isCleared: true));
    }

    final destTile = board.getTile(destRow, destCol);

    // If destination is cleared → chain clear this tile too
    if (destTile != null && destTile.isCleared) {
      events.add(TileMoved(
        fromRow: tile.row,
        fromCol: tile.col,
        toRow: destRow,
        toCol: destCol,
      ));
      events.add(TileCleared(row: tile.row, col: tile.col));
      return board.updateTile(tile.copyWith(isCleared: true));
    }

    // If destination is occupied → bump that tile too (chain bump)
    if (destTile != null && !destTile.isCleared) {
      final newDirection = destTile.arrowDirection.rotateClockwise();
      events.add(TileRotated(
        row: destRow,
        col: destCol,
        newDirection: newDirection.name,
      ));

      final rotatedTile = destTile.copyWith(arrowDirection: newDirection);
      var updatedBoard = board.updateTile(rotatedTile);

      // Recurse for further chain reactions
      updatedBoard = _processChainReaction(
        updatedBoard,
        rotatedTile,
        events,
        depth: depth + 1,
      );

      return updatedBoard;
    }

    return board;
  }

  /// Returns `true` if the given [tile] can make a valid move.
  ///
  /// A tile can move if:
  /// - It is not cleared.
  /// - Its arrow points somewhere (always true for active tiles).
  static bool canMove(HexBoard board, HexTile tile) {
    return !tile.isCleared;
  }

  /// Returns all tiles that can currently be moved.
  static List<HexTile> getValidMoves(HexBoard board) {
    return board.activeTiles;
  }
}
