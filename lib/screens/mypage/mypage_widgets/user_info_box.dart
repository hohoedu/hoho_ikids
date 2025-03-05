import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';

class UserInfoBox extends StatefulWidget {
  final String text;
  final bool isIcon;
  final bool isSuffixIcon;
  final bool isPwd;
  final bool isBackground;

  const UserInfoBox({
    super.key,
    required this.text,
    this.isIcon = false,
    this.isSuffixIcon = false,
    this.isPwd = false,
    this.isBackground = false,
  });

  @override
  State<UserInfoBox> createState() => _UserInfoBoxState();
}

class _UserInfoBoxState extends State<UserInfoBox> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            height: 50,
            decoration: BoxDecoration(
              color: widget.isBackground ? Colors.transparent : mBackWhite,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: widget.isSuffixIcon
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.start,
                children: [
                  if (widget.isIcon)
                    Icon(
                      Icons.add_circle,
                      color: Colors.grey,
                      size: 30,
                    ),
                  Padding(
                    padding: EdgeInsets.only(left: widget.isIcon ? 8.0 : 24.0),
                    child: Text(
                      widget.isPwd ? '•' * widget.text.length : widget.text,
                    ),
                  ),
                  Visibility(
                    visible: widget.isSuffixIcon,
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: Icon(
                        CupertinoIcons.clear,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
