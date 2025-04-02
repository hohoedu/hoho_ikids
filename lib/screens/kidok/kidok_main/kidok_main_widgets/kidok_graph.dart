import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:logger/logger.dart';

class KidokGraph extends StatelessWidget {
  final kidokChart = Get.find<KidokChartDataController>();
  final dynamic constraints;

  KidokGraph({super.key, this.constraints});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 24.0),
            child: Text(
              '진단결과 그래프',
              style: TextStyle(fontSize: 20, fontFamily: 'BMJUA'),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF7F5EA), borderRadius: BorderRadius.circular(15)),
                child: Obx(() {
                  if (kidokChart.kidokChartDataList.isEmpty) {
                    return const Center(
                      child: Text(
                        "학습 데이터가 없습니다.",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    );
                  }

                  final chartData = kidokChart.kidokChartDataList.last;
                  final scores = [
                    double.tryParse(chartData.understanding) ?? 0,
                    double.tryParse(chartData.emotion) ?? 0,
                    double.tryParse(chartData.vocabulary) ?? 0,
                    double.tryParse(chartData.expression) ?? 0,
                    double.tryParse(chartData.knowledge) ?? 0,
                    double.tryParse(chartData.thought) ?? 0,
                  ];

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
                        child: BarChart(
                          BarChartData(
                            maxY: 2,
                            minY: 0,
                            barGroups: _generateBarGroups(scores, constraints),
                            barTouchData: BarTouchData(
                              enabled: false,
                            ),
                            titlesData: FlTitlesData(
                              bottomTitles: AxisTitles(
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (double value, TitleMeta meta) {
                                    const categories = ['이해', '감정', '어휘', '표현', '지식', '사고'];
                                    return Padding(
                                      padding: const EdgeInsets.only(top: 8.0),
                                      child: Align(
                                        alignment: Alignment.center,
                                        child: Text(
                                          categories[value.toInt()],
                                          style: TextStyle(
                                            fontSize: 6.sp,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                  reservedSize: constraints.maxHeight * 0.12,
                                ),
                              ),
                              leftTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(
                              drawVerticalLine: false,
                              show: true,
                              horizontalInterval: 0.5,
                              getDrawingHorizontalLine: (value) {
                                return FlLine(
                                  color: Colors.grey[400],
                                  strokeWidth: 1,
                                  dashArray: [5, 5],
                                );
                              },
                            ),
                            borderData: FlBorderData(show: false),
                            extraLinesData: ExtraLinesData(
                              horizontalLines: [
                                HorizontalLine(
                                  y: 0,
                                  color: Colors.black,
                                  strokeWidth: 1,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }),
              ),
            ),
          ),
        ],
      ),
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
