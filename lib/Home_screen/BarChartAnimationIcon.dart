import 'package:flutter/material.dart';

class BarChartAnimationIcon extends StatefulWidget {
  final Color color;
  final double barWidth;

  const BarChartAnimationIcon({
    super.key,
    this.color = Colors.green,
    this.barWidth = 6.0,
  });

  @override
  State<BarChartAnimationIcon> createState() => _BarChartAnimationIconState();
}

class _BarChartAnimationIconState extends State<BarChartAnimationIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _barAnimations = List.generate(3, (i) {
      final begin = 10.0 + (i * 5);
      final end = 30.0 - (i * 5);
      return Tween<double>(begin: begin, end: end).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(i * 0.2, 1.0, curve: Curves.easeInOut),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.barWidth * 5,
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children:
            _barAnimations.map((animation) {
              return AnimatedBuilder(
                animation: _controller,
                builder:
                    (_, __) => Container(
                      width: widget.barWidth,
                      height: animation.value,
                      decoration: BoxDecoration(
                        color: widget.color,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
              );
            }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
