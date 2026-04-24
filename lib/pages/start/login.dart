import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/auth_service.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _BubbleData {
  double x, y, size, speed, phase;
  _BubbleData({
    required this.x,
    required this.y,
    required this.size,
    required this.speed,
    required this.phase,
  });
}

class _LoginState extends State<Login> with TickerProviderStateMixin {
  String? email;
  String? password;
  bool rememberMe = false;
  bool obscurePassword = true;
  bool isLoading = false;

  late final AnimationController gradientController;
  late final AnimationController bubbleController;
  late final List<_BubbleData> bubbles;

  @override
  void initState() {
    super.initState();
    _loadRememberMe();

    gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);

    bubbleController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();

    final rng = Random();
    bubbles = List.generate(
      8,
      (i) => _BubbleData(
        x: rng.nextDouble(),
        y: rng.nextDouble(),
        size: 40 + rng.nextDouble() * 80,
        speed: 0.3 + rng.nextDouble() * 0.7,
        phase: rng.nextDouble() * 2 * pi,
      ),
    );
  }

  Future<void> _loadRememberMe() async {
    final val = await AuthService.getRememberMe();
    if (mounted) setState(() => rememberMe = val);
  }

  @override
  void dispose() {
    gradientController.dispose();
    bubbleController.dispose();
    super.dispose();
  }

  InputDecoration getInputDecoration(
    String label,
    IconData icon, {
    bool isPassword = false,
    VoidCallback? toggleVisibility,
    bool obscure = false,
  }) {
    return InputDecoration(
      hintText: label,
      hintStyle: const TextStyle(color: Colors.black54),
      prefixIcon: isPassword
          ? IconButton(
              icon: Icon(
                obscure
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.black54,
              ),
              onPressed: toggleVisibility,
            )
          : Icon(icon, color: Colors.black54),
      filled: true,
      fillColor: const Color(0xFFEAEDFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide.none,
        borderRadius: BorderRadius.circular(30),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFC0C9EE),
      body: SafeArea(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: gradientController,
              builder: (context, child) {
                return Container(
                  width: double.infinity,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: const [
                        Color(0xFF898AC4),
                        Color(0xFFA2AADB),
                        Color(0xFFC0C9EE),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      stops: [
                        0.0 + (gradientController.value * 0.1),
                        0.5 + (gradientController.value * 0.1),
                        1.0,
                      ],
                    ),
                  ),
                );
              },
            ),
            AnimatedBuilder(
              animation: bubbleController,
              builder: (context, child) {
                return Stack(
                  children: bubbles.map((b) {
                    final t = bubbleController.value;
                    final dy = sin(t * 2 * pi * b.speed + b.phase) * 0.06;
                    final dx = cos(t * 2 * pi * b.speed * 0.7 + b.phase) * 0.03;
                    return Positioned(
                      left: (b.x + dx) * screenWidth - b.size / 2,
                      top: (b.y + dy) * screenHeight * 0.45 - b.size / 2,
                      child: Container(
                        width: b.size,
                        height: b.size,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withOpacity(0.15),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(24, 40, 24, 30),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Hi! Welcome back",
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Sign in to your account",
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 32),
                    TextField(
                      onChanged: (val) => email = val,
                      style: const TextStyle(color: Colors.black),
                      decoration: getInputDecoration(
                        "Email",
                        Icons.email_outlined,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      obscureText: obscurePassword,
                      onChanged: (val) => password = val,
                      style: const TextStyle(color: Colors.black),
                      decoration: getInputDecoration(
                        "Password",
                        Icons.lock_outline,
                        isPassword: true,
                        obscure: obscurePassword,
                        toggleVisibility: () {
                          setState(() => obscurePassword = !obscurePassword);
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Checkbox(
                          activeColor: const Color(0xFF1A1B1F),
                          value: rememberMe,
                          onChanged: (value) {
                            setState(() => rememberMe = value ?? false);
                          },
                        ),
                        const Text(
                          "Remember me",
                          style: TextStyle(color: Colors.black87, fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 45,
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF898AC4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: isLoading
                            ? null
                            : () async {
                                if (email == null || password == null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        "Please enter email and password",
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                if (!RegExp(
                                  r'^[^@]+@[^@]+\.[^@]+',
                                ).hasMatch(email!)) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Invalid email format"),
                                    ),
                                  );
                                  return;
                                }
                                setState(() => isLoading = true);
                                try {
                                  await AuthService.signInWithEmail(
                                    email: email!.trim(),
                                    password: password!.trim(),
                                    rememberMe: rememberMe,
                                  );
                                  if (mounted)
                                    Navigator.pushNamed(context, '/home');
                                } catch (e) {
                                  if (mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Login failed: $e"),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (mounted)
                                    setState(() => isLoading = false);
                                }
                              },
                        child: isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign In",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        "Or login with",
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () async {
                            try {
                              await AuthService.signInWithGoogle(
                                rememberMe: rememberMe,
                              );
                              if (mounted)
                                Navigator.pushNamed(context, '/home');
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Google login failed: $e"),
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.12),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(14),
                            child: Image.asset('assets/images/google.png'),
                          ),
                        ),
                        const SizedBox(width: 20),
                        InkWell(
                          onTap: () async {
                            try {
                              await AuthService.signInWithApple(
                                rememberMe: rememberMe,
                              );
                              if (mounted)
                                Navigator.pushNamed(context, '/home');
                            } catch (e) {
                              if (mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Apple login failed: $e"),
                                  ),
                                );
                              }
                            }
                          },
                          borderRadius: BorderRadius.circular(30),
                          child: Container(
                            width: 55,
                            height: 55,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color.fromRGBO(0, 0, 0, 0.12),
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(12),
                            child: Image.asset('assets/images/apple.png'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(fontSize: 13, color: Colors.black54),
                        ),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/register'),
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontSize: 13,
                              color: Color(0xFF5E686D),
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
