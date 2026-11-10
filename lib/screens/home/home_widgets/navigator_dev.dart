import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/booki/basket/basket_screen.dart';
import 'package:hani_booki/screens/booki/proviso/proviso_screen.dart';
import 'package:hani_booki/screens/booki/sentence/sentence_screen.dart';
import 'package:hani_booki/screens/booki/story_board/story_board_screen.dart';
import 'package:hani_booki/screens/hani/cooking/cooking_screen.dart';
import 'package:hani_booki/screens/hani/hani_pang/hani_pang_screen.dart';
import 'package:hani_booki/screens/hani/hari_run/hani_run_screen.dart';
import 'package:hani_booki/screens/hani/relics/relics_screen.dart';

class NavigatorDev extends StatelessWidget {
  const NavigatorDev({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => RelicsScreen());
                    },
                    child: Container(
                      color: Colors.redAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => CookingScreen());
                    },
                    child: Container(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => HaniPangScreen());
                    },
                    child: Container(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => HaniRunScreen());
                    },
                    child: Container(
                      color: Colors.yellowAccent,
                    ),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => StoryBoardScreen());
                    },
                    child: Container(
                      color: Colors.yellowAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => SentenceScreen());
                    },
                    child: Container(
                      color: Colors.blueAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => ProvisoScreen());
                    },
                    child: Container(
                      color: Colors.greenAccent,
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.to(() => BasketScreen());
                    },
                    child: Container(
                      color: Colors.redAccent,
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
