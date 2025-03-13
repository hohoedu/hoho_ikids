import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/verify_button.dart';
import 'package:hani_booki/services/auth/join_code_service.dart';
import 'package:hani_booki/services/auth/legacy_user_service.dart';
import 'package:hani_booki/services/auth/search_id_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class LegacyUserScreen extends StatefulWidget {
  final String id;
  final bool isAutoLoginChecked;

  const LegacyUserScreen({
    super.key,
    required this.id,
    required this.isAutoLoginChecked,
  });

  @override
  State<LegacyUserScreen> createState() => _LegacyUserScreenState();
}

class _LegacyUserScreenState extends State<LegacyUserScreen> {
  final TextEditingController code1Controller = TextEditingController();
  final TextEditingController code2Controller = TextEditingController();
  final FocusNode code1FocusNode = FocusNode();
  final FocusNode code2FocusNode = FocusNode();

  bool isCode1Verified = false;
  bool isCode2Verified = false;

  Future<void> _verifyCode(
      TextEditingController controller, bool isCode1) async {
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
    return SafeArea(
      top: false,
      bottom: false,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: mBackAuth,
        appBar: MainAppBar(
          title: ' ',
          isContent: false,
        ),
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              physics: NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Center(
                    child: Text(
                      '기관에서 안내받으신\n코드를 입력해주세요',
                      style: TextStyle(
                        color: fontMain,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: CustomTextField(
                          controller: code1Controller,
                          focusNode: code1FocusNode,
                          hintText: '수업코드',
                          isObscure: false,
                          suffix: isCode1Verified
                              ? code1Controller.text.isNotEmpty
                                  ? ' '
                                  : null
                              : null,
                        ),
                      ),
                      Expanded(
                        flex: 2,
                        child: Center(
                          child: SizedBox(
                            height: 50,
                            child: VerifyButton(
                              onTap: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                if (code2Controller.text.isNotEmpty &&
                                    code1Controller.text.substring(5, 6) ==
                                        code2Controller.text.substring(5, 6)) {
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
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Expanded(
                        flex: 8,
                        child: CustomTextField(
                          controller: code2Controller,
                          focusNode: code2FocusNode,
                          hintText: '수업코드 (선택)',
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
                      )
                    ],
                  ),
                  AuthButton(
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
                        await legacyUserService(
                          id: widget.id,
                          classCode1: code1Controller.text,
                          classCode2: code2Controller.text,
                          isAutoLoginChecked: widget.isAutoLoginChecked,
                        );
                      }
                    },
                    text: '코드 등록하기',
                  ),
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
    super.dispose();
  }
}
