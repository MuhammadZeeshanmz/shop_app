import 'package:flutter/material.dart';

class HomeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget route;

  const HomeCard({super.key, 
    required this.title,
    required this.icon,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:
          () =>
              Navigator.push(context, MaterialPageRoute(builder: (_) => route)),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),

        elevation: 5,

        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 40, color: Colors.indigo),
              SizedBox(height: 10),
              Text(
                title,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
