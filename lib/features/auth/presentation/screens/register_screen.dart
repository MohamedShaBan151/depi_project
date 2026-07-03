import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../cubit/auth_cubit.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _acceptTerms = false;
  bool _isLoading = false;

  /// user = customer
  /// provider = vendor
  /// admin = admin login only
  String _selectedRole = 'user';

  bool get _isAdminSelected => _selectedRole == 'admin';

  final List<Map<String, String>> _countries = const [
    {'name': 'Egypt', 'code': '+20', 'hint': '10 1234 5678'},
    {'name': 'UAE', 'code': '+971', 'hint': '50 123 4567'},
    {'name': 'Saudi Arabia', 'code': '+966', 'hint': '50 123 4567'},
    {'name': 'Kuwait', 'code': '+965', 'hint': '500 12345'},
    {'name': 'Qatar', 'code': '+974', 'hint': '3000 1234'},
    {'name': 'Bahrain', 'code': '+973', 'hint': '3600 1234'},
    {'name': 'Oman', 'code': '+968', 'hint': '9000 1234'},
    {'name': 'Jordan', 'code': '+962', 'hint': '79 123 4567'},
    {'name': 'Lebanon', 'code': '+961', 'hint': '70 123 456'},
    {'name': 'Iraq', 'code': '+964', 'hint': '770 123 4567'},
    {'name': 'Syria', 'code': '+963', 'hint': '944 123 456'},
    {'name': 'Palestine', 'code': '+970', 'hint': '59 123 4567'},
    {'name': 'Morocco', 'code': '+212', 'hint': '6 12 34 56 78'},
    {'name': 'Algeria', 'code': '+213', 'hint': '551 23 45 67'},
    {'name': 'Tunisia', 'code': '+216', 'hint': '20 123 456'},
    {'name': 'Libya', 'code': '+218', 'hint': '91 123 4567'},
    {'name': 'Sudan', 'code': '+249', 'hint': '91 123 4567'},
    {'name': 'Turkey', 'code': '+90', 'hint': '530 123 4567'},
    {'name': 'United States', 'code': '+1', 'hint': '555 123 4567'},
    {'name': 'United Kingdom', 'code': '+44', 'hint': '7400 123456'},
    {'name': 'Germany', 'code': '+49', 'hint': '151 12345678'},
    {'name': 'France', 'code': '+33', 'hint': '6 12 34 56 78'},
    {'name': 'Italy', 'code': '+39', 'hint': '312 345 6789'},
    {'name': 'Spain', 'code': '+34', 'hint': '612 345 678'},
    {'name': 'Canada', 'code': '+1', 'hint': '555 123 4567'},
    {'name': 'India', 'code': '+91', 'hint': '98765 43210'},
    {'name': 'Pakistan', 'code': '+92', 'hint': '300 1234567'},
  ];

  late Map<String, String> _selectedCountry;

  @override
  void initState() {
    super.initState();
    _selectedCountry = _countries.first;
  }

  String get _fullPhoneNumber {
    return '${_selectedCountry['code']} ${_phoneController.text.trim()}';
  }

  void _handleMainButton() {
    if (_isAdminSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Admin account is created by the system. Please login.'),
          backgroundColor: Colors.orange,
        ),
      );

      context.go('/login');
      return;
    }

    _signUp();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept terms and conditions'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthCubit>().signUp(
            _emailController.text.trim(),
            _passwordController.text,
            _nameController.text.trim(),
            phone: _fullPhoneNumber,
            role: _selectedRole,
          );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _googleSignUp() async {
    if (_isAdminSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Admin cannot sign up with Google. Please login.'),
          backgroundColor: Colors.orange,
        ),
      );

      context.go('/login');
      return;
    }

    if (_selectedRole == 'provider') {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vendor registration is available with email only.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<AuthCubit>().signInWithGoogle();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _goToHomeByRole(String role) {
    if (role == 'admin') {
      context.go('/admin-home');
    } else if (role == 'provider') {
      context.go('/provider-home');
    } else {
      context.go('/user-home');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xff006C45);
    const Color goldColor = Color(0xffC8A45D);

    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          _goToHomeByRole(state.role);
        }

        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 22),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: greenColor,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: goldColor,
                          size: 22,
                        ),
                      ),
                      const Spacer(),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Create Account',
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Join millions of shoppers today.',
                    style: TextStyle(
                      color: greenColor.withValues(alpha: 0.7),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const _FieldLabel(text: 'REGISTER AS'),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _RoleButton(
                          title: 'Customer',
                          icon: Icons.person_outline,
                          isSelected: _selectedRole == 'user',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'user';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RoleButton(
                          title: 'Vendor',
                          icon: Icons.storefront_outlined,
                          isSelected: _selectedRole == 'provider',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'provider';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _RoleButton(
                          title: 'Admin',
                          icon: Icons.admin_panel_settings_outlined,
                          isSelected: _selectedRole == 'admin',
                          onTap: () {
                            setState(() {
                              _selectedRole = 'admin';
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                  if (_isAdminSelected) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xffFFF8E7),
                        borderRadius: BorderRadius.circular(8),
                        border:
                            Border.all(color: goldColor.withValues(alpha: 0.6)),
                      ),
                      child: const Text(
                        'Admin accounts cannot be created from registration. Use the default admin email and password to login.',
                        style: TextStyle(
                          color: greenColor,
                          fontSize: 12,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 30),
                  const _FieldLabel(text: 'FULL NAME'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. John Doe',
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffEEEEEE)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel(text: 'EMAIL ADDRESS'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'e.g. name@example.com',
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffEEEEEE)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: greenColor),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Enter email';
                      }

                      if (!v.contains('@')) {
                        return 'Invalid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel(text: 'PHONE NUMBER'),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 135,
                        child: DropdownButtonFormField<Map<String, String>>(
                          initialValue: _selectedCountry,
                          isExpanded: true,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: greenColor,
                            size: 18,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffEEEEEE),
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: greenColor),
                            ),
                          ),
                          dropdownColor: Colors.white,
                          items: _countries.map((country) {
                            return DropdownMenuItem<Map<String, String>>(
                              value: country,
                              child: Text(
                                '${country['name']} ${country['code']}',
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: greenColor,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            if (value == null) return;

                            setState(() {
                              _selectedCountry = value;
                              _phoneController.clear();
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            hintText: _selectedCountry['hint'],
                            border: InputBorder.none,
                            enabledBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Color(0xffEEEEEE),
                              ),
                            ),
                            focusedBorder: const UnderlineInputBorder(
                              borderSide: BorderSide(color: greenColor),
                            ),
                          ),
                          validator: (v) {
                            if (v == null || v.trim().isEmpty) {
                              return 'Enter phone number';
                            }

                            if (v.trim().length < 7) {
                              return 'Invalid phone number';
                            }

                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  const _FieldLabel(text: 'PASSWORD'),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: 'At least 8 characters',
                      border: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffEEEEEE)),
                      ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffEEEEEE)),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: greenColor),
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          color: greenColor,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Enter password';
                      }

                      if (v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: Checkbox(
                          value: _acceptTerms,
                          activeColor: greenColor,
                          onChanged: (v) {
                            setState(() {
                              _acceptTerms = v ?? false;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              color: greenColor,
                              fontSize: 11,
                              height: 1.4,
                            ),
                            children: [
                              TextSpan(
                                text:
                                    'By creating an account, you agree to our ',
                              ),
                              TextSpan(
                                text: 'Terms and Conditions',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              TextSpan(text: ' and '),
                              TextSpan(
                                text: 'Privacy Policy',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleMainButton,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: greenColor,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(7),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              _isAdminSelected
                                  ? 'Go to Admin Login'
                                  : 'Create Account',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'SIGN UP WITH',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: _SocialButton(
                          text: 'Google',
                          iconText: 'G',
                          onTap: _isLoading ? null : _googleSignUp,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _SocialButton(
                          text: 'Facebook',
                          icon: Icons.facebook,
                          onTap: () {
                            // Facebook sign up
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: TextStyle(
                          color: greenColor.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.go('/login'),
                        child: const Text(
                          'Log in',
                          style: TextStyle(
                            color: greenColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleButton({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xff006C45);
    const Color goldColor = Color(0xffC8A45D);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        height: 72,
        padding: const EdgeInsets.symmetric(horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? goldColor.withValues(alpha: 0.18) : Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? goldColor : const Color(0xffEEEEEE),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: greenColor,
              size: 22,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: greenColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;

  const _FieldLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xff006C45);

    return Text(
      text,
      style: const TextStyle(
        color: greenColor,
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.4,
      ),
    );
  }
}

class _SocialButton extends StatelessWidget {
  final String text;
  final String? iconText;
  final IconData? icon;
  final VoidCallback? onTap;

  const _SocialButton({
    required this.text,
    this.iconText,
    this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const Color greenColor = Color(0xff006C45);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: const Color(0xffEEEEEE)),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (iconText != null)
              Text(
                iconText!,
                style: const TextStyle(
                  color: greenColor,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Icon(
                icon,
                color: greenColor,
                size: 20,
              ),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: greenColor,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
