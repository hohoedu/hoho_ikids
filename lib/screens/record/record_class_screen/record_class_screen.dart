import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/record/booki_record_highfive_data.dart';
import 'package:hani_booki/_data/record/booki_record_home_data.dart';
import 'package:hani_booki/_data/record/booki_record_learning_data.dart';
import 'package:hani_booki/_data/record/booki_record_reading_data.dart';
import 'package:hani_booki/_data/record/hani_record_highfive_data.dart';
import 'package:hani_booki/_data/record/hani_record_home_data.dart';
import 'package:hani_booki/_data/record/hani_record_learning_data.dart';
import 'package:hani_booki/_data/record/hani_record_tenacity_data.dart';
import 'package:hani_booki/screens/record/record_class_screen/booki_record_class_widgets/booki_record_high_five.dart';
import 'package:hani_booki/screens/record/record_class_screen/booki_record_class_widgets/booki_record_learning.dart';
import 'package:hani_booki/screens/record/record_class_screen/booki_record_class_widgets/booki_record_reading.dart';
import 'package:hani_booki/screens/record/record_class_screen/booki_record_class_widgets/booki_record_speech.dart';
import 'package:hani_booki/screens/record/record_class_screen/hani_record_class_widgets/hani_record_high_five.dart';
import 'package:hani_booki/screens/record/record_class_screen/hani_record_class_widgets/hani_record_learning.dart';
import 'package:hani_booki/screens/record/record_class_screen/hani_record_class_widgets/hani_record_speech.dart';
import 'package:hani_booki/screens/record/record_class_screen/hani_record_class_widgets/hani_record_tenacity.dart';
import 'package:hani_booki/services/record/booki/booki_record_highfive_service.dart';
import 'package:hani_booki/services/record/booki/booki_record_learning_service.dart';
import 'package:hani_booki/services/record/booki/booki_record_reading_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_highfive_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_home_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_learning_service.dart';
import 'package:hani_booki/services/record/hani/hani_record_tenacity_service.dart';
import 'package:hani_booki/utils/text_format.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class RecordClassScreen extends StatefulWidget {
  final String type;
  final String classStatus;

  const RecordClassScreen({super.key, required this.type, required this.classStatus});

  @override
  State<RecordClassScreen> createState() => _RecordClassScreenState();
}

class _RecordClassScreenState extends State<RecordClassScreen> {
  final userData = Get.find<UserDataController>();
  HaniRecordHomeDataController haniReportData = HaniRecordHomeDataController();
  BookiRecordHomeDataController bookiReportData = BookiRecordHomeDataController();

  int selectedIndex = 0;
  bool isToggle = true;
  String hosu = '';

  @override
  void initState() {
    super.initState();
    reportInit();

    if (widget.classStatus == 'a') {
      isToggle = true;
      hosu = haniReportData.recordHomeData!.category;
    }
    if (widget.classStatus == 'b') {
      isToggle = false;
      hosu = bookiReportData.recordHomeData!.category;
    }
    if (widget.classStatus == 'c') {
      if (widget.type == 'hani') {
        isToggle = true;
        hosu = haniReportData.recordHomeData!.category;
      } else {
        isToggle = false;
        hosu = bookiReportData.recordHomeData!.category;
      }
    }

    Get.lazyPut<HaniRecordLearningDataController>(() => HaniRecordLearningDataController());
    Get.lazyPut<HaniRecordHighfiveDataController>(() => HaniRecordHighfiveDataController());
    Get.lazyPut<HaniRecordTenacityDataController>(() => HaniRecordTenacityDataController());
    Get.lazyPut<BookiRecordLearningDataController>(() => BookiRecordLearningDataController());
    Get.lazyPut<BookiRecordHighfiveDataController>(() => BookiRecordHighfiveDataController());
    Get.lazyPut<BookiRecordReadingDataController>(() => BookiRecordReadingDataController());
    fetchData();
  }

  void reportInit() {
    if (widget.classStatus == 'a') {
      haniReportData = Get.find<HaniRecordHomeDataController>();
      return;
    }
    if (widget.classStatus == 'b') {
      bookiReportData = Get.find<BookiRecordHomeDataController>();
      return;
    }
    if (widget.classStatus == 'c') {
      haniReportData = Get.find<HaniRecordHomeDataController>();
      bookiReportData = Get.find<BookiRecordHomeDataController>();
    }
  }

