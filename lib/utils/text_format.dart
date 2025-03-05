import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';

String formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M'; // 1M 이상
  } else if (number >= 1000) {
    return '${(number / 1000).toInt()}K'; // 1K 이상
  } else {
    return number.toString(); // 1K 미만
  }
}

String removeHyphen(String phoneNumber) {
  return phoneNumber.replaceAll('-', '');
}

String splitWithNewLine(String input) {
  return input.split('. ').join('.\n');
}

String removeTwoChars(String text){
  return text.length > 2 ? text.substring(2) : '';
}

String insertNewlineAtFirstSpace(String text) {
  int spaceIndex = text.indexOf(' ');
  if (spaceIndex == -1) return text;

  return text.substring(0, spaceIndex) + '\n' + text.substring(spaceIndex + 1);
}

// 자동 줄바꿈
String autoWrapText(String text, int maxCharsPerLine) {
  List<String> words = text.split(" ");
  String result = "";
  String currentLine = "";

  for (var word in words) {
    if (word.contains("[") && word.contains("]")) {
      if (currentLine.isNotEmpty) {
        result += "$currentLine\n";
      }
      result += "$word\n";
      currentLine = "";
      continue;
    }

    if ((currentLine.length + word.length) > maxCharsPerLine) {
      result += "$currentLine\n";
      currentLine = word;
    } else {
      currentLine += currentLine.isEmpty ? word : " $word";
    }
  }

  if (currentLine.isNotEmpty) {
    result += "$currentLine";
  }

  return result.trim();
}

// 밑줄 추가
TextSpan exampleText(String text) {
  text = text.replaceAll('~r~n', '\n'); // ~r~n을 \n으로 변환
  text = text.replaceAll('()', '(        )'); // () 내부에 4칸 공백 추가
  text = text.replaceAll('@@@@@', '"');
  text = text.replaceAll('A', '        ');

  final regex = RegExp(r'\[(.*?)\]');
  List<TextSpan> spans = [];

  text.splitMapJoin(
    regex,
    onMatch: (Match match) {
      spans.add(
        TextSpan(
          text: match.group(1),
          style: TextStyle(
              decoration: TextDecoration.underline,
              color: fontMain,
              fontSize: 7.sp,
              fontWeight: FontWeight.bold),

        ),
      );
      return "";
    },
    onNonMatch: (String nonMatch) {
      spans.add(
        TextSpan(
          text: nonMatch,
          style: TextStyle(
            color: fontMain,
            fontSize: 7.sp,
          ),
        ),
      );
      return "";
    },
  );

  return TextSpan(children: spans);
}
