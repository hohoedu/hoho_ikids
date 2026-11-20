import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_board.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad, {int seed = 3, String keyCode = 'Y011'}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(360, 722), // main.dart 와 같게 (결과 다이얼로그가 씀)
    builder: (_, __) => GetMaterialApp(home: HaniPangScreen(keyCode: keyCode, random: Random(seed))),
  ));
  // 하는 방법 안내 → 3, 2, 1 동안은 시간이 안 흐름 → 시작!
  final dynamic state = tester.state(find.byType(HaniPangScreen));
  expect(find.text('시작하기'), findsOneWidget);
  await tester.tap(find.text('시작하기'));
  await tester.pump();
  for (final label in ['3', '2', '1']) {
    expect(find.text(label), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 800));
  }
  expect(find.text('시작!'), findsOneWidget);
  expect(state.timeValue, 0);
  await tester.pump(const Duration(milliseconds: 800)); // 시작! 사라질 때까지(남은 타이머 정리)
  expect(find.text('시작!'), findsNothing);
}

Future<void> _run(WidgetTester tester, Duration total) async {
  for (var t = Duration.zero; t < total; t += const Duration(milliseconds: 50)) {
    await tester.pump(const Duration(milliseconds: 50));
  }
}

Finder _wood() => find
    .byWidgetPredicate((w) => w is Image && (w.image as AssetImage).assetName == 'assets/images/hani/pang/wood.png');

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  testWidgets('뒤로가기 안내가 떠 있는 동안 시간이 멈추고, 계속 하기면 이어서 흐름', (tester) async {
    final (size, pad) = devices.values.first;
    await _pump(tester, size, pad);
    final dynamic state = tester.state(find.byType(HaniPangScreen));
    await tester.tap(find.descendant(of: find.byType(AppBar), matching: find.byType(GestureDetector)).first);
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.text('계속 하기'), findsOneWidget);
    final paused = state.timeValue;
    await _run(tester, const Duration(seconds: 3));
    expect(state.timeValue, paused);
    await tester.tap(find.text('계속 하기'));
    await _run(tester, const Duration(seconds: 1));
    expect(state.timeValue, greaterThan(paused));
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('hani pang layout: $name', (tester) async {
      await _pump(tester, size, pad);
      expect(tester.takeException(), isNull);

      final board = tester.getRect(find.byKey(const ValueKey('board')));
      final bar = tester.getRect(find.byKey(const ValueKey('timeBar')));
      final panels = [tester.getRect(_wood().at(0)), tester.getRect(_wood().at(1))];
      final safeArea = Rect.fromLTRB(pad.left, 0, size.width - pad.right, size.height);

      for (final r in [board, bar, ...panels]) {
        expect(safeArea.contains(r.topLeft) && safeArea.contains(r.bottomRight - const Offset(1, 1)), isTrue,
            reason: '화면·노치 안: $r');
      }
      for (final p in panels) {
        expect(p.overlaps(board), isFalse, reason: '점수판과 보드가 겹침');
        expect(p.top, greaterThan(56), reason: '뒤로가기 버튼 아래');
      }
      expect(panels[0].bottom, lessThanOrEqualTo(panels[1].top));
      expect(bar.left, greaterThanOrEqualTo(board.right));

      // ignore: avoid_print
      print('$name: block ${(board.width / 8.4).round()}px, board ${board.width.round()}x${board.height.round()}');
    });
  }

  // 키코드 첫 글자에 맞는 블록 세트만 쓰고, 그 파일이 실제로 있음 (G는 세트가 없어 y 사용)
  for (final (keyCode, prefix, max) in [('Y011', 'y', 64), ('S011', 's', 60), ('G011', 'y', 64)]) {
    testWidgets('블록 세트: $keyCode → block-$prefix', (tester) async {
      for (final seed in [1, 2, 3, 4, 5, 6, 7, 8]) {
        await _pump(tester, const Size(874, 402), EdgeInsets.zero, seed: seed, keyCode: keyCode);
        final blocks = find
            .byWidgetPredicate((w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName.contains('/block-'))
            .evaluate()
            .map((e) => ((e.widget as Image).image as AssetImage).assetName)
            .toSet();
        // 판을 랜덤으로 채워서 6종 중 하나가 우연히 안 깔릴 수도 있음
        expect(blocks.length, inInclusiveRange(5, 6), reason: '한 판에 6종: $blocks');
        // 색은 번호 순서로 8색 반복 → (번호-1) % 8 이 모두 달라야 색이 안 겹침
        final colors = blocks.map((b) => (int.parse(RegExp(r'(\d{2})\.png$').firstMatch(b)!.group(1)!) - 1) % 8);
        expect(colors.toSet().length, blocks.length, reason: '색 겹침: $blocks');
        for (final b in blocks) {
          final m = RegExp(r'/block-([a-z])(\d{2})\.png$').firstMatch(b);
          expect(m?.group(1), prefix, reason: b);
          expect(int.parse(m!.group(2)!), inInclusiveRange(1, max), reason: b);
          expect(File(b).existsSync(), isTrue, reason: '파일 없음: $b');
        }
        await tester.pumpWidget(const SizedBox()); // 다음 시드로 새로 그림
      }
    });
  }

  testWidgets('맞는 수를 두면 점수가 오르고, 시간이 끝나면 다시 하기', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero);
    final state = tester.state(find.byType(HaniPangScreen)) as dynamic;
    final Board board = state.board;
    expect(find.text('0점'), findsOneWidget);

    Offset center(Pos p) => tester.getCenter(find.byKey(ValueKey(board.tileAt(p)!.id)));

    final (a, b) = board.findHint()!;
    final firstId = board.tileAt(a)!.id;

    // 힌트대로 탭 두 번 → 터지고 점수 오름
    await tester.tapAt(center(a));
    await tester.pump();
    await tester.tapAt(center(b));
    await _run(tester, const Duration(seconds: 3));
    expect(tester.takeException(), isNull);
    expect(find.text('0점'), findsNothing);
    expect(board.tileAt(a)?.id == firstId, isFalse); // 옮겨졌거나 터짐

    // 모든 칸이 다시 채워져 있음
    expect(board.tiles.length, 40);

    // 시간 끝
    await _run(tester, const Duration(seconds: 60));
    await _run(tester, const Duration(milliseconds: 400));
    expect(find.textContaining('스타', findRichText: true), findsOneWidget); // 부키와 같은 결과 다이얼로그

    await tester.tap(find.text('다시하기'));
    await _run(tester, const Duration(milliseconds: 400));
    expect(find.textContaining('스타', findRichText: true), findsNothing);
    expect(find.text('0점'), findsOneWidget);
    // 다시하기도 3, 2, 1, 시작! 뒤에 시간이 흐름
    expect(find.text('3'), findsOneWidget);
    expect(state.timeValue, 0);
    await _run(tester, const Duration(milliseconds: 2400));
    expect(find.text('시작!'), findsOneWidget);
    await _run(tester, const Duration(seconds: 1));
    expect(state.timeValue, greaterThan(0));
  });

  testWidgets('3초 동안 못 맞추면 힌트 두 칸이 깜빡이고, 맞추면 사라짐', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero);
    final Board board = (tester.state(find.byType(HaniPangScreen)) as dynamic).board;
    final hint = find.byKey(const ValueKey('hint'));

    await _run(tester, const Duration(seconds: 2));
    expect(hint, findsNothing);
    await _run(tester, const Duration(milliseconds: 1100));
    expect(hint, findsNWidgets(2));

    final (a, b) = board.findHint()!;
    Offset center(Pos p) => tester.getCenter(find.byKey(ValueKey(board.tileAt(p)!.id)));
    await tester.tapAt(center(a));
    await tester.pump();
    await tester.tapAt(center(b));
    await _run(tester, const Duration(seconds: 3));
    expect(hint, findsNothing);
  });

  testWidgets('드래그로도 바꿀 수 있음', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero, seed: 7);
    final state = tester.state(find.byType(HaniPangScreen)) as dynamic;
    final Board board = state.board;
    final (a, b) = board.findHint()!;
    final from = tester.getCenter(find.byKey(ValueKey(board.tileAt(a)!.id)));
    final to = tester.getCenter(find.byKey(ValueKey(board.tileAt(b)!.id)));

    await tester.dragFrom(from, to - from);
    await _run(tester, const Duration(seconds: 3));
    expect(find.text('0점'), findsNothing);
  });

  testWidgets('빠르게 휙 밀어도 처음 누른 블록이 옮겨짐', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero, seed: 7);
    final state = tester.state(find.byType(HaniPangScreen)) as dynamic;
    final Board board = state.board;
    final (a, b) = board.findHint()!;
    final from = tester.getCenter(find.byKey(ValueKey(board.tileAt(a)!.id)));
    final to = tester.getCenter(find.byKey(ValueKey(board.tileAt(b)!.id)));

    // 첫 이동 이벤트부터 옆 칸까지 넘어가는 빠른 손놀림
    final g = await tester.startGesture(from);
    await g.moveTo(to);
    await g.up();
    await _run(tester, const Duration(seconds: 3));
    expect(find.text('0점'), findsNothing);
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
