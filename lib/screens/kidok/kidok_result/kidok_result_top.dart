import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/widgets/custom_text.dart';

class KidokResultTop extends StatelessWidget {
  final int correctCount;


  const KidokResultTop({super.key, required this.correctCount});

  @override
  Widget build(BuildContext context) {
    String resultImage = '';
    String resultText = '';
    if (correctCount <= 5) {
      resultImage = 'assets/images/kidok/kidok_result_image1.png';
      resultText = 'assets/images/kidok/kidok_result_text1.png';
    } else if (correctCount <= 9){
      resultImage = 'assets/images/kidok/kidok_result_image2.png';
      resultText = 'assets/images/kidok/kidok_result_text2.png';
    } else {
      resultImage = 'assets/images/kidok/kidok_result_image3.png';
      resultText = 'assets/images/kidok/kidok_result_text3.png';
    }
    return Expanded(
      flex: 9,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: Image.asset(resultImage),
          ),
          Expanded(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child:
                      Image.asset(resultText),
                ),
                Expanded(
                  flex: 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      OutlinedText(
                        text: '$correctCount',
                        fontSize: 10.sp,
                        outlineWidth: 2.sp,
                        fillColor: Colors.orange,
                      ),
                      OutlinedText(
                        text: ' / 10',
                        fontSize: 10.sp,
                        outlineWidth: 2.sp,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
