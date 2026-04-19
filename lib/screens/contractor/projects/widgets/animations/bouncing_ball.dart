import 'package:flutter/material.dart';

/// A bouncing basketball widget — red (#FF383C) with a basketball icon,
/// matching the web app's BasketballIcon with color='#FF383C' and animate-bounce.
class BouncingBall extends StatefulWidget {
  final double size;
  final Color color;

  const BouncingBall({
    super.key,
    this.size = 24,
    this.color = const Color(0xFFFF383C),
  });

  @override
  State<BouncingBall> createState() => _BouncingBallState();
}

class _BouncingBallState extends State<BouncingBall>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _squishAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    // Bounce upward
    _bounceAnimation = Tween<double>(begin: 0, end: -20).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.bounceIn,
      ),
    );

    // Subtle squish on landing
    _squishAnimation = Tween<double>(begin: 1.0, end: 0.88).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
      ),
    );
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
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.translate(
              offset: Offset(0, _bounceAnimation.value),
              child: Transform.scale(
                scaleX: 1.0 + (1.0 - _squishAnimation.value) * 0.15,
                scaleY: _squishAnimation.value,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 6),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      Icons.sports_basketball,
                      color: Colors.white,
                      size: widget.size * 0.6,
                    ),
                  ),
                ),
              ),
            ),
            // Shadow on ground that shrinks when ball is high
            AnimatedBuilder(
              animation: _bounceAnimation,
              builder: (context, _) {
                final progress = (_bounceAnimation.value.abs() / 20).clamp(0.0, 1.0);
                return Container(
                  margin: const EdgeInsets.only(top: 2),
                  width: widget.size * (1.0 - progress * 0.4),
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.08 * (1.0 - progress * 0.5)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ],
        );
      },
    );
  }
}
