import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/star/star_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/record/record_home_school/record_home_school_screen.dart';
import 'package:hani_booki/screens/record/record_screen.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hani_booki/services/record/booki/booki_record_home_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_home_service.dart';
import 'package:hani_booki/services/record/report_star_service.dart';
import 'package:hani_booki/utils/get_record_list.dart';
import 'package:hani_booki/utils/text_format.dart';

class NewStarCount extends StatelessWidget {
  final String keyCode;
  final String type;
  final BoxConstraints constraints;

  const NewStarCount({super.key, required this.keyCode, required this.type, required this.constraints});

  @override
  Widget build(BuildContext context) {
    final starDataController = Get.find<StarDataController>();
    return GestureDetector(
      onTap: () async {
        await contentStarService(keyCode, type);
        await reportStarService(keyCode);
        await getRecordList(keyCode, type);
        Get.to(() => RecordHomeSchoolScreen(type: type, keyCode: keyCode));
      },
      child: Container(
        width: screenWidth >= 1000 ? constraints.maxWidth * 0.75 : constraints.maxWidth * 0.83,
        height: screenWidth >= 1000 ? constraints.maxHeight * 0.15 : constraints.maxHeight * 0.28,
        decoration: BoxDecoration(
          color: Color(0xFFFFDE00),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Color(0xFFFFF3A3)),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/star.png',
                    scale: 2,
                  ),
                ),
              ),
            ),
            Obx(
              () => Text(
                formatNumber(int.parse(starDataController.totalStar.value)),
                style: const TextStyle(
                    color: Color(0xFF4E3A16), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'BMJUA'),
                softWrap: false,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
