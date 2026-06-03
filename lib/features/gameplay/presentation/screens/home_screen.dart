import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/three_d_widgets.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Home screen with Campaign Mode and practice selection.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gameState = ref.watch(gameProvider);
    final currentLevel = gameState.unlockedCampaignLevel;

    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              children: [
                const SizedBox(height: 24),

                // ── Game Title ─────────────────────────────────────
                _buildTitle(),

                const SizedBox(height: 12),

                // ── Subtitle ───────────────────────────────────────
                Text(
                  'Clear all tiles by shifting them\nalong their arrows',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 36),

                // ── Campaign Mode Card ──────────────────────────────
                _buildCampaignCard(context, ref, currentLevel),

                const SizedBox(height: 36),

                // ── Practice Mode Title ─────────────────────────────
                Text(
                  'PRACTICE MODE',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 3,
                  ),
                ),

                const SizedBox(height: 16),

                ...Difficulty.values.map(
                  (d) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _DifficultyCard(
                      difficulty: d,
                      onTap: () => _startGame(context, ref, d),
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          AppColors.primary,
          AppColors.tileUp,
          AppColors.primaryLight,
        ],
      ).createShader(bounds),
      child: const Column(
        children: [
          Icon(
            Icons.hexagon_rounded,
            color: Colors.white,
            size: 56,
          ),
          SizedBox(height: 12),
          Text(
            'HEXA SHIFT',
            style: TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: 6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCampaignCard(BuildContext context, WidgetRef ref, int currentLevel) {
    return ThreeDCard(
      color: AppColors.cardDark,
      glowColor: AppColors.primary,
      borderRadius: 24,
      depth: 6,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Banner row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.emoji_events_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'CAMPAIGN MODE',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.tileUp.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Infinite levels',
                  style: TextStyle(
                    color: AppColors.tileUp,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // Level status
          Text(
            'Level $currentLevel',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 26,
              fontWeight: FontWeight.w900,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Challenge yourself with solvable, procedurally generated puzzles that scale in difficulty.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 20),

          Text(
            'SELECT LEVEL TO PLAY:',
            style: TextStyle(
              color: AppColors.textMuted,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.5,
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 52,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: currentLevel,
              itemBuilder: (context, index) {
                final lvl = index + 1;
                final isCurrent = lvl == currentLevel;
                final isCompleted = lvl < currentLevel;

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: ThreeDLevelButton(
                    label: '$lvl',
                    isCurrent: isCurrent,
                    isCompleted: isCompleted,
                    onTap: () => _startCampaign(context, ref, lvl),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          // Play button (3D pressable)
          ThreeDButton(
            onPressed: () => _startCampaign(context, ref, currentLevel),
            color: AppColors.primary,
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'PLAY NOW',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startCampaign(BuildContext context, WidgetRef ref, int levelIndex) {
    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).startInfiniteLevel(levelIndex);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _startGame(BuildContext context, WidgetRef ref, Difficulty difficulty) {
    HapticFeedback.mediumImpact();
    ref.read(gameProvider.notifier).startGame(difficulty);
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const GameScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.05),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
              )),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }
}

/// A glassmorphism card for selecting a difficulty level.
class _DifficultyCard extends StatefulWidget {
  const _DifficultyCard({
    required this.difficulty,
    required this.onTap,
  });

  final Difficulty difficulty;
  final VoidCallback onTap;

  @override
  State<_DifficultyCard> createState() => _DifficultyCardState();
}

class _DifficultyCardState extends State<_DifficultyCard> {
  bool _isPressed = false;

  Color get _accentColor {
    return switch (widget.difficulty) {
      Difficulty.easy => AppColors.tileUp,
      Difficulty.medium => AppColors.tileUpRight,
      Difficulty.hard => AppColors.tileDown,
    };
  }

  IconData get _icon {
    return switch (widget.difficulty) {
      Difficulty.easy => Icons.sentiment_satisfied_rounded,
      Difficulty.medium => Icons.psychology_rounded,
      Difficulty.hard => Icons.local_fire_department_rounded,
    };
  }

  @override
  Widget build(BuildContext context) {
    return ThreeDButton(
      color: AppColors.cardDark,
      depthColor: Color.lerp(_accentColor, Colors.black, 0.4),
      onPressed: widget.onTap,
      borderRadius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _icon,
              color: _accentColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Label & size
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.difficulty.label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.difficulty.sizeLabel,
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: AppColors.textMuted,
            size: 16,
          ),
        ],
      ),
    );
  }
}
