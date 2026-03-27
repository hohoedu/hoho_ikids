import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/check_box.dart';
import 'package:hani_booki/screens/auth/join_widgets/join_consent_screen.dart';
import 'package:hani_booki/screens/home/home_screen.dart';
import 'package:hani_booki/services/auth/join_service.dart';
import 'package:hani_booki/services/auth/user_count_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/join_text_field.dart';
import 'package:logger/logger.dart';

class JoinParentScreen extends StatefulWidget {
  const JoinParentScreen({super.key});

  @override
  State<JoinParentScreen> createState() => _JoinParentScreenState();
}

class _JoinParentScreenState extends State<JoinParentScreen> {
  final userCountController = Get.put(UserCountController());
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController pnameController = TextEditingController();
  final FocusNode phoneFocusNode = FocusNode();
  final FocusNode pnameFocusNode = FocusNode();

  bool isChecked = false;
  String? selectedRelation;

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
                        '법정대리인 정보 입력',
                        style: TextStyle(
                          color: fontMain,
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '※만 14세 미만 아동인 경우 학부모 등 법정대리인의 정보가 필요합니다.\n 해당 정보는 자녀와의 관계를 확인하는 이외의 용로는 사용되지 않습니다.',
                        style: TextStyle(
                          color: fontMain,
                          fontSize: 5.sp,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                    ),
                  ),
                  CustomTextField(
                    controller: pnameController,
                    focusNode: pnameFocusNode,
                    hintText: '법정대리인 성명',
                    isObscure: false,
                    isNumberField: false,
                    isKoreanOnly: true,
                  ),
                  Obx(
                    () => CustomTextField(
                      controller: phoneController,
                      focusNode: phoneFocusNode,
                      hintText: '법정대리인 연락처',
                      isObscure: false,
                      isNumberField: true,
                      onFocusLost: (_) {
                        userCountController.resetValidationMessage();
                      },
                      completeText: userCountController.message.value,
                      messageColor: userCountController.messageColor.value,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: selectedRelation,
                          hint: Padding(
                            padding: EdgeInsets.only(left: 16.0),
                            child: Text(
                              '자녀와의 관계',
                              style: TextStyle(color: Color(0xFFB0B0B0), fontSize: 16),
                            ),
                          ),
                          isExpanded: true,
                          icon: Icon(Icons.arrow_drop_down, color: fontMain),
                          dropdownColor: Colors.white,
                          borderRadius: BorderRadius.circular(15),
                          elevation: 8,
                          menuMaxHeight: 250,
                          items: ['부', '모', '조부모', '기타']
                              .asMap()
                              .entries
                              .map((entry) => DropdownMenuItem(
                                    value: entry.key.toString(),
                                    child: Padding(
                                      padding: const EdgeInsets.only(left: 8.0),
                                      child: Text(entry.value, style: TextStyle(fontSize: 16)),
                                    ),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRelation = value;
                            });
                          },
                          style: TextStyle(
                            color: fontMain,
                            fontSize: 10.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AuthButton(
                      onTap: () async {
                        JoinController joinController = Get.find();

                        // 유효성 검사
                        if (pnameController.text.isEmpty) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '법정대리인 성명을 입력해주세요',
                              onTap: () {
                                Get.back();
                              },
                              buttonText: '확인');
                        } else if (phoneController.text.length <= 10) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '휴대폰 번호를 입력해주세요',
                              onTap: () {
                                Get.back();
                              },
                              buttonText: '확인');
                        } else if (!userCountController.isComplete.value) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '전화번호를 확인해주세요.',
                              onTap: () {
                                Get.back();
                              },
                              buttonText: '확인');
                        } else if (selectedRelation == null) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '자녀와의 관계를 선택해주세요.',
                              onTap: () {
                                Get.back();
                              },
                              buttonText: '확인');
                        } else {
                          joinController.updateParentInfo(
                            pnameController.text,
                            phoneController.text,
                            selectedRelation!,
                          );
                          Get.to(() => JoinConsentScreen());
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
}
