import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/services/auth/search_id_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class SearchIdScreen extends StatefulWidget {
  const SearchIdScreen({super.key});

  @override
  State<SearchIdScreen> createState() => _SearchIdScreenState();
}

class _SearchIdScreenState extends State<SearchIdScreen> {
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();
  final FocusNode phoneNumberFocusNode = FocusNode();
  final FocusNode usernameFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      phoneNumberFocusNode.unfocus();
      usernameFocusNode.unfocus();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: mBackAuth,
          appBar: MainAppBar(title: ' ',isContent: false,),
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
                        '아이디 찾기',
                        style: TextStyle(
                            color: fontMain,
                            fontSize: 24,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    CustomTextField(
                      controller: usernameController,
                      focusNode: usernameFocusNode,
                      hintText: '학생 이름',
                      isObscure: false,
                    ),
                    CustomTextField(
                      controller: phoneNumberController,
                      focusNode: phoneNumberFocusNode,
                      hintText: '전화번호',
                      isObscure: false,
                    ),
                    AuthButton(
                      onTap: () async {
                        FocusManager.instance.primaryFocus?.unfocus();
                        if(usernameController.text.isEmpty){
                          oneButtonDialog(
                            title: '아이디 찾기',
                            content: '학생 이름을 입력해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        }
                        else if (phoneNumberController.text.isEmpty) {
                          oneButtonDialog(
                            title: '아이디 찾기',
                            content: '전화번호를 입력해주세요.',
                            onTap: () => Get.back(),
                            buttonText: '확인',
                          );
                        } else {
                          await searchIdService(
                            usernameController.text,
                            phoneNumberController.text,

                          );
                        }
                      },
                      text: '아이디 찾기',
                    ),
                  ],
                ),
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
