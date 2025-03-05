import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_main_data.dart';
import 'package:hani_booki/screens/kidok/kidok_question/kidok_question_screen.dart';
import 'package:hani_booki/services/kidok/kidok_question_service.dart';

class KidokMainCard extends StatelessWidget {
  final int index;
  final String keycode;

  const KidokMainCard({super.key, required this.index, required this.keycode});

  @override
  Widget build(BuildContext context) {
    final kidokMainController = Get.find<KidokMainDataController>();
    return GestureDetector(
      onTap: () async {
        await kidokQuestionService(
          kidokMainController.kidokMainDataList[index].bookCode,
          1,
        );
        Get.to(() =>
            KidokQuestionScreen(
              bookCode:
              kidokMainController.kidokMainDataList[index].bookCode,
              keycode: keycode,));
      },
      child: Image.network(
        kidokMainController.kidokMainDataList[index].bookImage,
        fit: BoxFit.contain,
      ),
    );
  }
}
