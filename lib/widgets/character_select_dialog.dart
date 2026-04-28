import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

Future<String?> showCharacterSelectDialog(BuildContext context, {String? initialCharacter}) {
  return showDialog<String>(
    context: context,
    builder: (context) => _CharacterSelectDialog(initialCharacter: initialCharacter),
  );
}

class _CharacterSelectDialog extends StatefulWidget {
  final String? initialCharacter;

  const _CharacterSelectDialog({this.initialCharacter});

  @override
  State<_CharacterSelectDialog> createState() => _CharacterSelectDialogState();
}

class _CharacterSelectDialogState extends State<_CharacterSelectDialog> with SingleTickerProviderStateMixin {
  String? _selectedValue;
  int _startIndex = 0;
  double _dragStart = 0;
  late AnimationController _animController;
  late Animation<double> _slideAnim;
  double _slideFrom = 0;

  static const int _visibleCount = 4;

  // peek으로 보여줄 비율 (0.45 = 다음 아이템의 45%가 보임)
  static const double _peekFraction = 0.45;

  final List<Map<String, String>> _characters = [
    {'id': 'H1', 'imageName': 'H1', 'label': '하니'},
    {'id': 'B1', 'imageName': 'B1', 'label': '부키'},
    {'id': 'T1', 'imageName': 'T1', 'label': '어흥이'},
    {'id': 'R1', 'imageName': 'R1', 'label': '토닥이'},
    {'id': 'U1', 'imageName': 'U1', 'label': '곰곰이'},
    {'id': 'S1', 'imageName': 'S1', 'label': '다람이'},
  ];

  bool get _canGoPrev => _startIndex > 0;

