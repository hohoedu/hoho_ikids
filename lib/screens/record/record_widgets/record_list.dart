import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_booki_data.dart';
import 'package:hani_booki/_data/auth/user_hani_data.dart';
import 'package:hani_booki/_data/auth/user_record_list_data.dart';
import 'package:hani_booki/services/content_star_service.dart';
import 'package:logger/logger.dart';

class RecordList extends StatefulWidget {
  final String type;

  const RecordList({super.key, required this.type});

  @override
  State<RecordList> createState() => _RecordListState();
}

class _RecordListState extends State<RecordList> {
  final userRecordList = Get.find<UserRecordListDataController>();
  late UserHaniDataController haniData = UserHaniDataController();
  late UserBookiDataController bookiData = UserBookiDataController();

  final ScrollController _scrollController = ScrollController();
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
  }

  void _goPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _scrollToCurrentIndex();
      setState(() {});
    }
  }

  void _goNext() {
    if (_currentIndex < userRecordList.userrRecordListDataList.length - 1) {
      _currentIndex++;
      _scrollToCurrentIndex();
      setState(() {});
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadItemWidth();
  }

  bool _isKeycodeMatched(String bookListKeycode, String recordKeycode) {
    return bookListKeycode.isNotEmpty &&
        recordKeycode.isNotEmpty &&
        (bookListKeycode == recordKeycode);
  }

  void _loadItemWidth() {
    final image =
        NetworkImage(userRecordList.userrRecordListDataList[0].imagePath);
    image.resolve(const ImageConfiguration()).addListener(
      ImageStreamListener((ImageInfo info, bool _) {
        final double intrinsicWidth = info.image.width.toDouble() /
            MediaQuery.of(context).devicePixelRatio;
        setState(() {
          itemWidth = intrinsicWidth;
        });
      }),
    );
  }

  void _scrollToCurrentIndex() {
    double offset =
        _currentIndex * itemWidth - (_availableWidth / 2 - itemWidth / 2);

    if (offset < 0) offset = 0;
    if (_scrollController.hasClients &&
        offset > _scrollController.position.maxScrollExtent) {
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
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_left, size: 40),
              onPressed: _goPrevious,
            ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: EdgeInsets.zero,
                scrollDirection: Axis.horizontal,
                itemCount: userRecordList.userrRecordListDataList.length,
                itemBuilder: (context, index) {
                  final record = userRecordList.userrRecordListDataList[index];
                  final bool isSelected = index == _currentIndex;
                  String bookKeyCode = '';
                  if (widget.type == 'hani') {
                    if (index < haniData.userHaniDataList.length) {
                      bookKeyCode = haniData.userHaniDataList[index].keyCode;
                    }
                  } else {
                    if (index < bookiData.userBookiDataList.length) {
                      bookKeyCode = bookiData.userBookiDataList[index].keyCode;
                    }
                  }
                  final double imageOpacity =
                      _isKeycodeMatched(bookKeyCode, record.keyCode)
                          ? 1.0
                          : 0.5;

                  return GestureDetector(
                    onTap: () {
                      setState(() async {
                        _currentIndex = index;
                        _scrollToCurrentIndex();
                      });
                    },
                    child: Transform.scale(
                      scale: isSelected ? 1.1 : 0.9,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Opacity(
                          opacity: imageOpacity,
                          child: Image.network(
                            record.imagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_right, size: 40),
              onPressed: _goNext,
            ),
          ],
        );
      },
    );
  }
}
