import 'package:flutter/material.dart';
import 'dart:async';

class SplashScreenAdmin extends StatefulWidget {
  const SplashScreenAdmin({super.key});

  @override
  State<SplashScreenAdmin> createState() => _SplashScreenAdminState();
}

class _SplashScreenAdminState extends State<SplashScreenAdmin> {
  @override
  void initState() {
    super.initState();
    // Menjalankan jeda 2 detik sebelum pindah ke Beranda
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/beranda');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenHeight = constraints.maxHeight;
          final screenWidth = constraints.maxWidth;

          return Stack(
            children: [
              // Background Image
              Positioned.fill(
                child: Image.asset(
                  'assets/splash_background.png',
                  fit: BoxFit.cover,
                ),
              ),

              // Logo Bisnis
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: EdgeInsets.only(bottom: screenHeight * 0.25),
                  child: Image.asset(
                    'assets/logo_food.png',
                    width: screenWidth * 0.6,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}