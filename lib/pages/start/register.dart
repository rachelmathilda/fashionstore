import 'package:flutter/material.dart';
import 'dart:math';
import '../../services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
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

class _RegisterState extends State<Register> with TickerProviderStateMixin {
  String? email;
  String? name;
  String? username;
  String? password;
  String? confirmPassword;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool rememberMe = true;
  bool isLoading = false;

  final double buttonHeight = 50;

  late final AnimationController gradientController;
  late final AnimationController bubbleController;
  late final List<_BubbleData> bubbles;

  @override
  void initState() {
    super.initState();

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
        y: rng.nextDouble() * 0.4,
        size: 40 + rng.nextDouble() * 80,
        speed: 0.3 + rng.nextDouble() * 0.7,
        phase: rng.nextDouble() * 2 * pi,
      ),
    );
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
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
                  final dy = sin(t * 2 * pi * b.speed + b.phase) * 30;
                  final dx = cos(t * 2 * pi * b.speed * 0.7 + b.phase) * 15;
                  return Positioned(
                    left: b.x * screenWidth + dx - b.size / 2,
                    top: b.y * 300 + dy - b.size / 2,
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
          SafeArea(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Make an Account",
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          "Fill the blank spaces below",
                          style: TextStyle(fontSize: 16, color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextField(
                          onChanged: (val) => email = val,
                          style: const TextStyle(color: Colors.black),
                          decoration: getInputDecoration(
                            "Email",
                            Icons.email_outlined,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (val) => name = val,
                          style: const TextStyle(color: Colors.black),
                          decoration: getInputDecoration(
                            "Name",
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          onChanged: (val) => username = val,
                          style: const TextStyle(color: Colors.black),
                          decoration: getInputDecoration(
                            "Username",
                            Icons.person_outline,
                          ),
                        ),
                        const SizedBox(height: 20),
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
                              setState(
                                () => obscurePassword = !obscurePassword,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          obscureText: obscureConfirmPassword,
                          onChanged: (val) => confirmPassword = val,
                          style: const TextStyle(color: Colors.black),
                          decoration: getInputDecoration(
                            "Confirm Password",
                            Icons.lock_outline,
                            isPassword: true,
                            obscure: obscureConfirmPassword,
                            toggleVisibility: () {
                              setState(
                                () => obscureConfirmPassword =
                                    !obscureConfirmPassword,
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: buttonHeight,
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF898AC4),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 0,
                            ),
                            onPressed: isLoading
                                ? null
                                : () async {
                                    if (email == null ||
                                        name == null ||
                                        username == null ||
                                        password == null ||
                                        confirmPassword == null) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Please fill all fields",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (password != confirmPassword) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Passwords do not match",
                                          ),
                                        ),
                                      );
                                      return;
                                    }
                                    if (!RegExp(
                                      r'^[^@]+@[^@]+\.[^@]+',
                                    ).hasMatch(email!)) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text("Invalid email format"),
                                        ),
                                      );
                                      return;
                                    }
                                    setState(() => isLoading = true);
                                    try {
                                      await AuthService.registerWithEmail(
                                        email: email!,
                                        name: name!,
                                        username: username!,
                                        password: password!,
                                      );
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              "Registration successful",
                                            ),
                                          ),
                                        );
                                        Navigator.pushNamed(context, '/login');
                                      }
                                    } catch (e) {
                                      if (mounted) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              "Registration failed: $e",
                                            ),
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
                                    "Register",
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
                            "Or register with",
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.black54,
                            ),
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
                                        content: Text(
                                          "Google sign-up failed: $e",
                                        ),
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
                                        content: Text(
                                          "Apple sign-up failed: $e",
                                        ),
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
                        const SizedBox(height: 25),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text(
                              "Already have an account? ",
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            GestureDetector(
                              onTap: () =>
                                  Navigator.pushNamed(context, '/login'),
                              child: const Text(
                                "Sign In",
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
