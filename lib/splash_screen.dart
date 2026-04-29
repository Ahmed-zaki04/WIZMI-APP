import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _lineAnimation;
  late Animation<double> _scaleAnimation;
  double op = 0.0;
  final Color _primaryColor = const Color(0xFF0D47A1);

  @override
  void initState() {
    super.initState();

    // Initialize Animation
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _lineAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    // Start fade in
    Future.delayed(Duration.zero, () {
      setState(() {
        op = 1.0;
      });
    });

    // After 3 seconds, check login status and navigate
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        _checkLogin();
      }
    });
  }

  void _checkLogin() {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && user.emailVerified) {
      Navigator.of(context).pushReplacementNamed("home");
    } else {
      Navigator.of(context).pushReplacementNamed("log");
    }
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
      body: AnimatedOpacity(
        opacity: op,
        duration: const Duration(milliseconds: 700),
        curve: Curves.easeInOut,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white,
                _primaryColor.withOpacity(0.1),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      Icon(
                        Icons.car_repair,
                        size: 80,
                        color: _primaryColor,
                      ),
                      const SizedBox(height: 20),
                      Text(
                        "WIZMI",
                        style: TextStyle(
                          fontSize: 40,
                          color: _primaryColor,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                AnimatedBuilder(
                  animation: _lineAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment.center,
                      child: Container(
                        width: 160 * _lineAnimation.value,
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _primaryColor.withOpacity(0.5),
                              _primaryColor,
                              _primaryColor.withOpacity(0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Text(
                    "Your Car Service Partner",
                    style: TextStyle(
                      fontSize: 16,
                      color: _primaryColor.withOpacity(0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
