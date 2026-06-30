import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_home_data.dart';
import 'package:hani_booki/widgets/cooltime_icon.dart';

class HaniContents extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String lastTime;
  final String type;

  const HaniContents({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.lastTime,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HaniHomeDataController>(
      builder: (controller) {
        final cooltime = controller.isCooltime(lastTime, type);
        final remaining = controller.remainingTime(lastTime);

        return Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Stack(
                children: [
                  Image.network(imagePath, fit: BoxFit.contain),
                  if (cooltime)
                    Positioned(
                      right: 0,
                      child: CooltimeIcon(lastTime: lastTime),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
