import 'dart:io';

import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/hani/hani_rotate_data.dart';
import 'package:hani_booki/screens/hani/rotate/rotate_widgets/rotate_images.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class RotateScreen extends StatefulWidget {
  final String keyCode;

  const RotateScreen({super.key, required this.keyCode});

  @override
  State<RotateScreen> createState() => _RotateScreenState();
}

class _RotateScreenState extends State<RotateScreen> {
  final bgmController = Get.find<BgmController>();
  late AudioPlayer _audioPlayer;

  final CarouselSliderController carouselController = CarouselSliderController();
  final rotateData = Get.put(HaniRotateDataController());
  int currentIndex = 0;
  late List<dynamic> randomCards = [];

  late Key _rotateKey;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    bgmController.playBgm('flip');
    _audioPlayer = AudioPlayer();

    _initGame();
  }

  void _initGame() {
    final allData = rotateData.rotateDataList;
    randomCards = (List.of(allData)..shuffle()).sublist(0, 8);
    currentIndex = 0;
    _rotateKey = UniqueKey();
  }

  Future<void> _playSound(String url) async {
    try {
      await _audioPlayer.setUrl(url);
      _audioPlayer.play();
    } catch (e) {
      Logger().e("Error playing sound: $e");
    }
  }

  void _resetGame() {
    setState(() {
      _initGame();
    });
  }

  void completeGame() async {
    await starUpdateService('card', widget.keyCode);
    Future.delayed(
      Duration(seconds: 1),
      () {
        verticalLottieDialog(
          onReset: () {
            _resetGame();
            Get.back();
          },
          onMain: () async {
            if (Platform.isIOS) {
              await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeRight]);
            } else {
              await SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft]);
            }
            Get.back();
            Get.back();
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FFF1),
      extendBodyBehindAppBar: false,
      appBar: MainAppBar(
        isContent: true,
        isPortraitMode: true,
        title: Platform.isIOS ? '카드를 뒤집어\n한자를 맞혀보세요' : '',
        titleStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        onTapBackIcon: () => verticalBackDialog(true),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            Platform.isIOS
                ? Spacer()
                : Expanded(
                    child: Text(
                    '카드를 뒤집어\n한자를 맞혀보세요.',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  )),
            Expanded(
              flex: 8,
              child: RotateImages(
                key: _rotateKey,
                items: randomCards,
                carouselController: carouselController,
                onFirstTap: (index) {
                  _playSound(randomCards[index].sound);
                },
                onComplete: () {
                  Future.delayed(
                    Duration(milliseconds: 500),
                    () => completeGame(),
                  );
                },
                onPageChanged: (index) {
                  setState(() {
                    currentIndex = index;
                  });
                },
              ),
            ),
            Expanded(
              flex: 2,
              child: Center(
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${currentIndex + 1}',
                        style: TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: ' / ${randomCards.length}',
                        style: TextStyle(color: fontMain, fontSize: 26, fontWeight: FontWeight.bold),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    if (Platform.isIOS) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
      ]);
    }
    _audioPlayer.dispose();
    super.dispose();
  }
}
