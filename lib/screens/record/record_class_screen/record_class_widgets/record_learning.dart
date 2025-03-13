import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class RecordLearning extends StatelessWidget {
  const RecordLearning({super.key});

  Widget _buildLeftItem(String title) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFEF2CC),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/icons/complete.png',
                  scale: 1.5,
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    height: 2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRichText() {
    return Container(
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Color(0xFFF5E4B5)),
        ),
      ),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(height: 2.5, fontSize: 14, color: Colors.black),
          children: [
            const TextSpan(text: '신습한자 '),
            ...['月', '火', '水', '木', '金', '土', '日', '口'].map(
                  (char) => WidgetSpan(
                alignment: PlaceholderAlignment.middle,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFF0F0F0),
                  ),
                  child: Text(
                    char,
                    style: const TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ),
              ),
            ),
            const TextSpan(text: ' 총 8자를 배웠어요.'),
          ],
        ),
      ),
    );
  }

  Widget _buildCircleItem(Color bgColor, List<String> texts) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(100),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: texts.asMap().entries.map(
                (entry) {
              int idx = entry.key;
              String text = entry.value;
              return Text(
                text,
                style: TextStyle(
                  fontSize: idx == 0 ? 14 : 18,
                  fontWeight: FontWeight.bold,
                  color: idx == 0 ? Colors.black : fontWhite,
                ),
              );
            },
          ).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final leftTitles = ['영재 1호', '유치원과 친구들', '배려'];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // 왼쪽 Column
          Expanded(
            flex: 1,
            child: Column(
              children: leftTitles.map((title) => _buildLeftItem(title)).toList(),
            ),
          ),
          // 오른쪽 영역
          Expanded(
            flex: 3,
            child: Column(
              children: [
                Expanded(flex: 1, child: _buildRichText()),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircleItem(const Color(0xFFF8B82F), ['한자동요', '노래하는', '일주일']),
                      _buildCircleItem(const Color(0xFF57A6FF), ['한자 워크북', '영재 1권', '4주']),
                      _buildCircleItem(const Color(0xFF85CF3C), ['한자동화', '훈이의', '일주일']),
                    ],
                  ),
                ),
                Expanded(
                  flex: 3,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildCircleItem(const Color(0xFFEA7EC3), ['성어스토리', '수어지교', '水魚之交']),
                      _buildCircleItem(const Color(0xFFF3825F), ['인성실천', '배려를', '실천해요']),
                      _buildCircleItem(const Color(0xFF867DF2), ['기초한글', '한글', '놀이터']),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
