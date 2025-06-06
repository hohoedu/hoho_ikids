import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/_data/auth/join_user_data.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_phone_screen.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class JoinUserInfoScreen extends StatelessWidget {
  final joinUserDataController = Get.find<JoinUserDataController>();
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController classNameController = TextEditingController();
  final FocusNode usernameFocusNode = FocusNode();
  final FocusNode classNameFocusNode = FocusNode();

  JoinUserInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    final userData = joinUserDataController.joinUserData;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: mBackAuth,
        extendBodyBehindAppBar: true,
        appBar: MainAppBar(
          title: '',
          isContent: false,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              physics: isKeyboardVisible
                  ? const AlwaysScrollableScrollPhysics()
                  : const NeverScrollableScrollPhysics(),
              child: Column(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '기관과 반 이름을 확인 후\n이름을 입력해 주세요',
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
                  UserInfoField(
                    text: userData != null ? userData.schoolName : '유치원 이름',
                  ),
                  UserInfoField(
                    text: userData != null ? userData.className : '반 이름',
                  ),
                  CustomTextField(
                    controller: usernameController,
                    focusNode: usernameFocusNode,
                    hintText: '학생 이름',
                    isObscure: false,
                    isKoreanOnly: true,
                  ),
                  AuthButton(
                    onTap: () {
                      if (usernameController.text.isEmpty) {
                        oneButtonDialog(
                          title: '회원가입',
                          content: '학생 이름을 입력해주세요.',
                          onTap: () => Get.back(),
                          buttonText: '확인',
                        );
                      } else {
                        JoinController joinController = Get.find();
                        joinController.updateUsernameAndClassName(
                          usernameController.text,
                          classNameController.text,
                        );
                        showNameCheckDialog(
                          isBarrier: false,
                          title: '회원가입',
                          content: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: '${usernameController.text}',
                                  style: const TextStyle(
                                      color: fontMain,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0),
                                ),
                                const TextSpan(
                                  text: ' 학생이 맞나요?\n',
                                  style: TextStyle(
                                    color: fontMain,
                                    fontSize: 16.0,
                                  ),
                                ),
                                TextSpan(
                                  text: '',
                                  style: TextStyle(fontSize: 2.0),
                                ),
                                TextSpan(
                                  text: '이름은 변경이 불가합니다',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmOnTap: () {
                            Get.back();
                            Get.to(() => const JoinPhoneScreen());
                          },
                          cancelOnTap: () {},
                          confirmButtonText: '맞아요',
                          cancelButtonText: '아니요',
                        );
                        //
                      }
                    },
                    text: '위의 정보가 맞아요',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class UserInfoField extends StatelessWidget {
  final String text;

  const UserInfoField({
    super.key,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width * 0.5,
        decoration: BoxDecoration(
            color: Colors.grey[300], borderRadius: BorderRadius.circular(30)),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 12.0,
            horizontal: 30,
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: fontMain,
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
