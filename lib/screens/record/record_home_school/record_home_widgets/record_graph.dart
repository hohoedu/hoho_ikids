import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/star/content_star_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hive/hive.dart';

class RecordGraph extends StatefulWidget {
  final ContentStarDataController contentStar;
  final String type;
  final String keyCode;
  final Function(bool) onGraphTapChanged;
  bool isOnTap;

  RecordGraph({super.key, required this.contentStar, required this.type, required this.isOnTap, required this.onGraphTapChanged, required this.keyCode});

  @override
  State<RecordGraph> createState() => _RecordGraphState();
}

class _RecordGraphState extends State<RecordGraph> {
  // 선택한 막대: 그래프 목록에서 몇 번째인지(1부터). 0 이면 선택 없음
  int _currentIndex = 0;
  bool isGraphTap = false;

  String formattedSubject(String content) {
    String cleaned = content.replaceAll(' 활동', '');

    // 공백 포함 길이 기준
    if (cleaned.length >= 6) {
      return cleaned.substring(0, 4) + '\n' + cleaned.substring(4);
    }
    if (cleaned.length >= 5) {
      return cleaned.substring(0, 3) + '\n' + cleaned.substring(3);
    }
    return cleaned;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(
          () => Container(
            decoration: BoxDecoration(color: Colors.transparent),
            child: widget.contentStar.contentStarDataList.length.isEqual(0)
                ? Center(
                    child: Text(
                      '학습 기록이 없습니다.',
                      style: TextStyle(color: fontSub, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  )
                : Stack(
                    children: [
                      LayoutBuilder(
                        builder: (context, constraints) {
                          return BarChart(
                            BarChartData(
                              minY: 0,
                              maxY: 5,
                              barGroups: _generateBarGroups(constraints),
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) => null,
                                ),
                                touchCallback: (FlTouchEvent event, BarTouchResponse? response) {
                                  if (response != null && response.spot != null) {
                                    setState(() {
                                      _currentIndex = response.spot!.touchedBarGroupIndex + 1;
                                      isGraphTap = true;
                                      widget.onGraphTapChanged(true);
                                    });
                                  }
                                },
                              ),
                              titlesData: FlTitlesData(
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (double value, TitleMeta meta) {
                                      if (value.toInt() < widget.contentStar.contentStarDataList.length) {
                                        return GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _currentIndex = value.toInt() + 1;
                                              isGraphTap = true;
                                              widget.isOnTap = false;
                                            });
                                          },
                                          child: Container(
                                            width: constraints.maxWidth * 0.15,
                                            alignment: Alignment.center,
                                            decoration:
                                                BoxDecoration(color: Colors.transparent, borderRadius: BorderRadius.vertical(bottom: Radius.circular(5))),
                                            child: Text(
                                              formattedSubject(widget.contentStar.contentStarDataList[value.toInt()].subject),
                                              style: TextStyle(
                                                  color: widget.type == 'hani'
                                                      ? haniReportTextColor[widget.contentStar.contentStarDataList[value.toInt()].index]
                                                      : bookiReportTextColor[widget.contentStar.contentStarDataList[value.toInt()].index],
                                                  fontWeight: FontWeight.bold,
                                                  height: 1.2),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    reservedSize: screenWidth >= 1000 ? constraints.maxHeight * 0.15 : constraints.maxHeight * 0.3,
                                  ),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              gridData: FlGridData(
                                drawVerticalLine: false,
                                horizontalInterval: 1,
                                show: true,
                                drawHorizontalLine: true,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.grey[400],
                                    strokeWidth: 0.3,
                                    dashArray: [4, 2],
                                  );
                                },
                              ),
                              borderData: FlBorderData(show: false),
                              extraLinesData: ExtraLinesData(
                                horizontalLines: [
                                  HorizontalLine(
                                    y: 0,
                                    color: fontMain,
                                    strokeWidth: 1,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // 상세 팝업: 숨겨 둬도 안쪽을 만들면 목록을 읽으므로, 선택한 막대가 목록 안에 있을 때만 만듦
                      if (isGraphTap && _currentIndex >= 1 && _currentIndex <= widget.contentStar.contentStarDataList.length)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              widget.isOnTap = false;
                              isGraphTap = false;
                              widget.onGraphTapChanged(false);
                            });
                          },
                          child: Container(
                            width: constraints.maxWidth,
                            height: screenWidth >= 1000 ? constraints.maxHeight / 3 : constraints.maxHeight / 2,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(width: 1),
                              color: Colors.white.withOpacity(0.5),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        widget.contentStar.contentStarDataList[_currentIndex - 1].subject,
                                        style: TextStyle(
                                          fontSize: 8.sp,
                                          fontWeight: FontWeight.bold,
                                          color: widget.type == 'hani'
                                              ? haniReportTextColor[widget.contentStar.contentStarDataList[_currentIndex - 1].index]
                                              : bookiReportColor[widget.contentStar.contentStarDataList[_currentIndex - 1].index],
                                        ),
                                      ),
                                      ...List.generate(
                                        widget.contentStar.contentStarDataList[_currentIndex - 1].contentList.length,
                                        (index) {
                                          return Padding(
                                            padding: const EdgeInsets.all(8.0),
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: widget.type == 'hani'
                                                      ? haniReportTextColor[widget.contentStar.contentStarDataList[_currentIndex - 1].index]
                                                      : bookiReportColor[widget.contentStar.contentStarDataList[_currentIndex - 1].index],
                                                  borderRadius: BorderRadius.circular(5)),
                                              child: Center(
                                                child: Padding(
                                                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                                                  child: Text(
                                                    widget.contentStar.contentStarDataList[_currentIndex - 1].contentList[index],
                                                    style: TextStyle(
                                                      color: fontWhite,
                                                      fontWeight: FontWeight.bold,
                                                      fontSize: 6.sp,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )
                                    ],
                                  ),
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        widget.contentStar.contentStarDataList[_currentIndex - 1].note,
                                        style: TextStyle(
                                          color: fontMain,
                                          fontSize: 6.5.sp,
                                          height: 1,
                                        ),
                                        textAlign: TextAlign.start,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
          ),
        ),
      );
    });
  }

  List<BarChartGroupData> _generateBarGroups(constraints) {
    return List.generate(
      widget.contentStar.contentStarDataList.length,
      (index) {
        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: double.parse(widget.contentStar.contentStarDataList[index].score),
              color: widget.type == 'hani' ? haniReportColor['${index + 1}'] : bookiReportColor['${index + 1}'],
              width: constraints.maxWidth * 0.15,
              borderRadius: BorderRadius.vertical(top: Radius.circular(5)),
            ),
          ],
        );
      },
    );
  }
}
