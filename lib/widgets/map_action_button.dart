

import 'package:flutter/material.dart';

class MapActionButton extends StatelessWidget {
  const MapActionButton({
    super.key,
    required this.onTap,
    required this.icon,
  });

  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60.0,
        width: 60,
        margin:
        const EdgeInsets.only(bottom: 6.0), //Same as `blurRadius` i guess
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25.0),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.grey,
              offset: Offset(0.0, 2.0), //(x,y)
              blurRadius: 6.0,
            ),
          ],
        ),
        child: Icon(
          icon,
          color: Colors.black,
        ),
      ),
    );
  }
}