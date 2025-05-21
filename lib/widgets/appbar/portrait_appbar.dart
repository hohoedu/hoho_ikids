import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class PortraitAppBar extends StatefulWidget implements PreferredSizeWidget {
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

  const PortraitAppBar({
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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  State<PortraitAppBar> createState() => _PortraitAppBarState();
}

class _PortraitAppBarState extends State<PortraitAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.transparent,
      scrolledUnderElevation: 0,
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
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      actions: [],
    );
  }
}
