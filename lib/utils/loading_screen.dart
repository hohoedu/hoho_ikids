import 'package:flutter/material.dart';
import 'package:hani_booki/_core/constants.dart';
import 'package:lottie/lottie.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    loadingText.shuffle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            children: [
              Expanded(flex: 5, child: Lottie.asset('assets/lottie/loading.json')),
              Expanded(
                  child: Text(
                loadingText[1],
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, fontFamily: 'Cookie'),
              ))
            ],
          ),
        ),
      ),
    );
    ;
  }
}
