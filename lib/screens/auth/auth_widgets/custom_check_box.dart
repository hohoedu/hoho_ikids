import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class CustomCheckBox extends StatelessWidget {
  final String text;
  final double? fontSize;
  final bool isChecked;
  final Function(bool?) onChanged;
  final void Function(BuildContext)? onTap;
  final double? scale;

  const CustomCheckBox({
    super.key,
    required this.text,
    required this.isChecked,
    required this.onChanged,
    this.onTap,
    this.fontSize,
    this.scale = 1,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  onChanged(!isChecked);
                },
                child: Transform.scale(
                  scale: scale,
                  child: Checkbox(
                    value: isChecked,
                    onChanged: onChanged,
                    activeColor: flame,
                    checkColor: Colors.white,
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                    side: BorderSide(
                      color: isChecked ? flame : Colors.grey,
                      width: 2,
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (onTap != null) {
                    onTap!(context);
                  }
                },
                child: Text(
                  text,
                  style: TextStyle(
                    color: fontMain,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
