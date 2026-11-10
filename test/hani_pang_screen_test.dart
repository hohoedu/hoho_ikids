import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_board.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad, {int seed = 3}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(GetMaterialApp(home: HaniPangScreen(random: Random(seed))));
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
    expect(find.text('시간 끝!'), findsOneWidget);

    await tester.tap(find.text('다시 하기'));
    await tester.pump();
    expect(find.text('시간 끝!'), findsNothing);
    expect(find.text('0점'), findsOneWidget);
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
