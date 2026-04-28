import 'package:depi_project/const/appColors.dart';
import 'package:depi_project/screens/categories.dart';
import 'package:depi_project/screens/home_screen.dart';
import 'package:depi_project/screens/profile.dart';
import 'package:depi_project/screens/wishlist.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});
  static const String routeName = '/bottomNavBar';

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;
  List<Widget> pages = [
    const HomeScreen(),
    const Categories(),
    const Wishlist(),
    const Profile(),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: BottomNavigationBar(
          selectedFontSize: 0, // removes the label spacing
          unselectedFontSize: 0,
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.primaryColor,
          currentIndex: currentIndex,
          onTap: (value) => setState(() => currentIndex = value),
          items: [
            buildNavItem(
              iconPath: 'assets/icons/Home_on.svg',
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.backgroundColor,
            ),
            buildNavItem(
              iconPath: 'assets/icons/categories.svg',
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.backgroundColor,
            ),
            buildNavItem(
              iconPath: 'assets/icons/wishlist.svg',
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.backgroundColor,
            ),
            buildNavItem(
              iconPath: 'assets/icons/account.svg',
              activeColor: AppColors.primaryColor,
              inactiveColor: AppColors.backgroundColor,
            ),
          ],
        ),
      ),
      body: pages[currentIndex],
    );
  }

  BottomNavigationBarItem buildNavItem({
    required String iconPath,
    required Color activeColor,
    required Color inactiveColor,
  }) {
    return BottomNavigationBarItem(
      label: '',
      icon: SizedBox(
        height: 50,
        width: 50,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(inactiveColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
      activeIcon: SizedBox(
        height: 50,
        width: 50,
        child: Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: Center(
            child: CircleAvatar(
              radius: 25,
              backgroundColor: Colors.white,
              child: SvgPicture.asset(
                iconPath,
                colorFilter: ColorFilter.mode(activeColor, BlendMode.srcIn),
              ),
            ),
          ),
        ),
      ),
    );
  }
}