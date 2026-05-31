import 'arrow_direction.dart';

/// An immutable hexagonal tile on the game board.
///
/// Each tile has a position ([row], [col]), an [arrowDirection] indicating
/// where it can move, and an [isCleared] flag.
class HexTile {
  const HexTile({
    required this.row,
    required this.col,
    required this.arrowDirection,
    this.isCleared = false,
  });

  /// Row index in the hex grid (0-based from top).
  final int row;

  /// Column index in the hex grid (0-based from left).
  final int col;

  /// The direction this tile's arrow points — determines movement direction.
  final ArrowDirection arrowDirection;

  /// Whether this tile has been cleared (removed from play).
  final bool isCleared;

  /// Returns a copy of this tile with the given fields replaced.
  HexTile copyWith({
    int? row,
    int? col,
    ArrowDirection? arrowDirection,
    bool? isCleared,
  }) {
    return HexTile(
      row: row ?? this.row,
      col: col ?? this.col,
      arrowDirection: arrowDirection ?? this.arrowDirection,
      isCleared: isCleared ?? this.isCleared,
    );
  }

  /// Unique key for this tile's position on the board.
  String get positionKey => '$row,$col';

  /// Serializes this tile to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'row': row,
    'col': col,
    'arrowDirection': arrowDirection.toJson(),
    'isCleared': isCleared,
  };

  /// Deserializes a tile from a JSON-compatible map.
  factory HexTile.fromJson(Map<String, dynamic> json) {
    return HexTile(
      row: json['row'] as int,
      col: json['col'] as int,
      arrowDirection: ArrowDirection.fromJson(json['arrowDirection'] as String),
      isCleared: json['isCleared'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexTile &&
          row == other.row &&
          col == other.col &&
          arrowDirection == other.arrowDirection &&
          isCleared == other.isCleared;

  @override
  int get hashCode => Object.hash(row, col, arrowDirection, isCleared);

  @override
  String toString() =>
      'HexTile($row, $col, ${arrowDirection.name}, cleared=$isCleared)';
}
