import 'package:carousel_slider/carousel_slider.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_rotate_data.dart';
import 'package:hani_booki/main.dart';
import 'package:logger/logger.dart';

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

  void _onFrontTap(int index) {
    widget.onFirstTap(index);
    cardKeys[index].currentState?.toggleCard();

    if (!isFlippedList[index]) {
      setState(() => isFlippedList[index] = true);
      if (isFlippedList.every((flipped) => flipped)) {
        widget.onComplete();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenH = MediaQuery.of(context).size.height;
    return CarouselSlider.builder(
      itemCount: widget.items.length,
      carouselController: widget.carouselController,
      itemBuilder: (context, index, realIndex) {
        return _KeepAliveCard(
          key: ValueKey(index),
          cardKey: cardKeys[index],
          front: preImage(index),
          back: sufImage(index),
          onFrontTap: () => _onFrontTap(index),
        );
      },
      options: CarouselOptions(
        height: screenH,
        enlargeCenterPage: true,
        enableInfiniteScroll: false,
        viewportFraction: 0.82,
        onPageChanged: (index, reason) {
          widget.onPageChanged(index);
        },
      ),
    );
  }

  // 이미지의 앞면
  Widget preImage(int index) {
    final data = widget.items[index];
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Image.network(
          data.frontImage,
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

class _KeepAliveCard extends StatefulWidget {
  final GlobalKey<FlipCardState> cardKey;
  final Widget front, back;
  final VoidCallback onFrontTap;

  const _KeepAliveCard({
    required Key key,
    required this.cardKey,
    required this.front,
    required this.back,
    required this.onFrontTap,
  }) : super(key: key);

  @override
  __KeepAliveCardState createState() => __KeepAliveCardState();
}

class __KeepAliveCardState extends State<_KeepAliveCard> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return FlipCard(
      key: widget.cardKey,
      flipOnTouch: false,
      front: GestureDetector(
        onTap: widget.onFrontTap,
        child: widget.front,
      ),
      back: GestureDetector(
        onTap: () => widget.cardKey.currentState?.toggleCard(),
        child: widget.back,
      ),
    );
  }
}
