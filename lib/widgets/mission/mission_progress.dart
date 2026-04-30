import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MissionProgress extends StatefulWidget {
  final int totalCount;
  final int completedCount;
  final String completedAsset;
  final bool isCleared;

  const MissionProgress({
    super.key,
    required this.totalCount,
    required this.completedCount,
    required this.completedAsset,
    this.isCleared = false,
  });

  @override
  State<MissionProgress> createState() => _MissionProgressState();
}

class _MissionProgressState extends State<MissionProgress> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnim;
  late Animation<double> _opacityAnim;
  late Animation<double> _rotationAnim;

  int _animatingIndex = -1;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _scaleAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 1.7, end: 0.85).chain(CurveTween(curve: Curves.easeIn)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.85, end: 1.05).chain(CurveTween(curve: Curves.easeOut)),
        weight: 25,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.05, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 15,
      ),
    ]).animate(_controller);

    _opacityAnim = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    _rotationAnim = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: -0.08, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 0.0),
        weight: 40,
      ),
    ]).animate(_controller);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!widget.isCleared) {
        _stampSequentially(0);
      }
    });
  }

  Future<void> _stampSequentially(int index) async {
    if (!mounted) return;
    if (index >= widget.completedCount) return;

    setState(() => _animatingIndex = index);
    HapticFeedback.mediumImpact();

    _controller.reset();
    await _controller.forward();

    if (!mounted) return;

    await Future.delayed(const Duration(milliseconds: 180));
    _stampSequentially(index + 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageSize = constraints.maxWidth / 5;
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.totalCount, (i) {
            if (widget.isCleared) {
              return Image.asset(
                widget.completedAsset,
                height: imageSize,
                width: imageSize,
              );
            }

            final isDone = i < widget.completedCount;
            final isAnimating = i == _animatingIndex;
            final isRevealedDone = isDone && i < _animatingIndex;

            if (isAnimating) {
              return AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnim.value,
                    child: Opacity(
                      opacity: _opacityAnim.value,
                      child: Transform.scale(
                        scale: _scaleAnim.value,
                        child: child,
                      ),
                    ),
                  );
                },
                child: Image.asset(
                  widget.completedAsset,
                  height: imageSize,
                  width: imageSize,
                ),
              );
            }

            if (isRevealedDone) {
              return Image.asset(
                widget.completedAsset,
                height: imageSize,
                width: imageSize,
              );
            }

            return Image.asset(
              'assets/images/mission/lock_gray.png',
              height: imageSize,
              width: imageSize,
            );
          }),
        );
      },
    );
  }
}
