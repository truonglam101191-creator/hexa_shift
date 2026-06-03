import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/hex_math.dart';
import '../../domain/models/game_state.dart';
import '../../domain/models/hex_tile.dart';
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
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  late AnimationController _moveController;

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

    // Movement transition animation controller
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _moveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final board = gameState.board;

    // Listen to changes in the game state to trigger move animations and tactile feedback
    ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.lastMoveEvents.isNotEmpty) {
        _moveController.forward(from: 0.0);
        HapticFeedback.mediumImpact();
      }
    });

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
              animation: Listenable.merge([_pulseAnimation, _moveController]),
              builder: (context, _) {
                return CustomPaint(
                  size: availableSize,
                  painter: HexBoardPainter(
                    board: board,
                    radius: radius,
                    offset: boardOffset,
                    selectedTile: gameState.selectedTile,
                    pulseValue: _pulseAnimation.value,
                    moveAnimationValue: _moveController.value,
                    lastMoveEvents: gameState.lastMoveEvents,
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  /// Handles tap events: converts screen coordinates to hex grid coordinates using inverse 3D projection.
  void _onTapUp(TapUpDetails details, double radius, Offset boardOffset) {
    final tapPos = details.localPosition;
    final gameState = ref.read(gameProvider);
    final board = gameState.board;
    final selectedTile = gameState.selectedTile;

    // To handle 3D depth, we test tiles in reverse rendering order (closest tiles / bottom rows first).
    final tiles = List<HexTile>.from(board.tiles);
    tiles.sort((a, b) {
      if (a.row != b.row) return b.row.compareTo(a.row);
      return b.col.compareTo(a.col);
    });

    for (final tile in tiles) {
      final center2D = HexMath.hexCenter(tile.row, tile.col, radius) + boardOffset;
      
      // Determine the height of this tile
      double z = 0.0;
      if (!tile.isCleared) {
        final isSelected = selectedTile != null &&
            selectedTile.row == tile.row &&
            selectedTile.col == tile.col;
        z = isSelected ? 22.0 : 12.0;
      }

      // Inverse project the tap position to the flat plane at height z
      // Project formula: y' = y * cos(30) - z * sin(30)
      // Inverse: y = (y' + z * sin(30)) / cos(30)
      final double flatY = (tapPos.dy + z * 0.5) / 0.866;
      final flatPos = Offset(tapPos.dx, flatY);

      if (HexMath.pointInHex(flatPos, center2D, radius)) {
        HapticFeedback.lightImpact();
        ref.read(gameProvider.notifier).tapTile(tile.row, tile.col);
        return;
      }
    }
  }
}
