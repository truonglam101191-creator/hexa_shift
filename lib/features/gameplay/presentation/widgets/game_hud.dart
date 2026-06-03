import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/three_d_widgets.dart';
import '../providers/game_provider.dart';

/// Heads-up display showing move count and undo/redo controls.
///
/// Features glassmorphism styling with smooth animated transitions.
class GameHud extends ConsumerWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ThreeDCard(
        color: AppColors.cardDark,
        borderRadius: 20,
        depth: 5,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Undo button
          _HudIconButton(
            icon: Icons.undo_rounded,
            onPressed: gameState.canUndo
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(gameProvider.notifier).undo();
                  }
                : null,
            tooltip: 'Undo',
          ),

          // Move counter
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'MOVES',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '${gameState.moveCount}',
                  key: ValueKey(gameState.moveCount),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Tiles remaining indicator
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TILES',
                style: TextStyle(
                  color: AppColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                transitionBuilder: (child, animation) {
                  return ScaleTransition(scale: animation, child: child);
                },
                child: Text(
                  '${gameState.board.activeTileCount}',
                  key: ValueKey(gameState.board.activeTileCount),
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          // Redo button
          _HudIconButton(
            icon: Icons.redo_rounded,
            onPressed: gameState.canRedo
                ? () {
                    HapticFeedback.lightImpact();
                    ref.read(gameProvider.notifier).redo();
                  }
                : null,
            tooltip: 'Redo',
          ),
        ],
      ),
    ),
  );
}
}

/// A glassmorphism-styled icon button for the HUD.
class _HudIconButton extends StatelessWidget {
  const _HudIconButton({
    required this.icon,
    required this.onPressed,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return Tooltip(
      message: tooltip,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: isEnabled ? 1.0 : 0.35,
        child: isEnabled
            ? ThreeDButton(
                onPressed: onPressed!,
                color: AppColors.cardDark,
                borderRadius: 12,
                depth: 3,
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: AppColors.textPrimary,
                  size: 22,
                ),
              )
            : Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon,
                  color: AppColors.textMuted,
                  size: 22,
                ),
              ),
      ),
    );
  }
}
