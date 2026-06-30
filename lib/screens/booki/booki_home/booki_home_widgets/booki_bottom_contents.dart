import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/booki/booki_home_data.dart';
import 'package:hani_booki/widgets/cooltime_icon.dart';

class BookiBottomContents extends StatelessWidget {
  final String imagePath;
  final Color color;
  final VoidCallback onTap;
  final String lastTime;
  final String type;

  const BookiBottomContents({
    super.key,
    required this.imagePath,
    required this.color,
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

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Stack(
              children: [
                GestureDetector(
                  onTap: onTap,
                  child: Align(
                    alignment: FractionalOffset(0.5, 2 / 3),
                    child: Image.network(imagePath, fit: BoxFit.contain),
                  ),
                ),
                if (cooltime)
                  Positioned(
                    right: 0,
                    child: CooltimeIcon(lastTime: lastTime),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
