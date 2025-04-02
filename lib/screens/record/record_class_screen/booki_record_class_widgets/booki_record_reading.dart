import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/record/booki_record_reading_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/text_format.dart';

class BookiRecordReading extends StatelessWidget {
  final readingData = Get.put(BookiRecordReadingDataController());

  BookiRecordReading({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (readingData.recordReadingDataList.isEmpty) {
        return const Center(child: EmptyRecords());
      }

      return Padding(
        padding: EdgeInsets.all(8.0),
        child: Column(
          children: [
            if (readingData.recordReadingDataList.length < 4)
              Expanded(
                flex: (readingData.recordReadingDataList.length == 1)
                    ? 1
                    : (4 - readingData.recordReadingDataList.length) ~/ 2,
                child: const SizedBox.shrink(),
              ),
            Expanded(
              flex: 1,
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 32.0, right: 8.0),
                    child: Image.asset('assets/images/icons/parent.png'),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: fontMain, fontSize: 7.5.sp),
                      children: [
                        TextSpan(
                          text: '부모님과 함께하는  ',
                          style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: '[${readingData.recordReadingDataList[0].title ?? "제목 없음"}]',
                        ),
                        const TextSpan(text: ' 지식확장 독서활동'),
                      ],
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Column(
                  children: [
                    ...List.generate(
                      readingData.recordReadingDataList.length,
                      (index) {
                        final bool isHomeSchool = readingData.recordReadingDataList[index].check == '가정연계';

                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(
                              left: 8.0,
                              right: 8.0,
                              bottom: 8.0,
                            ),
                            child: Container(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 4,
                                    child: Row(
                                      children: [
                                        Expanded(
                                          flex: 2,
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Color(isHomeSchool ? 0xFFF0F0F0 : 0xFFFFF3A0),
                                              borderRadius: const BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(8.0),
                                              child: Container(
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(5),
                                                  color: mBackWhite,
                                                ),
                                                child: Center(
                                                  child: Text(
                                                    readingData.recordReadingDataList[index].note ?? '노트 정보 없음',
                                                    style: TextStyle(
                                                      color: Color(isHomeSchool ? 0xFF757575 : 0xFFFFBA00),
                                                      fontSize: 6.5.sp,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          flex: 3,
                                          child: Container(
                                            height: double.infinity,
                                            color: Color(isHomeSchool ? 0xFFF0F0F0 : 0xFFFFF3A0),
                                            child: Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                              child: Align(
                                                alignment: Alignment.center,
                                                child: Text(
                                                  autoWrapText(
                                                    readingData.recordReadingDataList[index].subject ?? '제목 없음',
                                                    4,
                                                  ),
                                                  style: TextStyle(fontSize: 7.sp),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    flex: 4,
                                    child: Container(
                                      height: double.infinity,
                                      color: Color(isHomeSchool ? 0xFFDADADA : 0xFFFFED77),
                                      child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: Padding(
                                          padding: const EdgeInsets.only(left: 24.0),
                                          child: RichText(
                                            text: TextSpan(
                                              text: readingData.recordReadingDataList[index].bookName ?? '책 이름 없음',
                                              style: TextStyle(
                                                color: fontMain,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 8.sp,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Container(
                                      height: double.infinity,
                                      decoration: BoxDecoration(
                                        color: Color(isHomeSchool ? 0xFFBDBDBD : 0xFFFFBA00),
                                        borderRadius: const BorderRadius.only(
                                          topRight: Radius.circular(10),
                                          bottomRight: Radius.circular(10),
                                        ),
                                      ),
                                      child: isHomeSchool
                                          ? Center(
                                              child: Text(
                                                '가정\n연계',
                                                style: TextStyle(
                                                  height: 1.2,
                                                  fontSize: 6.sp,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            )
                                          : Icon(
                                              Icons.circle_outlined,
                                              size: 15.w,
                                              color: Colors.white,
                                            ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    if (readingData.recordReadingDataList.length < 4)
                      Expanded(
                        flex: (readingData.recordReadingDataList.length == 1)
                            ? 1
                            : (4 - readingData.recordReadingDataList.length + 1) ~/ 2,
                        child: const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }
}
