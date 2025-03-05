import 'package:flutter/material.dart';

class BookiTopContents extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;

  const BookiTopContents({
    super.key,
    required this.imagePath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Image.network(
            imagePath,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
