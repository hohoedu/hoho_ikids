import 'dart:io';

import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/hani/hani_Flip_data.dart';
import 'package:hani_booki/screens/hani/flip_card/flip_card_widgets/flip_sindong.dart';
import 'package:hani_booki/screens/hani/flip_card/flip_card_widgets/flip_soojae.dart';
import 'package:hani_booki/screens/hani/flip_card/flip_card_widgets/flip_default.dart';
import 'package:hani_booki/services/star_update_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';

class FlipCardScreen extends StatefulWidget {
  final String keyCode;

  const FlipCardScreen({super.key, required this.keyCode});

  @override
  State<FlipCardScreen> createState() => _FlipCardScreenState();
}

class _FlipCardScreenState extends State<FlipCardScreen> {
  final haniFlipDataController = Get.find<HaniFlipDataController>();
  final bgmController = Get.find<BgmController>();
  late GlobalKey<FlipCardState> _cardKey;
  late String _frontImage;
  late String _backImage;
  late AudioPlayer _audioPlayer;
  int _currentIndex = 0;
  final Set<int> flippedIndices = {};

  @override
  void initState() {
    super.initState();
    bgmController.playBgm('flip');
    _cardKey = GlobalKey<FlipCardState>();
    _audioPlayer = AudioPlayer();

    _frontImage = haniFlipDataController.haniFlipDataList[0].frontImagePath;
    _backImage = haniFlipDataController.haniFlipDataList[0].backImagePath;
  }

  void _updateSelectedCard(int index) {
    setState(() {
      _currentIndex = index;
      _frontImage = haniFlipDataController.haniFlipDataList[index].frontImagePath;
      _backImage = haniFlipDataController.haniFlipDataList[index].backImagePath;

      if (_cardKey.currentState != null && !_cardKey.currentState!.isFront) {
        _cardKey = GlobalKey<FlipCardState>();
      }
    });
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
      _currentIndex = 0;
      flippedIndices.clear();
      _cardKey = GlobalKey<FlipCardState>();
      _frontImage = haniFlipDataController.haniFlipDataList[0].frontImagePath;
      _backImage = haniFlipDataController.haniFlipDataList[0].backImagePath;
    });
  }

  void completeGame() async {
    await starUpdateService('card', widget.keyCode);
    Future.delayed(
      Duration(seconds: 1),
      () {
        lottieDialog(
          onReset: () {
            _resetGame();
            Get.back();
          },
          onMain: () {
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
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFE2FFEE),
      appBar: MainAppBar(
        title: ' ',
        isContent: true,
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: Container(
          width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.85 : double.infinity,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: widget.keyCode.substring(0, 1) == 'Y'
                  ? FlipDefault(
                      haniFlipDataList: haniFlipDataController.haniFlipDataList,
                      cardKey: _cardKey,
                      updateSelectedCard: _updateSelectedCard,
                      frontImage: _buildCardImage(_frontImage),
                      backImage: _buildCardImage(_backImage),
                      playSound: _playSound,
                      currentIndex: _currentIndex,
                      flippedIndices: flippedIndices,
                      completeGame: completeGame,
                    )
                  : widget.keyCode.substring(0, 1) == 'G'
                      ? FlipSindong(
                          haniFlipDataList: haniFlipDataController.haniFlipDataList,
                          cardKey: _cardKey,
                          updateSelectedCard: _updateSelectedCard,
                          frontImage: _buildCardImage(_frontImage),
                          backImage: _buildCardImage(_backImage),
                          playSound: _playSound,
                          currentIndex: _currentIndex,
                          flippedIndices: flippedIndices,
                          completeGame: completeGame,
                        )
                      : FlipSoojae(
                          haniFlipDataList: haniFlipDataController.haniFlipDataList,
                          cardKey: _cardKey,
                          updateSelectedCard: _updateSelectedCard,
                          frontImage: _buildCardImage(_frontImage),
                          backImage: _buildCardImage(_backImage),
                          playSound: _playSound,
                          currentIndex: _currentIndex,
                          flippedIndices: flippedIndices,
                          completeGame: completeGame,
                        )),
        ),
      ),
    );
  }

  Widget _buildCardImage(String imageUrl) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Image.network(
        imageUrl,
        fit: BoxFit.contain,
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
