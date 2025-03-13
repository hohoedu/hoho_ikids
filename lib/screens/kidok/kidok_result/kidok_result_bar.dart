import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';

class KidokResultBar extends StatelessWidget {
  final List<bool> matchedAnswers;

  const KidokResultBar({super.key, required this.matchedAnswers});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 3,
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.orange[300],
                borderRadius: BorderRadius.circular(50.r),
              ),
              padding: EdgeInsets.all(10.r),
              child: Row(
                children: List.generate(
                  matchedAnswers.length,
                  (index) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(2.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: matchedAnswers[index]
                              ? Colors.white
                              : Colors.deepOrange,
                          borderRadius: BorderRadius.horizontal(
                            left: index == 0
                                ? Radius.circular(50.r)
                                : Radius.circular(5.r),
                            right: index == matchedAnswers.length - 1
                                ? Radius.circular(50.r)
                                : Radius.circular(5.r),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                                color: matchedAnswers[index]
                                    ? fontMain
                                    : fontWhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 7.sp),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
