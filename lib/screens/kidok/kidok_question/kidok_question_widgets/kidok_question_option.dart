import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/utils/text_format.dart';

class KidokQuestionOption extends StatelessWidget {
  final BoxConstraints constraints;
  final String text;
  final String number;

  const KidokQuestionOption({
    super.key,
    required this.constraints,
    required this.text,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Container(
          height: constraints.maxWidth / 4.25,
          width: constraints.maxWidth / 4.25,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/icons/bubble$number.png'),
            ),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  autoWrapText(text, 9),
                  style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  softWrap: true,
                  overflow: TextOverflow.visible,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