  bool get _canGoNext => _startIndex + _visibleCount < _characters.length;

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.initialCharacter;
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );
    _slideAnim = Tween<double>(begin: 0, end: 0).animate(_animController);
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _slide(int direction) {
    _slideFrom = direction * 1.0;
    _slideAnim = Tween<double>(begin: _slideFrom, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0);
  }

  void _prev() {
    if (_canGoPrev) {
      setState(() => _startIndex--);
      _slide(-1);
    }
  }

  void _next() {
    if (_canGoNext) {
      setState(() => _startIndex++);
      _slide(1);
    }
  }

  @override
  Widget build(BuildContext context) {
    final visible = _characters.sublist(
      _startIndex,
      (_startIndex + _visibleCount).clamp(0, _characters.length),
    );

    final double screenW = MediaQuery.of(context).size.width;
    final double dialogW = screenW * 0.8 - 48;
    const double arrowW = 28.0;
    final double contentW = dialogW - arrowW * 2;

    final double peekSidesCount = (_canGoPrev ? 1.0 : 0.0) + (_canGoNext ? 1.0 : 0.0);
    final double itemW = contentW / (_visibleCount + _peekFraction * peekSidesCount.clamp(1, 2));
    final double peekW = itemW * _peekFraction;

    final double fixedItemW = contentW / (_visibleCount + _peekFraction * 2);
    final double imageSize = fixedItemW;

    final displayItems = <Map<String, String>>[
      if (_canGoPrev) _characters[_startIndex - 1],
      ...visible,
      if (_canGoNext && _startIndex + _visibleCount < _characters.length) _characters[_startIndex + _visibleCount],
    ];

    return AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titlePadding: const EdgeInsets.only(top: 28, bottom: 8),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      actionsPadding: const EdgeInsets.only(bottom: 24),
      title: const Center(
        child: Text(
          '캐릭터 선택',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      content: SizedBox(
        width: dialogW,
        height: MediaQuery.of(context).size.height * 0.5,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) => _dragStart = d.globalPosition.dx,
          onHorizontalDragEnd: (d) {
            final diff = d.globalPosition.dx - _dragStart;
            if (diff < -30) _next();
            if (diff > 30) _prev();
          },
          child: Row(
            children: [
              SizedBox(
                width: arrowW,
                child: _canGoPrev
                    ? GestureDetector(
                        onTap: _prev,
                        child: const Icon(Icons.chevron_left_rounded, size: 28, color: Color(0xFF574AB0)),
                      )
                    : const SizedBox(),
              ),

              Expanded(
                child: ClipRect(
                  child: Stack(
                    children: [
                      AnimatedBuilder(
                        animation: _slideAnim,
                        builder: (context, child) {
                          return FractionalTranslation(
                            translation: Offset(_slideAnim.value * 0.15, 0),
                            child: Opacity(
                              opacity: (1 - _slideAnim.value.abs() * 0.5).clamp(0.0, 1.0),
                              child: child,
                            ),
                          );
                        },
                        child: OverflowBox(
                          maxWidth: double.infinity,
                          alignment: AlignmentGeometry.centerLeft,
                          child: Transform.translate(
                            offset: Offset(_canGoPrev ? -peekW : 0, 0),
                            child: Row(
                              children: displayItems.asMap().entries.map((entry) {
                                final i = entry.key;
                                final c = entry.value;
                                final isPeekItem = (_canGoPrev && i == 0) || (_canGoNext && i == displayItems.length - 1);

                                return SizedBox(
                                  width: itemW,
                                  child: Opacity(
                                    opacity: isPeekItem ? 0.45 : 1.0,
                                    child: _CharacterItem(
                                      imagePath: 'assets/images/rank/${c['imageName']}.png',
                                      value: c['id']!,
                                      label: c['label']!,
                                      imageSize: imageSize,
                                      isSelected: _selectedValue == c['id'],
                                      onTap: isPeekItem
                                          ? (_) {
                                              if (_canGoPrev && i == 0) _prev();
                                              if (_canGoNext && i == displayItems.length - 1) _next();
                                            }
                                          : (value) => setState(() {
                                                _selectedValue = _selectedValue == value ? null : value;
                                              }),
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                        ),
                      ),

                      // 왼쪽 그라디언트 (이전 peek 페이드)
                      // if (_canGoPrev)
                      //   Positioned(
                      //     left: 0,
                      //     top: 0,
                      //     bottom: 0,
                      //     width: peekW,
                      //     child: IgnorePointer(
                      //       child: Container(
                      //         decoration: const BoxDecoration(
                      //           gradient: LinearGradient(
                      //             begin: Alignment.centerLeft,
                      //             end: Alignment.centerRight,
                      //             colors: [Colors.white, Colors.transparent],
                      //           ),
                      //         ),
                      //       ),
                      //     ),
                      //   ),

                      // 오른쪽 그라디언트 (다음 peek 페이드)
                      // if (_canGoNext)
                      //   Positioned(
                      //     right: 0,
                      //     top: 0,
                      //     bottom: 0,
                      //     width: peekW,
                      //     child: ,
                      //   ),
                    ],
                  ),
                ),
              ),

              SizedBox(
                width: arrowW,
                child: _canGoNext
                    ? GestureDetector(
                        onTap: _next,
                        child: const Icon(Icons.chevron_right_rounded, size: 28, color: Color(0xFF574AB0)),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        ElevatedButton(
          onPressed: _selectedValue == null ? null : () => Navigator.pop(context, _selectedValue),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            backgroundColor: const Color(0xFF252525),
            disabledBackgroundColor: Colors.grey.shade300,
          ),
          child: const Text('저장', style: TextStyle(color: Colors.white, fontSize: 16)),
        ),
        const SizedBox(width: 12),
        OutlinedButton(
          onPressed: () => Navigator.pop(context, null),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            side: BorderSide(color: Colors.grey.shade400),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          ),
          child: const Text('취소', style: TextStyle(color: Colors.grey, fontSize: 16)),
        ),
      ],
    );
  }
}

class _CharacterItem extends StatelessWidget {
  final String imagePath;
  final String value;
  final String label;
  final double imageSize;
  final bool isSelected;
  final ValueChanged<String> onTap;

  const _CharacterItem({
    required this.imagePath,
    required this.value,
    required this.label,
    required this.imageSize,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onTap(value),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            isSelected ? 'assets/images/rank/selected_$value.png' : imagePath,
            width: isSelected ? imageSize : imageSize * 0.82,
            height: isSelected ? imageSize : imageSize * 0.82,
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.sp,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
              color: isSelected ? const Color(0xFF574AB0) : Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}
