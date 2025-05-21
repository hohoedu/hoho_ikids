import 'package:flutter/material.dart';

class HaniContents extends StatelessWidget {
  final String path;
  final VoidCallback onTap;

  const HaniContents({
    super.key,
    required this.path,
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
            path,
            fit: BoxFit.fill,
          ),
        ),
      ),
    );
  }
}
