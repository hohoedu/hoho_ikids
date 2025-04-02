import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/record/hani_record_highfive_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/empty_records.dart';
import 'package:hani_booki/utils/text_format.dart';

class HaniRecordHighFive extends StatefulWidget {
  const HaniRecordHighFive({super.key});

  @override
  State<HaniRecordHighFive> createState() => _HaniRecordHighFiveState();
}

class _HaniRecordHighFiveState extends State<HaniRecordHighFive> {
  final ScrollController _scrollController = ScrollController();
  final recordHighfiveData = Get.find<HaniRecordHighfiveDataController>();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  double get progress {
    if (_scrollController.hasClients && _scrollController.position.maxScrollExtent > 0) {
      return _scrollController.offset / _scrollController.position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double leftPosition = progress * constraints.maxWidth * 0.5;

        return Obx(() {
          if (recordHighfiveData.recordHighfiveDataList.isEmpty) {
            return const Center(child: EmptyRecords());
          }

          return Padding(
            padding: const EdgeInsets.only(top: 24.0, left: 24.0),
            child: Column(
              children: [
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    itemCount: recordHighfiveData.recordHighfiveDataList.length,
                    itemBuilder: (context, index) {
                      final highfiveData = recordHighfiveData.recordHighfiveDataList[index];
                      return Padding(
                        padding: const EdgeInsets.only(right: 16.0),
                        child: Container(
                          color: Colors.transparent,
                          width: constraints.maxWidth * 0.4,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(vertical: 8.0),
                                child: Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(right: 8.0),
                                      child: Image.asset(
                                        pentagons[index],
                                        scale: 2,
                                      ),
                                    ),
                                    Text(
                                      highfiveData.subject,
                                      style: TextStyle(
                                        color: HighFiveTextColor[highfiveData.index],
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.start,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: HighFiveColor[highfiveData.index],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                height: constraints.maxHeight * 0.7,
                                width: double.infinity,
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        addLineBreaks(highfiveData.bestContentValue),
                                        style: TextStyle(fontSize: 6.5.sp, letterSpacing: -0.2),
                                        softWrap: false,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(bottom: 8.0),
                                        child: Wrap(
                                          alignment: WrapAlignment.start,
                                          spacing: 6.0,
                                          runSpacing: 6.0,
                                          children: [
                                            highfiveData.contentCard1,
                                            highfiveData.contentCard2,
                                            highfiveData.contentCard3,
                                            highfiveData.contentCard4,
                                          ].where((card) => card.isNotEmpty).map((content) {
                                            return Container(
                                              decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius: BorderRadius.circular(50),
                                              ),
                                              child: Padding(
                                                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
                                                child: Text(
                                                  content,
                                                  style: TextStyle(
                                                    color: fontMain,
                                                    fontSize: 6.sp,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: leftPosition,
                          child: Container(
                            width: constraints.maxWidth * 0.5,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.grey,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          );
        });
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
