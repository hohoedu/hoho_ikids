import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_story_board_data.dart';
import 'package:hani_booki/screens/booki/story_board/story_board_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/text_format.dart';

// 서버 응답 모양 그대로, 그림만 앱 에셋으로 (테스트에선 네트워크를 못 씀)
List<BookiStoryBoardData> _stories(int count) => [
      for (var n = 1; n <= count; n++)
        BookiStoryBoardData.fromJson({
          'ilno': 20 + n,
          'title': '이야기 $n',
          for (var i = 1; i <= 4; i++) ...{
            'img$i': 'assets/images/booki/story_board/story22-$i.png',
            'txt$i': '이야기 $n 장면 $i',
            'voice$i': '',
          },
        }),
    ];

dynamic _state(WidgetTester tester) => tester.state(find.byType(StoryBoardScreen));

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50))); // 그림 precache
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// 지금 이야기의 2~4번 카드를 순서대로 칸에 끌어다 놓음
Future<void> _solveRound(WidgetTester tester) async {
  final List<BookiStoryScene> scenes = _state(tester).scenes;
  for (var i = 1; i < scenes.length; i++) {
    final card = tester.getCenter(find.text(keepWords(scenes[i].text)));
    final slot = tester.getCenter(find.byType(DragTarget<int>).at(i));
    final g = await tester.startGesture(card);
    await tester.pump(const Duration(milliseconds: 50));
    await g.moveTo(slot);
    await tester.pump(const Duration(milliseconds: 50));
    await g.up();
    await tester.pump(const Duration(milliseconds: 50));
  }
}

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  testWidgets('10개 중 7개 이야기를 차례로 완성하면 결과 다이얼로그, 다시하기는 새 7개', (tester) async {
    tester.view
      ..physicalSize = const Size(874, 402)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final all = _stories(10);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(360, 722),
      builder: (_, __) => GetMaterialApp(home: StoryBoardScreen(stories: all, random: Random(3))),
    ));
    await _settle(tester);

    final seen = <String>{};
    for (var r = 0; r < 7; r++) {
      expect(_state(tester).round, r);
      expect(find.text('${r + 1} / 7'), findsOneWidget);
      final List<BookiStoryScene> scenes = _state(tester).scenes;
      expect(seen.add(scenes.first.text), isTrue, reason: '같은 이야기가 두 번 나옴');
      await _solveRound(tester);
      expect(tester.takeException(), isNull);
      await tester.pump(const Duration(milliseconds: 1000)); // 다음 이야기로
      await _settle(tester);
    }
    expect(find.textContaining('스타', findRichText: true), findsOneWidget); // 7개 끝 → 결과 다이얼로그

    await tester.tap(find.text('다시하기'));
    await _settle(tester);
    expect(_state(tester).round, 0);
    expect(find.text('1 / 7'), findsOneWidget);
  });

  test('줄바꿈은 띄어쓰기에서만: 단어 안 글자 사이에 줄바꿈 금지 문자', () {
    expect(keepWords('전국으로 만세 운동이 퍼졌어요.'),
        ['전국으로', '만세', '운동이', '퍼졌어요.'].map((w) => w.split('').join(wordJoiner)).join(' '));
    expect(keepWords('3·1').replaceAll(wordJoiner, ''), '3·1');
    expect(keepWords(''), '');
  });

  test('서버 응답 항목을 장면 4개로 묶음', () {
    final d = BookiStoryBoardData.fromJson({
      'gamok': 'J',
      'ilno': 21,
      'title': '김구와 임시정부',
      for (var i = 1; i <= 4; i++) ...{'img$i': 'https://x/21_$i.jpg', 'txt$i': 't$i', 'voice$i': 'https://x/21_$i.mp3'},
    });
    expect(d.ilno, 21);
    expect(d.title, '김구와 임시정부');
    expect(d.scenes.map((s) => s.img), ['https://x/21_1.jpg', 'https://x/21_2.jpg', 'https://x/21_3.jpg', 'https://x/21_4.jpg']);
    expect(d.scenes.last.voice, 'https://x/21_4.mp3');
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
