import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/hex_math.dart';
import '../painters/hex_board_painter.dart';
import '../providers/game_provider.dart';

/// Interactive widget that renders the hex board and handles tap gestures.
///
/// Wraps the [HexBoardPainter] with gesture detection, zoom/pan support,
/// and a selection pulse animation.
class HexBoardWidget extends ConsumerStatefulWidget {
  const HexBoardWidget({super.key});

  @override
  ConsumerState<HexBoardWidget> createState() => _HexBoardWidgetState();
}

class _HexBoardWidgetState extends ConsumerState<HexBoardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Pulse animation for selected tile glow
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute optimal hex radius for the available space
        final availableSize = Size(
          constraints.maxWidth,
          constraints.maxHeight,
        );
        final radius = HexMath.optimalRadius(
          board.rows,
          board.cols,
          availableSize,
          AppConstants.boardPadding,
        );

        // Compute board size and centering offset
        final boardSize = HexMath.boardSize(board.rows, board.cols, radius);
        final offsetX = (availableSize.width - boardSize.width) / 2 + radius;
        final offsetY = (availableSize.height - boardSize.height) / 2 +
            radius * 0.866; // sqrt(3)/2
        final boardOffset = Offset(offsetX, offsetY);

        return InteractiveViewer(
          minScale: 0.6,
          maxScale: 2.5,
          boundaryMargin: const EdgeInsets.all(60),
          child: GestureDetector(
            onTapUp: (details) => _onTapUp(details, radius, boardOffset),
            child: AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, _) {
                return CustomPaint(
                  size: availableSize,
                  painter: HexBoardPainter(
                    board: board,
                    radius: radius,
                    offset: boardOffset,
                    selectedTile: gameState.selectedTile,
                    pulseValue: _pulseAnimation.value,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Handles tap events: converts screen coordinates to hex grid coordinates.
  void _onTapUp(TapUpDetails details, double radius, Offset boardOffset) {
    final tapPos = details.localPosition;
    final board = ref.read(gameProvider).board;

    // Find which tile was tapped by testing each tile's hex boundary
    for (final tile in board.tiles) {
      final center = HexMath.hexCenter(tile.row, tile.col, radius) + boardOffset;
      if (HexMath.pointInHex(tapPos, center, radius)) {
        // Haptic feedback on valid tap
        HapticFeedback.lightImpact();
        ref.read(gameProvider.notifier).tapTile(tile.row, tile.col);
        return;
      }
    }
  }
}
