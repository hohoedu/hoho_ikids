import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hani_booki/_core/colors.dart';

class CustomTextField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String hintText;
  final bool isObscure;
  final ValueChanged<String>? onFocusLost;
  final VoidCallback? onEditingComplete;
  final String? completeText;
  final Color? messageColor;
  final String? suffix;
  final bool? isNumberField;
  final bool? isKoreanOnly;

  const CustomTextField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.hintText,
    required this.isObscure,
    this.onFocusLost,
    this.onEditingComplete,
    this.completeText,
    this.messageColor,
    this.suffix,
    this.isNumberField = false,
    this.isKoreanOnly = false,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  @override
  void initState() {
    super.initState();
    if (widget.isNumberField == true) {
      widget.controller.text = "010";
    }
  }

  String formatPhoneNumber(String input) {
    String numbers = input.replaceAll(RegExp(r'\D'), ''); // 숫자만 남기기

    if (numbers.length > 3) {
      numbers = numbers.replaceFirstMapped(RegExp(r'(\d{3})(\d+)'), (match) {
        return '${match[1]}-${match[2]}';
      });
    }
    if (numbers.length > 8) {
      numbers =
          numbers.replaceFirstMapped(RegExp(r'(\d{3})-(\d{4})(\d+)'), (match) {
        return '${match[1]}-${match[2]}-${match[3]}';
      });
    }
    return numbers;
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
                maxLength: widget.isNumberField == true
                    ? 11
                    : (widget.hintText == '아이디' ? 10 : 20),
                keyboardType: widget.isNumberField == true
                    ? TextInputType.number
                    : TextInputType.text,
                inputFormatters: widget.isNumberField == true
                    ? [FilteringTextInputFormatter.digitsOnly]
                    : widget.isKoreanOnly == true
                        ? [
                            FilteringTextInputFormatter.allow(
                                RegExp(r'[ㄱ-ㅎㅏ-ㅣ가-힣]'))
                          ]
                        : [],
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
                  suffixIcon: widget.suffix != null
                      ? Icon(
                          CupertinoIcons.checkmark_alt,
                          color: Colors.green,
                        )
                      : SizedBox(),
                ),
                obscureText: widget.isObscure,
                onChanged: (text) {
                  if (widget.isNumberField == true) {
                    String formattedText = formatPhoneNumber(text);
                    widget.controller.value = TextEditingValue(
                      text: formattedText,
                      selection:
                          TextSelection.collapsed(offset: formattedText.length),
                    );
                  }
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
              alignment: Alignment.bottomLeft,
              child: Text(
                '* ${widget.completeText}',
                style: TextStyle(
                    color: widget.messageColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
