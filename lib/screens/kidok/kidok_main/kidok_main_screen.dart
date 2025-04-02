import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_book_list.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_graph.dart';
import 'package:hani_booki/screens/kidok/kidok_main/kidok_main_widgets/kidok_list_view.dart';
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
  final userData = Get.find<UserDataController>();

  @override
  void initState() {
    super.initState();
    isSelectedList = List.generate(items.length, (index) => index == 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      extendBodyBehindAppBar: true,
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
        keyCode: widget.keyCode,
        isSibling: widget.isSibling,
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
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
                          SizedBox(height: kToolbarHeight),
                          Expanded(
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              itemCount: kidokBookcaseController.kidokBookcaseDataList.length,
                              itemBuilder: (context, index) {
                                int reversedIndex = kidokBookcaseController.kidokBookcaseDataList.length - 1 - index;
                                final bookcase = kidokBookcaseController.kidokBookcaseDataList[reversedIndex];

                                return GestureDetector(
                                  onTap: () async {
                                    Get.delete<KidokChartDataController>();
                                    await kidokSublistService(
                                        kidokBookcaseController.kidokBookcaseDataList[reversedIndex].volume,
                                        widget.keyCode);
                                    await kidokChartService(
                                      kidokBookcaseController.kidokBookcaseDataList[reversedIndex].volume,
                                      widget.keyCode,
                                    );
                                    setState(() {
                                      isSelectedList = List.generate(items.length, (i) => i == index);
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
                    Image.asset(
                      'assets/images/icons/book.png',
                      fit: BoxFit.cover,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 16.0, right: 16.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
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
                          child: Row(
                            children: [
                              KidokBookList(),
                              KidokGraph(),
                            ],
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
      ),
    );
  }
}
