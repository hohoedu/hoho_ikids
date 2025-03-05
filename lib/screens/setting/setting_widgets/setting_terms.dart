import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/widgets/dialog.dart';

class SettingTerms extends StatelessWidget {
  const SettingTerms({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 2,
      child: Padding(
        padding: EdgeInsets.only(bottom: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GestureDetector(
              onTap: () {
                showTermsDialog(context,
                    title: '호호 아이키즈 이용약관',
                    assetTextPath: 'assets/text/hoho_i_kids_terms.txt',
                    onConfirmed: () {});
              },
              child: Text(
                '호호 아이키즈 이용약관',
                style: TextStyle(color: fontSub, fontSize: 10),
              ),
            ),
            VerticalDivider(
              indent: 8, // 위쪽 여백
              endIndent: 8,
            ),
            GestureDetector(
              onTap: () {
                showTermsDialog(context,
                    title: '개인정보 처리방침',
                    assetTextPath: 'assets/text/information_collection.txt',
                    onConfirmed: () {});
              },
              child: Text(
                '개인정보 처리방침',
                style: TextStyle(color: fontSub, fontSize: 10),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
