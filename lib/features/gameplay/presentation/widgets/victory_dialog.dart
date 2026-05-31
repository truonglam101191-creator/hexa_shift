import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Victory celebration dialog shown when all tiles are cleared.
///
/// Features a scale-in animation with particle-like decorations
/// and action buttons to replay or return home.
class VictoryDialog extends StatefulWidget {
  const VictoryDialog({
    super.key,
    required this.moveCount,
    required this.onPlayAgain,
    required this.onGoHome,
  });

  /// Total number of moves taken to win.
  final int moveCount;

  /// Callback when "Play Again" is tapped.
  final VoidCallback onPlayAgain;

  /// Callback when "Home" is tapped.
  final VoidCallback onGoHome;

  @override
  State<VictoryDialog> createState() => _VictoryDialogState();
}

class _VictoryDialogState extends State<VictoryDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value.clamp(0.0, 1.0),
          child: Transform.scale(
            scale: _scaleAnimation.value.clamp(0.0, 1.2),
            child: child,
          ),
        );
      },
      child: Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.cardDark.withValues(alpha: 0.95),
                AppColors.surfaceDark.withValues(alpha: 0.95),
              ],
            ),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: AppColors.primaryGlow,
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Trophy icon with glow
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppColors.primary.withValues(alpha: 0.3),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.emoji_events_rounded,
                  color: AppColors.tileUpRight,
                  size: 64,
                ),
              ),

              const SizedBox(height: 16),

              // Victory text
              ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [AppColors.primary, AppColors.tileUp],
                ).createShader(bounds),
                child: const Text(
                  'PUZZLE SOLVED!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: 3,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Move count
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.glassFill,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.touch_app_rounded,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.moveCount} moves',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // Action buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Home button
                  _VictoryButton(
                    label: 'Home',
                    icon: Icons.home_rounded,
                    onPressed: widget.onGoHome,
                    isPrimary: false,
                  ),
                  const SizedBox(width: 16),
                  // Play Again button
                  _VictoryButton(
                    label: 'Play Again',
                    icon: Icons.refresh_rounded,
                    onPressed: widget.onPlayAgain,
                    isPrimary: true,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Styled button for the victory dialog.
class _VictoryButton extends StatelessWidget {
  const _VictoryButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.isPrimary = false,
  });

  final String label;
  final IconData icon;
  final VoidCallback onPressed;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryLight],
                  )
                : null,
            color: isPrimary ? null : AppColors.glassFill,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isPrimary ? AppColors.primary : AppColors.glassBorder,
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isPrimary ? Colors.white : AppColors.textSecondary,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: isPrimary ? Colors.white : AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
