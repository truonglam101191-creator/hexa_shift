/// The six possible arrow directions on a hexagonal tile.
///
/// Each direction corresponds to one of the six edges of a flat-top hexagon.
/// The direction determines where a tile will move when activated.
enum ArrowDirection {
  up,
  down,
  upLeft,
  upRight,
  downLeft,
  downRight;

  /// Returns the index of this direction (used for color mapping).
  int get colorIndex => index;

  /// Returns the opposite direction.
  ArrowDirection get opposite {
    return switch (this) {
      ArrowDirection.up => ArrowDirection.down,
      ArrowDirection.down => ArrowDirection.up,
      ArrowDirection.upLeft => ArrowDirection.downRight,
      ArrowDirection.upRight => ArrowDirection.downLeft,
      ArrowDirection.downLeft => ArrowDirection.upRight,
      ArrowDirection.downRight => ArrowDirection.upLeft,
    };
  }

  /// Returns the next direction in clockwise order.
  ArrowDirection rotateClockwise() {
    return switch (this) {
      ArrowDirection.up => ArrowDirection.upRight,
      ArrowDirection.upRight => ArrowDirection.downRight,
      ArrowDirection.downRight => ArrowDirection.down,
      ArrowDirection.down => ArrowDirection.downLeft,
      ArrowDirection.downLeft => ArrowDirection.upLeft,
      ArrowDirection.upLeft => ArrowDirection.up,
    };
  }

  /// Returns the next direction in counter-clockwise order.
  ArrowDirection rotateCounterClockwise() {
    return switch (this) {
      ArrowDirection.up => ArrowDirection.upLeft,
      ArrowDirection.upLeft => ArrowDirection.downLeft,
      ArrowDirection.downLeft => ArrowDirection.down,
      ArrowDirection.down => ArrowDirection.downRight,
      ArrowDirection.downRight => ArrowDirection.upRight,
      ArrowDirection.upRight => ArrowDirection.up,
    };
  }

  /// Returns the (dRow, dCol) offset to reach the neighbor in this direction.
  ///
  /// Offset hex grid (odd-q): odd columns are shifted down.
  /// [isOddCol] indicates whether the source tile is in an odd column.
  (int, int) neighborOffset(bool isOddCol) {
    if (isOddCol) {
      // Odd column: shifted down
      return switch (this) {
        ArrowDirection.up => (-1, 0),
        ArrowDirection.down => (1, 0),
        ArrowDirection.upLeft => (0, -1),
        ArrowDirection.upRight => (0, 1),
        ArrowDirection.downLeft => (1, -1),
        ArrowDirection.downRight => (1, 1),
      };
    } else {
      // Even column
      return switch (this) {
        ArrowDirection.up => (-1, 0),
        ArrowDirection.down => (1, 0),
        ArrowDirection.upLeft => (-1, -1),
        ArrowDirection.upRight => (-1, 1),
        ArrowDirection.downLeft => (0, -1),
        ArrowDirection.downRight => (0, 1),
      };
    }
  }

  /// The angle in radians for drawing the arrow indicator.
  /// 0 = pointing right, π/2 = pointing down, etc.
  double get arrowAngle {
    return switch (this) {
      ArrowDirection.up => -1.5707963267948966, // -π/2 (-90 deg)
      ArrowDirection.down => 1.5707963267948966, // π/2 (90 deg)
      ArrowDirection.upLeft => -2.617993877991494, // -5π/6 (-150 deg)
      ArrowDirection.upRight => -0.5235987755982988, // -π/6 (-30 deg)
      ArrowDirection.downLeft => 2.617993877991494, // 5π/6 (150 deg)
      ArrowDirection.downRight => 0.5235987755982988, // π/6 (30 deg)
    };
  }

  /// JSON serialization: direction name as string.
  String toJson() => name;

  /// JSON deserialization: parse direction from string.
  static ArrowDirection fromJson(String json) {
    return ArrowDirection.values.firstWhere(
      (d) => d.name == json,
      orElse: () => ArrowDirection.up,
    );
  }
}
