import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:logger/logger.dart';

class InfoTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isObscure;
  final ValueChanged<String>? onFocusLost;
  final VoidCallback? onEditingComplete;
  final String? completeText;
  final Color? messageColor;
  final bool? isSuffix;

  const InfoTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isObscure,
    this.onFocusLost,
    this.onEditingComplete,
    this.completeText,
    this.messageColor,
    this.isSuffix = false,
  });

  @override
  State<InfoTextField> createState() => _InfoTextFieldState();
}

class _InfoTextFieldState extends State<InfoTextField> {
  @override
  void initState() {
    super.initState();
  }

  void showCodeDialog(isEditingCode) {
    Get.defaultDialog(
      title: "가입코드 변경",
      content: Text("가입코드를 변경하시겠습니까?"),
      textConfirm: "확인",
      textCancel: "취소",
      onConfirm: () {
        Get.back();
        setState(() {
          isEditingCode = true;
        });
      },
      onCancel: () {},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.5,
              height: 50,
              child: TextField(
                controller: widget.controller,
                focusNode: widget.focusNode,
                cursorColor: fontMain,
                maxLength: widget.hintText == '아이디' ? 10 : 20,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: widget.hintText,
                  hintStyle: const TextStyle(color: fontGrey),
                  enabledBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  focusedBorder: const OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.all(Radius.circular(50)),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12.0,
                    horizontal: 30,
                  ),
                  counterText: '',
                  fillColor: Colors.white,
                  filled: true,
                  suffixIcon: widget.isSuffix == true
                      ? Icon(
                        CupertinoIcons.clear,
                        color: Colors.red,
                      )
                      : SizedBox(),
                ),
                obscureText: widget.isObscure,
                onChanged: (text) {
                  if (text.isNotEmpty) {
                    widget.onFocusLost?.call('');
                  }
                },
                onEditingComplete: widget.onEditingComplete,
              ),
            ),
          ),
          if (widget.completeText != null && widget.completeText!.isNotEmpty)
            Align(
              alignment: Alignment.center,
              child: SizedBox(
                child: Text(
                  '* ${widget.completeText}',
                  style: TextStyle(
                      color: widget.messageColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
