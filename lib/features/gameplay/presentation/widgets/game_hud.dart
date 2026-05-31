import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../providers/game_provider.dart';

/// Heads-up display showing move count and undo/redo controls.
///
/// Features glassmorphism styling with smooth animated transitions.
class GameHud extends ConsumerWidget {
  const GameHud({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.glassFill,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.glassBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Undo button
          _HudIconButton(
            icon: Icons.undo_rounded,
            onPressed: gameState.canUndo
                ? () => ref.read(gameProvider.notifier).undo()
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
                ? () => ref.read(gameProvider.notifier).redo()
                : null,
            tooltip: 'Redo',
          ),
        ],
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
        opacity: isEnabled ? 1.0 : 0.3,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isEnabled
                    ? AppColors.glassFill
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? AppColors.glassBorder
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: isEnabled
                    ? AppColors.textPrimary
                    : AppColors.textMuted,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
