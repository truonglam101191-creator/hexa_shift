import 'dart:math';
import 'dart:ui';

/// Math helpers for hexagonal grid calculations.
///
/// Uses **offset coordinates (odd-q / flat-top)** where:
/// - `col` (q) is the horizontal column index.
/// - `row` (r) is the vertical row index.
/// - Odd columns are shifted down by half a tile height.
class HexMath {
  HexMath._();

  /// Square root of 3, cached for performance.
  static final double _sqrt3 = sqrt(3);

  /// Computes the pixel center of a hex tile at [row], [col] with given [radius].
  ///
  /// Uses flat-top hexagon layout (odd-q offset):
  /// - x = radius × 3/2 × col
  /// - y = radius × √3 × (row + 0.5 × (col % 2))
  static Offset hexCenter(int row, int col, double radius) {
    final double x = radius * 1.5 * col;
    final double y = radius * _sqrt3 * (row + 0.5 * (col % 2));
    return Offset(x, y);
  }

  /// Returns the 6 corner vertices of a flat-top hexagon centered at [center].
  ///
  /// Vertices are ordered starting from the right (0°) going counter-clockwise.
  static List<Offset> hexCorners(Offset center, double radius) {
    return List.generate(6, (i) {
      final angle = (60 * i) * pi / 180; // Flat-top: start at 0°
      return Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );
    });
  }

  /// Returns `true` if [point] falls inside the hexagon at [center] with [radius].
  ///
  /// Uses the point-in-polygon ray casting approach optimized for regular hexagons.
  static bool pointInHex(Offset point, Offset center, double radius) {
    // Quick bounding-box rejection
    final dx = (point.dx - center.dx).abs();
    final dy = (point.dy - center.dy).abs();
    if (dx > radius || dy > radius * _sqrt3 / 2) return false;

    // Precise hex boundary check for flat-top hex
    // A flat-top hex has width = 2*radius, height = sqrt(3)*radius
    // The hex boundary test: for a flat-top hex centered at origin,
    // a point (px, py) is inside if:
    //   |py| <= sqrt(3)/2 * radius  AND
    //   sqrt(3)*|px| + |py| <= sqrt(3) * radius
    return (_sqrt3 * dx + dy) <= _sqrt3 * radius;
  }

  /// Computes the total board size (width, height) in pixels for a grid of
  /// [rows] × [cols] hex tiles with the given [radius].
  static Size boardSize(int rows, int cols, double radius) {
    if (rows == 0 || cols == 0) return Size.zero;

    // Width: leftmost to rightmost hex center + one full radius on each side
    final double width = radius * 1.5 * (cols - 1) + radius * 2;

    // Height: topmost to bottommost hex center + half-height on each side
    // Odd columns shift down by half a hex height
    final double height = radius * _sqrt3 * rows + radius * _sqrt3 * 0.5;

    return Size(width, height);
  }

  /// Computes the optimal hex radius to fit a [rows] × [cols] board
  /// within the available [size], respecting [padding] on all sides.
  static double optimalRadius(int rows, int cols, Size size, double padding) {
    if (rows == 0 || cols == 0) return 36.0;

    final availW = size.width - padding * 2;
    final availH = size.height - padding * 2;

    // From width: availW = radius * 1.5 * (cols - 1) + radius * 2
    //           = radius * (1.5 * cols + 0.5)
    final radiusFromWidth = availW / (1.5 * (cols - 1) + 2);

    // From height: availH = radius * sqrt(3) * rows + radius * sqrt(3) * 0.5
    //            = radius * sqrt(3) * (rows + 0.5)
    final radiusFromHeight = availH / (_sqrt3 * (rows + 0.5));

    return min(radiusFromWidth, radiusFromHeight).clamp(16.0, 60.0);
  }
}
