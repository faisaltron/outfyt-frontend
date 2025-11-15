import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../recommendations/presentation/controllers/purchase_recommendation_screen.dart';
import '../../../recommendations/presentation/recommendation_screen.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: SvgPicture.asset(
          "assets/icons/logo.svg", // Ensure correct path
          height: 40,
          width: 40,
          fit: BoxFit.contain,
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0, // Remove shadow
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildLargeContainer(context), // Large Container with Random Stars
            const SizedBox(height: 16),
            // Two Small Containers Side by Side
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: _buildSmallContainer(
                    "Generate Outfits",
                    "Let AI style you",
                    "assets/icons/home.svg",
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const RecommendationScreen(),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: _buildSmallContainer(
                    "Wardrobe",
                    "Manage your clothes",
                    "assets/icons/camera.svg",
                    onTap: () {
                      // TODO: Implement wardrobe navigation
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// Large Container with Randomly Placed Small Stars
  Widget _buildLargeContainer(BuildContext context ) {
    return Stack(
      children: [
        // Background Container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [Color(0x7FF08EFC), Color(0x7FEE5166)],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // --- MODIFIED: ElevatedButton's onPressed ---
                ElevatedButton(
                  onPressed: () {
                    // Navigate to PurchaseRecommendationScreen when this button is pressed
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const PurchaseRecommendationScreen(),
                      ),
                    );
                  },
                  child: const Icon(Icons.star, color: Colors.pink, size: 30),
                ),
                // --- END MODIFIED ---
                const SizedBox(height: 8),
                const Text(
                  'Outfit Check',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 8),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Take a photo of your outfit and we\'ll tell you if it\'s good or not.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // Hardcoded Stars (Positioned Manually)
        const Positioned(top: 20, left: 30, child: Icon(Icons.star, color: Colors.pink, size: 24)),
        const Positioned(top: 50, right: 50, child: Icon(Icons.star, color: Colors.pink, size: 30)),
        const Positioned(bottom: 30, left: 50, child: Icon(Icons.star, color: Colors.pink, size: 28)),
        const Positioned(bottom: 35, right: 80, child: Icon(Icons.star, color: Colors.pink, size: 26)),
        const Positioned(top: 10, right: 20, child: Icon(Icons.star, color: Colors.pink, size: 18))
      ],
    );
  }

  /// Small Container with SVG Icon and Text
  Widget _buildSmallContainer(String title, String subtitle, String iconPath, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160,
        height: 150,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0x7FF08EFC), Color(0x7FEE5166)],
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onTap,
              child: SvgPicture.asset(
                iconPath,
                fit: BoxFit.contain,
                width: 40,
                height: 40,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}