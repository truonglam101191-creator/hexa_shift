import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hex_math.dart';
import '../../domain/models/arrow_direction.dart';
import '../../domain/models/hex_board.dart';
import '../../domain/models/hex_tile.dart';

/// Custom painter that renders the entire hexagonal game board.
///
/// Draws each hex tile with:
/// - Gradient fill colored by arrow direction.
/// - Arrow indicator showing movement direction.
/// - Visual states: selected, cleared, highlighted.
///
/// Uses [shouldRepaint] to avoid unnecessary redraws.
class HexBoardPainter extends CustomPainter {
  HexBoardPainter({
    required this.board,
    required this.radius,
    required this.offset,
    this.selectedTile,
    this.pulseValue = 0.0,
  });

  /// The current board state.
  final HexBoard board;

  /// Hex tile radius in pixels.
  final double radius;

  /// Offset to center the board in the canvas.
  final Offset offset;

  /// Currently selected tile (null if none).
  final HexTile? selectedTile;

  /// Pulse animation value (0.0 - 1.0) for selected tile glow.
  final double pulseValue;

  @override
  void paint(Canvas canvas, Size size) {
    for (final tile in board.tiles) {
      _drawTile(canvas, tile);
    }
  }

  /// Draws a single hex tile with all its visual elements.
  void _drawTile(Canvas canvas, HexTile tile) {
    final center = HexMath.hexCenter(tile.row, tile.col, radius) + offset;
    final corners = HexMath.hexCorners(center, radius);
    final path = _hexPath(corners);

    if (tile.isCleared) {
      _drawClearedTile(canvas, path, center);
    } else {
      final isSelected = selectedTile != null &&
          selectedTile!.row == tile.row &&
          selectedTile!.col == tile.col;

      _drawActiveTile(canvas, path, center, tile, isSelected);
      _drawArrow(canvas, center, tile.arrowDirection, isSelected);
    }
  }

  /// Draws a cleared (empty) tile with a subtle ghost outline.
  void _drawClearedTile(Canvas canvas, Path path, Offset center) {
    // Subtle fill
    final fillPaint = Paint()
      ..color = AppColors.tileCleared
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Dashed border effect
    final borderPaint = Paint()
      ..color = AppColors.tileClearedBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawPath(path, borderPaint);
  }

  /// Draws an active tile with gradient fill, border, and optional selection glow.
  void _drawActiveTile(
    Canvas canvas,
    Path path,
    Offset center,
    HexTile tile,
    bool isSelected,
  ) {
    final dirIndex = tile.arrowDirection.colorIndex;
    final baseColor = AppColors.tileColorForDirection(dirIndex);
    final glowColor = AppColors.tileGlowForDirection(dirIndex);

    // Gradient fill
    final gradient = ui.Gradient.radial(
      center,
      radius,
      [glowColor.withValues(alpha: 0.9), baseColor.withValues(alpha: 0.7)],
      [0.0, 1.0],
    );
    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Border
    final borderPaint = Paint()
      ..color = isSelected
          ? AppColors.tileSelected.withValues(alpha: 0.9)
          : AppColors.tileBorder
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.2;
    canvas.drawPath(path, borderPaint);

    // Selection glow effect
    if (isSelected) {
      final glowPaint = Paint()
        ..color = AppColors.tileSelected.withValues(alpha: 0.15 + pulseValue * 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 + pulseValue * 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      canvas.drawPath(path, glowPaint);
    }
  }

  /// Draws the arrow indicator inside a tile.
  void _drawArrow(
    Canvas canvas,
    Offset center,
    ArrowDirection direction,
    bool isSelected,
  ) {
    final angle = direction.arrowAngle;
    final arrowLength = radius * 0.45;
    final headSize = radius * 0.18;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);

    // Arrow shaft
    final shaftPaint = Paint()
      ..color = isSelected
          ? AppColors.arrowColor
          : AppColors.arrowColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.8 : 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-arrowLength * 0.4, 0),
      Offset(arrowLength * 0.5, 0),
      shaftPaint,
    );

    // Arrow head (chevron)
    final headPaint = Paint()
      ..color = isSelected
          ? AppColors.arrowColor
          : AppColors.arrowColor.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.8 : 2.2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final headPath = Path()
      ..moveTo(arrowLength * 0.5 - headSize, -headSize)
      ..lineTo(arrowLength * 0.5, 0)
      ..lineTo(arrowLength * 0.5 - headSize, headSize);
    canvas.drawPath(headPath, headPaint);

    canvas.restore();
  }

  /// Creates a closed path through the hex corners.
  Path _hexPath(List<Offset> corners) {
    final path = Path()..moveTo(corners[0].dx, corners[0].dy);
    for (var i = 1; i < corners.length; i++) {
      path.lineTo(corners[i].dx, corners[i].dy);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant HexBoardPainter oldDelegate) {
    return board != oldDelegate.board ||
        radius != oldDelegate.radius ||
        offset != oldDelegate.offset ||
        selectedTile != oldDelegate.selectedTile ||
        pulseValue != oldDelegate.pulseValue;
  }
}