  final List<Widget> haniTabContents = [
    HaniRecordLearning(),
    HaniRecordHighFive(),
    HaniRecordSpeech(),
    HaniRecordTenacity(),
  ];
  final List<Widget> bookiTabContents = [
    BookiRecordLearning(),
    BookiRecordHighFive(),
    BookiRecordSpeech(),
    BookiRecordReading()
  ];

  Future<void> fetchData() async {
    var haniRecord;
    var bookiRecord;

    if (widget.classStatus == 'a' || widget.classStatus == 'c') {
      haniRecord = haniReportData.recordHomeData!;
    }
    if (widget.classStatus == 'b' || widget.classStatus == 'c') {
      bookiRecord = bookiReportData.recordHomeData!;
    }

    if (isToggle) {
      if (selectedIndex == 0) {
        await haniRecordLearningService(
          haniRecord.teacherId,
          haniRecord.keyCode,
          hosu,
          haniRecord.schoolId,
        );
      }
      if (selectedIndex == 1 || selectedIndex == 2) {
        await haniRecordHighFiveService(
          haniRecord.teacherId,
          haniRecord.keyCode,
          hosu,
          haniRecord.schoolId,
        );
      }
      if (selectedIndex == 3) {
        await haniRecordTenacityService(
          haniRecord.teacherId,
          haniRecord.keyCode,
          hosu,
          haniRecord.schoolId,
        );
      }
    } else {
      if (selectedIndex == 0) {
        await bookiRecordLearningService(
          bookiRecord.teacherId,
          bookiRecord.keyCode,
          hosu,
          bookiRecord.schoolId,
        );
      }
      if (selectedIndex == 1 || selectedIndex == 2) {
        await bookiRecordHighFiveService(
          bookiRecord.teacherId,
          bookiRecord.keyCode,
          hosu,
          bookiRecord.schoolId,
        );
      }
      if (selectedIndex == 3) {
        await bookiRecordReadingService(
          bookiRecord.teacherId,
          bookiRecord.keyCode,
          hosu,
          bookiRecord.schoolId,
        );
      }
    }
  }

  void toggleMode() async {
    setState(() {
      isToggle = !isToggle;
    });
    await fetchData();
  }

  void onTabClick(int index) async {
    setState(() {
      selectedIndex = index;
    });

    await fetchData();
  }

  void prevHosu() async {
    if (int.parse(hosu) <= 1) return;
    int currentHosu = int.parse(hosu);
    currentHosu--;
    setState(() {
      hosu = currentHosu.toString().padLeft(2, '0');
    });
    if (isToggle) {
      Get.reload<HaniRecordLearningDataController>();
      await haniRecordLearningService(
        haniReportData.recordHomeData!.teacherId,
        haniReportData.recordHomeData!.keyCode,
        hosu,
        haniReportData.recordHomeData!.schoolId,
      );
    } else {
      Get.reload<BookiRecordLearningDataController>();
      await bookiRecordLearningService(
        bookiReportData.recordHomeData!.teacherId,
        bookiReportData.recordHomeData!.keyCode,
        hosu,
        bookiReportData.recordHomeData!.schoolId,
      );
    }
  }

