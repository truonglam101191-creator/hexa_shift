import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/three_d_widgets.dart';
import '../../domain/models/game_state.dart';
import '../providers/game_provider.dart';
import '../widgets/confetti_particles_widget.dart';
import '../widgets/game_help_dialog.dart';
import '../widgets/game_hud.dart';
import '../widgets/hex_board_widget.dart';
import '../widgets/victory_dialog.dart';

/// Main gameplay screen.
///
/// Displays the interactive hex board, HUD with move counter and undo/redo,
/// and a reset button. Listens for win condition to show victory dialog.
class GameScreen extends ConsumerStatefulWidget {
  const GameScreen({super.key});

  @override
  ConsumerState<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends ConsumerState<GameScreen> {
  bool _victoryShown = false;
  bool _showConfetti = false;

  @override
  Widget build(BuildContext context) {
    // Listen for win condition
    ref.listen<GameState>(gameProvider, (prev, next) {
      if (next.status == GameStatus.won && !_victoryShown) {
        _victoryShown = true;
        setState(() {
          _showConfetti = true;
        });
        HapticFeedback.heavyImpact();
        _showVictoryDialog(next.moveCount, next.levelIndex);
      }
      if (next.status == GameStatus.playing) {
        setState(() {
          _victoryShown = false;
          _showConfetti = false;
        });
      }
    });

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // ── Top Bar ──────────────────────────────────────
                _buildTopBar(context),

                // ── HUD ──────────────────────────────────────────
                const GameHud(),

                // ── Board ────────────────────────────────────────
                const Expanded(child: HexBoardWidget()),

                // ── Bottom Controls ──────────────────────────────
                _buildBottomControls(context),

                const SizedBox(height: 16),
              ],
            ),
            if (_showConfetti)
              const Positioned.fill(
                child: IgnorePointer(
                  child: ConfettiParticlesWidget(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    final gameState = ref.watch(gameProvider);
    final titleText = gameState.levelIndex != null
        ? 'LEVEL ${gameState.levelIndex}'
        : 'HEXA SHIFT';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          // Back button
          _GlassButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onPressed: () => _confirmExit(context),
            size: 40,
          ),
          const Spacer(),
          // Title
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [AppColors.primary, AppColors.tileUp],
            ).createShader(bounds),
            child: Text(
              titleText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: 3,
              ),
            ),
          ),
          const Spacer(),
          // Interactive Help button
          _GlassButton(
            icon: Icons.help_outline_rounded,
            onPressed: () {
              HapticFeedback.lightImpact();
              GameHelpDialog.show(context);
            },
            size: 40,
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _GlassButton(
            icon: Icons.refresh_rounded,
            label: 'Reset',
            onPressed: () {
              HapticFeedback.mediumImpact();
              ref.read(gameProvider.notifier).resetLevel();
            },
          ),
        ],
      ),
    );
  }

  void _showVictoryDialog(int moveCount, int? levelIndex) {
    Future.delayed(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      showDialog(
        context: context,
        barrierDismissible: false,
        barrierColor: Colors.black54,
        builder: (_) => VictoryDialog(
          moveCount: moveCount,
          levelIndex: levelIndex,
          onPlayAgain: () {
            Navigator.of(context).pop();
            ref.read(gameProvider.notifier).resetLevel();
          },
          onNextLevel: levelIndex != null
              ? () {
                  Navigator.of(context).pop();
                  ref
                      .read(gameProvider.notifier)
                      .startInfiniteLevel(levelIndex + 1);
                }
              : null,
          onGoHome: () {
            Navigator.of(context).pop(); // Close dialog
            Navigator.of(context).pop(); // Go back to home
          },
        ),
      );
    });
  }

  void _confirmExit(BuildContext context) {
    final gameState = ref.read(gameProvider);
    if (gameState.moveCount == 0) {
      Navigator.of(context).pop();
      return;
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.cardDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: const BorderSide(color: AppColors.glassBorder),
        ),
        title: const Text(
          'Leave Game?',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Your progress will be lost.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text(
              'Stay',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              Navigator.of(context).pop();
            },
            child: const Text(
              'Leave',
              style: TextStyle(color: AppColors.tileDown),
            ),
          ),
        ],
      ),
    );
  }
}

/// A small glass-styled button used in the game screen.
class _GlassButton extends StatelessWidget {
  const _GlassButton({
    required this.icon,
    required this.onPressed,
    this.label,
    this.size,
  });

  final IconData icon;
  final VoidCallback onPressed;
  final String? label;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return ThreeDButton(
      onPressed: onPressed,
      color: AppColors.cardDark,
      borderRadius: 14,
      depth: 4,
      padding: EdgeInsets.symmetric(
        horizontal: label != null ? 16 : 10,
        vertical: 10,
      ),
      width: size,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 18),
          if (label != null) ...[
            const SizedBox(width: 8),
            Text(
              label!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
