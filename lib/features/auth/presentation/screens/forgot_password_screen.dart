import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  bool _isLoading = false;

  static const Color greenColor = Color(0xff006C45);
  static const Color goldColor = Color(0xffC8A45D);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendResetLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: _emailController.text.trim(),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Reset link sent. Please check your email and spam folder.',
          ),
          backgroundColor: greenColor,
        ),
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Something went wrong. Please try again.';

      if (e.code == 'invalid-email') {
        message = 'Invalid email address.';
      } else if (e.code == 'user-not-found') {
        message = 'No account found with this email.';
      } else if (e.code == 'too-many-requests') {
        message = 'Too many requests. Please try again later.';
      } else if (e.message != null) {
        message = e.message!;
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  MediaQuery.of(context).padding.bottom,
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 22),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: IconButton(
                          onPressed: () {
                            context.go('/login');
                          },
                          icon: const Icon(
                            Icons.arrow_back_ios_new,
                            color: greenColor,
                            size: 20,
                          ),
                        ),
                      ),
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
                    ],
                  ),
                  const SizedBox(height: 70),
                  Container(
                    width: 66,
                    height: 66,
                    decoration: BoxDecoration(
                      color: greenColor.withValues(alpha: 0.06),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.key,
                      color: greenColor,
                      size: 34,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'Forgot Password',
                    style: TextStyle(
                      color: greenColor,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Enter your email address and we will send you\n'
                    'a link to reset your password.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: greenColor.withValues(alpha: 0.85),
                      fontSize: 13,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 42),
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'EMAIL ADDRESS',
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    cursorColor: greenColor,
                    decoration: const InputDecoration(
                      hintText: 'e.g. name@example.com',
                      border: InputBorder.none,
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color(0xffEEEEEE)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: greenColor),
                      ),
                      errorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.red),
                      ),
                    ),
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Enter email';
                      }

                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Enter a valid email';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 36),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _sendResetLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: goldColor,
                        foregroundColor: greenColor,
                        disabledBackgroundColor:
                            goldColor.withValues(alpha: 0.7),
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
                          : const Text(
                              'Send Reset Link',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextButton.icon(
                    onPressed: () {
                      context.go('/login');
                    },
                    icon: const Icon(
                      Icons.arrow_back,
                      size: 17,
                      color: greenColor,
                    ),
                    label: const Text(
                      'Back to Login',
                      style: TextStyle(
                        color: greenColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(height: 70),
                  Text(
                    "If you don't receive an email within a few minutes,\n"
                    'please check your spam folder.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontSize: 11,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FooterLink(text: 'HELP CENTER'),
                      SizedBox(width: 30),
                      _FooterLink(text: 'CONTACT US'),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;

  const _FooterLink({
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade500,
        fontSize: 9,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
