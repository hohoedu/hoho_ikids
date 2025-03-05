import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class AuthButton extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color? color;
  final bool? isPwdError;

  const AuthButton({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.isPwdError,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          width: MediaQuery.of(context).size.width * 0.5,
          height: 50,
          decoration: BoxDecoration(
            color: color != null ? color : flame,
            borderRadius: BorderRadius.circular(50),
          ),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: fontWhite,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
