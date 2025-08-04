import 'package:ags/Home_screen/BarChartAnimationIcon.dart';
import 'package:flutter/material.dart';

class HomeCard extends StatefulWidget {
  final String title;
  final IconData icon;
  final Widget route;
  final Color cardColor;
  final Color textColor;
  final Color iconColor;

  const HomeCard({
    super.key,
    required this.title,
    required this.icon,
    required this.route,
    this.cardColor = Colors.white,
    this.textColor = Colors.black,
    this.iconColor = Colors.black,
  });

  @override
  State<HomeCard> createState() => _HomeCardState();
}

class _HomeCardState extends State<HomeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get shouldScale {
    return widget.icon == Icons.add_shopping_cart ||
        widget.icon == Icons.payment ||
        widget.icon == Icons.receipt_long;
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double iconSize = screenWidth * 0.09; // Responsive icon
    double fontSize = screenWidth * 0.045;

    Widget animatedIcon;

    if (widget.icon == Icons.bar_chart) {
      animatedIcon = BarChartAnimationIcon(color: widget.iconColor);
    } else if (shouldScale) {
      animatedIcon = ScaleTransition(
        scale: _scaleAnimation,
        child: Icon(widget.icon, size: iconSize, color: widget.iconColor),
      );
    } else {
      animatedIcon = Icon(widget.icon, size: iconSize, color: widget.iconColor);
    }

    return GestureDetector(
      onTap:
          () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => widget.route),
          ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          vertical: screenWidth * 0.08,
          horizontal: screenWidth * 0.05,
        ),
        decoration: BoxDecoration(
          color: widget.cardColor,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            animatedIcon,
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                widget.title,
                style: TextStyle(
                  fontSize: fontSize,
                  color: widget.textColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
