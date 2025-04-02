import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:intl/intl.dart';
import 'package:logger/logger.dart';

String formatNumber(int number) {
  if (number >= 1000000) {
    return '${(number / 1000000).toStringAsFixed(1)}M'; // 1M 이상
  } else if (number >= 1000) {
    return '${(number / 1000).toInt()}K'; // 1K 이상
  } else {
    return number.toString(); // 1K 미만
  }
}

String removedZero(String text) {
  // if (text == '00') {
  //   Logger().d('실행 안함?');
  //   text = '01';
  // }

  if (RegExp(r'^0\d$|^[1-9]\d*$').hasMatch(text)) {
    return int.parse(text).toString();
  }
  return text;
}

String removeHyphen(String phoneNumber) {
  return phoneNumber.replaceAll('-', '');
}

String splitWithNewLine(String input) {
  return input.split('. ').join('.\n');
}

String removeTwoChars(String text) {
  return text.length > 2 ? text.substring(2) : '';
}

String insertNewlineAtFirstSpace(String text) {
  int spaceIndex = text.indexOf(' ');
  if (spaceIndex == -1) return text;

  return text.substring(0, spaceIndex) + '\n' + text.substring(spaceIndex + 1);
}

String formatNoticeTitle(String text) {
  String monthSplit = text.replaceAll(RegExp(r'\]\s*'), ']\n');
  List<String> lines = monthSplit.split('\n').map((line) {
    if (line.length < 6) return line;

    int spaceIndex = line.indexOf(RegExp(r'[\s]'), 6);
    int hyphenIndex = line.indexOf(RegExp(r'[\s-]'), 6);

    int breakIndex;
    if (spaceIndex == -1) {
      breakIndex = hyphenIndex;
    } else if (hyphenIndex == -1) {
      breakIndex = spaceIndex;
    } else {
      breakIndex = spaceIndex < hyphenIndex ? spaceIndex : hyphenIndex;
    }
    if (breakIndex != -1) {
      if (line[breakIndex] == '-') {
        return line.substring(0, breakIndex) + '\n' + line.substring(breakIndex);
      } else {
        return line.substring(0, breakIndex) + '\n' + line.substring(breakIndex + 1);
      }
    }
    return line;
  }).toList();
  return lines.join('\n');
}

String addLineBreaks(String text, {int maxLineLength = 15}) {
  text = text.replaceAllMapped(
    RegExp(r'([\[].*?[\]])'),
    (match) => '\n${match.group(0)}\n',
  );

  List<String> lines = text.split('\n');
  StringBuffer result = StringBuffer();

  for (String line in lines) {
    List<String> words = line.split(' ');
    String currentLine = '';

    for (String word in words) {
      if (currentLine.isEmpty) {
        currentLine = word;
      } else if ((currentLine.length + word.length + 1) <= maxLineLength) {
        currentLine += ' $word';
      } else {
        result.writeln(currentLine); // 줄바꿈 추가
        currentLine = word;
      }
    }

    if (currentLine.isNotEmpty) {
      result.writeln(currentLine); // 마지막 줄 추가
    }
  }

  return result.toString().trim();
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
              decoration: TextDecoration.underline, color: fontMain, fontSize: 7.sp, fontWeight: FontWeight.bold),
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

String newLineAfterThird(String text) {
  int count = text.indexOf(' ');
  if (count == -1) {
    return text;
  }
  return text.substring(0, count) + '\n' + text.substring(count + 1);
}

String removeWord(String text) {
  return text.replaceAll(RegExp(r'\s*활동$'), '');
}

String formatDateDifference(String dateString) {
  DateTime now = DateTime.now();
  DateTime inputDate = DateTime.parse(dateString);
  Duration difference = now.difference(inputDate);

  if (difference.inDays == 0) {
    return "오늘";
  } else if (difference.inDays == 1) {
    return "하루 전";
  } else if (difference.inDays == 2) {
    return "2일 전";
  } else if (difference.inDays <= 7) {
    return "${difference.inDays}일 전";
  } else if (difference.inDays <= 30) {
    int weeks = (difference.inDays / 7).floor();
    return "${weeks}주 전";
  } else {
    int months = (difference.inDays / 30).floor();
    return "${months}달 전";
  }
}
