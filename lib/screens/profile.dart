import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile({super.key});
  static const String routeName = '/profile';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.blue,
      child: const Center(child: Text('Profile')),
    );
  }
}