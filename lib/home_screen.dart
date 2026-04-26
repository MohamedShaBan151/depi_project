import 'package:depi_project/appColors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;
  List<Widget> pages = [
    Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.yellow,
      child: const Center(child: Text('Home Screen')),
    ),
    Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.green,
      child: const Center(child: Text('Settings Screen')),
    ),
    Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.yellow,
      child: const Center(child: Text('Home Screen')),
    ),
    Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue,
      child: const Center(child: Text('Profile Screen')),
    ),
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
          backgroundColor: Color(0xff004182),
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
