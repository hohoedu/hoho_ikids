import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/kidok/kidok_result_screen/kidok_result_bar.dart';
import 'package:hani_booki/screens/kidok/kidok_result_screen/kidok_result_button.dart';
import 'package:hani_booki/screens/kidok/kidok_result_screen/kidok_result_top.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/drawer/main_drawer.dart';
import 'package:logger/logger.dart';

class KidokResultScreen extends StatelessWidget {
  final List<bool> matchedAnswers;

  const KidokResultScreen({
    super.key,
    required this.matchedAnswers,
  });

  @override
  Widget build(BuildContext context) {
    int correctCount = matchedAnswers.where((e) => e).length;
    return Scaffold(
      backgroundColor: kidokColor,
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        isContent: false,
        title: ' ',
      ),
      body: Center(
        child: SizedBox(
          width: Platform.isIOS
              ? MediaQuery.of(context).size.width * 0.85
              : double.infinity,
          child: Column(
            children: [
              Expanded(flex: 1, child: Container()),
              Expanded(
                flex: 8,
                child: Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          KidokResultTop(
                            correctCount: correctCount,
                          ),
                          KidokResultBar(matchedAnswers: matchedAnswers),
                          Expanded(
                            flex: 3,
                            child: KidokResultButton(
                              text: '처음으로',
                              onPressed: () {
                                Get.back();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(),
              )
            ],
          ),
        ),
      ),
    );
  }
}
