
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../home/presentation/screens/home_screen.dart';
import '../mylooks/my_looks_screen.dart';
import '../profile/profile_screen.dart';
import '../wardrobe/presentation/wardrobe_screen.dart';

class HolderScreen extends StatefulWidget {
  const HolderScreen({super.key});

  @override
  State<HolderScreen> createState() => _HolderScreenState();
}

class _HolderScreenState extends State<HolderScreen> {
  int _selectedIndex = 0;

  void _navigationBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const MyLooksScreen(),
    const WardrobeScreen(),
    const ProfileScreen(),
  ];

  Widget _buildNavBarIcon(String assetPath, int index, double iconSize) {
    bool isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _navigationBottomBar(index),
      child: Container(
        padding: EdgeInsets.all(iconSize * 0.3), // Adjust padding dynamically
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isSelected ? Colors.pink : Colors.transparent, // Selected background
        ),
        child: SvgPicture.asset(
          assetPath,
          height: isSelected ? iconSize * 1.2 : iconSize, // Scale icon based on selection
          width: isSelected ? iconSize * 1.2 : iconSize,
          colorFilter: ColorFilter.mode(
            isSelected ? Colors.white : Colors.grey, // Change icon color dynamically
            BlendMode.srcIn,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double iconSize = screenWidth * 0.08; // Adaptive icon size

    return Scaffold(
      body: SafeArea(
        child: _pages[_selectedIndex], // Show only selected page
      ),
      bottomNavigationBar: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.02, left: screenWidth * 0.08, right: screenWidth * 0.08),
        padding: EdgeInsets.symmetric(vertical: screenHeight * 0.015),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(35),
          boxShadow: const [ // Shadow effect
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5,
              spreadRadius: 1,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildNavBarIcon("assets/icons/home.svg", 0, iconSize),
            _buildNavBarIcon("assets/icons/my-looks.svg", 1, iconSize),
            _buildNavBarIcon("assets/icons/wardrobe.svg", 2, iconSize),
            _buildNavBarIcon("assets/icons/profile.svg", 3, iconSize),
          ],
        ),
      ),
    );
  }
}
