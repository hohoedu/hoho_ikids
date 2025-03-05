import 'package:flutter/material.dart';

class BookiBottomContents extends StatelessWidget {
  final String imagePath;
  final Color color;
  final VoidCallback onTap;

  const BookiBottomContents({
    super.key,
    required this.imagePath,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: GestureDetector(
          onTap: onTap,
          child: Align(
            alignment: FractionalOffset(0.5, 2 / 3),
            child: Image.network(
              imagePath,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}
