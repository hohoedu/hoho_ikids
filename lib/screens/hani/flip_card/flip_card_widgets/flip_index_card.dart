import 'package:flutter/material.dart';

class FlipIndexCard extends StatelessWidget {
  final String imageUrl;
  final int index;
  final Function(int, String) onTap;

  const FlipIndexCard({
    super.key,
    required this.imageUrl,
    required this.index,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(index, imageUrl);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Image.network(
            imageUrl,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
