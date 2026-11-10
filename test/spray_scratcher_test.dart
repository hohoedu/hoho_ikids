import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hani_booki/screens/hani/relics/relics_widgets/spray_scratcher.dart';

void main() {
  Future<int> scratchRows(WidgetTester tester, List<double> rows) async {
    var hits = 0;
    await tester.pumpWidget(MaterialApp(
      home: Center(
        child: SizedBox(
          width: 400,
          height: 240,
          child: SprayScratcher(
            coverAsset: 'assets/images/hani/relics/relics_scratch_bg.png',
            brushSize: 52,
            onThreshold: () => hits++,
            child: const ColoredBox(color: Colors.white),
          ),
        ),
      ),
    ));
    final origin = tester.getTopLeft(find.byType(SprayScratcher));
    for (final y in rows) {
      await tester.dragFrom(origin + Offset(5, y), const Offset(390, 0));
      await tester.pump();
    }
    return hits;
  }

  testWidgets('한 줄만 긁으면 아직 안 열림', (tester) async {
    expect(await scratchRows(tester, [120]), 0);
  });

  testWidgets('75% 이상 긁으면 한 번만 열림', (tester) async {
    expect(await scratchRows(tester, [for (var y = 10.0; y < 240; y += 40) y, 230, 230]), 1);
  });
}
