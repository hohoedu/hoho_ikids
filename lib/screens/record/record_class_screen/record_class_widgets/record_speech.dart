import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_radar_chart/flutter_radar_chart.dart';

class RecordSpeech extends StatefulWidget {
  const RecordSpeech({super.key});

  @override
  State<RecordSpeech> createState() => _RecordSpeechState();
}

class _RecordSpeechState extends State<RecordSpeech> {
  @override
  Widget build(BuildContext context) {
    var ticks = [1, 2, 3, 4, 5];
    var data = [
      [4, 5, 5, 5, 4],
    ];
    var features = [
      '의미표현',
      '문장이해',
      '바른인성탐구',
      '창의놀이',
      '어휘활용',
    ];
    return Center(
      child: Row(
        children: [
          Expanded(
            flex: 8,
            child: RadarChart(
              ticks: ticks,
              features: features,
              data: data,
              ticksTextStyle: TextStyle(fontSize: 0.0),
              graphColors: [Colors.green],
              outlineColor: Colors.grey,
            ),
          ),
          Expanded(
            flex: 4,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.grey),
                  color: Colors.transparent,
                ),
                child: Column(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        '의미표현 활동',
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.blueAccent,
                      ),
                    ),
                    Container(),
                    Expanded(
                      flex: 4,
                      child: Text('한자 이미지를 머릿속에 떠롤리며 동요를 듣고 따라부르는 활동'),
                    )
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
