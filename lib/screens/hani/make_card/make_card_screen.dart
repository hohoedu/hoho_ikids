import 'package:flutter/material.dart';
import 'package:hani_booki/widgets/appbar/main_appbar.dart';
import 'package:hani_booki/widgets/dialog.dart';
import 'package:hive/hive.dart';

class MakeCardScreen extends StatelessWidget {
  const MakeCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Color(0xFFDFD7FE),
      appBar: MainAppBar(
        isContent: true,
        title: '알맞은 한자카드를 그림에 넣어 단어를 완성하세요!',
        titleStyle: TextStyle(
          fontSize: 22,
        ),
        onTapBackIcon: () => showBackDialog(false),
      ),
      body: Center(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.8,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Spacer(flex: 1),
              Expanded(
                flex: 12,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        flex: 8,
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(30),
                            child: Container(
                              color: Colors.green,
                              child: Column(
                                children: [
                                  Expanded(
                                    flex: 3,
                                    child: Container(
                                      color: Colors.green,
                                      child: Center(
                                          child: Text(
                                        '해와 달',
                                        style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                                      )),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 10,
                                    child: Stack(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                color: Colors.red,
                                                child: Image.network(
                                                  'https://picsum.photos/id/1008/300/300',
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                            Expanded(
                                              child: Container(
                                                color: Colors.indigo,
                                                child: Image.network(
                                                  'https://picsum.photos/id/1009/300/300',
                                                  fit: BoxFit.fill,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Align(
                                            alignment: Alignment.center,
                                            child: Image.asset('assets/images/icons/circle.png'))
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 3,
                        child: Container(
                          child: Column(
                            children: [
                              Expanded(
                                  child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network('https://picsum.photos/id/1006/500/500'),
                                ),
                              )),
                              Expanded(
                                  child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(25),
                                  child: Image.network('https://picsum.photos/id/104/500/500'),
                                ),
                              )),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
