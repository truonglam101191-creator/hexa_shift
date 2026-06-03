import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Interactive tutorial slides dialog explaining the game mechanics.
class GameHelpDialog extends StatefulWidget {
  const GameHelpDialog({super.key});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black87,
      builder: (_) => const GameHelpDialog(),
    );
  }

  @override
  State<GameHelpDialog> createState() => _GameHelpDialogState();
}

class _GameHelpDialogState extends State<GameHelpDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_HelpSlideData> _slides = [
    _HelpSlideData(
      title: 'OBJECTIVE',
      icon: Icons.hexagon_rounded,
      iconColor: AppColors.primary,
      description: 'Your goal is to clear the board by shifting all hexagonal tiles off the grid edges.',
    ),
    _HelpSlideData(
      title: 'SELECT & SHIFT',
      icon: Icons.touch_app_rounded,
      iconColor: AppColors.tileUp,
      description: 'Tap a tile once to select it (it will lift up in 3D). Tap it again to shift it in the direction of its arrow.\n\nThe tile will slide continuously until it hits another tile or the border.',
    ),
    _HelpSlideData(
      title: 'PUSH & ROTATE',
      icon: Icons.rotate_right_rounded,
      iconColor: AppColors.tileUpRight,
      description: 'When a shifting tile collides with another tile, the stationary tile is bumped and rotates 60° clockwise!\n\nUse push-rotations to reorient arrows and unlock new paths.',
    ),
    _HelpSlideData(
      title: 'CLEARING TILES',
      icon: Icons.outbox_rounded,
      iconColor: AppColors.tileDown,
      description: 'If a tile shifts and does not hit any obstacles, it slides off the edge of the board and is successfully cleared.\n\nUndo/redo steps anytime using the top HUD.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 360, maxHeight: 420),
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
            color: AppColors.glassBorder,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.4),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.only(top: 24, left: 24, right: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'HOW TO PLAY',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 2,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: AppColors.textMuted),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            // Page View
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (idx) => setState(() => _currentPage = idx),
                itemCount: _slides.length,
                itemBuilder: (context, index) {
                  final slide = _slides[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Slide Icon Container
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: slide.iconColor.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            slide.icon,
                            color: slide.iconColor,
                            size: 60,
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Slide Title
                        Text(
                          slide.title,
                          style: TextStyle(
                            color: slide.iconColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        // Slide Description
                        Text(
                          slide.description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Page Indicator & Action buttons
            Padding(
              padding: const EdgeInsets.only(bottom: 24, left: 24, right: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Indicators
                  Row(
                    children: List.generate(
                      _slides.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 6),
                        width: _currentPage == index ? 16 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: _currentPage == index
                              ? AppColors.primary
                              : AppColors.textMuted.withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),

                  // Action buttons
                  Row(
                    children: [
                      if (_currentPage > 0)
                        TextButton(
                          onPressed: () {
                            _pageController.previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          },
                          child: const Text(
                            'Back',
                            style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                          ),
                        ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onPressed: () {
                          if (_currentPage < _slides.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOut,
                            );
                          } else {
                            Navigator.of(context).pop();
                          }
                        },
                        child: Text(
                          _currentPage < _slides.length - 1 ? 'Next' : 'Got it',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HelpSlideData {
  _HelpSlideData({
    required this.title,
    required this.icon,
    required this.iconColor,
    required this.description,
  });

  final String title;
  final IconData icon;
  final Color iconColor;
  final String description;
}
