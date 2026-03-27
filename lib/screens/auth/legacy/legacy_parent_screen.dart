import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/screens/auth/auth_widgets/custom_check_box.dart';
import 'package:hani_booki/services/auth/ebook_status_manager_service.dart';
import 'package:hani_booki/services/auth/ebook_status_service.dart';
import 'package:hani_booki/services/auth/legacy_parent_service.dart';
import 'package:hani_booki/services/auth/legacy_privacy_service.dart';
import 'package:hani_booki/services/sibling_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/web.dart';

class LegacyParentScreen extends StatefulWidget {
  final UserData userData;
  final String id;

  const LegacyParentScreen(this.userData, this.id, {super.key});

  @override
  State<LegacyParentScreen> createState() => _LegacyParentScreenState();
}

class _LegacyParentScreenState extends State<LegacyParentScreen> {
  final TextEditingController pnameController = TextEditingController();
  final FocusNode pnameFocusNode = FocusNode();

  String? selectedRelation;
  bool isPrivacyChecked = false;

  late UserData userData;
  late String id;

  @override
  void initState() {
    super.initState();
    userData = widget.userData;
    id = widget.id;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
      },
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
                children: [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        '법정대리인 정보 추가 입력',
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                    child: CustomCheckBox(
                      text: '개인정보 수집 및 이용에 관한 동의(필수)',
                      isChecked: isPrivacyChecked,
                      onChanged: (value) {
                        setState(() {
                          isPrivacyChecked = value!;
                        });
                      },
                      onTap: (p0) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showTermsDialog(
                          context,
                          title: '개인정보 수집 및 이용에 관한 동의',
                          assetTextPath: 'assets/text/privacy_terms.txt',
                          onConfirmed: () {
                            setState(() {
                              isPrivacyChecked = true;
                            });
                          },
                        );
                      },
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.5,
                    child: AuthButton(
                      onTap: () async {
                        // 유효성 검사
                        if (pnameController.text.isEmpty) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '법정대리인 성명을 입력해주세요',
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
                        } else if (!isPrivacyChecked) {
                          oneButtonDialog(
                              title: '회원가입',
                              content: '개인정보 수집 및 이용은 필수 동의 항목입니다.',
                              onTap: () {
                                Get.back();
                              },
                              buttonText: '확인');
                        } else {
                          // 이름, 관계, 개인정보 동의 모두 전달
                          final infoSuccess = await legacyParentService(
                            id: id,
                            parentName: pnameController.text.trim(),
                            relation: selectedRelation!,
                          );

                          if (!infoSuccess) return;

                          final privacySuccess = await legacyPrivacyService(id: id, agreed: 'Y');

                          if (!privacySuccess) return;

                          // 두 통신 모두 성공 시 다음 화면으로 이동
                          if (int.parse(userData.siblingCount) >= 2) {
                            await siblingService(userData.parentTel);
                          } else {
                            if (userData.userType == 'M' || userData.userType == 'T') {
                              await ebookStatusManagerService(userData.schoolId, userData.year);
                            } else {
                              await ebookStatusService(id, userData.schoolId, userData.year);
                            }
                          }
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
