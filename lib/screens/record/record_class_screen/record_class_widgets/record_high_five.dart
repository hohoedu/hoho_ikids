import 'package:flutter/material.dart';
import 'package:hani_booki/_core/colors.dart';

class RecordHighFive extends StatefulWidget {
  const RecordHighFive({super.key});

  @override
  State<RecordHighFive> createState() => _RecordHighFiveState();
}

class _RecordHighFiveState extends State<RecordHighFive> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      setState(() {});
    });
  }

  double get progress {
    if (_scrollController.hasClients &&
        _scrollController.position.maxScrollExtent > 0) {
      return _scrollController.offset /
          _scrollController.position.maxScrollExtent;
    }
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        double leftPosition = progress * constraints.maxWidth * 0.5;
        return Padding(
          padding: const EdgeInsets.only(top: 24.0, left: 24.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  controller: _scrollController,
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.zero,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        color: Colors.transparent,
                        width: constraints.maxWidth * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                ' 의미표현 활동',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10)),
                              height: constraints.maxHeight * 0.7,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        '둥근해가 반짝 해 일! 요일 한자 이미지를 머릿속에 떠올리며 <노래하는 일주일>과 <룰루랄라 요일송>동료를 불렀어요.'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 6.0, // 자식 위젯 간의 가로 간격
                                        runSpacing: 6.0, // 줄바꿈 시 세로 간격
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '자원송',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '한글 놀이터',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '뜻을 알아요',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        color: Colors.transparent,
                        width: constraints.maxWidth * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '어휘활용 활동',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10)),
                              height: constraints.maxHeight * 0.7,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        '해가 뜨는 모습, 나무로 만든 의자를 떠올리면 생각나는 한자를 찾아 스티커붙이기, 색칠하기 활동을 했어요.'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 6.0, // 자식 위젯 간의 가로 간격
                                        runSpacing: 6.0, // 줄바꿈 시 세로 간격
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '자원송',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '한글 놀이터',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '뜻을 알아요',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: 16.0),
                      child: Container(
                        color: Colors.transparent,
                        width: constraints.maxWidth * 0.4,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 8.0),
                              child: Text(
                                '문장이해 활동',
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                  color: Colors.redAccent,
                                  borderRadius: BorderRadius.circular(10)),
                              height: constraints.maxHeight * 0.7,
                              width: double.infinity,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                        '둥근해가 반짝 해 일! 요일 한자 이미지를 머릿속에 떠올리며 <노래하는 일주일>과 <룰루랄라 요일송>동료를 불렀어요.'),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(bottom: 8.0),
                                      child: Wrap(
                                        alignment: WrapAlignment.start,
                                        spacing: 6.0, // 자식 위젯 간의 가로 간격
                                        runSpacing: 6.0, // 줄바꿈 시 세로 간격
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '자원송',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            decoration: BoxDecoration(
                                                color: mBackWhite,
                                                borderRadius:
                                                    BorderRadius.circular(50)),
                                            child: const Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 12.0,
                                                  vertical: 4.0),
                                              child: Text(
                                                '뜻을 알아요',
                                                style: TextStyle(
                                                  color: fontMain,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 5,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        left: leftPosition,
                        child: Container(
                          width: constraints.maxWidth * 0.5,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey,
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
