import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/_data/auth/join_user_data.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/verify_button.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_user_info_screen.dart';
import 'package:hani_booki/services/auth/join_code_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class JoinTwiceVerificationScreen extends StatefulWidget {
  const JoinTwiceVerificationScreen({super.key});

  @override
  State<JoinTwiceVerificationScreen> createState() =>
      _JoinTwiceVerificationScreenState();
}

class _JoinTwiceVerificationScreenState
    extends State<JoinTwiceVerificationScreen> {
  final TextEditingController code1Controller = TextEditingController();
  final TextEditingController code2Controller = TextEditingController();
  final FocusNode code1FocusNode = FocusNode();
  final FocusNode code2FocusNode = FocusNode();

  final joinUserDataController = Get.put(JoinUserDataController());

  bool isCode1Verified = false;
  bool isCode2Verified = false;

  Future<void> _verifyCode(
      TextEditingController controller, bool isCode1) async {
    FocusScope.of(context).unfocus();
    if (controller.text.isNotEmpty) {
      bool isVerified = await joinCodeService(controller);

      if (isVerified) {
        setState(() {
          if (isCode1) {
            isCode1Verified = true;
          } else {
            isCode2Verified = true;
          }
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    code1Controller.addListener(_onText1Changed);
    code2Controller.addListener(_onText2Changed);
  }

  void _onText1Changed() {
    if (isCode1Verified && code1Controller.text.isNotEmpty) {
      setState(() {
        isCode1Verified = false;
      });
    }
  }

  void _onText2Changed() {
    if (isCode2Verified && code2Controller.text.isNotEmpty) {
      setState(() {
        isCode2Verified = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: mBackAuth,
        extendBodyBehindAppBar: true,
        appBar: MainAppBar(
          title: ' ',
          isContent: false,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.6,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '기관에서 안내받으신 코드를 입력해 주세요',
                        style: TextStyle(
                          color: fontMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        '* 안내받으신 코드가 2개일 경우 모두 입력해주세요.',
                        style: TextStyle(
                            color: fontSub,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            height: 1.2),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: ValueListenableBuilder(
                            valueListenable: code1Controller,
                            builder: (context, value, child) {
                              return CustomTextField(
                                controller: code1Controller,
                                focusNode: code1FocusNode,
                                hintText: '가입 코드',
                                isObscure: false,
                                suffix: isCode1Verified
                                    ? code1Controller.text.isNotEmpty
                                        ? ' '
                                        : null
                                    : null,
                              );
                            },
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 50,
                              child: VerifyButton(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (code2Controller.text.isNotEmpty &&
                                      code1Controller.text.substring(5, 6) ==
                                          code2Controller.text
                                              .substring(5, 6)) {
                                    oneButtonDialog(
                                      title: '회원가입',
                                      content: '수업 코드는 중복될 수 없습니다.',
                                      onTap: () => Get.back(),
                                      buttonText: '확인',
                                    );
                                    code1Controller.text = ''; // code1 초기화
                                  } else {
                                    // 그렇지 않으면 code1을 검증한다.
                                    await _verifyCode(code1Controller, true);
                                  }
                                },
                                text: '인증',
                                controller: code1Controller,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 8,
                          child: CustomTextField(
                            controller: code2Controller,
                            focusNode: code2FocusNode,
                            hintText: '가입 코드 (선택)',
                            isObscure: false,
                            suffix: isCode2Verified
                                ? code2Controller.text.isNotEmpty
                                    ? ' '
                                    : null
                                : null,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Center(
                            child: SizedBox(
                              width: MediaQuery.of(context).size.width * 0.5,
                              height: 50,
                              child: VerifyButton(
                                onTap: () async {
                                  FocusManager.instance.primaryFocus?.unfocus();
                                  if (code1Controller.text.isNotEmpty &&
                                      code2Controller.text.isNotEmpty) {
                                    if (code1Controller.text.substring(5, 6) ==
                                        code2Controller.text.substring(5, 6)) {
                                      oneButtonDialog(
                                        title: '회원가입',
                                        content: '수업 코드는 중복될 수 없습니다.',
                                        onTap: () => Get.back(),
                                        buttonText: '확인',
                                      );
                                      code2Controller.text = '';
                                    } else {
                                      await _verifyCode(code2Controller, false);
                                    }
                                  } else {
                                    await _verifyCode(code2Controller, false);
                                  }
                                },
                                text: '인증',
                                controller: code2Controller,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AuthButton(
                      onTap: () async {
                        if (!isCode1Verified) {
                          oneButtonDialog(
                            title: '회원가입',
                            content: '가입 코드를 입력하고 인증을 완료해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        } else if (code2Controller.text.isNotEmpty &&
                            !isCode2Verified) {
                          oneButtonDialog(
                            title: '회원가입',
                            content: '인증을 완료해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        } else {
                          JoinController joinController = Get.find();
                          joinController.updateClassCodes(
                            code1Controller.text,
                            code2Controller.text,
                          );
                          Get.to(() => JoinUserInfoScreen());
                        }
                      },
                      text: '다음',
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    code1Controller.dispose();
    code2Controller.dispose();
    code1FocusNode.dispose();
    code2FocusNode.dispose();
    super.dispose();
  }
}
