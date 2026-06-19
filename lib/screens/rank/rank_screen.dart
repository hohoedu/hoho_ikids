import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/rank/rank_data.dart';
import 'package:hani_booki/main.dart';
import 'package:hani_booki/screens/rank/rank_widgets/rank_question.dart';
import 'package:hani_booki/services/rank/rank_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hive/hive.dart';
import 'package:logger/logger.dart';

class RankScreen extends StatefulWidget {
  final String hosu;

  const RankScreen({super.key, required this.hosu});

  @override
  State<RankScreen> createState() => _RankScreenState();
}

class _RankScreenState extends State<RankScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late int _selectedTab;
  bool _isLoading = false;

  final rankController = Get.find<RankDataController>();

  static const double podiumAspectRatio = 5;

  @override
  void initState() {
    super.initState();
    _selectedTab = int.tryParse(widget.hosu) ?? 1;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTabChanged(int hosu) async {
    setState(() {
      _selectedTab = hosu;
      _isLoading = true; // ✅ 로딩 시작
    });
    await rankService(hosu.toString().padLeft(2, '0'));
    setState(() => _isLoading = false); // ✅ 로딩 종료
  }

  String _getCharacterAsset(String rank, String characterNum) {
    final character = characterNum.startsWith('H') ? 'hani' : 'booki';
    return 'https://hohoeduimg.speedgabia.com/hohoeduapp/character/${rank}_$characterNum.png';
  }

  @override
  Widget build(BuildContext context) {
    final int currentHosu = int.tryParse(widget.hosu) ?? 1;
    // final int prevHosu = (currentHosu - 1).clamp(1, currentHosu);
    final int prevHosu = currentHosu == 1 ? 12 : currentHosu - 1;
    final userData = Get.find<UserDataController>();

    return Obx(() {
      final list = rankController.currentList;
      Logger().d(_isLoading);
      if (_isLoading)
        Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.45),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 12),
                  Text(
                    '랭킹 불러오는 중...',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12.w,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );

      if (list.isEmpty) {
        return Scaffold(
          backgroundColor: const Color(0xFF4F3C77),
          appBar: MainAppBar(
            isContent: false,
            title: screenWidth > 1000 ? '' : '${userData.userData!.schoolName} 호호스타 TOP3',
            titleStyle: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
          ),
          body: LayoutBuilder(
            builder: (context, constraints) {
              final double w = constraints.maxWidth;
              final double h = constraints.maxHeight;
              final double podiumWidth = w * 0.74;
              final double podiumHeight = podiumWidth / podiumAspectRatio;

              return Stack(
                children: [
                  // ── 스포트라이트
                  Positioned(
                    bottom: 0,
                    left: w * 0.13,
                    right: w * 0.13,
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) => Opacity(
                        opacity: _controller.value,
                        child: Image.asset(
                          'assets/images/rank/light.png',
                          width: w,
                          fit: BoxFit.fitWidth,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  // ── 단상
                  Positioned(
                    bottom: 0,
                    left: w * 0.13,
                    right: w * 0.13,
                    child: Image.asset('assets/images/rank/podium.png'),
                  ),

                  Positioned(
                    bottom: podiumHeight * 1.1,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.bar_chart_rounded, color: Colors.white.withOpacity(0.8), size: w * 0.06),
                        SizedBox(height: h * 0.015),
                        Text(
                          '랭킹을 집계중입니다.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: w * 0.03,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: h * 0.01),
                        SizedBox(height: h * 0.008),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Obx(
                            () => Text(
                              rankController.remainingTime.value,
                              style: TextStyle(
                                fontSize: w * 0.022,
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── 상단 타이틀
                  Positioned(
                    top: h * (screenWidth > 1000 ? 0.05 : 0),
                    left: 0,
                    right: 0,
                    height: h * 0.1,
                    child: Visibility(
                      visible: screenWidth > 1000,
                      child: Text(
                        textAlign: TextAlign.center,
                        '${userData.userData!.schoolName} 호호스타 TOP3',
                        style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Positioned(
                    top: h * (screenWidth > 1000 ? 0.15 : 0),
                    left: currentHosu == 3 ? (screenWidth > 1000 ? w * 0.4 : w * 0.42) : (screenWidth > 1000 ? w * 0.3 : w * 0.35),
                    right: currentHosu == 3 ? (screenWidth > 1000 ? w * 0.4 : w * 0.42) : (screenWidth > 1000 ? w * 0.3 : w * 0.35),
                    height: h * 0.1,
                    child: Container(
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                      padding: const EdgeInsets.all(4),
                      child: Stack(
                        children: [
                          AnimatedAlign(
                            duration: const Duration(milliseconds: 250),
                            curve: Curves.easeInOut,
                            alignment: _selectedTab == prevHosu ? Alignment.centerLeft : Alignment.centerRight,
                            child: FractionallySizedBox(
                              widthFactor: 0.5,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xff362265),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                              ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _onTabChanged(prevHosu),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      '$prevHosu월',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8.sp,
                                        color: _selectedTab == prevHosu ? Colors.white : const Color(0xffCFC9DC),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () => _onTabChanged(currentHosu),
                                  behavior: HitTestBehavior.opaque,
                                  child: Center(
                                    child: Text(
                                      '$currentHosu월',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 8.sp,
                                        color: _selectedTab == currentHosu ? Colors.white : const Color(0xffCFC9DC),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: h * 0.02,
                    right: w * 0.03,
                    width: w * 0.05,
                    child: RankQuestion(),
                  ),
                ],
              );
            },
          ),
        );
      }

      final myId = userData.userData!.id;

      final myRankItem = list.firstWhereOrNull((item) => item.id == myId);
      final isTopThree = myRankItem != null && myRankItem.rank <= 3;

      final first = rankController.getRepresentative(1, myId);
      final second = rankController.getRepresentative(2, myId);
      final third = rankController.getRepresentative(3, myId);

      final firstGroup = rankController.getGroup(1);
      final secondGroup = rankController.getGroup(2);
      final thirdGroup = rankController.getGroup(3);

      return Scaffold(
        backgroundColor: const Color(0xFF4F3C77),
        appBar: MainAppBar(
          isContent: false,
          title: screenWidth > 1000 ? '' : '${userData.userData!.schoolName} 호호스타 TOP3',
          titleStyle: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
        ),
        body: LayoutBuilder(
          builder: (context, constraints) {
            final double w = constraints.maxWidth;
            final double h = constraints.maxHeight;

            final double podiumWidth = w * 0.74;
            final double podiumHeight = podiumWidth / podiumAspectRatio;

            final double firstCharBottom = podiumHeight * 0.75;
            final double sideCharBottom = podiumHeight * 0.55;

            final double centerTextBottom = podiumHeight * 0.04;
            final double sideTextBottom = podiumHeight * 0.02;

            final double firstCharHeight = podiumHeight * 1.85;
            final double sideCharHeight = podiumHeight * 1.8;

            return Stack(
              children: [
                // ── 스포트라이트
                Positioned(
                  bottom: 0,
                  left: w * 0.13,
                  right: w * 0.13,
                  child: AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) => Opacity(
                      opacity: _controller.value,
                      child: Image.asset(
                        'assets/images/rank/light.png',
                        width: w,
                        fit: BoxFit.fitWidth,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),

                // ── 단상
                Positioned(
                  bottom: 0,
                  left: w * 0.13,
                  right: w * 0.13,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Image.asset('assets/images/rank/podium.png'),

                      // 1등 공동
                      if ((firstGroup?.length ?? 0) > 1)
                        Positioned(
                          bottom: podiumHeight * 0.5,
                          right: podiumWidth * 0.33,
                          child: _buildPlusButton(firstGroup!, w),
                        ),

                      // 2등 공동
                      if ((secondGroup?.length ?? 0) > 1)
                        Positioned(
                          bottom: podiumHeight * 0.3,
                          right: podiumWidth * 0.7,
                          child: _buildPlusButton(secondGroup!, w),
                        ),

                      // 3등 공동
                      if ((thirdGroup?.length ?? 0) > 1)
                        Positioned(
                          bottom: podiumHeight * 0.3,
                          right: podiumWidth * 0.01,
                          child: _buildPlusButton(thirdGroup!, w),
                        ),
                    ],
                  ),
                ),

                // ── 1등 캐릭터
                if (first != null)
                  Positioned(
                    bottom: firstCharBottom,
                    left: w * 0.32,
                    right: w * 0.32,
                    child: Image.network(
                      _getCharacterAsset('first', first.characterNum),
                      height: firstCharHeight,
                    ),
                  ),

                // ── 1등 텍스트
                if (first != null)
                  Positioned(
                    bottom: centerTextBottom,
                    left: w * 0.3,
                    right: w * 0.3,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          first.kinderClass,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.018, color: const Color(0xFF5E4610)),
                        ),
                        Text(
                          first.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.031, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          decoration: BoxDecoration(color: const Color(0xFF5E4610), borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            '${first.point} 점',
                            style: TextStyle(fontSize: w * 0.016, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── 2등 캐릭터
                if (second != null)
                  Positioned(
                    bottom: sideCharBottom,
                    left: w * 0.1,
                    right: w * 0.6,
                    child: Image.network(
                      _getCharacterAsset('second', second.characterNum),
                      height: sideCharHeight,
                    ),
                  ),

                // ── 2등 텍스트
                if (second != null)
                  Positioned(
                    bottom: sideTextBottom,
                    left: w * 0.1,
                    right: w * 0.6,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          second.kinderClass,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.015, color: const Color(0xFF0D4842), height: 0.8),
                        ),
                        Text(
                          second.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.026, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF0D4842), borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            '${second.point} 점',
                            style: TextStyle(fontSize: w * 0.016, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── 3등 캐릭터

                if (third != null)
                  Positioned(
                    bottom: sideCharBottom,
                    left: w * 0.6,
                    right: w * 0.1,
                    child: Image.network(
                      _getCharacterAsset('third', third.characterNum),
                      height: sideCharHeight,
                    ),
                  ),

                // ── 3등 텍스트
                if (third != null)
                  Positioned(
                    bottom: sideTextBottom,
                    left: w * 0.6,
                    right: w * 0.1,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          third.kinderClass,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.015, color: const Color(0xFF4A2F1C), height: 0.8),
                        ),
                        Text(
                          third.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: w * 0.026, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                          decoration: BoxDecoration(color: const Color(0xFF4A2F1C), borderRadius: BorderRadius.circular(15)),
                          child: Text(
                            '${third.point} 점',
                            style: TextStyle(fontSize: w * 0.016, color: Colors.white, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── 상단 타이틀
                Positioned(
                  top: h * (screenWidth > 1000 ? 0.05 : 0),
                  left: 0,
                  right: 0,
                  height: h * 0.1,
                  child: Visibility(
                    visible: screenWidth > 1000,
                    child: Text(
                      textAlign: TextAlign.center,
                      '${userData.userData!.schoolName} 호호스타 TOP3',
                      style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // ── 탭 바
                Positioned(
                  top: h * (screenWidth > 1000 ? 0.15 : 0),
                  left: currentHosu == 3 ? (screenWidth > 1000 ? w * 0.4 : w * 0.42) : (screenWidth > 1000 ? w * 0.3 : w * 0.35),
                  right: currentHosu == 3 ? (screenWidth > 1000 ? w * 0.4 : w * 0.42) : (screenWidth > 1000 ? w * 0.3 : w * 0.35),
                  height: h * 0.1,
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50)),
                    padding: const EdgeInsets.all(4),
                    child: currentHosu == 3
                        ? Container(
                            decoration: BoxDecoration(
                              color: const Color(0xff362265),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Center(
                              child: Text(
                                '3월',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 8.sp,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          )
                        : Stack(
                            children: [
                              AnimatedAlign(
                                duration: const Duration(milliseconds: 250),
                                curve: Curves.easeInOut,
                                alignment: _selectedTab == prevHosu ? Alignment.centerLeft : Alignment.centerRight,
                                child: FractionallySizedBox(
                                  widthFactor: 0.5,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: const Color(0xff362265),
                                      borderRadius: BorderRadius.circular(50),
                                    ),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _onTabChanged(prevHosu),
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: Text(
                                          '$prevHosu월',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8.sp,
                                            color: _selectedTab == prevHosu ? Colors.white : const Color(0xffCFC9DC),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () => _onTabChanged(currentHosu),
                                      behavior: HitTestBehavior.opaque,
                                      child: Center(
                                        child: Text(
                                          '$currentHosu월',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 8.sp,
                                            color: _selectedTab == currentHosu ? Colors.white : const Color(0xffCFC9DC),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                  ),
                ),
                // ── 물음표
                Positioned(
                  bottom: h * 0.02,
                  right: w * 0.03,
                  width: w * 0.05,
                  child: RankQuestion(),
                ),
                // if (myRankItem != null)
                //   Positioned(
                //     top: screenWidth > 1000 ? MediaQuery.of(context).size.height * 0.1 : 0,
                //     // top: 0,
                //     right: 0,
                //     child: SizedBox(
                //       width: MediaQuery.of(context).size.width * 0.25,
                //       height: screenWidth > 1000 ? MediaQuery.of(context).size.height * 0.15 : MediaQuery.of(context).size.height * 0.2,
                //       child: Container(
                //         padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                //         decoration: BoxDecoration(
                //           color: Colors.white,
                //           borderRadius: BorderRadius.only(bottomLeft: Radius.circular(50), topLeft: Radius.circular(50)),
                //           boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 6)],
                //         ),
                //         child: Center(
                //           child: Row(
                //             mainAxisAlignment: MainAxisAlignment.center,
                //             children: [
                //               Image.asset('assets/images/star.png'),
                //               Text(
                //                 ' ${myRankItem.point}점',
                //                 style: TextStyle(
                //                   fontSize: w * 0.04,
                //                   fontWeight: FontWeight.bold,
                //                   color: const Color(0xFF4F3C77),
                //                 ),
                //               ),
                //             ],
                //           ),
                //         ),
                //       ),
                //     ),
                //   ),
                if (myRankItem != null)
                  Positioned(
                      top: 0,
                      bottom: kToolbarHeight,
                      right: 16,
                      child: Center(
                        child: Container(
                          width: screenWidth >= 1000 ? constraints.maxWidth * 0.085 : constraints.maxWidth * 0.1,
                          height: screenWidth >= 1000 ? constraints.maxHeight * 0.2 : constraints.maxHeight * 0.35,
                          decoration: BoxDecoration(
                            color: Color(0xFFFFDE00),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(100), color: Color(0xFFFFF3A3)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/images/star.png',
                                      scale: 2,
                                    ),
                                  ),
                                ),
                              ),
                              Text(
                                '${myRankItem.point}',
                                style: const TextStyle(color: Color(0xFF4E3A16), fontSize: 20, fontWeight: FontWeight.bold, fontFamily: 'BMJUA'),
                                softWrap: false,
                              ),
                            ],
                          ),
                        ),
                      ))
              ],
            );
          },
        ),
      );
    });
  }

  Widget _buildPlusButton(List<RankItem> group, double w) {
    return GestureDetector(
      onTap: () {
        Get.defaultDialog(
          backgroundColor: mBackWhite,
          title: '공동 ${group.first.rank}등 (${group.first.point}점)',
          middleText: group.map((e) => '${e.kinderClass} ${e.name}').join('\n'),
          textConfirm: '확인',
          buttonColor: Colors.black,
          barrierDismissible: false,
          onConfirm: Get.back,
        );
      },
      child: Container(
        width: w * 0.03,
        height: w * 0.03,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
        ),
        child: Icon(Icons.add, size: w * 0.02, color: const Color(0xFF4F3C77)),
      ),
    );
  }
}
