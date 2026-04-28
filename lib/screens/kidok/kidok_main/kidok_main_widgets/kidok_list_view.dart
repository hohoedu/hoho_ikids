import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_data/kidok/kidok_bookcase.data.dart';
import 'package:logger/logger.dart';

class KidokListView extends StatelessWidget {
  final dynamic constraints;
  final String note;
  final String subject;
  final int color;
  final int circleColor;
  final List<bool> isSelectedList;
  final int index;

  const KidokListView({
    super.key,
    this.constraints,
    required this.note,
    required this.subject,
    required this.color,
    required this.circleColor,
    required this.isSelectedList,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: constraints.maxHeight / 7,
        decoration: BoxDecoration(
            color: Color(color),
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: Color(circleColor),
              width: isSelectedList[index] ? 3 : 0,
            )),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: CircleAvatar(
                radius: 8.sp,
                backgroundColor: Color(circleColor),
                child: Text(
                  subject,
                  style: TextStyle(fontSize: 6.sp, color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                note,
                style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold),
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
