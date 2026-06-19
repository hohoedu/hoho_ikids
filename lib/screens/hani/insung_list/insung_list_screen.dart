import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/hani/hani_song_list_data.dart';
import 'package:hani_booki/utils/star_event_mixin.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class InsungListScreen extends StatefulWidget {
  final String keyCode;

  const InsungListScreen({super.key, required this.keyCode});

  @override
  State<InsungListScreen> createState() => _InsungListScreenState();
}

class _InsungListScreenState extends State<InsungListScreen> with TickerProviderStateMixin, StarEventMixin<InsungListScreen> {
  final haniSongList = Get.find<HaniSongListController>();

  @override
  void initState() {
    super.initState();

    initStarEventFromServer(
      btype: 'H',
      hosu: widget.keyCode.substring(2, 4),
      gb: 'insung',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFFFFDE5),
      appBar: MainAppBar(
        isContent: false,
        title: '',
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Stack(
        children: [
          Center(
            child: SizedBox(
              width: Platform.isIOS ? MediaQuery.of(context).size.width * 0.8 : double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 12,
                    child: Row(
                      children: List.generate(
                        haniSongList.haniSongList.length,
                        (index) {
                          return Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: GestureDetector(
                                onTap: () {
                                  Logger().d('ontap');
                                  Logger().d(haniSongList.haniSongList[index].category);
                                },
                                child: Image.network(
                                  '${haniSongList.haniSongList[index].imagePath}',
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          ...buildStarWidgets(widget.keyCode)
        ],
      ),
    );
  }

  @override
  void dispose() {
    disposeStarEvent();
    super.dispose();
  }
}
