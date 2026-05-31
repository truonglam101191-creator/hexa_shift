import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/game_provider.dart';
import 'game_screen.dart';

/// Home screen with difficulty selection and premium dark UI.
///
/// Features gradient title, glassmorphism difficulty cards,
/// and smooth page transitions.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldDark,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const Spacer(flex: 2),

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

              const Spacer(flex: 2),

              // ── Difficulty Cards ───────────────────────────────
              Text(
                'SELECT DIFFICULTY',
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

              const Spacer(flex: 3),
            ],
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
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.97 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          decoration: BoxDecoration(
            color: AppColors.glassFill,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: _isPressed
                  ? _accentColor.withValues(alpha: 0.5)
                  : AppColors.glassBorder,
              width: 1,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: _accentColor.withValues(alpha: 0.15),
                      blurRadius: 20,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
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
        ),
      ),
    );
  }
}
