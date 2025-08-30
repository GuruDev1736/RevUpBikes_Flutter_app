import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../components/components.dart';
import 'home_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _loginFormKey = GlobalKey<FormState>();
  final _signupFormKey = GlobalKey<FormState>();

  // Login controllers
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Signup controllers
  final _signupNameController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Add listener to update UI when tab changes
    _tabController.addListener(() {
      setState(() {
        // This will rebuild the widget to update the progress indicator
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupNameController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_loginFormKey.currentState!.validate()) {
      _navigateToHome();
    }
  }

  void _handleSignup() {
    if (_signupFormKey.currentState!.validate()) {
      _navigateToHome();
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const HomeScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(0.0, 1.0);
          const end = Offset.zero;
          const curve = Curves.ease;

          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 600),
      ),
    );
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
            child: Column(
              children: [
                // Enhanced Header with Logo
                const AuthHeader(
                  title: 'RevUp',
                  subtitle: 'Your Journey, Your Ride',
                ),

                const SizedBox(height: 40),

                // Enhanced Auth Card
                AuthCard(
                  child: Column(
                    children: [
                      // Stepper Progress Indicator
                      StepProgressIndicator(
                        currentStep: _tabController.index,
                        totalSteps: 2,
                      ),

                      // Enhanced Stepper-Style Tab Bar
                      CustomTabBar(
                        tabController: _tabController,
                        tabs: const [
                          CustomTabItem(
                            text: 'Login',
                            icon: Icons.login_rounded,
                          ),
                          CustomTabItem(
                            text: 'Sign Up',
                            icon: Icons.person_add_rounded,
                          ),
                        ],
                      ),

                      const SizedBox(height: 35),

                      // Enhanced Tab Content with Animation
                      SizedBox(
                        height:
                            450, // Increased height to accommodate signup form
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            SingleChildScrollView(child: _buildLoginForm()),
                            SingleChildScrollView(child: _buildSignupForm()),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Enhanced Footer
                const AuthFooter(),

                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _loginFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _loginEmailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20), // Reduced from 25
          CustomTextField(
            controller: _loginPasswordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: _isLoginPasswordVisible,
            onPasswordToggle: () {
              setState(() {
                _isLoginPasswordVisible = !_isLoginPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 10), // Reduced from 15
          // Forgot Password
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                // Handle forgot password
              },
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20), // Reduced from 30
          CustomButton(text: 'Login', onPressed: _handleLogin),
        ],
      ),
    );
  }

  Widget _buildSignupForm() {
    return Form(
      key: _signupFormKey,
      child: Column(
        children: [
          CustomTextField(
            controller: _signupNameController,
            label: 'Full Name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Reduced from 20
          CustomTextField(
            controller: _signupEmailController,
            label: 'Email Address',
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Reduced from 20
          CustomTextField(
            controller: _signupPasswordController,
            label: 'Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: _isSignupPasswordVisible,
            onPasswordToggle: () {
              setState(() {
                _isSignupPasswordVisible = !_isSignupPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a password';
              }
              if (value.length < 6) {
                return 'Password must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Reduced from 20
          CustomTextField(
            controller: _signupConfirmPasswordController,
            label: 'Confirm Password',
            icon: Icons.lock_outline_rounded,
            isPassword: true,
            isPasswordVisible: _isConfirmPasswordVisible,
            onPasswordToggle: () {
              setState(() {
                _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
              });
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please confirm your password';
              }
              if (value != _signupPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
          const SizedBox(height: 25), // Reduced from 35
          CustomButton(text: 'Create Account', onPressed: _handleSignup),

          const SizedBox(height: 15), // Reduced from 20

          Text(
            'Already have an account?',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
          TextButton(
            onPressed: () {
              _tabController.animateTo(0);
            },
            child: const Text(
              'Login Here',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
