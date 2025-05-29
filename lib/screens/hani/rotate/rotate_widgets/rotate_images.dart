import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_rotate_data.dart';

class RotateImages extends StatefulWidget {
  final List<dynamic> items;
  final CarouselSliderController carouselController;
  final Function(int) onPageChanged;
  final Function(int) onFirstTap;
  final VoidCallback onComplete;

  const RotateImages({
    super.key,
    required this.items,
    required this.carouselController,
    required this.onPageChanged,
    required this.onFirstTap,
    required this.onComplete,
  });

  @override
  State<RotateImages> createState() => _RotateImagesState();
}

class _RotateImagesState extends State<RotateImages> {
  // final rotateData = Get.find<HaniRotateDataController>();
  final rotateData = Get.put(HaniRotateDataController());
  late List<bool> isFlippedList;
  late List<String> imgList;
  late List<GlobalKey<FlipCardState>> cardKeys = [];

  @override
  void initState() {
    super.initState();
    cardKeys = List.generate(rotateData.rotateDataList.length, (index) => GlobalKey<FlipCardState>());
    isFlippedList = List<bool>.filled(rotateData.rotateDataList.length, false);
    imgList = List<String>.generate(rotateData.rotateDataList.length, (index) {
      return 'https://sunandtree2.cafe24.com/app/memorize/80/img/8000${index + 1}_b.png';
    });
    cardKeys = List.generate(widget.items.length, (_) => GlobalKey<FlipCardState>());
    isFlippedList = List<bool>.filled(widget.items.length, false);
  }

  @override
  Widget build(BuildContext context) {
    return CarouselSlider(
      carouselController: widget.carouselController,
      options: CarouselOptions(
        height: double.infinity,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        onPageChanged: (index, reason) {
          setState(() {
            widget.onPageChanged(index);
          });
        },
        viewportFraction: 0.65.sp,
      ),
      items: List.generate(widget.items.length, (index) {
        return Builder(
          builder: (BuildContext context) {
            return Padding(
              padding: EdgeInsets.all(8.0.sp),
              child: FlipCard(
                key: cardKeys[index],
                flipOnTouch: false, // 자동으로 뒤집히지 않도록 설정
                front: GestureDetector(
                  onTap: () {
                    widget.onFirstTap(index);
                    cardKeys[index].currentState?.toggleCard();

                    if (!isFlippedList[index]) {
                      setState(() => isFlippedList[index] = true);
                      if (isFlippedList.every((flipped) => flipped)) {
                        widget.onComplete();
                      }
                    }
                  },
                  child: preImage(index),
                ),
                back: GestureDetector(
                  onTap: () {
                    cardKeys[index].currentState?.toggleCard();
                  },
                  child: sufImage(index),
                ),
              ),
            );
          },
        );
      }).toList(),
    );
  }

  // 이미지의 앞면
  Widget preImage(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          widget.items[index].frontImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  // 이미지의 뒷면
  Widget sufImage(int index) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          widget.items[index].backImage,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
