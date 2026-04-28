import 'package:flutter/material.dart';

class Categories extends StatelessWidget {
  const Categories({super.key});
  static const String routeName = '/categories';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.green,
      child: const Center(child: Text('Categories')),
    );
  }
}