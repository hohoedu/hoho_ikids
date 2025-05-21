import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/screens/setting/setting_screen.dart';
import 'package:hani_booki/services/auth/logout.dart';
import 'package:hani_booki/services/auth/withdraw_service.dart';
import 'package:hani_booki/services/notice/notice_list_service.dart';
import 'package:hani_booki/services/notice/notice_view_service.dart';
import 'package:hani_booki/utils/bgm_controller.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hani_booki/widgets/notice/notice_screen.dart';
import 'package:logger/logger.dart';

class MainAppBar extends StatefulWidget implements PreferredSizeWidget {
  final String? title;
  final bool isPortraitMode;
  final bool? isVisibleLeading;
  final bool isContent;
  final bool isInfo;
  final bool isMain;
  final bool isKidok;
  final VoidCallback? onTap;
  final VoidCallback? onTapBackIcon;
  final TextStyle? titleStyle;

  const MainAppBar({
    super.key,
    this.title,
    this.isPortraitMode = false,
    required this.isContent,
    this.isInfo = false,
    this.isMain = false,
    this.isKidok = false,
    this.onTap,
    this.isVisibleLeading = true,
    this.onTapBackIcon,
    this.titleStyle,
  });

  @override
  State<MainAppBar> createState() => _MainAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _MainAppBarState extends State<MainAppBar> {
  final bgmController = Get.find<BgmController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0.0,
      automaticallyImplyLeading: false,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      leading: Visibility(
        visible: widget.isVisibleLeading ?? true,
        child: GestureDetector(
          onTap: () async {
            if (widget.isContent) {
              widget.onTapBackIcon!();
            } else if (widget.isInfo) {
              widget.onTapBackIcon!();
            } else {
              Get.back();
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Image.asset(
              'assets/images/icons/back.png',
              scale: 2,
            ),
          ),
        ),
      ),
      title: widget.title != null
          ? Text(
              widget.title!,
              textAlign: TextAlign.center,
              style: widget.titleStyle == null
                  ? TextStyle(
                      fontWeight: FontWeight.bold,
                    )
                  : widget.titleStyle,
            )
          : null,
      centerTitle: true,
      actions: [
        Visibility(
          visible: widget.title == null,
          child: GestureDetector(
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Image.asset(
                'assets/images/icons/menu.png',
                scale: 2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
