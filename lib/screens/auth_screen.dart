import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../components/components.dart';
import '../services/api_services.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart';
import '../admin/screens/admin_dashboard_screen.dart';

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
  final _signupFirstNameController = TextEditingController();
  final _signupLastNameController = TextEditingController();
  final _signupPhoneController = TextEditingController();
  final _signupEmailController = TextEditingController();
  final _signupPasswordController = TextEditingController();
  final _signupConfirmPasswordController = TextEditingController();

  bool _isLoginPasswordVisible = false;
  bool _isSignupPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

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

    // Load saved credentials
    _loadSavedCredentials();
  }

  /// Load saved email and password for auto-fill
  Future<void> _loadSavedCredentials() async {
    final savedEmail = await AuthService.getSavedEmail();
    final savedPassword = await AuthService.getSavedPassword();

    if (savedEmail != null && savedPassword != null) {
      setState(() {
        _loginEmailController.text = savedEmail;
        _loginPasswordController.text = savedPassword;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _signupFirstNameController.dispose();
    _signupLastNameController.dispose();
    _signupPhoneController.dispose();
    _signupEmailController.dispose();
    _signupPasswordController.dispose();
    _signupConfirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_loginFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Use simple AuthService for login
        final result = await AuthService.login(
          _loginEmailController.text.trim(),
          _loginPasswordController.text,
        );

        if (mounted) {
          if (result['STS'] == "200") {
            final userData = result['CONTENT'];
            _navigateToHome();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Welcome back, ${userData['fullName']}!'),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['MSG'] ?? 'Login failed'),
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

  Future<void> _handleSignup() async {
    if (_signupFormKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final result = await AuthService.signup(
          _signupFirstNameController.text.trim(),
          _signupLastNameController.text.trim(),
          _signupPhoneController.text.trim(),
          _signupEmailController.text.trim(),
          _signupPasswordController.text.trim(),
          "https://example.com/profile.jpg", // Default profile picture
        );

        if (mounted) {
          if (result['STS'] == "200") {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome, ${result['CONTENT']['firstName']}! Account created successfully. Please log in.',
                ),
                backgroundColor: Colors.green,
              ),
            );
            _tabController.animateTo(0);

            _loginEmailController.text = _signupEmailController.text;
            _loginPasswordController.text = _signupPasswordController.text;
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(result['MSG'] ?? 'Signup failed'),
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

  Future<void> _navigateToHome() async {
    // Check user role to determine which dashboard to show
    final isAdmin = await AuthService.isAdmin();

    Widget destinationScreen;
    if (isAdmin) {
      // Import the AdminDashboardScreen
      destinationScreen = const AdminDashboardScreen();
    } else {
      destinationScreen = const HomeScreen();
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            destinationScreen,
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
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ForgotPasswordScreen(),
                  ),
                );
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
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, const Color(0xFFD32F2F)],
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
              : CustomButton(text: 'Login', onPressed: () => _handleLogin()),
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
            controller: _signupFirstNameController,
            label: 'First Name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your first name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Reduced from 20
          CustomTextField(
            controller: _signupLastNameController,
            label: 'Last Name',
            icon: Icons.person_outline_rounded,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your last name';
              }
              return null;
            },
          ),
          const SizedBox(height: 16), // Reduced from 20
          CustomTextField(
            controller: _signupPhoneController,
            label: 'Phone Number',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                return 'Phone number must be at least 10 digits';
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
          _isLoading
              ? Container(
                  width: double.infinity,
                  height: 55,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, const Color(0xFFD32F2F)],
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
                  text: 'Create Account',
                  onPressed: () => _handleSignup(),
                ),
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
