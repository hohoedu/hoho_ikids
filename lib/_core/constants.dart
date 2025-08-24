import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

const List<Color> profileColor = [
  Color(0xFFEA5F7F),
  Color(0xFF13BDB7),
  Color(0xFF6D61E6),
  Color(0xFFE6A161),
];
const List<Color> gridColors = [
  Color(0xFFC7E7C1),
  Color(0xFFF8EA8D),
  Color(0xFFEFD6DD),
  Color(0xFFAAE4DA),
  Color(0xFFCBD8EE),
  Color(0xFFFFDCD0),
  Color(0xFFE5D0F0),
  Color(0xFFDFF2B1),
  Color(0xFFC7E7C1),
  Color(0xFFF8EA8D),
  Color(0xFFEFD6DD),
  Color(0xFFAAE4DA),
];
const List<Color> gridInsideColors = [
  Color(0xFF8FBC86),
  Color(0xFFF1C64F),
  Color(0xFFDA9DAE),
  Color(0xFF6FC1B3),
  Color(0xFF94AFDC),
  Color(0xFFEAA993),
  Color(0xFFD1B3E0),
  Color(0xFFAECA69),
];

const Map<String, Color> kidoColors = {
  '배려': Color(0xFFCBF038),
  '존중': Color(0xFFF5DC52),
  '효': Color(0xFFF7B27D),
  '협력': Color(0xFFFFA8A9),
  '끈기': Color(0xFF84E9C2),
};
const Map<String, Color> kidoSubColors = {
  '배려': Color(0xFF5DB300),
  '존중': Color(0xFFE6B800),
  '효': Color(0xFFEC8E46),
  '협력': Color(0xFFF67B7C),
  '끈기': Color(0xFF3FCA94),
};

const Map<String, String> kidoMonth = {
  '1': '배려',
  '2': '존중',
  '3': '효',
  '4': '협력',
  '5': '끈기',
};

final items = [
  {'title': '루이브라유', 'category': '배려', 'color': gridColors[0], 'circleColor': gridInsideColors[0]},
  {'title': '방정환', 'category': '존중', 'color': gridColors[1], 'circleColor': gridInsideColors[1]},
  {'title': '김구', 'category': '효', 'color': gridColors[2], 'circleColor': gridInsideColors[2]},
  {'title': '간디', 'category': '협력', 'color': gridColors[3], 'circleColor': gridInsideColors[3]},
  {'title': '최무선', 'category': '끈기', 'color': gridColors[4], 'circleColor': gridInsideColors[4]},
  {'title': '유관순', 'category': '애국심', 'color': gridColors[5], 'circleColor': gridInsideColors[5]},
  {'title': '정조•정약용', 'category': '협력', 'color': gridColors[6], 'circleColor': gridInsideColors[6]},
];

final Map<String, String> haniCategory = {
  'song': '동요',
  'story': '동화',
  'insung': '한자성어',
  'write': '획순',
  'card': '카드놀이',
  'clean': '쓱싹쓱싹',
  'puz': '퍼즐놀이',
  'bell': '골든벨',
  'han': '낱말송',
};

final Map<String, String> bookiCategory = {
  'song': '동요',
  'story': '동화',
  'bell': '골든벨',
  'img': '그림 맞추기',
  'find': '다른 그림 찾기',
};

final List<Color> strokeColors = [
  haniColor,
  bookiColor,
  Color(0xFF8FBC86),
  Color(0xFFDA9DAE),
  Color(0xFF6FC1B3),
  Color(0xFF94AFDC),
  Color(0xFFEAA993),
  Color(0xFFD1B3E0),
  Color(0xFFAECA69),
  Color(0xFF8FBC86),
  Color(0xFFDA9DAE),
  Color(0xFF6FC1B3),
];

final List<Color> bookiStrokeColors = [
  Color(0xFFA93A8B),
  Color(0xFF2C9C37),
  Color(0xFF0DBCEF),
  Color(0xFFF18B02),
];

final Map<String, String> noticeIcon = {
  '0': 'assets/images/icons/board_type4.png', // 공지사항
  '1': 'assets/images/icons/board_type3.png', // 교육정보 - 카카오 채널
  '2': 'assets/images/icons/board_type2.png', // 한자성어 - 유튜브
  '3': 'assets/images/icons/board_type6.png', // 인물소개 - 유튜브
  '7': 'assets/images/icons/board_type5.png', // 호호스타 발표
  '8': 'assets/images/icons/board_type1.png', // 호호스타 콘텐츠
};

final List<String> pentagons = [
  'assets/images/icons/blue.png',
  'assets/images/icons/orange.png',
  'assets/images/icons/pink.png',
  'assets/images/icons/purple.png',
  'assets/images/icons/green.png',
];

final List<String> haniTitles = [
  '호호하니 학습 내용',
  'High-five 수업',
  '우리반 언어활동',
  '인성활동',
];

final List<String> bookiTitles = [
  '호호부키 학습 내용',
  'High-five 수업',
  '우리반 언어활동',
  '지식확장 독서활동',
];

final List<String> loadingText = [
  '띠링~ 새로운 문제를 불러오는 중이에요!',
  '딩동댕~ 오늘도 최고가 될 준비 됐나요?',
  '공부 요정이 마법 가루를 뿌리는 중이에요~',
  '두근두근! 알쏭달쏭 퀴즈를 섞는 중이에요~',
];
