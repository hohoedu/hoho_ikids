import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_basket_data.dart';
import 'package:hani_booki/screens/booki/basket/basket_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';

const _dir = 'assets/images/booki/basket';
// 서버 문제 대신 앱 샘플 그림 (유관순: 무궁화·만세운동·일본 순사가 정답)
final _problems = [
  BookiBasketData(
    ilno: 7,
    personImg: '$_dir/inmul-07.png',
    answerImgs: ['$_dir/object07-1.png', '$_dir/object07-2.png', '$_dir/object07-3.png'],
    wrongImgs: ['$_dir/object03-1.png', '$_dir/object25-1.png', '$_dir/object10-1.png'],
  ),
];

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  test('응답 항목을 인물·정답 3개·오답 3개로 읽는다', () {
    const b = 'https://hohoeduimg.speedgabia.com/hohoeduapp/basket';
    final d = BookiBasketData.fromJson({
      'gamok': 'K',
      'ilno': 1,
      'person_img': '$b/01.jpg',
      'answer_img1': '$b/basket_img/01_1.jpg',
      'answer_img2': '$b/basket_img/01_2.jpg',
      'answer_img3': '$b/basket_img/01_3.jpg',
      'wrong_img1': '$b/basket_img/02_3.jpg',
      'wrong_img2': '$b/basket_img/24_1.jpg',
      'wrong_img3': '$b/basket_img/28_3.jpg',
    });
    expect(d.ilno, 1);
    expect(d.personImg, '$b/01.jpg');
    expect(d.answerImgs, ['$b/basket_img/01_1.jpg', '$b/basket_img/01_2.jpg', '$b/basket_img/01_3.jpg']);
    expect(d.wrongImgs, ['$b/basket_img/02_3.jpg', '$b/basket_img/24_1.jpg', '$b/basket_img/28_3.jpg']);
  });

  testWidgets('맞는 물건은 바구니에 담기고, 틀린 물건은 제자리로, 다 담으면 결과', (tester) async {
    tester.view
      ..physicalSize = const Size(874, 402)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(360, 722),
      builder: (_, __) => GetMaterialApp(home: BasketScreen(problems: _problems, random: Random(0))),
    ));
    expect(tester.takeException(), isNull);
    // 바구니는 그림 크기로 높이가 정해지므로, 그림을 다 불러온 뒤에 위치를 잡음
    await tester.runAsync(() => precacheImage(const AssetImage('$_dir/basket.png'), tester.element(find.byType(BasketScreen))));
    await tester.pumpAndSettle();
    final basket = tester.getCenter(find.byType(DragTarget<int>));
    Finder item(String name) => find.byKey(ValueKey('$_dir/$name.png'));

    Future<void> drop(String name) async {
      final g = await tester.startGesture(tester.getCenter(item(name)));
      await g.moveBy(const Offset(5, 5));
      await tester.pump();
      await g.moveTo(basket);
      await tester.pump();
      await g.up();
      await tester.pumpAndSettle();
    }

    final before = tester.getRect(item('object03-1'));
    await drop('object03-1'); // 오답
    expect(tester.getRect(item('object03-1')), before);

    await drop('object07-1');
    expect(item('object07-1'), findsNothing);
    await drop('object07-2');
    await drop('object07-3');
    await tester.pump(const Duration(milliseconds: 700));
    await tester.pump(const Duration(milliseconds: 400));
    expect(find.textContaining('스타', findRichText: true), findsOneWidget);
  });

  testWidgets('문제 10개 중 7개를 차례로 풀어야 결과가 뜸', (tester) async {
    tester.view
      ..physicalSize = const Size(874, 402)
      ..devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final ten = [
      for (var i = 1; i <= 10; i++)
        BookiBasketData(
            ilno: i, personImg: _problems.first.personImg, answerImgs: _problems.first.answerImgs, wrongImgs: _problems.first.wrongImgs),
    ];
    await tester.pumpWidget(ScreenUtilInit(
      designSize: const Size(360, 722),
      builder: (_, __) => GetMaterialApp(home: BasketScreen(problems: ten, random: Random(1))),
    ));
    await tester.runAsync(() => precacheImage(const AssetImage('$_dir/basket.png'), tester.element(find.byType(BasketScreen))));
    await tester.pumpAndSettle();
    final basket = tester.getCenter(find.byType(DragTarget<int>));
    final dialog = find.textContaining('스타', findRichText: true);

    for (var round = 1; round <= 7; round++) {
      expect(dialog, findsNothing, reason: '$round번째 문제 시작 전엔 결과 없음');
      for (final name in ['object07-1', 'object07-2', 'object07-3']) {
        final g = await tester.startGesture(tester.getCenter(find.byKey(ValueKey('$_dir/$name.png'))));
        await g.moveBy(const Offset(5, 5));
        await tester.pump();
        await g.moveTo(basket);
        await tester.pump();
        await g.up();
        await tester.pumpAndSettle();
      }
      await tester.pump(const Duration(milliseconds: 700)); // 다음 문제로
      await tester.pump(const Duration(milliseconds: 400));
    }
    expect(dialog, findsOneWidget, reason: '7문제를 다 풀면 결과');
  });
}

class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
