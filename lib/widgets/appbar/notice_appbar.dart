import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/screens/setting/setting_screen.dart';
import 'package:hani_booki/services/auth/logout.dart';
import 'package:hani_booki/services/auth/withdraw_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:logger/logger.dart';

class NoticeAppbar extends StatelessWidget implements PreferredSizeWidget {
  const NoticeAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.white,
      centerTitle: true,
      title: Text('호호에서 알려드려요!'),
      actions: [
        GestureDetector(
          onTap: () {
            Get.back();
          },
          child: Icon(Icons.clear),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight * 0.75);
}
