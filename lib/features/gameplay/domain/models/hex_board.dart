import 'hex_tile.dart';

/// An immutable hexagonal game board.
///
/// Holds a flat list of [HexTile]s and provides query methods.
/// All mutation returns a new [HexBoard] instance (immutable pattern).
class HexBoard {
  const HexBoard({
    required this.rows,
    required this.cols,
    required this.tiles,
  });

  /// Number of rows in the grid.
  final int rows;

  /// Number of columns in the grid.
  final int cols;

  /// All tiles on the board (including cleared ones).
  final List<HexTile> tiles;

  /// Returns the tile at [row], [col], or `null` if out of bounds.
  HexTile? getTile(int row, int col) {
    if (row < 0 || row >= rows || col < 0 || col >= cols) return null;
    // Tiles are stored in row-major order: index = row * cols + col
    final index = row * cols + col;
    if (index < 0 || index >= tiles.length) return null;
    return tiles[index];
  }

  /// Returns a new board with [updatedTile] replacing the tile at its position.
  HexBoard updateTile(HexTile updatedTile) {
    final newTiles = List<HexTile>.from(tiles);
    final index = updatedTile.row * cols + updatedTile.col;
    if (index >= 0 && index < newTiles.length) {
      newTiles[index] = updatedTile;
    }
    return HexBoard(rows: rows, cols: cols, tiles: newTiles);
  }

  /// Returns a new board with multiple tiles updated at once.
  HexBoard updateTiles(List<HexTile> updatedTiles) {
    final newTiles = List<HexTile>.from(tiles);
    for (final tile in updatedTiles) {
      final index = tile.row * cols + tile.col;
      if (index >= 0 && index < newTiles.length) {
        newTiles[index] = tile;
      }
    }
    return HexBoard(rows: rows, cols: cols, tiles: newTiles);
  }

  /// Returns `true` if all tiles have been cleared.
  bool isCleared() => tiles.every((t) => t.isCleared);

  /// Returns the number of tiles that are still active (not cleared).
  int get activeTileCount => tiles.where((t) => !t.isCleared).length;

  /// Returns all active (non-cleared) tiles.
  List<HexTile> get activeTiles => tiles.where((t) => !t.isCleared).toList();

  /// Checks if a position is within the board bounds.
  bool isInBounds(int row, int col) {
    return row >= 0 && row < rows && col >= 0 && col < cols;
  }

  /// Serializes the board to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
    'rows': rows,
    'cols': cols,
    'tiles': tiles.map((t) => t.toJson()).toList(),
  };

  /// Deserializes a board from a JSON-compatible map.
  factory HexBoard.fromJson(Map<String, dynamic> json) {
    return HexBoard(
      rows: json['rows'] as int,
      cols: json['cols'] as int,
      tiles: (json['tiles'] as List)
          .map((t) => HexTile.fromJson(t as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HexBoard &&
          rows == other.rows &&
          cols == other.cols &&
          _tilesEqual(other.tiles);

  bool _tilesEqual(List<HexTile> otherTiles) {
    if (tiles.length != otherTiles.length) return false;
    for (var i = 0; i < tiles.length; i++) {
      if (tiles[i] != otherTiles[i]) return false;
    }
    return true;
  }

  @override
  int get hashCode => Object.hash(rows, cols, Object.hashAll(tiles));
}
