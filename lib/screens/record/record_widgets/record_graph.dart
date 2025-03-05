import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/_data/content_star_data.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:logger/logger.dart';

class RecordGraph extends StatelessWidget {
  final ContentStarDataController contentStar;
  final String type;

  const RecordGraph({super.key, required this.contentStar, required this.type});

  double _getMaxScore() {
    if (contentStar.contentStarDataList.isEmpty) return 20;
    return contentStar.contentStarDataList
        .map((data) => double.parse(data.starCount))
        .reduce((a, b) => a > b ? a : b);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: contentStar.contentStarDataList.length.isEqual(0)
            ? Center(
                child: Text(
                  '학습 기록이 없습니다.',
                  style: TextStyle(
                      color: fontSub,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  Logger().d('type = $type');
                  return BarChart(
                    BarChartData(
                      maxY: _getMaxScore(),
                      barGroups: _generateBarGroups(constraints),
                      titlesData: FlTitlesData(
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (double value, TitleMeta meta) {
                              if (value.toInt() <
                                  contentStar.contentStarDataList.length) {
                                String categoryKey = contentStar
                                    .contentStarDataList[value.toInt()]
                                    .category;
                                String categoryName = type == 'hani'
                                    ? haniCategory[categoryKey] ?? ''
                                    : bookiCategory[categoryKey] ?? '';

                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(categoryName),
                                );
                              }
                              return const SizedBox();
                            },
                            reservedSize: constraints.maxHeight / 5,
                          ),
                        ),
                        topTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        rightTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: false,
                          ),
                        ),
                      ),
                      gridData: FlGridData(
                        drawVerticalLine: false,
                        show: true,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey[400],
                            strokeWidth: 1,
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
      ),
    );
  }

  List<BarChartGroupData> _generateBarGroups(constraints) {
    final scores = [13, 2, 1, 5, 2];
    final maxScore = scores.reduce((a, b) => a > b ? a : b);
    final minScore = scores.reduce((a, b) => a < b ? a : b);

    return List.generate(
      scores.length,
      (index) {
        final score = scores[index];

        Color barColor = Color(0xFFFFFFFF);
        if (score == maxScore) {
          barColor = Colors.red;
        } else if (score == minScore) {
          barColor = Colors.green;
        }

        return BarChartGroupData(
          x: index,
          barRods: [
            BarChartRodData(
              toY: scores[index].toDouble(),
              color: barColor,
              width: constraints.maxWidth * 0.1,
              borderRadius: BorderRadius.circular(0),
            ),
          ],
        );
      },
    );
  }
}
