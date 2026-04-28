import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class KidokGraph extends StatelessWidget {
  final kidokChart = Get.find<KidokChartDataController>();
  final dynamic constraints;
  final List<FlSpot> spots;

  KidokGraph({super.key, this.constraints, required this.spots});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 1000;

    final totalBooks = spots.fold<int>(0, (sum, spot) => sum + spot.y.toInt());
    final maxX = spots.isEmpty ? 1.0 : spots.last.x + 0.2;
    final maxY = spots.isEmpty ? 5.0 : (spots.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1);

    final barData = LineChartBarData(
      spots: spots,
      isCurved: true,
      curveSmoothness: 0.4,
      color: const Color(0xFF5ECFB1),
      barWidth: 2.5,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(
        show: true,
        color: const Color(0xFF5ECFB1).withOpacity(0.1),
      ),
    );
    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 12.0),
            child: Text(
              '누적 독서량',
              style: TextStyle(fontSize: 7.sp, fontFamily: 'BMJUA', color: Color(0xFF968B52)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 상단 타이틀
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 7.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(text: '2026년에\n총 '),
                            TextSpan(
                              text: '$totalBooks권',
                              style: TextStyle(color: Color(0xFF4CAF50)),
                            ),
                            TextSpan(text: '의 책을 읽었어요'),
                          ],
                        ),
                      ),
                    ),
                    // 차트
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(8, 16, 24, 16),
                        child: LineChart(
                          LineChartData(
                            minX: spots.isEmpty ? 0.8 : spots.first.x - 0.2,
                            maxX: maxX,
                            minY: 0,
                            maxY: 5,
                            lineBarsData: [barData],
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: 5,
                                  color: const Color(0xFFAFB8B4),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                ),
                              ],
                            ),
                            titlesData: FlTitlesData(
                              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value != value.roundToDouble()) return const SizedBox.shrink();
                                    final index = value.toInt();
                                    if (index < 1 || index > 12) return const SizedBox.shrink();
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 6),
                                      child: Text(
                                        '$index',
                                        style: const TextStyle(
                                          color: Color(0xFFAFB8B4),
                                          fontSize: 14,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  reservedSize: 52,
                                  interval: 1,
                                  getTitlesWidget: (value, meta) {
                                    if (value != 5) return const SizedBox.shrink();
                                    return Text(
                                      '${value.toInt()}권',
                                      style: const TextStyle(
                                        color: Color(0xFFAFB8B4),
                                        fontSize: 14,
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                            gridData: FlGridData(
                              show: false,
                              drawVerticalLine: false,
                              horizontalInterval: 1,
                              getDrawingHorizontalLine: (value) {
                                if (value == 0) return FlLine(color: Colors.transparent, strokeWidth: 0);
                                return const FlLine(
                                  color: Color(0xFFCAD5D0),
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                            ),
                            borderData: FlBorderData(
                              show: true,
                              border: const Border(
                                bottom: BorderSide(color: Color(0xFFCAD6D0), width: 1),
                                left: BorderSide.none,
                                right: BorderSide.none,
                                top: BorderSide.none,
                              ),
                            ),
                          ),
                          duration: Duration.zero,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          // Expanded(
          //   child: Padding(
          //     padding: const EdgeInsets.all(8.0),
          //     child: Container(
          //       decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
          //       child: Obx(() {
          //         final dataList = kidokChart.kidokChartDataList;
          //         if (dataList.isEmpty) {
          //           return const Center(
          //             child: Text(
          //               "학습 데이터가 없습니다.",
          //               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          //             ),
          //           );
          //         }
          //
          //         final scores = dataList.map((chartData) {
          //           final values = [
          //             double.tryParse(chartData.understanding) ?? 0,
          //             double.tryParse(chartData.emotion) ?? 0,
          //             double.tryParse(chartData.vocabulary) ?? 0,
          //             double.tryParse(chartData.expression) ?? 0,
          //             double.tryParse(chartData.knowledge) ?? 0,
          //             double.tryParse(chartData.thought) ?? 0,
          //           ];
          //           return values.reduce((a, b) => a + b) / values.length;
          //         }).toList();
          //
          //         final spots = _generateSpots(scores);
          //
          //         // ✅ maxY를 데이터 기준으로 동적 계산
          //         final maxScore = scores.isNotEmpty ? scores.reduce((a, b) => a > b ? a : b) : 2.0;
          //         final maxY = (maxScore * 1.3).clamp(2.0, 12.0);
          //         final barData = LineChartBarData(
          //           spots: spots,
          //           isCurved: true,
          //           curveSmoothness: 0.5,
          //           color: Color(0xFF5FCFB0),
          //           barWidth: 1,
          //           dotData: FlDotData(show: false),
          //           belowBarData: BarAreaData(
          //             show: true,
          //             color: Color(0xFF5FCFB0).withOpacity(0.1),
          //           ),
          //         );
          //
          //         return LayoutBuilder(
          //           builder: (context, constraints) {
          //             return Padding(
          //               padding: const EdgeInsets.all(16.0),
          //               child: LineChart(
          //                 LineChartData(
          //                   minY: 0,
          //                   // ✅ 수정: 뒤바뀐 min/max 교체
          //                   maxY: maxY,
          //                   // ✅ 수정
          //                   minX: 0,
          //                   maxX: (scores.length - 1).toDouble(),
          //                   // ✅ 수정: 실제 데이터 길이 기준
          //                   lineBarsData: [barData],
          //                   showingTooltipIndicators: List.generate(
          //                     spots.length,
          //                     (index) => ShowingTooltipIndicators([
          //                       LineBarSpot(barData, 0, spots[index]),
          //                     ]),
          //                   ),
          //                   lineTouchData: LineTouchData(
          //                     enabled: false,
          //                     touchTooltipData: LineTouchTooltipData(
          //                       tooltipPadding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
          //                       tooltipMargin: 12,
          //                       getTooltipItems: (touchedSpots) {
          //                         return touchedSpots.map((spot) {
          //                           return LineTooltipItem(
          //                             spot.y.toStringAsFixed(1),
          //                             const TextStyle(
          //                               color: Colors.white,
          //                               fontSize: 11,
          //                               fontWeight: FontWeight.bold,
          //                             ),
          //                           );
          //                         }).toList();
          //                       },
          //                     ),
          //                   ),
          //                   titlesData: FlTitlesData(
          //                     bottomTitles: AxisTitles(
          //                       sideTitles: SideTitles(
          //                         showTitles: true,
          //                         interval: 1,
          //                         getTitlesWidget: (double value, TitleMeta meta) {
          //                           const categories = [
          //                             '1호',
          //                             '2호',
          //                             '3호',
          //                             '4호',
          //                             '5호',
          //                             '6호',
          //                             '7호',
          //                             '8호',
          //                             '9호',
          //                             '10호',
          //                             '11호',
          //                             '12호',
          //                           ];
          //                           final index = value.toInt();
          //                           if (index < 0 || index >= categories.length) {
          //                             return const SizedBox.shrink();
          //                           }
          //                           return Padding(
          //                             padding: const EdgeInsets.only(top: 8.0),
          //                             child: Text(
          //                               categories[index],
          //                               style: TextStyle(
          //                                 fontSize: 6.sp,
          //                                 fontWeight: FontWeight.bold,
          //                               ),
          //                             ),
          //                           );
          //                         },
          //                         reservedSize: constraints.maxHeight * 0.12,
          //                       ),
          //                     ),
          //                     leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //                     topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //                     rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          //                   ),
          //                   gridData: FlGridData(
          //                     show: true,
          //                     drawVerticalLine: false,
          //                     horizontalInterval: 0.5,
          //                     getDrawingHorizontalLine: (value) => FlLine(
          //                       color: Colors.grey[400],
          //                       strokeWidth: 1,
          //                       dashArray: [5, 5],
          //                     ),
          //                   ),
          //                   borderData: FlBorderData(
          //                     show: true,
          //                     border: const Border(
          //                       bottom: BorderSide(color: Colors.black, width: 1),
          //                       left: BorderSide.none,
          //                       right: BorderSide.none,
          //                       top: BorderSide.none,
          //                     ),
          //                   ),
          //                 ),
          //               ),
          //             );
          //           },
          //         );
          //       }),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }

  List<FlSpot> _generateSpots(List<double> scores) {
    return List.generate(
      scores.length,
      (index) => FlSpot(index.toDouble(), scores[index]),
    );
  }

  List<BarChartGroupData> _generateBarGroups(List<double> scores, BoxConstraints constraints) {
    return List.generate(scores.length, (index) {
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: scores[index],
            color: Colors.orange,
            width: constraints.maxWidth * 0.1,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      );
    });
  }
}
