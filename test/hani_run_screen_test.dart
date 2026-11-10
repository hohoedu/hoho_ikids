import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_logic.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

const _laneY = [0.4755, 0.6955];

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad, {bool obstacles = false}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(home: HaniRunScreen(random: Random(5), obstacles: obstacles)));
}

Future<void> _run(WidgetTester tester, Duration total, {bool Function()? until}) async {
  for (var t = Duration.zero; t < total; t += const Duration(milliseconds: 50)) {
    await tester.pump(const Duration(milliseconds: 50));
    if (until?.call() ?? false) return;
  }
}

dynamic _state(WidgetTester tester) => tester.state(find.byType(HaniRunScreen));

/// 문제가 나올 때까지 기다렸다가, 정답(또는 오답) 길을 탭하고 채점까지 기다림
Future<HanjaQuestion> _answer(WidgetTester tester, Size size, {required bool correct}) async {
  await _run(tester, const Duration(seconds: 3), until: () => _state(tester).question != null);
  final HanjaQuestion q = _state(tester).question;
  final targetLane = q.targetSide == Side.left ? 0 : 1;
  final lane = correct ? targetLane : 1 - targetLane;
  await tester.tapAt(Offset(size.width / 2, size.height * _laneY[lane]));
  await _run(tester, const Duration(seconds: 6), until: () => _state(tester).question == null);
  return q;
}

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('hani run layout: $name', (tester) async {
      await _pump(tester, size, pad);
      await _run(tester, const Duration(seconds: 2), until: () => _state(tester).question != null);
      expect(tester.takeException(), isNull);

      final hud = tester.getRect(find.byKey(const ValueKey('hud')));
      final bubble = tester.getRect(find.byKey(const ValueKey('bubble')));
      final character = tester.getRect(find.byKey(const ValueKey('character')));
      final safeArea = Rect.fromLTRB(pad.left, 0, size.width - pad.right, size.height);

      for (final r in [hud, bubble, character]) {
        expect(safeArea.contains(r.topLeft) && safeArea.contains(r.bottomRight - const Offset(1, 1)), isTrue,
            reason: '화면·노치 안: $r');
      }
      expect(bubble.overlaps(hud), isFalse, reason: '말풍선과 점수판 겹침');
      expect(bubble.left, greaterThan(pad.left + 56), reason: '뒤로가기 버튼과 안 겹침');
      expect(find.text(_state(tester).question.target.reading), findsOneWidget);

      // ignore: avoid_print
      print(
          '$name: character ${character.height.round()}px, bubble ${bubble.width.round()}px, hud ${hud.width.round()}px');
    });
  }

  testWidgets('정답 길은 점수, 오답 길은 하트 감소, 하트 0이면 게임 끝 → 다시 하기', (tester) async {
    const size = Size(874, 402);
    await _pump(tester, size, EdgeInsets.zero);
    final HanjaRun run = _state(tester).run;

    await _answer(tester, size, correct: true);
    expect(run.score, greaterThan(0));
    expect(run.hearts, 3);
    expect(find.text('+10'), findsOneWidget);

    final q = await _answer(tester, size, correct: false);
    expect(run.hearts, 2);
    expect(run.mistakes, contains(q.target));
    expect(find.textContaining('정답은 ${q.target.char}'), findsOneWidget);

    await _answer(tester, size, correct: false);
    await _answer(tester, size, correct: false);
    expect(run.isOver, isTrue);
    await _run(tester, const Duration(seconds: 1));
    expect(find.text('게임 끝!'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('다시 하기'));
    await tester.pump();
    expect(find.text('게임 끝!'), findsNothing);
    expect(_state(tester).run.hearts, 3);
    expect(_state(tester).run.score, 0);
  });

  testWidgets('장애물이 나오고, 계속 달려도 에러가 없음', (tester) async {
    const size = Size(874, 402);
    await _pump(tester, size, EdgeInsets.zero, obstacles: true);
    final obstacle = find.byWidgetPredicate(
        (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.contains(RegExp('rock|trash')));
    var sawObstacle = false;
    HanjaQuestion? answered;
    // 40초 동안 문제마다 정답 길을 누르며 달림
    for (var t = 0; t < 800 && !_state(tester).run.isOver; t++) {
      await tester.pump(const Duration(milliseconds: 50));
      final HanjaQuestion? q = _state(tester).question;
      if (q != null && !identical(q, answered)) {
        answered = q;
        await tester.tapAt(Offset(size.width / 2, size.height * _laneY[q.targetSide == Side.left ? 0 : 1]));
      }
      sawObstacle |= obstacle.evaluate().isNotEmpty;
    }
    expect(tester.takeException(), isNull);
    expect(sawObstacle, isTrue);
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
