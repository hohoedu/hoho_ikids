import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_sentence_data.dart';
import 'package:hani_booki/screens/booki/sentence/sentence_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

// 서버 응답 모양 그대로, 그림만 앱 에셋으로 (테스트에선 네트워크를 못 씀)
List<BookiSentenceData> _questions(int count) => [
      for (var n = 1; n <= count; n++)
        BookiSentenceData.fromJson({
          'gamok': 'J',
          'ilno': 20 + n,
          'munje': '문제 $n 은 ?년에 반포되었어요.',
          'ans': '정답$n',
          'img': 'assets/images/booki/sentence/inmul-16.png',
          'answer_img': 'assets/images/booki/sentence/a-16-1.png',
          'wrong': '오답$n',
          'wrong_img': 'assets/images/booki/sentence/a-16-1.png',
          'voice': '',
        }),
    ];

dynamic _state(WidgetTester tester) => tester.state(find.byType(SentenceScreen));

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(360, 722),
    builder: (_, __) => GetMaterialApp(home: SentenceScreen(questions: _questions(10), random: Random(4))),
  ));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50))); // 그림 precache
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  test('munje 의 ? 자리를 빈칸으로 나눔', () {
    final q = BookiSentenceData.fromJson({
      'ilno': 25,
      'munje': '정조는 수원에 ?을 쌓았어요.',
      'ans': '화성',
      'img': 'https://x/25.jpg',
      'answer_img': 'https://x/25_1.jpg',
      'wrong': '자격루',
      'wrong_img': 'https://x/28_1.jpg',
      'voice': 'https://x/25.mp3',
    });
    expect(q.before, '정조는 수원에 ');
    expect(q.after, '을 쌓았어요.');
    expect(q.answer, (word: '화성', img: 'https://x/25_1.jpg'));
    expect(q.wrong, (word: '자격루', img: 'https://x/28_1.jpg'));
    expect(BookiSentenceData.fromJson({'ilno': 1, 'munje': '3·1 운동은 ?년에 일어났어요.'}).before, '3·1 운동은 ');
  });

  testWidgets('문장은 나눔스퀘어라운드: BMJUA 는 가운뎃점 모양이 비어 있어서 안 씀', (tester) async {
    tester.view
      ..physicalSize = const Size(874, 402)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final q = BookiSentenceData.fromJson({
      'ilno': 27,
      'munje': '3·1 운동은 ?년에 일어났어요.',
      'ans': '1919',
      'wrong': '자격루',
      'img': 'assets/images/booki/sentence/inmul-16.png',
      'answer_img': 'assets/images/booki/sentence/a-16-1.png',
      'wrong_img': 'assets/images/booki/sentence/a-16-1.png',
      'voice': '',
    });
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(360, 722),
      builder: (_, __) => GetMaterialApp(home: SentenceScreen(questions: [q])),
    ));
    await _settle(tester);
    final spans = <TextSpan>[];
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      rich.text.visitChildren((span) {
        if (span is TextSpan && span.text != null) spans.add(span);
        return true;
      });
    }
    expect(spans.map((s) => s.text).join(), contains('3·1 운동은 '));
    final families = <String?>{};
    for (final rich in tester.widgetList<RichText>(find.byType(RichText))) {
      rich.text.visitChildren((span) {
        families.add(span.style?.fontFamily);
        return true;
      });
    }
    expect(families, isNot(contains('BMJUA')));
    expect(families, contains('NANUM-EB'));
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('문장 완성 레이아웃: $name', (tester) async {
      await _pump(tester, size, pad);
      expect(tester.takeException(), isNull);
      expect(find.text('1 / 7'), findsOneWidget);
    });
  }

  testWidgets('10개 중 7문제: 오답은 그대로, 정답이면 다음 문제, 7개 끝나면 결과 → 다시하기', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero);
    final seen = <int>{};
    for (var n = 0; n < 7; n++) {
      final BookiSentenceData q = _state(tester).question;
      expect(seen.add(q.ilno), isTrue, reason: '같은 문제가 두 번 나옴');
      expect(find.text('${n + 1} / 7'), findsOneWidget);

      await tester.tap(find.text(q.wrong.word).last); // 보기는 그림자용으로 두 번 그려짐
      await tester.pump(const Duration(milliseconds: 300));
      expect(_state(tester).index, n, reason: '오답이면 넘어가지 않음');

      await tester.tap(find.text(q.answer.word).last);
      await tester.pump(const Duration(milliseconds: 1000));
      await _settle(tester);
      expect(tester.takeException(), isNull);
    }
    expect(find.textContaining('스타', findRichText: true), findsOneWidget);

    await tester.tap(find.text('다시하기'));
    await _settle(tester);
    expect(_state(tester).index, 0);
    expect(find.text('1 / 7'), findsOneWidget);
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
