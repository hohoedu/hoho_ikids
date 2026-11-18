import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_proviso_data.dart';
import 'package:hani_booki/screens/booki/proviso/proviso_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

const _p = 'assets/images/booki/proviso';

// 서버 응답 모양 그대로, 그림만 앱 에셋으로 (테스트에선 네트워크를 못 씀)
Map<String, dynamic> _text(int n) => {
      'gamok': 'J',
      'ilno': 20 + n,
      'clue1': '단서 $n-1 3·1 운동에 앞장섰어요.',
      'clue2': '단서 $n-2',
      'clue3': '단서 $n-3 손가락 한 마디가 짧은 손도장이 유명해요.',
      'clue_img1': null,
      'clue_img2': null,
      'clue_mp3_1': '',
      'clue_mp3_2': '',
      'clue_mp3_3': '',
      'answer_img': '$_p/inmul-16.png',
      'wrong_img': '$_p/inmul14.png',
    };

Map<String, dynamic> _image(int n) => {
      'gamok': 'K',
      'ilno': 20 + n,
      'clue1': null,
      'clue2': null,
      'clue3': null,
      'clue_img1': '$_p/clude-20-1.png',
      'clue_img2': '$_p/clude-20-2.png',
      'answer_img': '$_p/inmul20.png',
      'wrong_img': '$_p/inmul14.png',
    };

dynamic _state(WidgetTester tester) => tester.state(find.byType(ProvisoScreen));

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad, List<BookiProvisoData> questions) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(360, 722),
    builder: (_, __) => GetMaterialApp(home: ProvisoScreen(questions: questions, random: Random(2))),
  ));
  await _settle(tester);
}

Future<void> _settle(WidgetTester tester) async {
  await tester.runAsync(() => Future.delayed(const Duration(milliseconds: 50))); // 그림 precache
  for (var i = 0; i < 10; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

/// 정답 인물(answer_img) 그림의 화면 위치
Finder _option(String src) =>
    find.byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == src);

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  test('자람은 글 단서 3개, 키움·만남은 그림 단서 2개 (null·빈 값은 건너뜀)', () {
    final t = BookiProvisoData.fromJson(_text(1));
    expect(t.isImage, isFalse);
    expect(t.textClues.map((c) => c.text), ['단서 1-1 3·1 운동에 앞장섰어요.', '단서 1-2', '단서 1-3 손가락 한 마디가 짧은 손도장이 유명해요.']);
    expect(t.imageClues, isEmpty);

    final i = BookiProvisoData.fromJson(_image(1));
    expect(i.isImage, isTrue);
    expect(i.imageClues, ['$_p/clude-20-1.png', '$_p/clude-20-2.png']);
    expect(i.textClues, isEmpty);
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('단서 레이아웃: $name', (tester) async {
      await _pump(tester, size, pad, [BookiProvisoData.fromJson(_text(1))]);
      expect(tester.takeException(), isNull);
      await _pump(tester, size, pad, [BookiProvisoData.fromJson(_image(1))]);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('10개 중 7문제: 오답은 그대로, 정답이면 다음, 끝나면 결과 → 다시하기', (tester) async {
    final all = [for (var n = 1; n <= 10; n++) BookiProvisoData.fromJson(n.isEven ? _image(n) : _text(n))];
    await _pump(tester, const Size(874, 402), EdgeInsets.zero, all);
    final seen = <int>{};
    for (var n = 0; n < 7; n++) {
      final BookiProvisoData q = _state(tester).question;
      expect(seen.add(q.ilno), isTrue, reason: '같은 문제가 두 번 나옴');
      expect(find.text('${n + 1} / 7'), findsOneWidget);
      expect(find.text(q.isImage ? '단서를 보고 관련된 인물을 맞혀보세요.' : '단서를 보고 어떤 인물인지 맞혀보세요.'), findsOneWidget);
      if (!q.isImage) expect(find.text(q.textClues.first.text), findsOneWidget);

      await tester.tap(_option(q.wrongImg));
      await tester.pump(const Duration(milliseconds: 300));
      expect(_state(tester).index, n, reason: '오답이면 넘어가지 않음');

      await tester.tap(_option(q.answerImg));
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
