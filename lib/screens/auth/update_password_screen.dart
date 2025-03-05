import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/services/auth/search_password_service.dart';
import 'package:hani_booki/services/auth/update_password_service.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final String id;

  const UpdatePasswordScreen({super.key, required this.id});

  @override
  State<UpdatePasswordScreen> createState() => _SearchIdScreenState();
}

class _SearchIdScreenState extends State<UpdatePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pwdConfirmController = TextEditingController();
  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode pwdConfirmFocusNode = FocusNode();

  String? pwdErrorMessage;
  bool isPwdError = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      passwordFocusNode.unfocus();
      pwdConfirmFocusNode.unfocus();
    });
  }

  Future<void> validatePassword() async {
    if (passwordController.text != pwdConfirmController.text) {
      setState(() {
        isPwdError = false;
        pwdErrorMessage = "비밀번호가 일치하지 않습니다.";
      });
    } else {
      setState(() {
        isPwdError = true;
        pwdErrorMessage = null;
      });
    }
    FocusManager.instance.primaryFocus?.unfocus();
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
                      '비밀번호 변경',
                      style: TextStyle(
                          color: fontMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextField(
                    controller: passwordController,
                    focusNode: passwordFocusNode,
                    hintText: '새 비밀번호',
                    isObscure: true,
                  ),
                  CustomTextField(
                    controller: pwdConfirmController,
                    focusNode: pwdConfirmFocusNode,
                    hintText: '새 비밀번호 확인',
                    isObscure: true,
                  ),
                  if (pwdErrorMessage != null)
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Text(
                        '* $pwdErrorMessage',
                        style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AuthButton(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if (passwordController.text.isEmpty) {
                          oneButtonDialog(
                            title: '비밀번호 변경',
                            content: '새로운 비밀번호를 입력해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        } else if (pwdConfirmController.text.isEmpty) {
                          oneButtonDialog(
                            title: '비밀번호 변경',
                            content: '비밀번호를 확인해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        } else {
                          await validatePassword();
                          if (isPwdError) {
                            await updatePasswordService(
                              widget.id,
                              md5_convertHash(pwdConfirmController.text),
                            );
                          }
                        }
                      },
                      text: '비밀번호 변경',
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

  @override
  void dispose() {
    super.dispose();
  }
}
