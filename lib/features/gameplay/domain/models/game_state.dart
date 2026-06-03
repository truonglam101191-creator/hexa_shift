import 'hex_board.dart';
import 'hex_tile.dart';

/// The overall game state, managed by the GameNotifier.
///
/// Immutable — all mutations produce a new [GameState] via [copyWith].
class GameState {
  const GameState({
    required this.board,
    required this.initialBoard,
    this.moveCount = 0,
    this.moveHistory = const [],
    this.redoStack = const [],
    this.status = GameStatus.playing,
    this.selectedTile,
    this.validMoves = const [],
    this.lastMoveEvents = const [],
    this.levelIndex,
    this.unlockedCampaignLevel = 1,
  });

  /// The current board state.
  final HexBoard board;

  /// The initial board state (for reset).
  final HexBoard initialBoard;

  /// Number of moves the player has made.
  final int moveCount;

  /// Stack of previous board states for undo.
  final List<HexBoard> moveHistory;

  /// Stack of undone board states for redo.
  final List<HexBoard> redoStack;

  /// Current game status.
  final GameStatus status;

  /// Currently selected tile (tapped but not yet moved).
  final HexTile? selectedTile;

  /// List of tiles that can be moved from the current state.
  final List<HexTile> validMoves;

  /// Events from the last move (for animation sequencing).
  final List<MoveEvent> lastMoveEvents;

  /// The level number if playing Campaign/Infinite Mode (1-based).
  /// Null if playing in custom Sandbox/Practice Mode.
  final int? levelIndex;

  /// The highest unlocked level in Campaign/Infinite Mode (1-based).
  final int unlockedCampaignLevel;

  /// Whether the player can undo.
  bool get canUndo => moveHistory.isNotEmpty;

  /// Whether the player can redo.
  bool get canRedo => redoStack.isNotEmpty;

  /// Returns a copy with the given fields replaced.
  GameState copyWith({
    HexBoard? board,
    HexBoard? initialBoard,
    int? moveCount,
    List<HexBoard>? moveHistory,
    List<HexBoard>? redoStack,
    GameStatus? status,
    HexTile? selectedTile,
    bool clearSelectedTile = false,
    List<HexTile>? validMoves,
    List<MoveEvent>? lastMoveEvents,
    int? levelIndex,
    bool clearLevelIndex = false,
    int? unlockedCampaignLevel,
  }) {
    return GameState(
      board: board ?? this.board,
      initialBoard: initialBoard ?? this.initialBoard,
      moveCount: moveCount ?? this.moveCount,
      moveHistory: moveHistory ?? this.moveHistory,
      redoStack: redoStack ?? this.redoStack,
      status: status ?? this.status,
      selectedTile: clearSelectedTile ? null : (selectedTile ?? this.selectedTile),
      validMoves: validMoves ?? this.validMoves,
      lastMoveEvents: lastMoveEvents ?? this.lastMoveEvents,
      levelIndex: clearLevelIndex ? null : (levelIndex ?? this.levelIndex),
      unlockedCampaignLevel: unlockedCampaignLevel ?? this.unlockedCampaignLevel,
    );
  }
}

/// Possible game statuses.
enum GameStatus {
  /// The game is actively being played.
  playing,

  /// The player has cleared all tiles — victory!
  won,
}

/// Represents a single event that occurred during a move, used to drive animations.
sealed class MoveEvent {
  const MoveEvent();
}

/// A tile slid from one position to another.
class TileMoved extends MoveEvent {
  const TileMoved({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });

  final int fromRow;
  final int fromCol;
  final int toRow;
  final int toCol;
}

/// A tile was cleared (removed from the board).
class TileCleared extends MoveEvent {
  const TileCleared({required this.row, required this.col});

  final int row;
  final int col;
}

/// A tile's arrow was rotated (chain reaction).
class TileRotated extends MoveEvent {
  const TileRotated({
    required this.row,
    required this.col,
    required this.newDirection,
  });

  final int row;
  final int col;
  final String newDirection;
}
