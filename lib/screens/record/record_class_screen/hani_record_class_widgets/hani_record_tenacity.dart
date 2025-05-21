import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/record/hani_record_tenacity_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/text_format.dart';

class HaniRecordTenacity extends StatelessWidget {
  final recordTenacityController = Get.put(HaniRecordTenacityDataController());

  HaniRecordTenacity({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final tenacityData = recordTenacityController.recordTenacityData;

      if (tenacityData == null) {
        return const Center(child: EmptyRecords());
      }

      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.circle,
                        size: 10,
                      ),
                    ),
                    SizedBox(
                      width: MediaQuery.of(context).size.width * 0.55,
                      child: Text(
                        tenacityData.note ?? '노트 정보가 없습니다.',
                        style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.bold),
                        softWrap: true,
                        textWidthBasis: TextWidthBasis.parent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: const Color(0xFFFFF4AE),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: tenacityData.imagePath != null
                                  ? Image.network(tenacityData.imagePath!)
                                  : const Text('이미지 없음'),
                            ),
                            Text(
                              tenacityData.title.replaceAll(' ', '  '),
                              style: TextStyle(fontSize: 7.sp, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        color: Colors.white,
                        child: Column(
                          children: List.generate(
                            4,
                            (index) {
                              List<String?> insungTitles = [
                                tenacityData.insungTitle1,
                                tenacityData.insungTitle2,
                                tenacityData.insungTitle3,
                                tenacityData.insungTitle4,
                              ];
                              List<bool> isInsungs = [
                                tenacityData.isInsung1 ?? true,
                                tenacityData.isInsung2 ?? true,
                                tenacityData.isInsung3 ?? true,
                                tenacityData.isInsung4 ?? true,
                              ];

                              return Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                    left: 8.0,
                                    right: 8.0,
                                    top: 8.0,
                                  ),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: isInsungs[index] ? const Color(0xFFFFED77) : const Color(0xFFC7C7C8),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                      child: Row(
                                        children: [
                                          Container(
                                            width: 10.w,
                                            height: 10.w,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(100),
                                              color: mBackWhite,
                                            ),
                                            child: Center(
                                              child: Text(
                                                '${index + 1}',
                                                style: TextStyle(
                                                  fontSize: 6.sp,
                                                  color: Color(0xFF757575),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Expanded(
                                            flex: 10,
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Text(
                                                insungTitles[index] ?? '데이터 없음',
                                                style: TextStyle(fontSize: 6.sp),
                                              ),
                                            ),
                                          ),
                                          Image.asset(
                                            isInsungs[index]
                                                ? 'assets/images/icons/checkbox.png'
                                                : 'assets/images/icons/checkbox_blank.png',
                                            scale: screenWidth >= 1000 ? 2 : 2.5,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }
}
