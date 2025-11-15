import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../auth/presentation/controllers/auth_state_provider.dart'; // This import is fine

// We need to import the actual AuthService provider to call completeOnboarding
import '../auth/data/services/auth_service.dart'; // <--- NEW IMPORT for authServiceProvider

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<String> images = [
    "assets/images/scaned_shirt.png",
    "assets/images/scaned_shirt2.png",
    "assets/images/scaned_shirt3.png"
  ];

  void _onPageChanged(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFFFFFFF),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              SizedBox(height: size.height * 0.05),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: const Text(
                  'OUTFYT elevates your\nwardrobe',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 24,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(height: size.height * 0.02),

              // Image Carousel
              Container(
                width: size.width * 0.8,
                height: size.height * 0.35,
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: images.length,
                    onPageChanged: _onPageChanged,
                    itemBuilder: (context, index) {
                      return Image.asset(
                        images[index],
                        fit: BoxFit.contain,
                      );
                    },
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.02),

              // Vertical Progress Indicators
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: 10,
                    height: index == _currentIndex ? 30 : 15,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: index == _currentIndex
                          ? const Color(0xFFD00A62)
                          : Colors.grey[400],
                      borderRadius: BorderRadius.circular(5),
                    ),
                  );
                }),
              ),

              SizedBox(height: size.height * 0.03),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: size.width * 0.1),
                child: const Text(
                  'Upload your clothes and OUTFYT will \nremove background automatically',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF656565),
                    fontSize: 12,
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w400,
                    height: 1.4,
                    letterSpacing: 1,
                  ),
                ),
              ),

              SizedBox(height: size.height * 0.05),

              // Bottom Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                    horizontal: size.width * 0.08,
                    vertical: size.height * 0.03),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    ElevatedButton(
                      onPressed: () async { // Make onPressed async
                        // Call completeOnboarding on the AuthService instance
                        await ref.read(authServiceProvider.notifier).completeOnboarding(); // <--- UPDATED
                        if (context.mounted) {
                          Navigator.pushNamed(context, "/signup");
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD00A62),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, size.height * 0.06),
                      ),
                      child: const Text(
                        'Get Started',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    SizedBox(height: size.height * 0.02),
                    OutlinedButton(
                      onPressed: () async { // Make onPressed async
                        // Call completeOnboarding on the AuthService instance
                        await ref.read(authServiceProvider.notifier).completeOnboarding(); // <--- UPDATED
                        if (context.mounted) {
                          Navigator.pushNamed(context, "/signin");
                        }
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD00A62), width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        minimumSize: Size(double.infinity, size.height * 0.06),
                      ),
                      child: const Text(
                        'I already have an account',
                        style: TextStyle(
                          color: Color(0xFFD00A62),
                          fontSize: 16,
                          fontFamily: 'Plus Jakarta Sans',
                          fontWeight: FontWeight.w500,
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