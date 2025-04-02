import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_select_verification_screen.dart';
import 'package:hani_booki/services/auth/dupe_check_service.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';

class JoinScreen extends StatefulWidget {
  const JoinScreen({super.key});

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  final JoinInputController joinInputController =
      Get.put(JoinInputController());
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final TextEditingController pwdCheckController = TextEditingController();
  final FocusNode idFocusNode = FocusNode();
  final FocusNode pwdFocusNode = FocusNode();
  final FocusNode pwdCheckFocusNode = FocusNode();

  final GlobalKey _pwdFieldKey = GlobalKey();

  String? pwdErrorMessage;
  bool isPwdError = true;

  @override
  void initState() {
    super.initState();

    idFocusNode.addListener(() {
      if (!idFocusNode.hasFocus) {
        joinInputController.checkDuplicateId(idController.text);
      }
    });
    pwdFocusNode.addListener(() {
      if (pwdFocusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 300), () {
          if (_pwdFieldKey.currentContext != null) {
            Scrollable.ensureVisible(
              _pwdFieldKey.currentContext!,
              alignment: 0.5,
              duration: const Duration(milliseconds: 300),
            );
          }
        });
      }
    });
  }

  void validatePassword() {
    if (pwdController.text != pwdCheckController.text) {
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
    final JoinController joinController = Get.put(JoinController());
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: mBackAuth,
        extendBodyBehindAppBar: true,
        appBar: const MainAppBar(
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
                    child: Text(
                      '회원가입',
                      style: TextStyle(
                          color: fontMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  Obx(
                    () => CustomTextField(
                      controller: idController,
                      focusNode: idFocusNode,
                      hintText: '아이디',
                      isObscure: false,
                      onFocusLost: (_) {
                        joinInputController.resetValidationMessage();
                      },
                      completeText: joinInputController.message.value,
                      messageColor: joinInputController.messageColor.value,
                      isUserId: true,
                    ),
                  ),
                  CustomTextField(
                    key: _pwdFieldKey,
                    controller: pwdController,
                    focusNode: pwdFocusNode,
                    hintText: '비밀번호',
                    isObscure: true,
                    onEditingComplete: () {
                      pwdCheckFocusNode.requestFocus();
                    },
                  ),
                  CustomTextField(
                      controller: pwdCheckController,
                      focusNode: pwdCheckFocusNode,
                      hintText: '비밀번호 확인',
                      isObscure: true,
                      onEditingComplete: () {
                        validatePassword();
                      }),
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
                  AuthButton(
                    onTap: () {
                      validatePassword();
                      if (isPwdError &&
                          idController.text.isNotEmpty &&
                          pwdController.text.isNotEmpty &&
                          pwdCheckController.text.isNotEmpty &&
                          joinInputController.isComplete.value) {
                        joinController.updateIdAndPassword(idController.text,
                            pwdController.text);

                        // showCodeQuantityDialog();
                        Get.to(() => const JoinSelectVerificationScreen
                          (loginCode: '0000',));
                      }
                    },
                    text: '다음',
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
