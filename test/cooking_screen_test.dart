import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_cooking_data.dart';
import 'package:hani_booki/screens/hani/cooking/cooking_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

import 'relics_layout_test.dart' show devices;

const _dir = 'assets/images/hani/cooking';
const _cards = [
  'cooking_card_iceberg',
  'cooking_card_weightlifting',
  'cooking_card_mountain',
  'cooking_card_orchard',
  'cooking_card_stream',
  'cooking_card_pediatrics',
];
// 서버 문제 대신 앱 샘플 카드 (주제 자연: 빙산·산·개울·과수원이 정답, 역도·소아과가 오답)
final _problems = [
  HaniCookingData(ilno: 1, topic: '자연', answers: [
    for (final c in ['cooking_card_iceberg', 'cooking_card_mountain', 'cooking_card_stream', 'cooking_card_orchard'])
      (word: c, img: '$_dir/$c.png'),
  ], wrongs: [
    for (final c in ['cooking_card_weightlifting', 'cooking_card_pediatrics']) (word: c, img: '$_dir/$c.png'),
  ]),
];
const _title = '아래의 주제와 관련된 것을 요리볼에 담아보세요.';

Rect _card(WidgetTester t, String name) => t.getRect(find.byKey(ValueKey('$_dir/$name.png')));

Finder _asset(String name) => find.byWidgetPredicate(
    (w) => w is Image && w.image is AssetImage && (w.image as AssetImage).assetName == '$_dir/$name.png');

Rect _image(WidgetTester t, String name) => t.getRect(_asset(name));

int _count(String name) => _asset(name).evaluate().length;

Future<void> _pump(WidgetTester tester, Size size, EdgeInsets pad, {int seed = 0}) async {
  tester.view
    ..physicalSize = size
    ..devicePixelRatio = 1
    ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
  addTearDown(tester.view.reset);
  await tester.pumpWidget(ScreenUtilInit(
    designSize: const Size(360, 722), // main.dart 와 같게 (결과 다이얼로그가 씀)
    builder: (_, __) => GetMaterialApp(home: CookingScreen(problems: _problems, random: Random(seed))),
  ));
}

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('cooking layout: $name (카드 자리 섞어도)', (tester) async {
      // 자리를 섞어도 어떤 카드가 어느 자리에 가든 겹치거나 잘리지 않음
      for (var seed = 0; seed < 30; seed++) {
        await _pump(tester, size, pad, seed: seed);
        expect(tester.takeException(), isNull);

        final screen = Offset.zero & size;
        final cards = [for (final c in _cards) _card(tester, c)];
        final center = [
          _image(tester, 'cooking_sign'),
          _image(tester, 'cooking_bowl'),
          _image(tester, 'cooking_tiger')
        ];

        for (var i = 0; i < cards.length; i++) {
          final r = cards[i];
          expect(screen.contains(r.topLeft) && screen.contains(r.bottomRight - const Offset(1, 1)), isTrue,
              reason: '${_cards[i]} 화면 안');
          expect(r.left >= pad.left && r.right <= size.width - pad.right, isTrue, reason: '${_cards[i]} 노치에 안 가림');
          expect(r.top, greaterThanOrEqualTo(kToolbarHeight - 8), reason: '${_cards[i]} 제목과 안 겹침');
          for (var j = i + 1; j < cards.length; j++) {
            expect(r.overlaps(cards[j]), isFalse, reason: '${_cards[i]} ↔ ${_cards[j]} 겹침');
          }
          for (final c in center) {
            expect(r.overlaps(c), isFalse, reason: '${_cards[i]}가 가운데 요리볼/팻말/호랑이와 겹침');
          }
        }
        expect(tester.getSize(find.text(_title)).height, lessThan(40), reason: '제목 한 줄');

        if (seed == 0) {
          // ignore: avoid_print
          print('$name: card ${cards.first.height.round()}px, bowl ${center[1].width.round()}px');
        }
      }
    });
  }

  testWidgets('맞는 카드는 요리볼에 담기고, 틀린 카드는 제자리로', (tester) async {
    await _pump(tester, const Size(874, 402), EdgeInsets.zero);
    final bowl = tester.getCenter(_asset('cooking_bowl'));

    Future<void> dropOnBowl(String name) async {
      final from = _card(tester, name).center;
      final g = await tester.startGesture(from);
      await g.moveBy(const Offset(5, 5));
      await tester.pump();
      await g.moveTo(bowl);
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
    }

    expect(_count('cooking_check'), 0);
    expect(_count('cooking_question'), 4);

    await dropOnBowl('cooking_card_iceberg');
    expect(find.byKey(const ValueKey('$_dir/cooking_card_iceberg.png')), findsNothing);
    expect(_count('cooking_check'), 1);

    final before = _card(tester, 'cooking_card_weightlifting');
    await dropOnBowl('cooking_card_weightlifting');
    expect(_card(tester, 'cooking_card_weightlifting'), before);
    expect(_count('cooking_check'), 1);

    for (final c in ['cooking_card_mountain', 'cooking_card_orchard', 'cooking_card_stream']) {
      await dropOnBowl(c);
    }
    expect(_count('cooking_check'), 4);
    expect(_count('cooking_question'), 0);

    // 다 담으면 결과 다이얼로그 → 다시하기
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('스타', findRichText: true), findsOneWidget);
    await tester.tap(find.text('다시하기'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400)); // 닫히는 애니메이션
    expect(find.textContaining('스타', findRichText: true), findsNothing);
    expect(_count('cooking_question'), 4);
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
