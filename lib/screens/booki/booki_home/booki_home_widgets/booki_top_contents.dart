import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/utils/cooltime_dialog_content.dart';
import 'package:hani_booki/utils/cooltime_utils.dart';
import 'package:hani_booki/widgets/cooltime_icon.dart';

class BookiTopContents extends StatelessWidget {
  final String imagePath;
  final VoidCallback onTap;
  final String lastTime;
  final String type;

  const BookiTopContents({
    super.key,
    required this.imagePath,
    required this.onTap,
    required this.lastTime,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookiHomeDataController>(
      builder: (controller) {
        final cooltime = controller.isCooltime(lastTime, type);
        final remaining = controller.remainingTime(lastTime);

        final blocked = cooltime && videoBlockedCooltimeTypes.contains(type);

        return Expanded(
          child: GestureDetector(
            onTap: blocked ? () => showCooltimeBlockDialog(lastTime) : onTap,
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