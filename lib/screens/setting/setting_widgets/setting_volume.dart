import 'package:flutter/material.dart';
import 'package:flutter_volume_controller/flutter_volume_controller.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/utils/sound_manager.dart';
import 'package:hive/hive.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';

class SettingVolume extends StatefulWidget {
  const SettingVolume({super.key});

  @override
  State<SettingVolume> createState() => _SettingVolumeState();
}

class _SettingVolumeState extends State<SettingVolume> {
  late AudioPlayer _effectPlayer;

  double _bgmValue = 10.0;
  double _effectValue = 10.0;
  double _systemVolume = 0.0;

  late Box settingBox;

  @override
  void initState() {
    super.initState();
    _effectPlayer = AudioPlayer();
    settingBox = Hive.box('settings');

    _loadVolumeSettings();
    _getSystemVolume();
  }

  Future<void> _getSystemVolume() async {
    double? volume = await FlutterVolumeController.getVolume();
    setState(() {
      _systemVolume = volume ?? 1.0;
    });
  }

  Future<void> _setSystemVolume(double value) async {
    await FlutterVolumeController.setVolume(value);
    setState(() {
      _systemVolume = value;
    });
  }

  Future<void> _loadVolumeSettings() async {
    setState(() {
      _bgmValue = settingBox.get('bgmVolume', defaultValue: 10.0);
      _effectValue = settingBox.get('effectVolume', defaultValue: 10.0);
    });
    _applyVolumeSettings();
  }

  Future<void> _saveVolumeSettings() async {
    settingBox.put('bgmVolume', _bgmValue);
    settingBox.put('effectVolume', _effectValue);
  }

  void _applyVolumeSettings() {
    double bgmNormalized = _bgmValue / 10;
    double effectNormalized = _effectValue / 10;

    _effectPlayer.setVolume(effectNormalized);
    SoundManager.setEffectVolume(effectNormalized);
    Get.find<BgmController>().setBgmVolume(bgmNormalized);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  alignment: Alignment.center,
                  child: Text(
                    '사운드 설정',
                    style: TextStyle(color: fontSub, fontSize: 20),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildSlider(
                      '시스템',
                      _systemVolume * 10,
                      (value) {
                        _setSystemVolume(value / 10);
                      },
                    ),
                    _buildSlider(
                      '배경음',
                      _bgmValue,
                      (value) {
                        setState(() {
                          _bgmValue = value;
                        });
                        _applyVolumeSettings();
                        _saveVolumeSettings();
                      },
                    ),
                    _buildSlider(
                      '효과음',
                      _effectValue,
                      (value) {
                        setState(() {
                          _effectValue = value;
                        });
                        _applyVolumeSettings();
                        _saveVolumeSettings();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, double value, ValueChanged<double> onChanged) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            label,
            style: TextStyle(color: fontSub, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            trackHeight: 6.0,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10.0),
          ),
          child: Slider(
            value: value,
            min: 0.0,
            max: 10.0,
            inactiveColor: const Color(0xFFEAE8E4),
            activeColor: const Color(0xFFFFBA00),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _effectPlayer.dispose();
    super.dispose();
  }
}
