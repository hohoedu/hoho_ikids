import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_once_verification_screen.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_twice_verification_screen.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';

class JoinSelectVerificationScreen extends StatelessWidget {
  const JoinSelectVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: mBackAuth,
      extendBodyBehindAppBar: true,
      appBar: MainAppBar(
        title: '',
        isContent: false,
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            children: [
              Expanded(
                flex: 2,
                child: const Center(
                  child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      '기관에서 안내받으신\n 가입코드 개수를 선택해 주세요.',
                      style: TextStyle(
                        color: fontMain,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Get.to(() => JoinOnceVerificationScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                              color: mBackWhite,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                            child: Text(
                              '1개',
                              style: TextStyle(
                                color: fontMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 35,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Get.to(() => JoinTwiceVerificationScreen());
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          decoration: BoxDecoration(
                              color: mBackWhite,
                              borderRadius: BorderRadius.circular(25)),
                          child: Center(
                              child: Text(
                            '2개',
                            style: TextStyle(
                                color: fontMain,
                                fontWeight: FontWeight.bold,
                                fontSize: 35),
                          )),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Spacer(
                flex: 1,
              )
            ],
          ),
        ),
      ),
    );
  }
}
