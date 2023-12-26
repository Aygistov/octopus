import 'dart:math';

import 'package:flutter/material.dart';

/// Shows a bubbles animation.
///
/// The widget fills the available space (like [SizedBox.expand] would).
///
/// When [isStopped] is `true`, the animation will not run. This is useful
/// when the widget is not visible yet, for example.
///
class Bubbles extends StatefulWidget {
  final bool isStopped;

  const Bubbles({
    this.isStopped = false,
    super.key,
  });

  @override
  State<Bubbles> createState() => _BubblesState();
}

class BubblesPainter extends CustomPainter {
  final defaultPaint = Paint();

  final int bubblesCount = 50;

  late final List<_BubbleLifling> _snippings;

  Size? _size;

  DateTime _lastTime = DateTime.now();

  BubblesPainter({
    required Listenable animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    if (_size == null) {
      // First time we have a size.
      _snippings = List.generate(
          bubblesCount,
          (i) => _BubbleLifling(
                bounds: size,
              ));
    }

    final didResize = _size != null && _size != size;
    final now = DateTime.now();
    final dt = now.difference(_lastTime);
    for (final snipping in _snippings) {
      if (didResize) {
        snipping.updateBounds(size);
      }
      snipping.update(dt.inMilliseconds / 1000);
      snipping.draw(canvas);
    }

    _size = size;
    _lastTime = now;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class _BubblesState extends State<Bubbles> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: BubblesPainter(
        animation: _controller,
      ),
      willChange: true,
      child: const SizedBox.expand(),
    );
  }

  @override
  void didUpdateWidget(covariant Bubbles oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isStopped && !widget.isStopped) {
      _controller.repeat();
    } else if (!oldWidget.isStopped && widget.isStopped) {
      _controller.stop(canceled: false);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      // We don't really care about the duration, since we're going to
      // use the controller on loop anyway.
      duration: const Duration(seconds: 1),
      vsync: this,
    );

    if (!widget.isStopped) {
      _controller.repeat();
    }
  }
}

class _BubbleLifling {
  static final Random _random = Random();

  static const degToRad = pi / 180;

  Size _bounds;

  late final _Vector position = _Vector(
    _random.nextDouble() * _bounds.width,
    _random.nextDouble() * _bounds.height,
  );

  final double rotationSpeed = 800 + _random.nextDouble() * 600;

  final double angle = _random.nextDouble() * 360 * degToRad;

  double rotation = _random.nextDouble() * 360 * degToRad;

  double cosA = 1.0;

  final double size = 10.0;

  final double oscillationSpeed = 0.5 + _random.nextDouble() * 1.5;

  final double xSpeed = 40;

  final double ySpeed = 50 + _random.nextDouble() * 60;

  double time = _random.nextDouble();

  final paint = Paint()..style = PaintingStyle.fill;

  _BubbleLifling({
    required Size bounds,
  }) : _bounds = bounds;

  void draw(Canvas canvas) {
    final Gradient gradient = RadialGradient(
      colors: [
        Colors.white,
        Colors.blue.withOpacity(0.7),
        Colors.blue.withOpacity(0.3),
      ],
      stops: const [0.0, 0.7, 1.0],
      center: Alignment(0.7, -0.7),
      radius: 0.8,
    );
    paint.shader = gradient.createShader(
        Rect.fromCircle(center: Offset(position.x, position.y), radius: size));
    canvas.drawCircle(
        Offset(position.x + size, position.y + size), size, paint);
  }

  void update(double dt) {
    time += dt;
    rotation += rotationSpeed * dt;
    cosA = cos(degToRad * rotation);
    position.x += cos(time * oscillationSpeed) * xSpeed * dt;
    position.y -= ySpeed * dt;
    if (position.y < 0) {
      position.x = _random.nextDouble() * _bounds.width;
      position.y = _bounds.height;
    }
  }

  void updateBounds(Size newBounds) {
    if (!newBounds.contains(Offset(position.x, position.y))) {
      position.x = _random.nextDouble() * newBounds.width;
      position.y = _random.nextDouble() * newBounds.height;
    }
    _bounds = newBounds;
  }
}

class _Vector {
  double x, y;
  _Vector(this.x, this.y);
}
