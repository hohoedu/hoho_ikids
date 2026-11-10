import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/hani/relics/relics_screen.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/screens/hani/relics/relics_widgets/spray_scratcher.dart';

// 가로 모드 논리 해상도와 안전영역(노치·홈 인디케이터)
const devices = <String, (Size, EdgeInsets)>{
  'iPhone SE': (Size(667, 375), EdgeInsets.zero),
  'iPhone 16 Pro': (Size(874, 402), EdgeInsets.fromLTRB(62, 0, 62, 21)),
  'iPhone 16 Pro Max': (Size(956, 440), EdgeInsets.fromLTRB(62, 0, 62, 21)),
  'Galaxy S24': (Size(780, 360), EdgeInsets.fromLTRB(24, 0, 0, 0)),
  'Galaxy Tab S9': (Size(1280, 800), EdgeInsets.zero),
  'iPad mini': (Size(1133, 744), EdgeInsets.fromLTRB(0, 24, 0, 20)),
  'iPad Pro 13': (Size(1376, 1032), EdgeInsets.fromLTRB(0, 24, 0, 20)),
};

void main() {
  setUpAll(() {
    Get.testMode = true;
    Get.put<BgmController>(_NoAudioBgm());
  });

  for (final MapEntry(key: name, value: (size, pad)) in devices.entries) {
    testWidgets('relics layout: $name', (tester) async {
      tester.view
        ..physicalSize = size
        ..devicePixelRatio = 1
        ..padding = FakeViewPadding(left: pad.left, top: pad.top, right: pad.right, bottom: pad.bottom);
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const GetMaterialApp(home: RelicsScreen()));
      expect(tester.takeException(), isNull); // overflow 등 레이아웃 에러 없음

      final frame = tester.getRect(find.byType(AspectRatio).first);
      final scratch = tester.getRect(find.byType(SprayScratcher));
      final buttons = find.byWidgetPredicate((w) => w is AspectRatio && w.aspectRatio == 603 / 406);
      final top = tester.getRect(buttons.at(0)), bottom = tester.getRect(buttons.at(1));
      final screen = Offset.zero & size;

      // ignore: avoid_print
      print('$name ${size.width.toInt()}x${size.height.toInt()}: '
          'frame ${frame.width.round()}x${frame.height.round()} (${(frame.width / size.width * 100).round()}% w, '
          '${(frame.height / size.height * 100).round()}% h), button ${top.width.round()}x${top.height.round()}');

      for (final r in [frame, top, bottom]) {
        expect(screen.contains(r.topLeft) && screen.contains(r.bottomRight - const Offset(1, 1)), isTrue);
      }
      expect(frame.top, greaterThanOrEqualTo(40), reason: '제목과 겹치지 않음');
      expect(top.left, greaterThan(frame.right), reason: '버튼이 액자와 겹치지 않음');
      expect(bottom.top, greaterThanOrEqualTo(top.bottom));
      // 긁는 영역은 노치/펀치홀에 가려지지 않음
      expect(scratch.left, greaterThanOrEqualTo(pad.left));
      expect(scratch.right, lessThanOrEqualTo(size.width - pad.right));
      expect(frame.height / size.height, greaterThan(0.6), reason: '액자가 충분히 큼');
    });
  }
}

// 테스트 환경엔 오디오 플러그인이 없어 BGM 미리 불러오기를 건너뜀
class _NoAudioBgm extends BgmController {
  @override
  // ignore: must_call_super
  void onInit() {}
}
