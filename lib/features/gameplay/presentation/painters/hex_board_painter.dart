import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/hex_math.dart';
import '../../domain/models/arrow_direction.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/hex_board.dart';
import '../../domain/models/hex_tile.dart';

/// Custom painter that renders the entire hexagonal game board in a 3D Isometric view.
class HexBoardPainter extends CustomPainter {
  HexBoardPainter({
    required this.board,
    required this.radius,
    required this.offset,
    this.selectedTile,
    this.pulseValue = 0.0,
    this.moveAnimationValue = 0.0,
    this.lastMoveEvents = const [],
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

  /// Movement animation value (0.0 - 1.0).
  final double moveAnimationValue;

  /// Event list from the last executed move.
  final List<MoveEvent> lastMoveEvents;

  // ── 3D Projection Constants ──────────────────────────────────────────────
  static const double _tiltCos = 0.866; // cos(30 degrees)
  static const double _tiltSin = 0.500; // sin(30 degrees)
  static const double _baseHeight = 12.0; // default height of active tile
  static const double _hoverHeight = 22.0; // height of selected tile

  /// Projects a flat 2D point into 3D isometric space at a given height [z].
  Offset _project(Offset pt, double z) {
    return Offset(pt.dx, pt.dy * _tiltCos - z * _tiltSin);
  }

  @override
  void paint(Canvas canvas, ui.Size size) {
    // 1. Draw all cleared (empty) tiles first to lay the background grid
    for (final tile in board.tiles) {
      if (tile.isCleared) {
        // Only draw static cleared tiles that are NOT currently the source of a slide animation
        final isAnimatingAway = lastMoveEvents.any((e) =>
            e is TileMoved &&
            e.fromRow == tile.row &&
            e.fromCol == tile.col &&
            moveAnimationValue < 1.0);
        if (!isAnimatingAway) {
          _drawClearedTile(canvas, tile);
        }
      }
    }

    // 2. Draw active tiles (including hovering/selected and moving/sliding tiles).
    // The tiles list is sorted row-major, so drawing from top-to-bottom naturally
    // handles depth sorting correctly (nearer rows overlay further rows).
    for (final tile in board.tiles) {
      if (!tile.isCleared) {
        _drawActiveTileWithAnimations(canvas, tile);
      }
    }

    // 3. Draw sliding tiles that are already logically cleared in the new board
    // but should still be rendered sliding during the transition animation.
    if (moveAnimationValue < 1.0) {
      for (final event in lastMoveEvents) {
        if (event is TileMoved) {
          _drawSlidingTile(canvas, event);
        }
      }
    }
  }

  /// Draws a cleared (empty) slot as a flat outline in the ground plane (z = 0).
  void _drawClearedTile(Canvas canvas, HexTile tile) {
    final center2D = HexMath.hexCenter(tile.row, tile.col, radius) + offset;
    final corners2D = HexMath.hexCorners(center2D, radius);
    final corners3D = corners2D.map((c) => _project(c, 0.0)).toList();
    final path = _hexPath(corners3D);

    // Flat shadow background
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

  /// Draws an active tile, checking for selected hover elevation or rotation animations.
  void _drawActiveTileWithAnimations(Canvas canvas, HexTile tile) {
    final center2D = HexMath.hexCenter(tile.row, tile.col, radius) + offset;
    final isSelected = selectedTile != null &&
        selectedTile!.row == tile.row &&
        selectedTile!.col == tile.col;

    // Check if the tile is rotating (bumped)
    TileRotated? rotatedEvent;
    if (moveAnimationValue < 1.0) {
      for (final event in lastMoveEvents) {
        if (event is TileRotated && event.row == tile.row && event.col == tile.col) {
          rotatedEvent = event;
          break;
        }
      }
    }

    // Animate selection hover elevation smoothly
    final double z = isSelected
        ? ui.lerpDouble(_baseHeight, _hoverHeight, pulseValue)!
        : _baseHeight;

    // Draw the 3D block
    _draw3DHexPrism(canvas, center2D, z, tile.arrowDirection, isSelected, 1.0);

    // Draw the arrow
    if (rotatedEvent != null) {
      // Interpolate the arrow direction from old (counter-clockwise) to new (clockwise)
      final newDir = tile.arrowDirection;
      final oldDir = newDir.rotateCounterClockwise();
      final double angle = ui.lerpDouble(oldDir.arrowAngle, newDir.arrowAngle, moveAnimationValue)!;
      _drawArrow3D(canvas, center2D, z, newDir, isSelected, 1.0, overrideAngle: angle);
    } else {
      _drawArrow3D(canvas, center2D, z, tile.arrowDirection, isSelected, 1.0);
    }
  }

  /// Draws a tile that is sliding from one position to another (transition state).
  void _drawSlidingTile(Canvas canvas, TileMoved event) {
    final startCenter = HexMath.hexCenter(event.fromRow, event.fromCol, radius) + offset;
    final endCenter = HexMath.hexCenter(event.toRow, event.toCol, radius) + offset;
    final currentCenter = Offset.lerp(startCenter, endCenter, moveAnimationValue)!;

    // Fade out as it reaches destination
    final opacity = (1.0 - moveAnimationValue).clamp(0.0, 1.0);

    // Infer arrow direction from the movement vector
    final direction = _inferDirection(event.fromRow, event.fromCol, event.toRow, event.toCol);

    // Draw the 3D block & arrow sliding
    _draw3DHexPrism(canvas, currentCenter, _baseHeight, direction, false, opacity);
    _drawArrow3D(canvas, currentCenter, _baseHeight, direction, false, opacity);

    // Draw trail and explosion particles
    _drawParticleSparks(canvas, currentCenter, direction, opacity);
  }

  /// Draws trail and clear explosion particles for the sliding tile.
  void _drawParticleSparks(
    Canvas canvas,
    Offset center2D,
    ArrowDirection direction,
    double opacity,
  ) {
    final dirIndex = direction.colorIndex;
    final sparkColor = AppColors.tileGlowForDirection(dirIndex);

    // 1. Trail Particles (glowing dots behind the movement direction)
    final movementAngle = direction.arrowAngle + pi; // Opposite direction
    final trailCount = 3;
    final trailPaint = Paint()..style = PaintingStyle.fill;

    for (var i = 1; i <= trailCount; i++) {
      final double distance = radius * 0.4 * i * (1.0 - moveAnimationValue);
      final trailOffsetFlat = Offset(
        center2D.dx + cos(movementAngle) * distance,
        center2D.dy + sin(movementAngle) * distance,
      );
      final trailOffset3D = _project(trailOffsetFlat, _baseHeight + 2.0);

      trailPaint.color = sparkColor.withValues(alpha: opacity * (1.0 - (i / (trailCount + 1))) * 0.6);
      canvas.drawCircle(trailOffset3D, 3.0 * (1.0 - moveAnimationValue), trailPaint);
    }

    // 2. Clear Explosion (Sparks expanding outwards in the second half of the animation)
    if (moveAnimationValue > 0.3) {
      final double explodeProgress = (moveAnimationValue - 0.3) / 0.7; // 0.0 to 1.0
      final sparkPaint = Paint()..style = PaintingStyle.fill;
      final int sparkCount = 6;

      for (var i = 0; i < sparkCount; i++) {
        final double angle = (i * 2 * pi) / sparkCount + (explodeProgress * 0.5); // Add rotation sway
        final double distance = radius * (0.3 + explodeProgress * 1.2);
        final sparkOffsetFlat = Offset(
          center2D.dx + cos(angle) * distance,
          center2D.dy + sin(angle) * distance,
        );
        final sparkOffset3D = _project(sparkOffsetFlat, _baseHeight + 2.0);

        sparkPaint.color = sparkColor.withValues(alpha: (1.0 - explodeProgress) * 0.95 * opacity);
        canvas.drawCircle(sparkOffset3D, 2.5 * (1.0 - explodeProgress), sparkPaint);
      }
    }
  }

  /// Renders the extruded 3D hex block with drop shadows, Southern side walls, and shaded lighting.
  void _draw3DHexPrism(
    Canvas canvas,
    Offset center2D,
    double h,
    ArrowDirection direction,
    bool isSelected,
    double opacity,
  ) {
    final corners2D = HexMath.hexCorners(center2D, radius);
    final topCorners = corners2D.map((c) => _project(c, h)).toList();
    final baseCorners = corners2D.map((c) => _project(c, 0.0)).toList();

    // 1. Draw 3D Drop Shadow on ground plane
    final shadowOffset = Offset(radius * 0.1, radius * 0.15 + h * 0.2);
    final shadowPath = Path()..moveTo(baseCorners[0].dx + shadowOffset.dx, baseCorners[0].dy + shadowOffset.dy);
    for (var i = 1; i < baseCorners.length; i++) {
      shadowPath.lineTo(baseCorners[i].dx + shadowOffset.dx, baseCorners[i].dy + shadowOffset.dy);
    }
    shadowPath.close();

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: (0.22 - (h > _baseHeight ? 0.05 : 0.0)) * opacity)
      ..style = PaintingStyle.fill
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, radius * 0.15 + h * 0.1);
    canvas.drawPath(shadowPath, shadowPaint);

    // 2. Draw Side Walls ( Southern faces are visible: Left-Bottom 3->2, Bottom 2->1, Right-Bottom 1->0)
    final dirIndex = direction.colorIndex;
    final baseColor = AppColors.tileColorForDirection(dirIndex);

    // Apply shading multipliers to simulate directional lighting from top-left
    final leftColor = Color.lerp(baseColor, Colors.black, 0.28)!.withValues(alpha: opacity);
    final bottomColor = Color.lerp(baseColor, Colors.black, 0.48)!.withValues(alpha: opacity);
    final rightColor = Color.lerp(baseColor, Colors.black, 0.14)!.withValues(alpha: opacity);

    // Left face (Corner 3 to 2)
    _drawSideWall(canvas, topCorners[3], topCorners[2], baseCorners[2], baseCorners[3], leftColor);
    // Bottom face (Corner 2 to 1)
    _drawSideWall(canvas, topCorners[2], topCorners[1], baseCorners[1], baseCorners[2], bottomColor);
    // Right face (Corner 1 to 0)
    _drawSideWall(canvas, topCorners[1], topCorners[0], baseCorners[0], baseCorners[1], rightColor);

    // Stroke the creases/joints between side faces to make them pop
    final creasePaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.12 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    _strokeCrease(canvas, topCorners[2], baseCorners[2], creasePaint);
    _strokeCrease(canvas, topCorners[1], baseCorners[1], creasePaint);

    // 3. Draw Top Face
    final topPath = Path()..moveTo(topCorners[0].dx, topCorners[0].dy);
    for (var i = 1; i < topCorners.length; i++) {
      topPath.lineTo(topCorners[i].dx, topCorners[i].dy);
    }
    topPath.close();

    final glowColor = AppColors.tileGlowForDirection(dirIndex);
    final topCenter = _project(center2D, h);

    // Radial gradient on the top face
    final gradient = ui.Gradient.radial(
      topCenter,
      radius,
      [glowColor.withValues(alpha: 0.9 * opacity), baseColor.withValues(alpha: 0.7 * opacity)],
      [0.0, 1.0],
    );
    final fillPaint = Paint()
      ..shader = gradient
      ..style = PaintingStyle.fill;
    canvas.drawPath(topPath, fillPaint);

    // Top Face Outline
    final borderPaint = Paint()
      ..color = isSelected
          ? AppColors.tileSelected.withValues(alpha: 0.95 * opacity)
          : AppColors.tileBorder.withValues(alpha: 0.35 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.5 : 1.2;
    canvas.drawPath(topPath, borderPaint);

    // Selection Glow (Pulse)
    if (isSelected) {
      final glowPaint = Paint()
        ..color = AppColors.tileSelected.withValues(alpha: (0.15 + pulseValue * 0.15) * opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4.0 + pulseValue * 2.0
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 8.0);
      canvas.drawPath(topPath, glowPaint);
    }
  }

  /// Draws a single quad for a lăng trụ side wall.
  void _drawSideWall(Canvas canvas, Offset t1, Offset t2, Offset b2, Offset b1, Color color) {
    final path = Path()
      ..moveTo(t1.dx, t1.dy)
      ..lineTo(t2.dx, t2.dy)
      ..lineTo(b2.dx, b2.dy)
      ..lineTo(b1.dx, b1.dy)
      ..close();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);
  }

  /// Strokes a dividing crease between sides.
  void _strokeCrease(Canvas canvas, Offset top, Offset base, Paint paint) {
    canvas.drawLine(top, base, paint);
  }

  /// Renders a floating 3D arrow indicator with an underlying shadow.
  void _drawArrow3D(
    Canvas canvas,
    Offset center2D,
    double h,
    ArrowDirection direction,
    bool isSelected,
    double opacity, {
    double? overrideAngle,
  }) {
    final angle = overrideAngle ?? direction.arrowAngle;
    final arrowLength = radius * 0.45;
    final headSize = radius * 0.18;

    // 1. Draw Arrow Shadow (floating slightly above top face)
    final shadowCenter = _project(center2D, h + 0.8);
    canvas.save();
    canvas.translate(shadowCenter.dx, shadowCenter.dy);
    canvas.rotate(angle);

    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.32 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.8 : 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-arrowLength * 0.4, 1.0),
      Offset(arrowLength * 0.5, 1.0),
      shadowPaint,
    );
    canvas.restore();

