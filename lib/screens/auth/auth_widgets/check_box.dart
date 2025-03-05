import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/join_dto.dart';
import 'package:hani_booki/screens/auth/auth_widgets/custom_check_box.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class JoinCheckBox extends StatefulWidget {
  const JoinCheckBox({super.key});

  @override
  State<JoinCheckBox> createState() => _JoinCheckBoxState();
}

class _JoinCheckBoxState extends State<JoinCheckBox> {
  bool isAllChecked = false;
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;

  final JoinController joinController = Get.find<JoinController>();

  void updateJoinDTOCheckBoxes() {
    joinController.updateCheckBoxes(isChecked1, isChecked2, isChecked3);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CustomCheckBox(
            text: '이용약관에 모두 동의합니다.',
            fontSize: 18,
            isChecked: isAllChecked,
            onChanged: (value) {
              FocusScope.of(context).unfocus();
              setState(() {
                isAllChecked = value!;
                isChecked1 = value;
                isChecked2 = value;
                isChecked3 = value;
              });
              updateJoinDTOCheckBoxes();
            },
            scale: 1.5,
          ),
        ),
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.3,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 64),
                  child: CustomCheckBox(
                      text: '호호에듀(주) 온라인 교육서비스 이용약관 동의(필수)',
                      isChecked: isChecked1,
                      onChanged: (value) {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          isChecked1 = value!;
                          isAllChecked = isChecked1 && isChecked2 && isChecked3;
                        });
                        updateJoinDTOCheckBoxes();
                      },
                      onTap: (p0) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showTermsDialog(
                          context,
                          title: '호호에듀(주) 온라인 교육 서비스 이용약관 동의',
                          assetTextPath: 'assets/text/hoho_i_kids_terms.txt',
                          onConfirmed: () {
                            setState(() {
                              isChecked1 = true;
                            });
                            updateJoinDTOCheckBoxes();
                          },
                        );
                      }),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 64.0),
                  child: CustomCheckBox(
                    text: '14세 미만 아동의 정보 수집 동의(필수)',
                    isChecked: isChecked2,
                    onChanged: (value) {
                      setState(() {
                        isChecked2 = value!;
                        isAllChecked = isChecked1 && isChecked2 && isChecked3;
                      });
                      updateJoinDTOCheckBoxes();
                    },
                    onTap: (p0) {
                      FocusManager.instance.primaryFocus?.unfocus();
                      showTermsDialog(
                        context,
                        title: '14세 미만 아동의 정보 수집 동의',
                        assetTextPath: 'assets/text/information_collection.txt',
                        onConfirmed: () {
                          setState(() {
                            isChecked2 = true;
                          });
                          updateJoinDTOCheckBoxes();
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 64.0),
                  child: CustomCheckBox(
                      text: '마케팅 활용에 대한 동의(선택)',
                      isChecked: isChecked3,
                      onChanged: (value) {
                        setState(() {
                          isChecked3 = value!;
                          isAllChecked = isChecked1 && isChecked2 && isChecked3;
                        });
                        updateJoinDTOCheckBoxes();
                      },
                      onTap: (p0) {
                        FocusManager.instance.primaryFocus?.unfocus();
                        showTermsDialog(
                          context,
                          title: '마케팅 활용에 대한 동의',
                          assetTextPath: 'assets/text/marketing.txt',
                          onConfirmed: () {
                            setState(() {
                              isChecked3 = true;
                            });
                            updateJoinDTOCheckBoxes();
                          },
                        );
                      }),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

// void showTermsDialog(BuildContext context) {
//   Future<String> loadTermText() async {
//     return await rootBundle.loadString('assets/text/hoho_i_kids_terms.txt');
//   }
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         title: const Center(child: Text('호호에듀(주) 온라인 교육 서비스 이용약관 동의')),
//         buttonPadding: EdgeInsets.zero,
//         content: FutureBuilder(
//             future: loadTermText(),
//             builder: (context, snapshot) {
//               return SingleChildScrollView(
//                 child: ListBody(
//                   children: [Text(snapshot.data ?? 'No terms found')],
//                 ),
//               );
//             }),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//
//               },
//               child: Text(
//                 '확인',
//                 style: TextStyle(color: fontWhite),
//               ),
//               style: ButtonStyle(
//                   backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.green)),
//             ),
//           ),
//         ],
//       );
//     },
//   ).then((_) {
//     setState(() {
//       isChecked1 = true;
//     });
//     updateJoinDTOCheckBoxes();
//   });
// }

// void showPrivacyPolicyDialog(BuildContext context) {
//   Future<String> loadPrivacyText() async {
//     return await rootBundle
//         .loadString('assets/text/information_collection.txt');
//   }
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         title: const Center(child: Text('14세 미만 아동의 정보 수집 동의')),
//         content: FutureBuilder(
//             future: loadPrivacyText(),
//             builder: (context, snapshot) {
//               return SingleChildScrollView(
//                 child: ListBody(
//                   children: [Text(snapshot.data ?? 'No terms found')],
//                 ),
//               );
//             }),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 FocusScope.of(context).unfocus();
//                 setState(() {
//                   isChecked2 = true;
//                 });
//                 updateJoinDTOCheckBoxes();
//               },
//               child: Text(
//                 '확인',
//                 style: TextStyle(color: fontWhite),
//               ),
//               style: ButtonStyle(
//                   backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.green)),
//             ),
//           ),
//         ],
//       );
//     },
//   ).then((_) {
//     setState(() {
//       isChecked2 = true;
//     });
//     updateJoinDTOCheckBoxes();
//   });
// }

// void showMarketingDialog(BuildContext context) {
//   Future<String> loadTermText() async {
//     return await rootBundle.loadString('assets/text/marketing.txt');
//   }
//
//   showDialog(
//     context: context,
//     builder: (BuildContext context) {
//       return AlertDialog(
//         backgroundColor: Colors.white,
//         title: const Center(child: Text('마케팅 활용에 대한 동의')),
//         buttonPadding: EdgeInsets.zero,
//         content: FutureBuilder(
//             future: loadTermText(),
//             builder: (context, snapshot) {
//               return SingleChildScrollView(
//                 child: ListBody(
//                   children: [Text(snapshot.data ?? 'No terms found')],
//                 ),
//               );
//             }),
//         actions: [
//           Center(
//             child: ElevatedButton(
//               onPressed: () {
//                 FocusScope.of(context).unfocus();
//                 Get.back();
//                 setState(() {
//                   isChecked3 = true;
//                 });
//                 updateJoinDTOCheckBoxes();
//               },
//               child: Text(
//                 '확인',
//                 style: TextStyle(color: fontWhite),
//               ),
//               style: ButtonStyle(
//                   backgroundColor:
//                       MaterialStateProperty.all<Color>(Colors.green)),
//             ),
//           ),
//         ],
//       );
//     },
//   ).then((_) {
//     setState(() {
//       isChecked3 = true;
//     });
//     updateJoinDTOCheckBoxes();
//   });
// }
}
