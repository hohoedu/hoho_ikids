import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_code_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/auth/login_screen.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/screens/mypage/mypage_widgets/user_info_box.dart';
import 'package:hani_booki/services/auth/join_code_service.dart';
import 'package:hani_booki/services/auth/keycode_service.dart';
import 'package:hani_booki/services/auth/update_password_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/del_user_code.dart';
import 'package:hani_booki/utils/encryption.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/info_text_field.dart';
import 'package:logger/logger.dart';

class MypageScreen extends StatefulWidget {
  const MypageScreen({super.key});

  @override
  State<MypageScreen> createState() => _MypageScreenState();
}

class _MypageScreenState extends State<MypageScreen> {
  final codeVerifyController = Get.put(CodeVerifyController());
  final userData = Get.find<UserDataController>();
  final userCodeData = Get.find<UserCodeDataController>();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController pwdConfirmController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController code1Controller = TextEditingController();
  final TextEditingController code2Controller = TextEditingController();

  final FocusNode passwordFocusNode = FocusNode();
  final FocusNode pwdConfirmFocusNode = FocusNode();
  final FocusNode nameFocusNode = FocusNode();
  final FocusNode code1FocusNode = FocusNode();
  final FocusNode code2FocusNode = FocusNode();

  bool isCode2 = false;

  bool isEditingPassword = false;
  bool isEditingName = false;
  bool isEditingCode1 = false;
  bool isEditingCode2 = false;
  bool isPwdChanged = false;

  bool isValid = false;

  @override
  void initState() {
    super.initState();
    Get.find<BgmController>().pauseBgm();
    code1FocusNode.addListener(() {
      if (!code1FocusNode.hasFocus) {
        codeVerifyController.checkClassCode(code: code1Controller.text, codeIndex: 1);
      }
    });
    code2FocusNode.addListener(() {
      if (!code2FocusNode.hasFocus) {
        codeVerifyController.checkClassCode(code: code2Controller.text, codeIndex: 2);
      }
    });
  }

  void passwordField() {
    setState(() {
      isEditingPassword = true;
    });
  }

