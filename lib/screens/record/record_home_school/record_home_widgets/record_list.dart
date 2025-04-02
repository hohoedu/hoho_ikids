import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/auth/user_record_list_data.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:hani_booki/services/record/report_star_service.dart';
import 'package:hani_booki/services/total_star_service.dart';
import 'package:logger/logger.dart';

class RecordList extends StatefulWidget {
  final String type;
  final String keyCode;

  const RecordList({super.key, required this.type, required this.keyCode});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final userData = Get.find<UserDataController>();
  final userRecordList = Get.find<UserRecordListDataController>();
  late UserHaniDataController haniData = UserHaniDataController();
  late UserBookiDataController bookiData = UserBookiDataController();

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _itemKey = GlobalKey();

  bool isSelected = false;
  int _currentIndex = 0;
  double itemWidth = 0;
  double _availableWidth = 0;

  @override
  void initState() {
    super.initState();
    if (widget.type == 'hani') {
      haniData = Get.find<UserHaniDataController>();
    } else {
      bookiData = Get.find<UserBookiDataController>();
    }
    _currentIndex = userRecordList.userRecordListDataList.indexWhere((item) => item.keyCode == widget.keyCode);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadItemWidth();
  }

  void _loadItemWidth() {
    final image = NetworkImage(userRecordList.userRecordListDataList[0].imagePath);
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final double intrinsicWidth = info.image.width.toDouble() / MediaQuery.of(context).devicePixelRatio;
        setState(() {
          itemWidth = intrinsicWidth;
        });

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToCurrentIndex(itemWidth);
        });
      }),
    );
  }

  void _scrollToCurrentIndex(double itemWidth) {
    double offset = _currentIndex * itemWidth - (_availableWidth / 2 - itemWidth / 2);

    if (offset < 0) offset = 0;
    if (_scrollController.hasClients && offset > _scrollController.position.maxScrollExtent) {
      offset = _scrollController.position.maxScrollExtent;
    }

    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }


  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _availableWidth = constraints.maxWidth;

        // 스크롤 위치 조정 (item build 이후)
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final context = _itemKey.currentContext;
          if (context != null) {
            final RenderBox renderBox = context.findRenderObject() as RenderBox;
            final double itemWidth = renderBox.size.width;
            _scrollToCurrentIndex(itemWidth);
          }
        });

        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(flex: 1, child: Container()),
            Expanded(
              flex: 10,
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: userRecordList.userRecordListDataList.length,
                itemBuilder: (context, index) {
                  final record = userRecordList.userRecordListDataList[index];
                  final bool isActive = record.keyCode.isNotEmpty;
                  final double imageOpacity = isActive ? 1.0 : 0.5;
                  final bool isSelected = index == _currentIndex;

                  return GestureDetector(
                    onTap: () async {
                      await reportStarService(record.keyCode);
                      await contentStarService(record.keyCode, widget.type);
                      setState(() {
                        _currentIndex = index;
                      });
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Opacity(
                        opacity: imageOpacity,
                        child: Transform.scale(
                          scale: isSelected ? 1.0 : 0.9,
                          child: Image.network(
                            record.imagePath,
                            key: index == _currentIndex ? _itemKey : null,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Expanded(flex: 1, child: Container()),
          ],
        );
      },
    );
  }
}
