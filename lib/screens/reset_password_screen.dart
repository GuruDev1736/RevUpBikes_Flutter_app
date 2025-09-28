import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../components/components.dart';
import '../services/api_services.dart';
import 'auth_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String otp;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.otp,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.resetPassword(
          widget.email,
          widget.otp,
          _newPasswordController.text.trim(),
        );

        if (mounted) {
          if (result['STS'] == "200") {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Password reset successfully! Please login with your new password.',
                ),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const AuthScreen()),
              (route) => false,
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['MSG'] ?? 'Failed to reset password'),
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

                const SizedBox(height: 30),

                // Header
                Text(
                  'Reset Password',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[800],
                  ),
                ),

                const SizedBox(height: 12),

                Text(
                  'Create a new password for your account. Make sure it\'s strong and secure.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 30),

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
                      Icons.lock_reset_rounded,
                      size: 80,
                      color: AppColors.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

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
                            : 10,
                        vertical: 32,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            // New Password Field
                            CustomTextField(
                              controller: _newPasswordController,
                              label: 'New Password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              isPasswordVisible: _isNewPasswordVisible,
                              onPasswordToggle: () {
                                setState(() {
                                  _isNewPasswordVisible =
                                      !_isNewPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter a new password';
                                }
                                if (value.length < 6) {
                                  return 'Password must be at least 6 characters';
                                }
                                if (!RegExp(
                                  r'^(?=.*[A-Za-z])(?=.*\d)',
                                ).hasMatch(value)) {
                                  return 'Password must contain letters and numbers';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 20),

                            // Confirm Password Field
                            CustomTextField(
                              controller: _confirmPasswordController,
                              label: 'Confirm New Password',
                              icon: Icons.lock_outline_rounded,
                              isPassword: true,
                              isPasswordVisible: _isConfirmPasswordVisible,
                              onPasswordToggle: () {
                                setState(() {
                                  _isConfirmPasswordVisible =
                                      !_isConfirmPasswordVisible;
                                });
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm your new password';
                                }
                                if (value != _newPasswordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),

                            const SizedBox(height: 25),

                            // Password requirements info
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.info_outline,
                                        color: Colors.blue.shade600,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Password Requirements:',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.blue.shade700,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '• At least 6 characters long\n'
                                    '• Contains both letters and numbers\n'
                                    '• Must match confirmation password',
                                    style: TextStyle(
                                      color: Colors.blue.shade600,
                                      fontSize: 13,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Reset Password Button
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
                                    text: 'Reset Password',
                                    onPressed: _handleResetPassword,
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
                                  onTap: () {
                                    Navigator.of(context).pushAndRemoveUntil(
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AuthScreen(),
                                      ),
                                      (route) => false,
                                    );
                                  },
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
