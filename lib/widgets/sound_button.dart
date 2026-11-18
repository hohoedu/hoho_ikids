import 'package:flutter/material.dart';
import 'package:hani_booki/utils/sound_manager.dart';

/// 누르면 [voice] 음성을 읽어 주는 스피커 아이콘
class SoundButton extends StatelessWidget {
  const SoundButton({super.key, required this.voice, required this.size});

  final String voice;
  final double size;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => SoundManager.playVoice(voice),
      child: Image.asset('assets/images/icons/sound.png', width: size, height: size),
    );
  }
}
