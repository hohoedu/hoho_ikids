// 이미지의 앞면
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
  late List<bool> isFlippedList;
  late List<GlobalKey<FlipCardState>> cardKeys = [];

  @override
  void initState() {
    super.initState();
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
          widget.onPageChanged(index);
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
                flipOnTouch: false,
                // isFlippedList[index] 가 true 면 뒤집힌(back) 채로 시작
                side: isFlippedList[index] ? CardSide.BACK : CardSide.FRONT,
                // flip 완료 시 호출 → isFlippedList 업데이트
                onFlipDone: (isFront) {
                  setState(() {
                    isFlippedList[index] = !isFront;
                    if (isFlippedList.every((v) => v)) widget.onComplete();
                  });
                },
                front: GestureDetector(
                  onTap: () {
                    widget.onFirstTap(index);
                    cardKeys[index].currentState?.toggleCard();
                  },
                  child: preImage(index),
                ),
                back: GestureDetector(
                  onTap: () => cardKeys[index].currentState?.toggleCard(),
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
