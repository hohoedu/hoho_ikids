import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class EmptyRecords extends StatelessWidget {
  const EmptyRecords({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Expanded(flex: 3, child: Image.asset('assets/images/records/talk_icon.png')),
          Expanded(
            flex: 2,
            child: Center(
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20,
                    color: Color(0xFF919191),
                    fontWeight: FontWeight.bold,
                  ),
                  children: [
                    TextSpan(text: '아직 선생님이 열심히 수업을 하고 있어요!\n'),
                    TextSpan(text: '수업이 모두 끝날 때까지 조금만 기다려 주세요~'),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Text(
              '(설정에서 알림을 켜두면 보고서 도착 시 알림을 보내드려요)',
              style: TextStyle(fontSize: 16, color: Color(0xFF919191)),
            ),
          ),
        ],
      ),
    );
  }
}
