import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class VerifyButton extends StatefulWidget {
  final VoidCallback onTap;
  final String text;
  final Color? color;
  final TextEditingController controller;

  const VerifyButton({
    super.key,
    required this.onTap,
    required this.text,
    required this.controller,
    this.color,
  });

  @override
  State<VerifyButton> createState() => _VerifyButtonState();
}

class _VerifyButtonState extends State<VerifyButton> {

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: widget.controller.text.isNotEmpty ? flame : Colors.grey,
          borderRadius: BorderRadius.circular(50),
        ),
        child: Center(
          child: Text(
            widget.text,
            style: const TextStyle(
              color: fontWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }
}
