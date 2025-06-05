import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hani_booki/utils/notification_controller.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SettingNotification extends StatefulWidget {
  const SettingNotification({super.key});

  @override
  _SettingNotificationState createState() => _SettingNotificationState();
}

class _SettingNotificationState extends State<SettingNotification> {
  static const _boxName = 'notification_settings';

  final NotificationController notiController = Get.put(NotificationController());

  bool allChecked = true;
  final Map<String, bool> categories = {
    '신규 E-BOOK': true,
    '언어분석 리포트': true,
    '교육정보': true,
    '공지사항': true,
  };

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final box = Hive.box(_boxName);
    setState(() {
      allChecked = box.get('allChecked', defaultValue: true) as bool;
      categories.forEach((key, _) {
        categories[key] = box.get('category_$key', defaultValue: true) as bool;
      });
    });
  }

  Future<void> _saveSettings() async {
    final box = Hive.box(_boxName);
    await box.put('allChecked', allChecked);
    for (var entry in categories.entries) {
      await box.put('category_${entry.key}', entry.value);
    }
  }

  void _onAllChanged(bool value) {
    setState(() {
      allChecked = value;
      for (var key in categories.keys) {
        categories[key] = value;
      }
    });
    _saveSettings();
    notiController.toggleBroadcast(value);
  }

  void _onCategoryChanged(String key, bool value) {
    setState(() {
      categories[key] = value;
      allChecked = categories.values.every((v) => v);
    });
    _saveSettings();

    if (key == '교육정보') {
      notiController.toggleBroadcast(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              Expanded(
                flex: 1,
                child: Center(
                  child: Text(
                    '알림 설정',
                    style: TextStyle(color: Color(0xFF606060), fontSize: 20),
                  ),
                ),
              ),
              // 체크박스 리스트
              Expanded(
                flex: 4,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 전체
                    NotificationCheckBox(
                      label: '전체',
                      value: allChecked,
                      onChanged: _onAllChanged,
                      leftPadding: 20,
                    ),
                    ...categories.entries.map((entry) {
                      return NotificationCheckBox(
                        label: entry.key,
                        value: entry.value,
                        onChanged: (v) => _onCategoryChanged(entry.key, v),
                        leftPadding: 40,
                      );
                    }).toList(),
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
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      child: Padding(
        padding: EdgeInsets.only(left: leftPadding),
        child: GestureDetector(
          onTap: () => onChanged(!value),
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
                    style: TextStyle(
                      color: Color(0xFF606060),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
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
