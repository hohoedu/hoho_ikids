import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/kidok/kidok_main_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/kidok/kidok_question/kidok_question_screen.dart';
import 'package:hani_booki/services/kidok/kidok_question_service.dart';
import 'package:hani_booki/utils/dashed_line.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class KidokMainCard extends StatelessWidget {
  final int index;
  final String keycode;
  final Color boxColor;
  final bool isLast;

  const KidokMainCard({
    super.key,
    required this.index,
    required this.keycode,
    required this.boxColor,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final kidokMainController = Get.find<KidokMainDataController>();
    return Column(
      children: [
        isLast
            ? Align(
                alignment: AlignmentDirectional.topEnd,
                child: GestureDetector(
                  onTap: () {
                    showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (context) {
                        return Dialog(
                          insetPadding: EdgeInsets.symmetric(
                            horizontal: MediaQuery.of(context).size.width * 0.1,
                          ),
                          backgroundColor: Colors.transparent,
                          child: Stack(
                            children: [
                              Image.asset(
                                'assets/images/kidok/kidok_desc_radius.png',
                                fit: BoxFit.contain,
                              ),
                              Positioned(
                                top: 20.h,
                                right: 10.w,
                                child: GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Image.asset(
                                    'assets/images/rank/rank_cancel.png',
                                    scale: 6,
                                  ),
                                ),
                              )
                            ],
                          ),
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                      height: MediaQuery.of(context).size.height * 0.05,
                      width: MediaQuery.of(context).size.height * 0.05,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: boxColor),
                      child: Center(
                          child: Text(
                        '?',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 6.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      )),
                    ),
                  ),
                ),
              )
            : Padding(
                padding: const EdgeInsets.all(4.0),
                child: SizedBox(
                  height: MediaQuery.of(context).size.height * 0.05,
                  width: MediaQuery.of(context).size.height * 0.05,
                ),
              ),
        GestureDetector(
          onTap: () async {
            await kidokQuestionService(
              kidokMainController.kidokMainDataList[index].bookCode,
              1,
            );
            Get.to(() => KidokQuestionScreen(
                  bookCode: kidokMainController.kidokMainDataList[index].bookCode,
                  keycode: keycode,
                ));
          },
          child: Image.network(
            kidokMainController.kidokMainDataList[index].bookImage,
            fit: BoxFit.contain,
          ),
        ),
      ],
    );
  }
}
