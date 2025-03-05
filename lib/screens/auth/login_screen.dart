import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/join_screen.dart';
import 'package:hani_booki/screens/auth/search/search_id_screen.dart';
import 'package:hani_booki/screens/auth/search/search_password_screen.dart';
import 'package:hani_booki/services/auth/login_service.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController pwdController = TextEditingController();
  final FocusNode idFocusNode = FocusNode();
  final FocusNode pwdFocusNode = FocusNode();
  bool isAutoLoginChecked = false;
  final storage = Get.find<FlutterSecureStorage>();

  @override
  void initState() {
    super.initState();
    _requestNotificationPermission();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      idFocusNode.unfocus();
      pwdFocusNode.unfocus();
    });
  }

  void _requestNotificationPermission() async {
    var requestStatus = await Permission.notification.request();
    var status = await Permission.notification.status;

    if (requestStatus.isGranted) {
      print("✅ 알림 권한 허용됨");
    } else if (requestStatus.isPermanentlyDenied || status.isPermanentlyDenied) {
      print("❌ 알림 권한이 영구적으로 거부됨, 설정에서 변경 필요");
      openAppSettings();
    } else if (status.isRestricted) {
      print("⚠️ iOS에서 알림 권한이 제한됨, 설정에서 변경 필요");
      openAppSettings();
    } else if (status.isDenied) {
      print("🚫 알림 권한 거부됨");
    }


    print("Request Status: ${requestStatus.name}");
    print("Current Status: ${status.name}");
  }

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: mBackAuth,
        body: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.5,
            child: SingleChildScrollView(
              physics: isKeyboardVisible
                  ? AlwaysScrollableScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.3,
                      height: MediaQuery.of(context).size.height * 0.12,
                      child: Image.asset(
                        'assets/images/hoho_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: idController,
                    focusNode: idFocusNode,
                    hintText: '아이디',
                    isObscure: false,
                  ),
                  CustomTextField(
                    controller: pwdController,
                    focusNode: pwdFocusNode,
                    hintText: '비밀번호',
                    isObscure: true,
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isAutoLoginChecked =
                            !isAutoLoginChecked; // true/false 토글
                      });
                    },
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16.0, vertical: 8.0),
                          child: Image.asset(
                            isAutoLoginChecked
                                ? 'assets/images/icons/checkbox.png' // 체크된 상태
                                : 'assets/images/icons/checkbox_blank.png',
                            // 체크 해제된 상태
                            fit: BoxFit.contain,
                            scale: 2,
                          ),
                        ),
                        const Text(
                          '자동로그인',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AuthButton(
                    onTap: () async {
                      FocusManager.instance.primaryFocus?.unfocus();
                      if (idController.text.isEmpty) {
                        oneButtonDialog(
                          title: '로그인',
                          content: '아이디를 입력해주세요',
                          onTap: () => Get.back(),
                          buttonText: '확인',
                        );
                      } else if (pwdController.text.isEmpty) {
                        oneButtonDialog(
                          title: '로그인',
                          content: '비밀번호를 입력해주세요',
                          onTap: () => Get.back(),
                          buttonText: '확인',
                        );
                      } else {
                        loginService(
                            idController.text,
                            md5_convertHash(pwdController.text),
                            isAutoLoginChecked);
                      }
                    },
                    text: '로그인',
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                            onTap: () {
                              Get.to(() => SearchIdScreen());
                            },
                            child: const Text('아이디 찾기')),
                        const SizedBox(
                          height: 16,
                          child: VerticalDivider(
                            color: fontMain,
                            thickness: 1,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const SearchPasswordScreen());
                          },
                          child: const Text('비밀번호 찾기'),
                        ),
                        const SizedBox(
                          height: 16,
                          child: VerticalDivider(
                            color: fontMain,
                            thickness: 1,
                            width: 50,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FocusManager.instance.primaryFocus?.unfocus();
                            Get.to(() => const JoinScreen());
                          },
                          child: const Text('회원가입'),
                        ),
                      ],
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
    idController.dispose();
    pwdController.dispose();
    idFocusNode.dispose();
    pwdFocusNode.dispose();
    super.dispose();
  }
}
