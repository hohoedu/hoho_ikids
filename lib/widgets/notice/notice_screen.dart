import 'package:flutter/material.dart';
import 'package:flutter_launcher_icons/constants.dart';
import 'package:get/get.dart';
import 'package:hani_booki/_core/colors.dart';
import 'package:hani_booki/widgets/appbar/notice_appbar.dart';

class NoticeScreen extends StatefulWidget {
  const NoticeScreen({super.key});

  @override
  State<NoticeScreen> createState() => _NoticeScreenState();
}

class _NoticeScreenState extends State<NoticeScreen> {
  bool isNotice = false;
  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: FractionallySizedBox(
        widthFactor: 1,
        heightFactor: 1,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          backgroundColor: mBackWhite,
          body: Column(
            children: [
              Expanded(
                flex: 1,
                child: SizedBox(
                  height: kToolbarHeight * 0.75,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Spacer(
                        flex: 1,
                      ),
                      Expanded(
                        flex: 8,
                        child: Center(
                          child: Text(
                            '호호에서 알려드려요!',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: GestureDetector(
                          onTap: () {
                            Get.back();
                          },
                          child: Icon(Icons.clear),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 9,
                child: Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 4.0, right: 4.0),
                        child: Container(
                          width: 10,
                          decoration: BoxDecoration(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(25)),
                          child: ListView.builder(
                            itemCount: 6,
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        currentIndex = index;
                                      });
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.only(top: 8.0),
                                      child: ClipPath(
                                        clipper: index == currentIndex
                                            ? BubbleClipper()
                                            : null,
                                        child: Container(
                                          width: double.infinity,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            color: Colors.green,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: Row(
                                            children: [
                                              Padding(
                                                padding:
                                                    const EdgeInsets.all(8.0),
                                                child: Image.asset(
                                                  'assets/images/icons/board_type1.png',
                                                  scale: 2.5,
                                                ),
                                              ),
                                              Text(
                                                '4월의 키도키독',
                                                style: TextStyle(
                                                  color: fontWhite,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 12,
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Visibility(
                                    visible: index == 0 || index == 1,
                                    child: SizedBox(
                                        width: 30,
                                        child: Image.asset(
                                            'assets/images/icons/board_new.png')),
                                  )
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 10,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            top: 4.0, left: 4.0, right: 8.0, bottom: 8.0),
                        child: Container(
                          clipBehavior: Clip.hardEdge,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: Colors.white),
                          child: ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                  left: 4.0,
                                  top: 4.0,
                                  right: 4.0,
                                ),
                                child: Container(
                                  height: 500,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
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

class BubbleClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const double borderRadius = 10;
    const double arrowWidth = 5;

    // 왼쪽 모서리
    path.moveTo(0, 0);

    // 오른쪽 상단 모서리
    path.lineTo(size.width - arrowWidth - borderRadius, 0);

    // 오른쪽 상단 모서리 라운드
    path.quadraticBezierTo(
      size.width - arrowWidth,
      0,
      size.width - arrowWidth,
      borderRadius,
    );

    //
    path.lineTo(size.width - arrowWidth, size.height * 0.4);

    path.lineTo(size.width, size.height * 0.5);

    path.lineTo(size.width - arrowWidth, size.height * 0.6);

    path.lineTo(size.width - arrowWidth, size.height - borderRadius);

    path.quadraticBezierTo(
      size.width - arrowWidth,
      size.height,
      size.width - arrowWidth - borderRadius,
      size.height,
    );

    path.lineTo(0, size.height);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
