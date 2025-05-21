import 'package:carousel_slider/carousel_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/_data/hani/hani_rotate_data.dart';
import 'package:hani_booki/screens/hani/rotate/rotate_widgets/rotate_images.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class RotateScreen extends StatefulWidget {
  final String keyCode;

  const RotateScreen({super.key, required this.keyCode});

  @override
  State<RotateScreen> createState() => _RotateScreenState();
}

class _RotateScreenState extends State<RotateScreen> {
  final CarouselSliderController carouselController = CarouselSliderController();
  final rotateData = Get.put(HaniRotateDataController());
  int currentIndex = 0;

  List<String> imgList = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF9FFF1),
      extendBodyBehindAppBar: false,
      appBar: MainAppBar(
        isContent: true,
        isPortraitMode: true,
        title: '카드를 뒤집어\n한자를 맞혀보세요',
        titleStyle: TextStyle(
          fontSize: 22,
        ),
        onTapBackIcon: () => verticalBackDialog(true),
      ),
      body: Padding(
        padding: EdgeInsets.only(bottom: 32),
        child: Column(
          children: [
            Spacer(),
            Expanded(
              flex: 8,
              child: RotateImages(
                carouselController: carouselController,
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
                        text: '1',
                        style: TextStyle(color: Colors.green, fontSize: 26, fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: '/${rotateData.rotateDataList.length}',
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
}
