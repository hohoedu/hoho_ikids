import 'dart:io';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/bubble_data.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_book_list.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_bubble.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_graph.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_list_view.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_tendency.dart';
import 'package:hani_booki/services/kidok/kidok_chart_service.dart';
import 'package:hani_booki/services/kidok/kidok_sublist_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:logger/logger.dart';

class KidokMainScreen extends StatefulWidget {
  final String type;
  final String keyCode;
  final bool isSibling;

  const KidokMainScreen({
    super.key,
    required this.keyCode,
    required this.type,
    required this.isSibling,
  });

  @override
  State<KidokMainScreen> createState() => _KidokMainScreenState();
}

class _KidokMainScreenState extends State<KidokMainScreen> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  List<bool> isSelectedList = [];
  final kidokBookcaseController = Get.find<KidokBookcaseDataController>();
  final kidokChartController = Get.find<KidokChartDataController>();
  final userData = Get.find<UserDataController>();
  String currentPage = '1';

  List<BubbleData> getDummyBubbleData() {
    return [
      BubbleData(
        label: '논리',
        value: kidokChartController.kidokChartDataList[0].knowledge,
        color: Color(0xFFFFDAD6),
        textColor: Color(0xFF8B3A3A),
      ),
      BubbleData(
        label: '어휘',
        value: kidokChartController.kidokChartDataList[0].vocabulary,
        color: Color(0xFFE0D4F5),
        textColor: Color(0xFF6A3FA0),
      ),
      BubbleData(
        label: '감정',
        value: kidokChartController.kidokChartDataList.first.emotion,
        color: Color(0xFFFFF5C2),
        textColor: Color(0xFF8B7320),
      ),
      BubbleData(
        label: '사고',
        value: kidokChartController.kidokChartDataList.first.thought,
        color: Color(0xFFBEEDD8),
        textColor: Color(0xFF2E7D5E),
      ),
      BubbleData(
        label: '이해',
        value: kidokChartController.kidokChartDataList.first.understanding,
        color: Color(0xFFD4F0C0),
        textColor: Color(0xFF3A7A2A),
      ),
      BubbleData(
        label: '표현',
        value: kidokChartController.kidokChartDataList.first.expression,
        color: Color(0xFFBFE9F5),
        textColor: Color(0xFF1A6E8A),
      ),
    ];
  }

  List<TopItem> getTendency() {
    return [
      kidokChartController.kidokChartDataList.first.top1,
      kidokChartController.kidokChartDataList.first.top2,
      kidokChartController.kidokChartDataList.first.top3,
    ];
  }

  List<FlSpot> getHosuSpots() {
    if (kidokChartController.kidokChartDataList.isEmpty) return [];
    final hosuBooks = kidokChartController.kidokChartDataList.first.hosuBooks;
    return hosuBooks.map((e) => FlSpot(double.parse(e.hosu), e.count.toDouble())).toList();
  }

  @override
  void initState() {
    super.initState();
    isSelectedList = List.generate(kidokBookcaseController.kidokBookcaseDataList.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 1000;
    return Scaffold(
      key: scaffoldKey,
      endDrawerEnableOpenDragGesture: false,
      backgroundColor: const Color(0xFFF7FFD9),
      appBar: MainAppBar(
        isContent: false,
        onTap: () {
          scaffoldKey.currentState?.openEndDrawer();
        },
      ),
      endDrawer: MainDrawer(
        isHome: false,
        type: widget.type,
        isSibling: widget.isSibling,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.85,
          child: Row(
            children: [
              Expanded(
                flex: 1,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Column(
                        children: [
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: kidokBookcaseController.kidokBookcaseDataList.length,
                              itemBuilder: (context, index) {
                                int reversedIndex = kidokBookcaseController.kidokBookcaseDataList.length - 1 - index;
                                final bookcase = kidokBookcaseController.kidokBookcaseDataList[reversedIndex];

                                return GestureDetector(
                                  onTap: () async {
                                    kidokChartController.isLoading.value = true;
                                    kidokChartController.kidokChartDataList.clear();
                                    await kidokSublistService(kidokBookcaseController.kidokBookcaseDataList[reversedIndex].volume, widget.keyCode);
                                    await kidokChartService(
                                      kidokBookcaseController.kidokBookcaseDataList[reversedIndex].volume,
                                      widget.keyCode,
                                    );
                                    setState(() {
                                      isSelectedList = List.generate(kidokBookcaseController.kidokBookcaseDataList.length, (i) => i == index);
                                    });
                                  },
                                  child: KidokListView(
                                    constraints: constraints,
                                    index: index,
                                    isSelectedList: isSelectedList,
                                    note: bookcase.note,
                                    subject: bookcase.subject,
                                    color: bookcase.boxColor,
                                    circleColor: bookcase.subjectColor,
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    isTablet
                        ? Image.asset('assets/images/icons/book.png', fit: BoxFit.cover)
                        : Row(
                            children: [
                              _tabButton('읽은 도서 목록', '1'),
                              _tabButton('영역별 이해 & 성향', '0'),
                            ],
                          ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(0xFFF7F4EA),
                            borderRadius: BorderRadius.circular(15),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                          child: isTablet
                              ? Column(
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          KidokBookList(),
                                          KidokGraph(spots: getHosuSpots()),
                                        ],
                                      ),
                                    ),
                                    Expanded(
                                      child: Obx(() {
                                        if (kidokChartController.isLoading.value) {
                                          return Center(child: CircularProgressIndicator());
                                        }
                                        if (kidokChartController.kidokChartDataList.isEmpty) {
                                          return Center(
                                            child: Text(
                                              '학습 데이터가 없습니다.',
                                              style: TextStyle(fontSize: 7.sp, fontFamily: 'BMJUA'),
                                            ),
                                          );
                                        }

                                        final bubbleData = getDummyBubbleData();
                                        final isPerfect = bubbleData.every((b) => b.value == 100);

                                        return Row(
                                          children: [
                                            KidokBubble(bubbleData: bubbleData),
                                            KidokTendency(tendency: getTendency(), isPerfect: isPerfect),
                                          ],
                                        );
                                      }),
                                    ),
                                  ],
                                )
                              : currentPage == '1'
                                  ? Row(
                                      children: [
                                        KidokBookList(),
                                        KidokGraph(spots: getHosuSpots()),
                                      ],
                                    )
                                  : Obx(() {
                                      if (kidokChartController.isLoading.value) {
                                        return const Center(child: CircularProgressIndicator());
                                      }
                                      if (kidokChartController.kidokChartDataList.isEmpty) {
                                        return Center(
                                          child: Text(
                                            '학습 데이터가 없습니다.',
                                            style: TextStyle(fontSize: 7.sp, fontFamily: 'BMJUA'),
                                          ),
                                        );
                                      }
                                      final bubbleData = getDummyBubbleData();
                                      final isPerfect = bubbleData.every((b) => b.value == 100);

                                      return Row(
                                        children: [
                                          KidokBubble(bubbleData: bubbleData),
                                          KidokTendency(tendency: getTendency(), isPerfect: isPerfect),
                                        ],
                                      );
                                    }),
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
    );
  }

  Widget _tabButton(String label, String page) {
    final isSelected = currentPage == page;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => currentPage = page),
        child: Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected ? Color(0xFF3F8F00) : Color(0xFFBAD942),
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 7.sp,
                fontFamily: 'BMJUA',
                color: isSelected ? Color(0xFFFBFF00) : Colors.white,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
