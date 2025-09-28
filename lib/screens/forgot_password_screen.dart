import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../components/components.dart';
import '../services/api_services.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleForgotPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.forgotPassword(
          _emailController.text.trim(),
        );

        if (mounted) {
          if (result['STS'] == "200") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'OTP sent to ${_emailController.text.trim()}. Please check your email.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to OTP verification screen
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    OTPVerificationScreen(email: _emailController.text.trim()),
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['MSG'] ?? 'Failed to send OTP'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: MediaQuery.of(context).size.height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF8F9FA), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(
              horizontal: MediaQuery.of(context).size.width > 600 ? 48 : 24,
              vertical: 24,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Back button
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Header
                Text(
                  'Forgot Password?',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Don\'t worry! Enter your email address below and we\'ll send you an OTP to reset your password.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 60),

                // Illustration
                Center(
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(100),
                    ),
                    child: const Icon(
                      Icons.email_outlined,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 60),

                // Form
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      maxWidth: 400, // Maximum width for better appearance
                      minWidth: 280, // Minimum width for small screens
                    ),
                    child: AuthCard(
                      padding: EdgeInsets.symmetric(
                        horizontal: MediaQuery.of(context).size.width > 400
                            ? 40
                            : 0.5,
                        vertical: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            CustomTextField(
                              controller: _emailController,
                              label: 'Email Address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your email address';
                                }
                                if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                ).hasMatch(value)) {
                                  return 'Please enter a valid email address';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 30),

                            _isLoading
                                ? Container(
                                    width: double.infinity,
                                    height: 55,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          AppColors.primary,
                                          const Color(0xFFD32F2F),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  )
                                : CustomButton(
                                    text: 'Send OTP',
                                    onPressed: _handleForgotPassword,
                                  ),

                            const SizedBox(height: 20),

                            // Back to login
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  'Remember your password? ',
                                  style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context).pop(),
                                  child: const Text(
                                    'Back to Login',
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
