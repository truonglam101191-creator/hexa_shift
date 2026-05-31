/// Global constants for Hexa Shift game configuration.
class AppConstants {
  AppConstants._();

  // ── Board Size Presets ─────────────────────────────────────────────────
  static const int easyRows = 4;
  static const int easyCols = 4;

  static const int mediumRows = 5;
  static const int mediumCols = 6;

  static const int hardRows = 7;
  static const int hardCols = 8;

  // ── Animation Durations (milliseconds) ─────────────────────────────────
  static const int tileMoveDurationMs = 300;
  static const int tileClearDurationMs = 250;
  static const int tileRotateDurationMs = 200;
  static const int chainReactionDelayMs = 150;
  static const int victoryDelayMs = 600;

  // ── Hex Geometry ───────────────────────────────────────────────────────
  /// Default hex tile radius in logical pixels.
  /// Actual radius is computed dynamically from screen size.
  static const double defaultHexRadius = 36.0;

  /// Padding around the board edge.
  static const double boardPadding = 24.0;

  // ── Difficulty Enum ────────────────────────────────────────────────────
  /// Returns (rows, cols) for a given difficulty level.
  static (int, int) boardSizeForDifficulty(Difficulty difficulty) {
    return switch (difficulty) {
      Difficulty.easy => (easyRows, easyCols),
      Difficulty.medium => (mediumRows, mediumCols),
      Difficulty.hard => (hardRows, hardCols),
    };
  }
}

/// Game difficulty levels.
enum Difficulty {
  easy('Easy', '4 × 4'),
  medium('Medium', '5 × 6'),
  hard('Hard', '7 × 8');

  const Difficulty(this.label, this.sizeLabel);

  /// Human-readable label.
  final String label;

  /// Board size as a readable string.
  final String sizeLabel;
}