    // 2. Draw Main Arrow (floating higher at h + 2.5)
    final arrowCenter = _project(center2D, h + 2.5);
    canvas.save();
    canvas.translate(arrowCenter.dx, arrowCenter.dy);
    canvas.rotate(angle);

    final shaftPaint = Paint()
      ..color = isSelected
          ? AppColors.arrowColor.withValues(alpha: opacity)
          : AppColors.arrowColor.withValues(alpha: 0.88 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isSelected ? 2.8 : 2.2
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(-arrowLength * 0.4, 0),
      Offset(arrowLength * 0.5, 0),
      shaftPaint,
    );

    final headPath = Path()
      ..moveTo(arrowLength * 0.5 - headSize, -headSize)
      ..lineTo(arrowLength * 0.5, 0)
      ..lineTo(arrowLength * 0.5 - headSize, headSize);
    canvas.drawPath(headPath, shaftPaint);

    canvas.restore();
  }

  /// Infers the direction of a slide animation based on grid offsets.
  ArrowDirection _inferDirection(int fromRow, int fromCol, int toRow, int toCol) {
    final isOddCol = fromCol % 2 == 1;
    for (final dir in ArrowDirection.values) {
      final (dRow, dCol) = dir.neighborOffset(isOddCol);
      if (fromRow + dRow == toRow && fromCol + dCol == toCol) {
        return dir;
      }
    }
    return ArrowDirection.up;
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
        pulseValue != oldDelegate.pulseValue ||
        moveAnimationValue != oldDelegate.moveAnimationValue ||
        lastMoveEvents != oldDelegate.lastMoveEvents;
  }
}
