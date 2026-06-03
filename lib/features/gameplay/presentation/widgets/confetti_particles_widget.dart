import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import '../../../../core/constants/app_colors.dart';

/// Types of confetti shapes.
enum ConfettiShape { rectangle, circle, hexagon }

/// Data model representing a single confetti particle.
class ConfettiParticle {
  ConfettiParticle({
    required this.x,
    required this.y,
    required this.vx,
    required this.vy,
    required this.color,
    required this.shape,
    required this.size,
    required this.rotationSpeed,
    required this.rotation,
  });

  double x;
  double y;
  double vx;
  double vy;
  final Color color;
  final ConfettiShape shape;
  final double size;
  final double rotationSpeed;
  double rotation;
}

/// A custom full-screen confetti animation widget.
///
/// Spawns particles that drift down, oscillate horizontally, and rotate.
class ConfettiParticlesWidget extends StatefulWidget {
  const ConfettiParticlesWidget({super.key});

  @override
  State<ConfettiParticlesWidget> createState() => _ConfettiParticlesWidgetState();
}

class _ConfettiParticlesWidgetState extends State<ConfettiParticlesWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  final List<ConfettiParticle> _particles = [];
  final Random _random = Random();
  Size _screenSize = Size.zero;

  @override
  void initState() {
    super.initState();
    // Start updating particle positions on every frame
    _ticker = createTicker(_onTick);
    _ticker.start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  void _initializeParticles(Size size) {
    _particles.clear();
    final List<Color> colors = [
      AppColors.primary,
      AppColors.primaryLight,
      AppColors.tileUp,
      AppColors.tileUpRight,
      AppColors.tileDown,
      AppColors.tileSelected,
      Colors.yellowAccent,
      Colors.cyanAccent,
    ];

    // Spawn 100 particles at various points near the top of the screen
    for (var i = 0; i < 110; i++) {
      final shape = ConfettiShape.values[_random.nextInt(ConfettiShape.values.length)];
      _particles.add(
        ConfettiParticle(
          x: _random.nextDouble() * size.width,
          y: -_random.nextDouble() * size.height * 0.8 - 20,
          // Upward burst initially, then falling down
          vx: _random.nextDouble() * 4 - 2,
          vy: _random.nextDouble() * 5 + 3,
          color: colors[_random.nextInt(colors.length)],
          shape: shape,
          size: _random.nextDouble() * 6 + 6,
          rotation: _random.nextDouble() * 2 * pi,
          rotationSpeed: _random.nextDouble() * 0.15 - 0.075,
        ),
      );
    }
  }

  void _onTick(Duration elapsed) {
    if (_screenSize == Size.zero) return;

    setState(() {
      for (final p in _particles) {
        // Apply gravity and slight horizontal sway (wind)
        p.vy += 0.04; // Gravity
        p.vy = p.vy.clamp(2.0, 9.0); // Limit terminal velocity
        
        p.x += p.vx + sin(elapsed.inMilliseconds / 250 + p.size) * 0.6;
        p.y += p.vy;
        p.rotation += p.rotationSpeed;

        // Reset particle to top if it falls off bottom
        if (p.y > _screenSize.height + 20) {
          p.y = -20;
          p.x = _random.nextDouble() * _screenSize.width;
          p.vy = _random.nextDouble() * 4 + 2;
          p.vx = _random.nextDouble() * 4 - 2;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final currentSize = Size(constraints.maxWidth, constraints.maxHeight);
        if (_screenSize != currentSize) {
          _screenSize = currentSize;
          _initializeParticles(_screenSize);
        }

        return CustomPaint(
          size: _screenSize,
          painter: _ConfettiPainter(particles: _particles),
        );
      },
    );
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter({required this.particles});

  final List<ConfettiParticle> particles;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (final p in particles) {
      paint.color = p.color;
      canvas.save();
      canvas.translate(p.x, p.y);
      canvas.rotate(p.rotation);

      switch (p.shape) {
        case ConfettiShape.rectangle:
          canvas.drawRect(
            Rect.fromCenter(
              center: Offset.zero,
              width: p.size * 1.5,
              height: p.size * 0.8,
            ),
            paint,
          );
          break;
        case ConfettiShape.circle:
          canvas.drawCircle(Offset.zero, p.size * 0.6, paint);
          break;
        case ConfettiShape.hexagon:
          final path = Path();
          final r = p.size * 0.7;
          path.moveTo(r, 0);
          for (var i = 1; i < 6; i++) {
            final angle = i * pi / 3;
            path.lineTo(r * cos(angle), r * sin(angle));
          }
          path.close();
          canvas.drawPath(path, paint);
          break;
      }
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}
