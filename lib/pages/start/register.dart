import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String? email;
  String? name;
  String? username;
  String? password;
  String? confirmPassword;
  bool obscurePassword = true;
  bool obscureConfirmPassword = true;
  bool rememberMe = true;

  final double buttonHeight = 50;

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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 50, 24, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Make an Account",
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "Fill the blank spaces below",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 40),
              TextField(
                onChanged: (val) => email = val,
                style: const TextStyle(color: Colors.black),
                decoration: getInputDecoration("Email", Icons.email_outlined),
              ),
              const SizedBox(height: 20),
              TextField(
                onChanged: (val) => name = val,
                style: const TextStyle(color: Colors.black),
                decoration: getInputDecoration("Name", Icons.person_outline),
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
                    setState(() {
                      obscurePassword = !obscurePassword;
                    });
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
                    setState(() {
                      obscureConfirmPassword = !obscureConfirmPassword;
                    });
                  },
                ),
              ),
              const SizedBox(height: 12),
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
                  onPressed: () async {
                    if (email != null &&
                        name != null &&
                        username != null &&
                        password != null &&
                        confirmPassword != null) {
                      if (password != confirmPassword) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Passwords do not match"),
                            ),
                          );
                        }
                        return;
                      }
                      if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email!)) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Invalid email format"),
                            ),
                          );
                        }
                        return;
                      }
                      try {
                        await AuthService.registerWithEmail(
                          email: email!,
                          name: name!,
                          username: username!,
                          password: password!,
                        );
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Registration successful"),
                            ),
                          );
                          Navigator.pushNamed(context, '/login');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Registration failed: $e")),
                          );
                        }
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Please fill all fields"),
                          ),
                        );
                      }
                    }
                  },
                  child: const Text(
                    "Register",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Center(
                child: Text(
                  "Or register with",
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
                        if (mounted) {
                          Navigator.pushNamed(context, '/home');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Google sign-up failed: $e"),
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
                        if (mounted) {
                          Navigator.pushNamed(context, '/home');
                        }
                      } catch (e) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Apple sign-up failed: $e")),
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
                    style: TextStyle(fontSize: 13, color: Colors.black54),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/login');
                    },
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
      ),
    );
  }
}
