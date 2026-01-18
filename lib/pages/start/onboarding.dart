import 'package:flutter/material.dart';
import 'login.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _onboardingData = [
    {
      "bg": "images/onboarding_1.png",
      "title": "100+ Clothes Option",
      "desc": "Various clothes option",
    },
    {
      "bg": "images/onboarding_2.png",
      "title": "Try-On Before Buy",
      "desc": "You can try it using our AI based AR tech",
    },
    {
      "bg": "images/onboarding_3.png",
      "title": "Find Outfit That Suit You",
      "desc":
          "Our algorithm able to make recommendation of based on your style",
    },
  ];

  void _nextPage() {
    if (_currentIndex < _onboardingData.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Login()),
      );
    }
  }

  Widget _buildPage(Map<String, String> data, int index) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    Alignment bgAlign;
    EdgeInsets bgPadding;

    switch (index) {
      case 0:
        bgAlign = Alignment.centerRight;
        bgPadding = const EdgeInsets.only(left: 24);
        break;
      case 1:
        bgAlign = Alignment.center;
        bgPadding = EdgeInsets.zero;
        break;
      case 2:
        bgAlign = Alignment.centerLeft;
        bgPadding = const EdgeInsets.only(right: 24);
        break;
      default:
        bgAlign = Alignment.center;
        bgPadding = EdgeInsets.zero;
    }

    return SafeArea(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SizedBox(
            height: screenHeight * 0.55,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: bgPadding,
                    child: Align(
                      alignment: bgAlign,
                      child: Image.asset(
                        data["bg"]!,
                        fit: BoxFit.fitWidth,
                        width: screenWidth,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Text(
                  data["title"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  data["desc"]!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(_onboardingData.length, (i) {
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: _currentIndex == i ? 27 : 15,
                      height: 10,
                      decoration: BoxDecoration(
                        color: _currentIndex == i
                            ? const Color(0xFF898AC4)
                            : const Color(0xFFC0C9EE),
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _nextPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF898AC4),
                    foregroundColor: Colors.white,
                    minimumSize: Size(screenWidth * 0.9, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    elevation: 4,
                  ),
                  child: Text(
                    _currentIndex == _onboardingData.length - 1
                        ? "Get Started"
                        : "Next",
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView.builder(
        controller: _controller,
        itemCount: _onboardingData.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
        },
        itemBuilder: (context, index) {
          return _buildPage(_onboardingData[index], index);
        },
      ),
    );
  }
}
