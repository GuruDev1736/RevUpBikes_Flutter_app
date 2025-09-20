import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'dart:convert';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userDataKey = 'user_data';
  static const String _emailKey = 'saved_email';
  static const String _passwordKey = 'saved_password';
  static const String _baseUrl = 'https://api.revupbikes.com';

  // Simple Dio instance for API calls
  static final Dio _dio =
      Dio(
          BaseOptions(
            baseUrl: _baseUrl,
            connectTimeout: const Duration(milliseconds: 30000),
            receiveTimeout: const Duration(milliseconds: 30000),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
          ),
        )
        ..interceptors.add(
          LogInterceptor(
            request: true, // log request method & URL
            requestHeader: true, // log request headers
            requestBody: true, // log request body
            responseHeader: true, // log response headers
            responseBody: true, // log response body
            error: true, // log errors
          ),
        );

  /// Login user with email and password
  /// Returns Map with 'success', 'message', and user data if successful
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        final userData = response.data;
        await _saveAuthData(userData);
        // Save email and password for auto-fill
        await _saveCredentials(email, password);
        return userData;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Login failed'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Login failed';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'MSG': errorMessage};
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  static Future<Map<String, dynamic>> signup(
    String firstName,
    String lastName,
    String phoneNumber,
    String email,
    String password,
    String profilePicture,
  ) async {
    try {
      final response = await _dio.post(
        '/api/auth/user/register',
        data: {
          "firstName": firstName,
          "lastName": lastName,
          "phoneNumber": phoneNumber,
          "email": email,
          "password": password,
          "profilePicture": profilePicture,
        },
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Signup failed'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Signup failed';
      if (e.response?.statusCode == 401) {
        errorMessage = 'Invalid email or password';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'MSG': errorMessage};
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Send forgot password OTP to user's email
  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    try {
      final response = await _dio.post(
        '/api/forgot-password/send-otp?email=$email',
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to send OTP'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Failed to send OTP';
      if (e.response?.statusCode == 404) {
        errorMessage = 'Email address not found';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'MSG': errorMessage};
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Verify OTP for password reset
  static Future<Map<String, dynamic>> verifyOTP(
    String email,
    String otp,
  ) async {
    try {
      final response = await _dio.post(
        '/api/forgot-password/verify-otp?email=$email&otp=$otp',
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Invalid OTP'};
      }
    } on DioException catch (e) {
      String errorMessage = 'OTP verification failed';
      if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid or expired OTP';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'MSG': errorMessage};
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Reset password with new password
  static Future<Map<String, dynamic>> resetPassword(
    String email,
    String otp,
    String newPassword,
  ) async {
    try {
      final response = await _dio.post(
        '/api/forgot-password/reset-password?email=$email&newPassword=$newPassword',
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to reset password'};
      }
    } on DioException catch (e) {
      String errorMessage = 'Password reset failed';
      if (e.response?.statusCode == 400) {
        errorMessage = 'Invalid or expired OTP';
      } else if (e.response?.statusCode == 500) {
        errorMessage = 'Server error. Please try again later';
      } else if (e.type == DioExceptionType.connectionTimeout) {
        errorMessage = 'Connection timeout. Check your internet connection';
      } else if (e.type == DioExceptionType.connectionError) {
        errorMessage = 'No internet connection';
      }

      return {'MSG': errorMessage};
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Save authentication data to local storage
  static Future<void> _saveAuthData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, userData['token'] ?? '');
    await prefs.setString(_userDataKey, jsonEncode(userData));
  }

  /// Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    return token != null && token.isNotEmpty;
  }

  /// Get stored auth token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Get stored user data as raw Map
  static Future<Map<String, dynamic>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userDataString = prefs.getString(_userDataKey);

    if (userDataString != null) {
      try {
        return jsonDecode(userDataString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Save email and password for auto-fill
  static Future<void> _saveCredentials(String email, String password) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_emailKey, email);
    await prefs.setString(_passwordKey, password);
  }

  /// Get saved email for auto-fill
  static Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Get saved password for auto-fill
  static Future<String?> getSavedPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_passwordKey);
  }

  /// Clear saved credentials (for privacy/security)
  static Future<void> clearSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
  }

  /// Logout user and clear stored data
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_passwordKey);
    print('🚪 User logged out successfully');
  }
}

class LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print("➡️ REQUEST [${options.method}] => PATH: ${options.path}");
    print("Headers: ${options.headers}");
    print("Body: ${options.data}");
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    print(
      "✅ RESPONSE [${response.statusCode}] => PATH: ${response.requestOptions.path}",
    );
    print("Data: ${response.data}");
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print(
      "❌ ERROR [${err.response?.statusCode}] => PATH: ${err.requestOptions.path}",
    );
    print("Message: ${err.message}");
    super.onError(err, handler);
  }
}
