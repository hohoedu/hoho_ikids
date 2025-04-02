import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/kidok/kidok_sublist_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/utils/dashed_divider.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:logger/logger.dart';

class KidokBookList extends StatefulWidget {
  const KidokBookList({
    super.key,
  });

  @override
  State<KidokBookList> createState() => _KidokBookListState();
}

class _KidokBookListState extends State<KidokBookList> {
  final kidokSublistController = Get.find<KidokSublistDataController>();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: Text(
              '나의 도서 목록',
              style: TextStyle(fontSize: 20, fontFamily: 'BMJUA'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: Color(0xFFF7F5EA), borderRadius: BorderRadius.circular(15)),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Column(
                      children: List.generate(
                        kidokSublistController.kidokSublistDataList.length,
                        (index) {
                          return Column(
                            children: [
                              SizedBox(
                                height: constraints.maxHeight / kidokSublistController.kidokSublistDataList.length - 1,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Row(
                                          children: [
                                            kidokSublistController.kidokSublistDataList[index].isCompleted
                                                ? Image.asset(
                                                    'assets/images/icons/checkbox.png',
                                                    scale: 2.5,
                                                  )
                                                : Image.asset(
                                                    'assets/images/icons/checkbox_blank.png',
                                                    scale: 2.5,
                                                    color: Color(0xFFDED6A9),
                                                  ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                              child: Text(
                                                autoWrapText(
                                                    kidokSublistController.kidokSublistDataList[index].bookName, 10),
                                                style: TextStyle(
                                                    fontSize: 7.sp,
                                                    color:
                                                        kidokSublistController.kidokSublistDataList[index].isCompleted
                                                            ? fontMain
                                                            : Colors.redAccent,
                                                    fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: constraints.maxWidth * 0.2,
                                        child: Center(
                                            child: kidokSublistController.kidokSublistDataList[index].isCompleted
                                                ? Container(
                                                    width: double.infinity,
                                                    height: 25.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(20),
                                                      color: Color(0xFFC1B67B),
                                                    ),
                                                    child: Padding(
                                                      padding: const EdgeInsets.symmetric(horizontal: 6.0),
                                                      child: Align(
                                                        alignment: Alignment.center,
                                                        child: Text(
                                                          '${kidokSublistController.kidokSublistDataList[index].correctCount}'
                                                          '/${kidokSublistController.kidokSublistDataList[index].questionCount}',
                                                          style: TextStyle(
                                                              fontSize: 5.sp,
                                                              fontWeight: FontWeight.bold,
                                                              color: fontWhite),
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : Image.asset('assets/images/icons/incomplete.png')),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              if (index < kidokSublistController.kidokSublistDataList.length - 1) dashedDivider(),
                            ],
                          );
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
