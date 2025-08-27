import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import 'package:hani_booki/screens/hani/flip_card/flip_card_widgets/flip_index_card.dart';

class FlipSindong extends StatefulWidget {
  final List<dynamic> haniFlipDataList;
  final GlobalKey<FlipCardState> cardKey;
  final Function(int) updateSelectedCard;
  final Widget frontImage;
  final Widget backImage;
  final Future<void> Function(String) playSound;
  final int currentIndex;
  final Set<int> flippedIndices;
  final VoidCallback completeGame;

  const FlipSindong({
    super.key,
    required this.haniFlipDataList,
    required this.cardKey,
    required this.updateSelectedCard,
    required this.frontImage,
    required this.backImage,
    required this.playSound,
    required this.currentIndex,
    required this.flippedIndices,
    required this.completeGame,
  });

  @override
  State<FlipSindong> createState() => _FlipSoojaeState();
}

class _FlipSoojaeState extends State<FlipSindong> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isInitialAnimationDone = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    _animation = Tween<double>(begin: 0, end: pi / 10).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _startCardWobble();
  }

  void _startCardWobble() async {
    await Future.delayed(Duration(milliseconds: 500));

    for (int i = 0; i < 2; i++) {
      await _controller.forward();
      await Future.delayed(Duration(milliseconds: 100));
      await _controller.reverse();
      await Future.delayed(Duration(milliseconds: 100));
    }

    setState(() {
      _isInitialAnimationDone = true;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    if (!_isInitialAnimationDone)
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform(
                            alignment: Alignment.center,
                            transform: Matrix4.identity()
                              ..setEntry(3, 2, 0.001)
                              ..rotateY(_animation.value),
                            child: widget.frontImage,
                          );
                        },
                      ),
                    if (_isInitialAnimationDone)
                      FlipCard(
                        key: widget.cardKey,
                        flipOnTouch: true,
                        front: widget.frontImage,
                        back: widget.backImage,
                        onFlip: () async {
                          if (widget.cardKey.currentState != null && widget.cardKey.currentState!.isFront) {
                            final soundUrl = widget.haniFlipDataList[widget.currentIndex].frontVoicePath;
                            await widget.playSound(soundUrl);
                            if (!widget.flippedIndices.contains(widget.currentIndex)) {
                              widget.flippedIndices.add(widget.currentIndex);
                              if (widget.flippedIndices.length == 6) {
                                widget.completeGame();
                              }
                            }
                          }else{
                            final soundUrl = widget.haniFlipDataList[widget.currentIndex].backVoicePath;
                            await widget.playSound(soundUrl);
                          }
                        },
                      ),
                  ],
                );
              },
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlipIndexCard(
                            imageUrl: widget.haniFlipDataList[index].frontImagePath,
                            index: index,
                            onTap: (index, imageUrl) async {
                              final soundUrl = widget.haniFlipDataList[index].backVoicePath;
                              await widget.playSound(soundUrl);
                              widget.updateSelectedCard(index);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    children: List.generate(
                      3,
                      (index) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: FlipIndexCard(
                            imageUrl: widget.haniFlipDataList[index + 3].frontImagePath,
                            index: index + 3,
                            onTap: (index, imageUrl) async {
                              final soundUrl = widget.haniFlipDataList[index].backVoicePath;
                              await widget.playSound(soundUrl);
                              widget.updateSelectedCard(index);
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
