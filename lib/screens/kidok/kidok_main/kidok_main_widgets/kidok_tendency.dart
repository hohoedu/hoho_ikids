import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:hani_booki/_data/kidok/kidok_chart_data.dart';
import 'package:hive/hive.dart';

class KidokTendency extends StatelessWidget {
  final List<TopItem> tendency;
  final bool isPerfect;

  const KidokTendency({super.key, required this.tendency, required this.isPerfect});

  @override
  Widget build(BuildContext context) {
    bool isTablet = MediaQuery.of(context).size.width > 1000;

    return Expanded(
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: isTablet ? 0.0 : 12.0),
            child: Text(
              '독서 성향',
              style: TextStyle(fontSize: 7.sp, fontFamily: 'BMJUA', color: Color(0xFF968B52)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: isPerfect
                  ? Center(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(width: 50, height: 50, child: Image.asset(tendencyIcon['완벽한 독서가']!)),
                            Text('완벽한 독서가'),
                          ],
                        ),
                      ),
                    )
                  : Column(
                      children: [
                        Spacer(),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                              child: Row(
                                children: [
                                  SizedBox(height: 50, width: 50, child: Image.asset(tendencyIcon['${tendency[0].text}']!)),
                                  Text('${tendency[0].text}'),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Row(
                                  children: [SizedBox(width: 50, height: 50, child: Image.asset(tendencyIcon['${tendency[1].text}']!)), Text('${tendency[1].text}')],
                                )),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 50,
                                      height: 50,
                                      child: Image.asset(tendencyIcon['${tendency[2].text}']!),
                                    ),
                                    Text('${tendency[2].text}')
                                  ],
                                )),
                          ),
                        ),
                        Spacer()
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
