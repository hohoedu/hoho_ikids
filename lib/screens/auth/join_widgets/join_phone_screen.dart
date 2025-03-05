import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/check_box.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/services/auth/join_service.dart';
import 'package:hani_booki/services/auth/user_count_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class JoinPhoneScreen extends StatefulWidget {
  const JoinPhoneScreen({super.key});

  @override
  State<JoinPhoneScreen> createState() => _JoinPhoneScreenState();
}

class _JoinPhoneScreenState extends State<JoinPhoneScreen> {
  final userCountController = Get.put(UserCountController());
  final TextEditingController phoneController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();

  bool isChecked = false;

  @override
  void initState() {
    super.initState();
    phoneFocusNode.addListener(() {
      if (!phoneFocusNode.hasFocus) {
        userCountController.checkUserCount(phoneController.text);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus(); // 포커스 해제
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
                        '회원가입',
                        style: TextStyle(
                          color: fontMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Obx(
                    () => CustomTextField(
                      controller: phoneController,
                      focusNode: phoneFocusNode,
                      hintText: '학부모 휴대폰 번호',
                      isObscure: false,
                      isNumberField: true,
                      onFocusLost: (_) {
                        userCountController.resetValidationMessage();
                      },
                      completeText: userCountController.message.value,
                      messageColor: userCountController.messageColor.value,
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
                            if (phoneController.text.length <= 10) {
                              oneButtonDialog(
                                  title: '회원가입',
                                  content: '휴대폰 번호를 입력해주세요',
                                  onTap: () {
                                    Get.back();
                                  },
                                  buttonText: '확인');
                            } else if (joinController.joinDTO.value.check1 ==
                                    'N' ||
                                joinController.joinDTO.value.check2 == 'N') {
                              oneButtonDialog(
                                  title: '회원가입',
                                  content: '필수 항목을 동의해주세요',
                                  onTap: () {
                                    Get.back();
                                  },
                                  buttonText: '확인');
                            } else if (!userCountController.isComplete.value){
                              oneButtonDialog(
                                  title: '회원가입',
                                  content: '전화번호를 확인해주세요.',
                                  onTap: () {
                                    Get.back();
                                  },
                                  buttonText: '확인');
                            }
                            else {
                              joinController
                                  .updateParentTel(phoneController.text);
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
