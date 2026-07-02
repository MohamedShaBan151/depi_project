import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/saudi_theme.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _signOut(BuildContext context) async {
    await context.read<AuthCubit>().signOut();

    if (context.mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    const Color greenColor = Color(0xff006C45);
    const Color goldColor = Color(0xffC8A45D);
    const Color borderColor = Color(0xffEEEEEE);
    const Color darkCardColor = Color(0xff111827);

    if (user == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center(
            child: Text('No user logged in'),
          ),
        ),
      );
    }

    final String userName = _getUserName(user);
    final String userEmail = user.email ?? '';
    final String initial = _getInitial(user);

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Header
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hello,',
                            style: TextStyle(
                              color: greenColor.withOpacity(0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            userName,
                            style: const TextStyle(
                              fontSize: 31,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: goldColor, width: 2),
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: greenColor,
                          backgroundImage: user.photoURL != null
                              ? NetworkImage(user.photoURL!)
                              : null,
                          child: user.photoURL == null
                              ? Text(
                            initial,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                      ),
                      Positioned(
                        right: -2,
                        bottom: -2,
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: goldColor,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: const Icon(
                            Icons.favorite,
                            size: 9,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 22),

              /// Banner Card
              Container(
                width: double.infinity,
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                decoration: BoxDecoration(
                  color: darkCardColor,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.flash_on,
                        color: Colors.black87,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'NOON ONE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 3),
                          Text(
                            'Unlimited free delivery & more',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: goldColor,
                        borderRadius: BorderRadius.circular(7),
                      ),
                      child: const Text(
                        'JOIN NOW',
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              /// Quick actions
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _QuickActionItem(
                    icon: Icons.inventory_2_outlined,
                    title: 'Orders',
                  ),
                  _QuickActionItem(
                    icon: Icons.location_on_outlined,
                    title: 'Addresses',
                  ),
                  _QuickActionItem(
                    icon: Icons.credit_card_outlined,
                    title: 'Payments',
                  ),
                  _QuickActionItem(
                    icon: Icons.favorite_outline,
                    title: 'Wishlist',
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Menu section
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    _ProfileRow(
                      icon: Icons.person_outline,
                      title: 'Account Information',
                      onTap: () {},
                    ),
                    const _ProfileDivider(),
                    _ProfileRow(
                      icon: Icons.notifications_none,
                      title: 'Notifications',
                      badgeText: '3',
                      onTap: () {},
                    ),
                    const _ProfileDivider(),
                    _ProfileRow(
                      icon: Icons.language,
                      title: 'Language',
                      trailingText: 'English',
                      onTap: () {},
                    ),
                    const _ProfileDivider(),
                    _ProfileRow(
                      icon: Icons.flag_outlined,
                      title: 'Country',
                      trailingText: 'UAE',
                      onTap: () {},
                    ),
                    const _ProfileDivider(),
                    _ProfileRow(
                      icon: Icons.help_outline,
                      title: 'Help Center',
                      onTap: () {},
                    ),
                    const _ProfileDivider(),
                    _ProfileRow(
                      icon: Icons.balance_outlined,
                      title: 'Legal',
                      onTap: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 26),

              /// Optional user info small text
              if (userEmail.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Text(
                    userEmail,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ),

              /// Sign out button
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton(
                  onPressed: () => _signOut(context),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: borderColor),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: goldColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 22),

              const Center(
                child: Text(
                  'NOON VERSION 8.42.0',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.8,
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  static String _getUserName(User user) {
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim();
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email!.split('@').first;
    }

    return 'Alex Thompson';
  }

  static String _getInitial(User user) {
    if (user.displayName != null && user.displayName!.trim().isNotEmpty) {
      return user.displayName!.trim()[0].toUpperCase();
    }

    if (user.email != null && user.email!.isNotEmpty) {
      return user.email![0].toUpperCase();
    }

    return '?';
  }
}

class _QuickActionItem extends StatelessWidget {
  final IconData icon;
  final String title;

  const _QuickActionItem({
    required this.icon,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xff006C45);

    return Column(
      children: [
        Icon(
          icon,
          color: Colors.black87,
          size: 22,
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: const TextStyle(
            color: greenColor,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _ProfileRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? trailingText;
  final String? badgeText;
  final VoidCallback onTap;

  const _ProfileRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.trailingText,
    this.badgeText,
  });

  @override
  Widget build(BuildContext context) {
    const Color goldColor = Color(0xffC8A45D);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 52,
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: Colors.black54,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            if (badgeText != null)
              Container(
                width: 20,
                height: 20,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: goldColor,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  badgeText!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (trailingText != null) ...[
              Text(
                trailingText!,
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: Colors.grey,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileDivider extends StatelessWidget {
  const _ProfileDivider();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 1,
      thickness: 0.8,
      color: Color(0xffEEEEEE),
    );
  }
}