import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/star_data.dart';
import 'package:hani_booki/screens/record/record_home_shool/record_home_school_screen.dart';
import 'package:hani_booki/screens/record/record_screen.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hani_booki/utils/get_record_list.dart';
import 'package:hani_booki/utils/text_format.dart';

class StarCount extends StatelessWidget {
  final String keyCode;
  final String type;

  const StarCount({
    super.key,
    required this.keyCode,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final starDataController = Get.find<StarDataController>();
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: Center(
            child: GestureDetector(
              onTap: () async {
                await contentStarService(keyCode);
                await getRecordList(keyCode, type);
                // Get.to(() => RecordScreen(keyCode: keyCode, type: type));
                Get.to(() => RecordHomeSchoolScreen(type: type));
              },
              child: Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: BoxDecoration(
                  color: Colors.yellow,
                  borderRadius: BorderRadius.circular(100),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/images/star.png',
                        ),
                      ),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          Obx(() => Text(
                                formatNumber(int.parse(
                                    starDataController.totalStar.value)),
                                style: const TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                softWrap: false,
                              )),
                          Text(
                            '획득',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
