import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/check_box.dart';
import 'package:hani_booki/services/auth/join_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';

class JoinConsentScreen extends StatefulWidget {
  const JoinConsentScreen({super.key});

  @override
  State<JoinConsentScreen> createState() => _JoinConsentScreenState();
}

class _JoinConsentScreenState extends State<JoinConsentScreen> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: mBackAuth,
        appBar: const MainAppBar(
          title: ' ',
          isContent: false,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '약관 및 개인정보 활용 동의',
                        style: TextStyle(
                          color: fontMain,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const JoinCheckBox(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.5,
                      height: 50,
                      decoration: BoxDecoration(
                        color: flame,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: AuthButton(
                          onTap: () async {
                            JoinController joinController = Get.find();
                            if (joinController.joinDTO.value.check1 == 'N' ||
                                joinController.joinDTO.value.check2 == 'N') {
                              oneButtonDialog(
                                  title: '회원가입',
                                  content: '필수 항목을 동의해주세요',
                                  onTap: () {
                                    Get.back();
                                  },
                                  buttonText: '확인');
                            } else {
                              await joinService();
                            }
                          },
                          text: '회원가입 완료하기'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
