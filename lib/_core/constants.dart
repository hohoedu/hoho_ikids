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

const missionStyles = [
  {
    'label': 'MISSION. 1',
    'labelColor': Color(0xFFCB778F),
    'cardColor': Color(0xFFFFD8E3),
    'footerColor': Color(0xFFEDA8BC),
    'completedAsset': 'assets/images/mission/complete_pink.png',
    'clearAsset':'assets/images/mission/attendance_complete.png'
  },
  {
    'label': 'MISSION. 2',
    'labelColor': Color(0xFF6EA997),
    'cardColor': Color(0xFFC8ECE1),
    'footerColor': Color(0xFF9BCABC),
    'completedAsset': 'assets/images/mission/complete_green.png',
    'clearAsset':'assets/images/mission/contents_complete.png'
  },
];

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

// 한자를 맞춰요 => card
// 퀴즈 그림 사전 => quiz

// 어휘사전 => workbook
// 어휘 맞추기 => quiz
// 골든벨 => bell

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

final Map<String, String> tendencyIcon = {
  '예리한 인간로봇': 'assets/images/kidok/report_ico01.png',
  '직관형 독서가': 'assets/images/kidok/report_ico02.png',
  '표현의 연금술사': 'assets/images/kidok/report_ico03.png',
  '표현의 마술사': 'assets/images/kidok/report_ico04.png',
  '걸어 다니는 어휘사전': 'assets/images/kidok/report_ico05.png',
  '똑똑한 어휘박사': 'assets/images/kidok/report_ico06.png',
  '감성적인 독서가': 'assets/images/kidok/report_ico07.png',
  '따뜻한 공감주의자': 'assets/images/kidok/report_ico08.png',
  '주제를 찾는 탐구자': 'assets/images/kidok/report_ico09.png',
  '깊이 생각하는 사색가': 'assets/images/kidok/report_ico10.png',
  '냉철한 분석가': 'assets/images/kidok/report_ico11.png',
  '꼼꼼한 논리주의자': 'assets/images/kidok/report_ico12.png',
  '호기심 많은 지식인': 'assets/images/kidok/report_ico13.png',
  '사려 깊은 추론가': 'assets/images/kidok/report_ico14.png',
  '완벽한 독서가': 'assets/images/kidok/report_ico15.png',
};
