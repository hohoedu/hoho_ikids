import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/utils/notification_controller.dart';

class SettingNotification extends StatelessWidget {
  SettingNotification({super.key});

  final NotificationController controller = Get.put(NotificationController());

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.transparent,
                  child: Center(
                    child: Text(
                      '알림 설정',
                      style: TextStyle(color: fontSub, fontSize: 20),
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 4,
                child: Column(
                  children: [
                    Obx(
                      () => NotificationCheckBox(
                        label: '전체',
                        value: controller.allChecked.value,
                        onChanged: (value) => controller.toggleAll(value),
                        leftPadding: 20,
                      ),
                    ),
                    Column(
                      children: controller.categories.keys.map((key) {
                        return Obx(
                          () => NotificationCheckBox(
                            label: key,
                            value: controller.categories[key]!.value,
                            onChanged: (value) => controller.toggleCategory(key, value),
                            leftPadding: 40,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class NotificationCheckBox extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double leftPadding;

  const NotificationCheckBox({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.leftPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: GestureDetector(
          onTap: () {
            onChanged(!value);
          },
          child: Row(
            children: [
              Image.asset(
                value ? 'assets/images/icons/checkbox.png' : 'assets/images/icons/checkbox_blank.png',
                width: 20,
                height: 20,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(
                    label,
                    style: TextStyle(color: fontSub, fontSize: 6.5.sp, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
