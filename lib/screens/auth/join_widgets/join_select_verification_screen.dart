import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_once_verification_screen.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_twice_verification_screen.dart';
import 'package:hani_booki/screens/auth/legacy/legacy_once_user_screen.dart';
import 'package:hani_booki/screens/auth/legacy/legacy_twice_user_screen.dart';
import 'package:hani_booki/screens/auth/referral/referral_once_code_screen.dart';
import 'package:hani_booki/screens/auth/referral/referral_twice_code_screen.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:logger/logger.dart';

class JoinSelectVerificationScreen extends StatelessWidget {
  final String loginCode;
  final String? id;
  final String? password;
  final bool? isAutoLoginChecked;

  const JoinSelectVerificationScreen({
    super.key,
    required this.loginCode,
    this.id,
    this.password,
    this.isAutoLoginChecked,
  });

  @override
  Widget build(BuildContext context) {
    Logger().d('loginCode = $loginCode');
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
                        if (loginCode == '0000') {
                          Get.to(() => JoinOnceVerificationScreen());
                        } else if (loginCode == '6666') {
                          Get.to(
                            () => ReferralOnceCodeScreen(
                                id: id!,
                                password: password!,
                                isAutoLoginChecked: isAutoLoginChecked!),
                          );
                        } else if (loginCode == '7777') {
                          Get.to(
                            () => LegacyOnceUserScreen(
                                id: id!,
                                isAutoLoginChecked: isAutoLoginChecked!),
                          );
                        }
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
                        if (loginCode == '0000') {
                          Get.to(() => JoinTwiceVerificationScreen());
                        } else if (loginCode == '6666') {
                          Get.to(
                            () => ReferralTwiceCodeScreen(
                                id: id!,
                                password: password!,
                                isAutoLoginChecked: isAutoLoginChecked!),
                          );
                        } else if (loginCode == '7777') {
                          Get.to(
                            () => LegacyTwiceUserScreen(
                                id: id!,
                                isAutoLoginChecked: isAutoLoginChecked!),
                          );
                        }
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
                            ),
                          ),
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
