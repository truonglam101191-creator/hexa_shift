import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  GameNotifier() : super(_createInitialState()) {
    _loadCampaignProgress();
  }

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

  /// Loads the highest unlocked level from shared preferences.
  Future<void> _loadCampaignProgress() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedLevel = prefs.getInt('hexa_shift_campaign_level') ?? 1;
      state = state.copyWith(unlockedCampaignLevel: savedLevel);
    } catch (_) {
      // Fallback silently if shared preferences fails (e.g. in tests)
    }
  }

  /// Saves the campaign progress to shared preferences.
  Future<void> _saveCampaignProgress(int levelIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('hexa_shift_campaign_level', levelIndex);
    } catch (_) {
      // Fail silently
    }
  }

  /// Starts an infinite campaign level.
  void startInfiniteLevel(int levelIndex) {
    final board = LevelGenerator.generateInfiniteLevel(levelIndex);
    state = GameState(
      board: board,
      initialBoard: board,
      validMoves: MoveEngine.getValidMoves(board),
      levelIndex: levelIndex,
      unlockedCampaignLevel: state.unlockedCampaignLevel,
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
      unlockedCampaignLevel: state.unlockedCampaignLevel,
    );
  }

  /// Handles a tap on the tile at [row], [col].
  void tapTile(int row, int col) {
    final tile = state.board.getTile(row, col);
    if (tile == null) return;

    if (tile.isCleared) {
      state = state.copyWith(clearSelectedTile: true, lastMoveEvents: []);
      return;
    }

    if (state.selectedTile != null &&
        state.selectedTile!.row == tile.row &&
        state.selectedTile!.col == tile.col) {
      _executeMove(tile);
      return;
    }

    state = state.copyWith(selectedTile: tile, lastMoveEvents: []);
  }

  /// Executes a move for the given [tile].
  void _executeMove(HexTile tile) {
    final newHistory = [...state.moveHistory, state.board];
    final result = MoveEngine.executeMove(state.board, tile);

    final newStatus = result.board.isCleared()
        ? GameStatus.won
        : GameStatus.playing;

    var newUnlockedLevel = state.unlockedCampaignLevel;
    if (newStatus == GameStatus.won && state.levelIndex != null) {
      if (state.levelIndex == state.unlockedCampaignLevel) {
        newUnlockedLevel = state.unlockedCampaignLevel + 1;
        _saveCampaignProgress(newUnlockedLevel);
      }
    }

    state = state.copyWith(
      board: result.board,
      moveCount: state.moveCount + 1,
      moveHistory: newHistory,
      redoStack: [],
      status: newStatus,
      clearSelectedTile: true,
      validMoves: MoveEngine.getValidMoves(result.board),
      lastMoveEvents: result.events,
      unlockedCampaignLevel: newUnlockedLevel,
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
      levelIndex: state.levelIndex,
      unlockedCampaignLevel: state.unlockedCampaignLevel,
    );
  }
}
