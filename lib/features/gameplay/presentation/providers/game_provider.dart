import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../core/constants/app_constants.dart';
import '../../domain/logic/level_generator.dart';
import '../../domain/logic/move_engine.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/hex_tile.dart';

/// Riverpod provider for the main game state.
final gameProvider = StateNotifierProvider<GameNotifier, GameState>((ref) {
  return GameNotifier();
});

/// Manages all game state transitions: moves, undo/redo, selection, and win detection.
class GameNotifier extends StateNotifier<GameState> {
  GameNotifier() : super(_createInitialState());

  /// Creates the initial game state with an easy board.
  static GameState _createInitialState() {
    final board = LevelGenerator.generateLevel(
      AppConstants.easyRows,
      AppConstants.easyCols,
      Difficulty.easy,
    );
    return GameState(
      board: board,
      initialBoard: board,
      validMoves: MoveEngine.getValidMoves(board),
    );
  }

  /// Starts a new game with the given difficulty.
  void startGame(Difficulty difficulty) {
    final (rows, cols) = AppConstants.boardSizeForDifficulty(difficulty);
    final board = LevelGenerator.generateLevel(rows, cols, difficulty);

    state = GameState(
      board: board,
      initialBoard: board,
      validMoves: MoveEngine.getValidMoves(board),
    );
  }

  /// Handles a tap on the tile at [row], [col].
  ///
  /// - First tap: selects the tile and highlights valid moves.
  /// - Tap on an already-selected tile: executes the move.
  /// - Tap on a different tile: selects the new tile instead.
  /// - Tap on a cleared tile: deselects.
  void tapTile(int row, int col) {
    final tile = state.board.getTile(row, col);
    if (tile == null) return;

    // Tapping a cleared tile → deselect
    if (tile.isCleared) {
      state = state.copyWith(clearSelectedTile: true, lastMoveEvents: []);
      return;
    }

    // If this tile is already selected → execute the move
    if (state.selectedTile != null &&
        state.selectedTile!.row == tile.row &&
        state.selectedTile!.col == tile.col) {
      _executeMove(tile);
      return;
    }

    // Otherwise → select this tile
    state = state.copyWith(selectedTile: tile, lastMoveEvents: []);
  }

  /// Executes a move for the given [tile].
  void _executeMove(HexTile tile) {
    // Save current board to history for undo
    final newHistory = [...state.moveHistory, state.board];

    // Execute the move via the engine
    final result = MoveEngine.executeMove(state.board, tile);

    // Check win condition
    final newStatus = result.board.isCleared()
        ? GameStatus.won
        : GameStatus.playing;

    state = state.copyWith(
      board: result.board,
      moveCount: state.moveCount + 1,
      moveHistory: newHistory,
      redoStack: [], // Clear redo on new move
      status: newStatus,
      clearSelectedTile: true,
      validMoves: MoveEngine.getValidMoves(result.board),
      lastMoveEvents: result.events,
    );
  }

  /// Undoes the last move.
  void undo() {
    if (!state.canUndo) return;

    final newHistory = [...state.moveHistory];
    final previousBoard = newHistory.removeLast();
    final newRedoStack = [...state.redoStack, state.board];

    state = state.copyWith(
      board: previousBoard,
      moveCount: state.moveCount - 1,
      moveHistory: newHistory,
      redoStack: newRedoStack,
      status: GameStatus.playing,
      clearSelectedTile: true,
      validMoves: MoveEngine.getValidMoves(previousBoard),
      lastMoveEvents: [],
    );
  }

  /// Redoes the last undone move.
  void redo() {
    if (!state.canRedo) return;

    final newRedoStack = [...state.redoStack];
    final redoBoard = newRedoStack.removeLast();
    final newHistory = [...state.moveHistory, state.board];

    state = state.copyWith(
      board: redoBoard,
      moveCount: state.moveCount + 1,
      moveHistory: newHistory,
      redoStack: newRedoStack,
      status: redoBoard.isCleared() ? GameStatus.won : GameStatus.playing,
      clearSelectedTile: true,
      validMoves: MoveEngine.getValidMoves(redoBoard),
      lastMoveEvents: [],
    );
  }

  /// Resets the board to its initial state.
  void resetLevel() {
    state = GameState(
      board: state.initialBoard,
      initialBoard: state.initialBoard,
      validMoves: MoveEngine.getValidMoves(state.initialBoard),
    );
  }
}
