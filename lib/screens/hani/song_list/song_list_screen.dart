import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/auth/user_data.dart';
import 'package:hani_booki/_data/hani/hani_song_list_data.dart';
import 'package:hani_booki/services/hani/hani_song_five_service.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';

class SongListScreen extends StatefulWidget {
  final String keyCode;

  const SongListScreen({super.key, required this.keyCode});

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  final haniSongList = Get.find<HaniSongListController>();
  final userData = Get.find<UserDataController>().userData;

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
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
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
                              haniSongFiveService(
                                userData!.id,
                                widget.keyCode,
                                userData!.year,
                                haniSongList.haniSongList[index].category,
                              );
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
    );
    ;
  }
}
