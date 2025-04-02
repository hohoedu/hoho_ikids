import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/auth/auth_widgets/auth_button.dart';
import 'package:hani_booki/services/auth/search_id_service.dart';
import 'package:hani_booki/services/auth/search_password_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/custom_text_field.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class SearchPasswordScreen extends StatefulWidget {
  const SearchPasswordScreen({super.key});

  @override
  State<SearchPasswordScreen> createState() => _SearchIdScreenState();
}

class _SearchIdScreenState extends State<SearchPasswordScreen> {
  final TextEditingController idController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final FocusNode idFocusNode = FocusNode();
  final FocusNode phoneNumberFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      idFocusNode.unfocus();
      phoneNumberFocusNode.unfocus();
    });
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
                      '비밀번호 찾기',
                      style: TextStyle(
                          color: fontMain,
                          fontSize: 24,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  CustomTextField(
                    controller: idController,
                    focusNode: idFocusNode,
                    hintText: '아이디',
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
                      if(idController.text.isEmpty){
                        oneButtonDialog(
                          title: '비밀번호 찾기',
                          content: '아이디를 입력해주세요.',
                          onTap: () => Get.back(),
                          buttonText: '확인',
                        );
                      }
                      else if (phoneNumberController.text.isEmpty) {
                        oneButtonDialog(
                          title: '비밀번호 찾기',
                          content: '전화번호를 입력해주세요.',
                          onTap: () => Get.back(),
                          buttonText: '확인',
                        );
                      } else {
                        await searchPasswordService(
                          idController.text,
                          phoneNumberController.text,
                        );
                      }
                    },
                    text: '임시 비밀번호 발급',
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
