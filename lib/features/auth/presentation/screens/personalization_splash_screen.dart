import 'package:flutter/material.dart';
import 'dart:async';

import '../../../shared/holder_screen.dart';

class PersonalizationSplashScreen extends StatefulWidget {
  const PersonalizationSplashScreen({super.key});

  @override
  _PersonalizationSplashScreenState createState() => _PersonalizationSplashScreenState();
}

class _PersonalizationSplashScreenState extends State<PersonalizationSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _gradientAnimation;
  int _textIndex = 0;
  double _progressValue = 0.0;
  final List<String> _loadingTexts = [
    "Processing information...",
    "Analyzing...",
    "Almost there..."
  ];

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat(reverse: true);

    _gradientAnimation = ColorTween(
      begin: const Color(0xFFFFA6C1).withOpacity(0.5),
      end: const Color(0xFFFFA6C1),
    ).animate(_controller);

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_textIndex < _loadingTexts.length - 1) {
        setState(() {
          _textIndex++;
          _progressValue += 1 / (_loadingTexts.length - 1);
        });
      } else {
        _progressValue = 1.0;
        timer.cancel();
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HolderScreen()),
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text("About You", textAlign: TextAlign.center),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 250,
              child: Text(
                "Personalizing the OUTFYT app for You",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF121A2C),
                  fontSize: 24,
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w500,
                  height: 1.40,
                ),
              ),
            ),
            const SizedBox(height: 20),
            AnimatedBuilder(
              animation: _gradientAnimation,
              builder: (context, child) {
                return Container(
                  width: 167,
                  height: 167,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [_gradientAnimation.value!, Colors.pink.shade300],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            Text(
              _loadingTexts[_textIndex],
              style: const TextStyle(
                color: Color(0xFF656565),
                fontSize: 14,
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w400,
                height: 1.40,
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: SizedBox(
                width: 200,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.pink),
                    minHeight: 6,
                    value: _progressValue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

