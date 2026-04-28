import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:hani_booki/main.dart';

class RankQuestion extends StatelessWidget {
  const RankQuestion({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isDismissible: true,
          enableDrag: false,
          isScrollControlled: true,
          constraints: const BoxConstraints(maxWidth: double.infinity),
          builder: (context) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              height: screenWidth > 1000 ? MediaQuery.of(context).size.height * 0.6 : MediaQuery.of(context).size.height * 0.9,
              width: MediaQuery.of(context).size.width * 0.8,
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 2,
                    child: Row(
                      children: [
                        const Spacer(),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '호호유치원 호호스타 TOP3',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold),
                          ),
                        ),
                        Expanded(
                          flex: 1,
                          child: GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Image.asset('assets/images/rank/rank_cancel.png', scale: 6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: const Text(
                      '우리 유치원 친구들 중 별포인트를 많이 모은 친구들을 보여줘요!\n별 포인트를 모을수록 TOP3에 올라갈 수 있어요.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 11,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Image.asset('assets/images/rank/first_desc.png'),
                        Image.asset('assets/images/rank/second_desc.png'),
                        Image.asset('assets/images/rank/third_desc.png'),
                        // _buildDescCard(
                        //   color: const Color(0xffFFF4D1),
                        //   imagePath: 'assets/images/rank/first_desc.png',
                        //   label: '끝까지 콘텐츠를\n학습해봐요!',
                        // ),
                        // _buildDescCard(
                        //   color: const Color(0xffD6E8FF),
                        //   imagePath: 'assets/images/rank/second_desc.png',
                        //   label: '깜짝 미션\n달성해요!',
                        // ),
                        // _buildDescCard(
                        //   color: const Color(0xffD3F3E2),
                        //   imagePath: 'assets/images/rank/third_desc.png',
                        //   label: '곳곳에 숨어있는\n별을 발견해요!',
                        // ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        '*별포인트 획득은 실시간 반영되며, [깜짝 미션] 달성 시 추가 획득 포인트와\n'
                        '[별포인트를 찾아라!] 이벤트에서 획득한 포인트는 랭킹 점수에서만 합산됩니다. (학습 포인트 반영 안됨)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Color(0xFFA2A2A2), fontSize: 4.sp),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
      child: Image.asset('assets/images/rank/question_mark.png'),
    );
  }

  Widget _buildDescCard({
    required Color color,
    required String imagePath,
    required String label,
  }) {
    return Container(
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(15)),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Image.asset(imagePath),
            ),
          ),
          Expanded(
            flex: 1,
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 6.sp, fontWeight: FontWeight.bold, letterSpacing: -1, height: 1.2),
            ),
          ),
        ],
      ),
    );
  }
}