  void nextHosu() async {
    if (int.parse(hosu) >= 10) return;
    int currentHosu = int.parse(hosu);
    currentHosu++;
    setState(() {
      hosu = currentHosu.toString().padLeft(2, '0');
    });

    if (isToggle) {
      Get.reload<HaniRecordLearningDataController>();
      await haniRecordLearningService(
        haniReportData.recordHomeData!.teacherId,
        haniReportData.recordHomeData!.keyCode,
        hosu,
        haniReportData.recordHomeData!.schoolId,
      );
    } else {
      Get.reload<BookiRecordLearningDataController>();
      await bookiRecordLearningService(
        bookiReportData.recordHomeData!.teacherId,
        bookiReportData.recordHomeData!.keyCode,
        hosu,
        bookiReportData.recordHomeData!.schoolId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(title: ' ', isContent: false),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Column(
            children: [
              Expanded(child: Container()),
              Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Container(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 1,
                              child: GestureDetector(
                                onTap: toggleMode,
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Visibility(
                                    visible: widget.classStatus == 'c',
                                    child: Image.asset(
                                      isToggle
                                          ? 'assets/images/records/booki_report.png'
                                          : 'assets/images/records/hani_report.png',
                                      scale: 1,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 10),
                            Expanded(
                              flex: 3,
                              child: LeftArea(
                                userData: userData,
                                haniData: haniReportData,
                                bookiData: bookiReportData,
                                type: widget.type,
                                isToggle: isToggle,
                                hosu: hosu,
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = 0;
                                      });
                                      prevHosu();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(right: 16.0),
                                      child: Image.asset(
                                        'assets/images/icons/prev.png',
                                        scale: 2,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    isToggle ? '${removedZero(hosu)}호' : '${removedZero(hosu)}호',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFFC7A51F),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        selectedIndex = 0;
                                      });
                                      nextHosu();
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 16.0),
                                      child: Image.asset(
                                        'assets/images/icons/next.png',
                                        scale: 2,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 12,
                      child: Column(
                        children: [
                          Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Row(
                                  children: List.generate(4, (index) {
                                    bool isSelected = selectedIndex == index;
                                    return RecordClassTab(
                                      onTap: () => onTabClick(index),
                                      text: isToggle ? haniTitles[index] : bookiTitles[index],
                                      color: isSelected
                                          ? Color(0xFFFFD200)
                                          : isToggle
                                              ? Color(0xFFA37EF2)
                                              : Color(0xFF00BCA8),
                                      fontColor:
                                          isSelected ? (isToggle ? Color(0xFF3E2081) : Color(0xFF013D44)) : Colors.white,
                                      child: Container(),
                                    );
                                  }),
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            flex: 9,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
                              ),
                              child: Center(
                                child: IndexedStack(
                                  index: selectedIndex,
                                  children: isToggle ? haniTabContents : bookiTabContents,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LeftArea extends StatelessWidget {
  final UserDataController userData;
  final HaniRecordHomeDataController haniData;
  final BookiRecordHomeDataController bookiData;
  final String type;
  final bool isToggle;
  final String hosu;

  const LeftArea({
    super.key,
    required this.userData,
    required this.haniData,
    required this.bookiData,
    required this.type,
    required this.isToggle,
    required this.hosu,
  });

  String forceLineBreak(String text, int maxCharsPerLine) {
    final buffer = StringBuffer();
    for (int i = 0; i < text.length; i += maxCharsPerLine) {
      if (i + maxCharsPerLine < text.length) {
        buffer.writeln(text.substring(i, i + maxCharsPerLine));
      } else {
        buffer.write(text.substring(i));
      }
    }
    return buffer.toString();
  }

  @override
  Widget build(BuildContext context) {
    bool isManager = userData.userData!.userType == 'M';
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: 8.sp, color: Color(0xFF3E2081), letterSpacing: -0.5),
        children: [
          TextSpan(
            text: forceLineBreak('${userData.userData!.schoolName}\n', 8),
          ),
          isManager
              ? TextSpan(
                  text: isToggle
                      ? '${haniData.recordHomeData!.teacherName} 선생님 반\n'
                      : '${bookiData.recordHomeData!.teacherName} 선생님 반\n',
                  style: TextStyle(fontWeight: FontWeight.bold))
              : TextSpan(),
          TextSpan(
            text: isManager
                ? isToggle
                    ? '${haniData.recordHomeData!.studentName} 어린이'
                    : '${bookiData.recordHomeData!.studentName} 어린이'
                : '${userData.userData!.username} '
                    '어린이',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: '의\n'),
          TextSpan(
              text: isToggle ? '호호하니 ${removedZero(hosu)}호\n' : '호호부키 ${removedZero(hosu)}호\n',
              style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '언어활동 보고서', style: TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(text: '가\n'),
          TextSpan(text: '도착했어요!'),
        ],
      ),
    );
  }
}

class RecordClassTab extends StatelessWidget {
  final VoidCallback onTap;
  final String text;
  final Color fontColor;
  final Color color;
  final Widget child;

  const RecordClassTab({
    super.key,
    required this.onTap,
    required this.child,
    required this.color,
    required this.fontColor,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              color: color,
            ),
            child: Center(
              child: Text(
                text,
                style: TextStyle(color: fontColor, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
