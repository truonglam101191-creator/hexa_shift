import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A pressable 3D skeuomorphic button.
///
/// Features a top face that physically depresses downward into the base
/// when tapped, simulating a mechanical tactile switch.
class ThreeDButton extends StatefulWidget {
  const ThreeDButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.color = const Color(0xFF6C63FF),
    this.depthColor,
    this.borderRadius = 16,
    this.depth = 5,
    this.width,
    this.height,
    this.padding = const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
  });

  final VoidCallback onPressed;
  final Widget child;
  final Color color;
  final Color? depthColor;
  final double borderRadius;
  final double depth;
  final double? width;
  final double? height;
  final EdgeInsetsGeometry padding;

  @override
  State<ThreeDButton> createState() => _ThreeDButtonState();
}

class _ThreeDButtonState extends State<ThreeDButton> {
  bool _isPressed = false;

  Color get _depthColor {
    if (widget.depthColor != null) return widget.depthColor!;
    // Default: Blend with black to get a darker shade of the main color
    return Color.lerp(widget.color, Colors.black, 0.35)!;
  }

  @override
  Widget build(BuildContext context) {
    final double activeDepth = _isPressed ? 1.0 : widget.depth;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onPressed();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.width,
        height: widget.height != null ? widget.height! + widget.depth : null,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // ── 3D Thickness / Base Layer (Determines size of stack) ──
            Container(
              margin: EdgeInsets.only(top: widget.depth),
              decoration: BoxDecoration(
                color: _depthColor,
                borderRadius: BorderRadius.circular(widget.borderRadius),
                border: Border.all(
                  color: Colors.transparent,
                  width:
                      1.2, // Match the border width of the top face to align sizes
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Opacity(
                opacity: 0.0,
                child: Padding(padding: widget.padding, child: widget.child),
              ),
            ),

            // ── Top Face Layer ──────────────────────────────────────────
            Positioned(
              left: 0,
              right: 0,
              top: widget.depth - activeDepth,
              bottom: activeDepth,
              child: Container(
                padding: widget.padding,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(widget.borderRadius),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.15),
                    width: 1.2,
                  ),
                ),
                child: widget.child,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A non-pressable 3D block card.
///
/// Features a layered 3D depth base and a clean top face.
class ThreeDCard extends StatelessWidget {
  const ThreeDCard({
    super.key,
    required this.child,
    this.color = const Color(0xFF1A2235),
    this.depthColor,
    this.borderRadius = 24,
    this.depth = 6,
    this.padding = const EdgeInsets.all(24),
    this.borderColor,
    this.glowColor,
  });

  final Widget child;
  final Color color;
  final Color? depthColor;
  final double borderRadius;
  final double depth;
  final EdgeInsetsGeometry padding;
  final Color? borderColor;
  final Color? glowColor;

  Color get _depthColor {
    if (depthColor != null) return depthColor!;
    return Color.lerp(color, Colors.black, 0.45)!;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        // ── 3D Thickness / Base Layer ─────────────────────────────────
        Container(
          margin: EdgeInsets.only(top: depth),
          height: 100, // Placeholder height, will stretch in Stack
          decoration: BoxDecoration(
            color: _depthColor,
            borderRadius: BorderRadius.circular(borderRadius),
            boxShadow: [
              BoxShadow(
                color: (glowColor ?? Colors.black).withValues(
                  alpha: glowColor != null ? 0.15 : 0.4,
                ),
                blurRadius: glowColor != null ? 30 : 12,
                spreadRadius: glowColor != null ? 2 : 0,
                offset: Offset(0, depth * 0.8),
              ),
            ],
          ),
        ),

        // ── Top Face Layer ──────────────────────────────────────────
        Container(
          margin: EdgeInsets.only(bottom: depth),
          padding: padding,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: borderColor ?? Colors.white.withValues(alpha: 0.08),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ],
    );
  }
}

/// A small 3D button specifically designed for circular/rounded numbers (e.g. Level Select).
class ThreeDLevelButton extends StatefulWidget {
  const ThreeDLevelButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isCurrent = false,
    this.isCompleted = false,
    this.color,
    this.depthColor,
    this.size = 48,
    this.depth = 4,
  });

  final String label;
  final VoidCallback onTap;
  final bool isCurrent;
  final bool isCompleted;
  final Color? color;
  final Color? depthColor;
  final double size;
  final double depth;

  @override
  State<ThreeDLevelButton> createState() => _ThreeDLevelButtonState();
}

class _ThreeDLevelButtonState extends State<ThreeDLevelButton> {
  bool _isPressed = false;

  Color get _color {
    if (widget.color != null) return widget.color!;
    if (widget.isCurrent) return const Color(0xFF6C63FF);
    return const Color(0xFF1E293B); // Tailwind slate-800
  }

  Color get _depthColor {
    if (widget.depthColor != null) return widget.depthColor!;
    return Color.lerp(_color, Colors.black, 0.4)!;
  }

  Color get _textColor {
    if (widget.isCurrent) return Colors.white;
    if (widget.isCompleted) return const Color(0xFF00D4AA); // app green accent
    return const Color(0xFF94A3B8); // textSecondary
  }

  @override
  Widget build(BuildContext context) {
    final double activeDepth = _isPressed ? 1.0 : widget.depth;

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _isPressed = true);
      },
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: SizedBox(
        width: widget.size,
        height: widget.size + widget.depth,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            // Base/Depth Layer
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              top: widget.depth,
              child: Container(
                decoration: BoxDecoration(
                  color: _depthColor,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            // Top Face Layer
            Positioned(
              left: 0,
              right: 0,
              top: widget.depth - activeDepth,
              bottom: activeDepth,
              child: Container(
                decoration: BoxDecoration(
                  color: _color,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: widget.isCurrent
                        ? Colors.white.withValues(alpha: 0.3)
                        : widget.isCompleted
                        ? const Color(0xFF00D4AA).withValues(alpha: 0.5)
                        : Colors.white.withValues(alpha: 0.08),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    widget.label,
                    style: TextStyle(
                      color: _textColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