  Future<bool> codeValidation() async {
    String code1 = code1Controller.text;
    String code2 = code2Controller.text;
    String pin1 = '';
    String pin2 = '';

    if (userCodeData.userCodeDataList[0].pin.isNotEmpty) {
      pin1 = userCodeData.userCodeDataList[0].pin;
    }
    if (userCodeData.userCodeDataList.length == 2) {
      if (userCodeData.userCodeDataList[1].pin.isNotEmpty) {
        pin2 = userCodeData.userCodeDataList[1].pin;
      }
    }

    // 아무것도 변경 없음
    if (code1.isEmpty && code2.isEmpty) {
      return true;
    }

    // code1 변경, code2 없음
    if (code1.isNotEmpty && (code2.isEmpty && pin2.isEmpty)) {
      return true;
    }

    // code1 변경, code2 추가
    else if (code1.isNotEmpty && code2.isNotEmpty) {
      if (code1.substring(5, 6) == code2.substring(5, 6)) {
        return false;
      } else {
        return true;
      }
    }
    // pin1 픽스, code2 추가
    else if (code2.isNotEmpty && (code1.isEmpty || pin1.isNotEmpty)) {
      if (pin1.substring(5, 6) == code2.substring(5, 6)) {
        return false;
      } else {
        return true;
      }
    }
    // code1 변경, pin2 픽스
    else if (code1.isNotEmpty && (code2.isEmpty || pin2.isNotEmpty)) {
      if (pin2.substring(5, 6) == code1.substring(5, 6)) {
        return false;
      } else {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    bool isCode2 = userCodeData.userCodeDataList.length > 1 && userCodeData.userCodeDataList[1].className.isNotEmpty;
    bool isManager = userData.userData!.userType == 'M';
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFAE6),
      appBar: MainAppBar(
        title: ' ',
        isContent: false,
        isInfo: true,
        onTapBackIcon: () {
          if ((isEditingCode1 && code1Controller.text.isEmpty) && (isEditingCode2 && code2Controller.text.isEmpty)) {
            oneButtonDialog(
                isBarrier: false,
                title: '안내',
                content: '가입 코드는 반드시 1개 이상 입력해야 합니다.',
                onTap: () {
                  Get.back();
                },
                buttonText: '확인');
          } else {
            Get.back();
          }
        },
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Center(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Image.asset(
                        'assets/images/icons/my_info.png',
                        scale: 2,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        '내 정보',
                        style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 8,
              child: SizedBox(
                width: double.infinity,
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      'ID',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                  flex: 8,
                                  child: UserInfoBox(text: userData.userData!.id),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    '비밀번호',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                Expanded(
                                  flex: 8,
                                  child: GestureDetector(
                                    onTap: !isManager ? passwordField : null,
                                    child: isEditingPassword
                                        ? InfoTextField(
                                            controller: passwordController,
                                            focusNode: passwordFocusNode,
                                            hintText: '비밀번호',
                                            isObscure: true)
                                        : UserInfoBox(text: '00000000', isPwd: true),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      '비밀번호 확인',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                  flex: 8,
                                  child: GestureDetector(
                                    onTap: !isManager ? passwordField : null,
                                    child: isEditingPassword
                                        ? InfoTextField(
                                            controller: pwdConfirmController,
                                            focusNode: pwdConfirmFocusNode,
                                            hintText: '비밀번호 확인',
                                            isObscure: true)
                                        : UserInfoBox(text: '00000000', isPwd: true),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      '학생 이름',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                  flex: 8,
                                  child: isEditingName
                                      ? InfoTextField(
                                          controller: nameController,
                                          focusNode: nameFocusNode,
                                          hintText: '학생 이름',
                                          isObscure: false,
                                        )
                                      : UserInfoBox(
                                          text: userData.userData!.username,
                                        ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: Text(
                                      '가입코드',
                                      style: TextStyle(fontWeight: FontWeight.bold),
                                    )),
                                Expanded(
                                  flex: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      !isManager
                                          ? showCodeDeleteDialog(
                                              onDeleteConfirmed: () async {
                                                await delUserCode(userCodeData.userCodeDataList[0].pin);
                                                setState(() {
                                                  isEditingCode1 = true;
                                                });
                                              },
                                            )
                                          : null;
                                    },
                                    child: isEditingCode1
                                        ? Obx(
                                            () => InfoTextField(
                                              controller: code1Controller,
                                              focusNode: code1FocusNode,
                                              hintText: '가입 코드',
                                              isObscure: false,
                                              onFocusLost: (_) {
                                                codeVerifyController.resetValidationMessage(codeIndex: 1);
                                                codeVerifyController.checkClassCode(
                                                    code: code1Controller.text, codeIndex: 1);
                                              },
                                              completeText: codeVerifyController.code1Message.value,
                                              messageColor: codeVerifyController.messageColor1.value,
                                            ),
                                          )
                                        : UserInfoBox(
                                            text: userCodeData.userCodeDataList[0].pin,
                                            isSuffixIcon: !isManager ? true : false),
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Expanded(
                                    flex: 2,
                                    child: isEditingCode2 || isCode2
                                        ? Text(
                                            '가입 코드 2',
                                            style: TextStyle(fontWeight: FontWeight.bold),
                                          )
                                        : SizedBox()),
                                Expanded(
                                  flex: 8,
                                  child: GestureDetector(
                                    onTap: () {
                                      if (!isManager) {
                                        if (!isCode2) {
                                          setState(() {
                                            isEditingCode2 = true;
                                          });
                                        } else {
                                          showCodeDeleteDialog(
                                            onDeleteConfirmed: () async {
                                              await delUserCode(userCodeData.userCodeDataList[1].pin);
                                              setState(() {
                                                isEditingCode2 = true;
                                              });
                                            },
                                          );
                                        }
                                      }
                                    },
                                    child: isEditingCode2
                                        ? Obx(
                                            () => InfoTextField(
                                              controller: code2Controller,
                                              focusNode: code2FocusNode,
                                              hintText: '가입 코드 2',
                                              isObscure: false,
                                              onFocusLost: (_) {
                                                codeVerifyController.resetValidationMessage(codeIndex: 2);
                                                codeVerifyController.checkClassCode(
                                                    code: code2Controller.text, codeIndex: 2);
                                              },
                                              completeText: codeVerifyController.code2Message.value,
                                              messageColor: codeVerifyController.messageColor2.value,
                                            ),
                                          )
                                        : !isManager
                                            ? UserInfoBox(
                                                text: isCode2 ? userCodeData.userCodeDataList[1].pin : '가입 코드 추가하기',
                                                isIcon: isCode2 ? false : true,
                                                isSuffixIcon: isCode2 ? true : false,
                                                isBackground: isCode2 ? false : true,
                                              )
                                            : SizedBox.shrink(),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () async {
                                if (isManager) {
                                  Get.back();
                                  return;
                                }


                                bool isCodeChanged = false;

                                // 비밀번호 변경 처리
                                if (passwordController.text.isNotEmpty) {
                                  await updatePasswordService(
                                      userData.userData!.id, md5_convertHash(passwordController.text));
                                  setState(() {
                                    isPwdChanged = true;
                                  });
                                }

                                if ((isEditingCode1 && code1Controller.text.isEmpty) &&
                                    (isEditingCode2 && code2Controller.text.isEmpty)) {
                                  oneButtonDialog(
                                    title: '안내',
                                    content: '가입 코드를 입력해 주세요.',
                                    onTap: () => Get.back(),
                                    buttonText: '확인',
                                  );
                                  return;
                                }
                                // 가입 코드 검증
                                isValid = await codeValidation();
                                if (isValid == false) {
                                  oneButtonDialog(
                                    title: '회원가입',
                                    content: '가입 코드는 중복될 수 없습니다.',
                                    onTap: () => Get.back(),
                                    buttonText: '확인',
                                  );
                                  return; // 검증 실패 시 종료
                                }

                                // 가입 코드 입력 확인
                                if (!isPwdChanged &&
                                    isEditingCode1 &&
                                    code1Controller.text.isEmpty &&
                                    (isEditingCode2 && code2Controller.text.isEmpty || !isEditingCode2 && !isCode2)) {
                                  isValid = false;
                                  oneButtonDialog(
                                      isBarrier: false,
                                      title: '안내',
                                      content: '가입 코드는 반드시 1개 이상 입력해야 합니다.',
                                      onTap: () {
                                        Get.back();
                                      },
                                      buttonText: '확인');
                                  return;
                                }

                                // 가입 코드 변경 처리
                                if (isEditingCode1 &&
                                    isValid &&
                                    codeVerifyController.isComplete1.value == true &&
                                    !isEditingCode2) {
                                  await keyCodeService(
                                    userData.userData!.id,
                                    code1Controller.text,
                                    userData.userData!.year,
                                  );
                                  isCodeChanged = true;
                                } else if (!isEditingCode1 &&
                                    isValid &&
                                    codeVerifyController.isComplete2.value == true) {
                                  await keyCodeService(
                                    userData.userData!.id,
                                    code2Controller.text,
                                    userData.userData!.year,
                                  );
                                  isCodeChanged = true;
                                } else if (isEditingCode1 &&
                                    isValid &&
                                    codeVerifyController.isComplete1.value == true &&
                                    codeVerifyController.isComplete2.value == true) {
                                  await keyCodeService(
                                    userData.userData!.id,
                                    code1Controller.text,
                                    userData.userData!.year,
                                  );
                                  await keyCodeService(
                                    userData.userData!.id,
                                    code2Controller.text,
                                    userData.userData!.year,
                                  );
                                  isCodeChanged = true;
                                }

                                // 비밀번호와 가입 코드 둘 다 변경된 경우
                                if (isPwdChanged && isCodeChanged) {
                                  oneButtonDialog(
                                    isBarrier: false,
                                    title: '안내',
                                    content: '비밀번호와 가입 코드가 변경되었습니다.\n다시 로그인해주세요.',
                                    onTap: () {
                                      Get.offAll(() => LoginScreen());
                                    },
                                    buttonText: '확인',
                                  );
                                  return;
                                }

                                // 비밀번호만 변경된 경우
                                if (isPwdChanged && !isCodeChanged) {
                                  oneButtonDialog(
                                    isBarrier: false,
                                    title: '안내',
                                    content: '비밀번호가 변경되었습니다.\n다시 로그인해주세요.',
                                    onTap: () {
                                      Get.offAll(() => LoginScreen());
                                    },
                                    buttonText: '확인',
                                  );
                                  return;
                                }

                                // 가입 코드만 변경된 경우
                                if (!isPwdChanged && isCodeChanged) {
                                  oneButtonDialog(
                                    isBarrier: false,
                                    title: '안내',
                                    content: '가입 코드가 변경되었습니다.\n다시 로그인해주세요.',
                                    onTap: () {
                                      Get.offAll(() => LoginScreen());
                                    },
                                    buttonText: '확인',
                                  );
                                  return;
                                }
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Center(
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * 0.2,
                                    decoration: BoxDecoration(
                                        color: Color(0xFFFE8900), borderRadius: BorderRadius.circular(50)),
                                    height: 50,
                                    child: Center(
                                      child: Text(
                                        !isManager ? '변경하기' : '확인',
                                        style: TextStyle(color: fontWhite, fontSize: 7.sp, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Visibility(
                              visible: !isManager,
                              child: Align(
                                alignment: Alignment.center,
                                child: GestureDetector(
                                  onTap: () {
                                    showWithdrawDialog();
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '회원탈퇴',
                                          style: TextStyle(
                                            color: fontGrey,
                                          ),
                                        ),
                                        SizedBox(height: 2),
                                        Container(
                                          width: 60,
                                          height: 1.5,
                                          color: fontGrey,
                                        ),
                                        Visibility(
                                          visible: userData.userData!.id == 'hoho',
                                          child: Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                GestureDetector(
                                                    onTap: () async {
                                                      await FirebaseMessaging.instance.subscribeToTopic('test');
                                                      Logger().d("✅ 'test' 토픽 구독 완료");
                                                    },
                                                    child: Text('알림 구독')),
                                                SizedBox(width: 10),
                                                GestureDetector(
                                                    onTap: () async {
                                                      await FirebaseMessaging.instance.unsubscribeFromTopic('test');
                                                      Logger().d("✅ 'test' 토픽 구독 취소");
                                                    },
                                                    child: Text('구독 취소')),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Spacer()
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
