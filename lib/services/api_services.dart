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
        ..interceptors.addAll([
          // Auth token interceptor - automatically adds token to headers
          AuthTokenInterceptor(),
          LogInterceptor(
            request: true, // log request method & URL
            requestHeader: true, // log request headers
            requestBody: true, // log request body
            responseHeader: true, // log response headers
            responseBody: true, // log response body
            error: true, // log errors
          ),
        ]);

  /// Login user with email and password
  /// Returns Map with 'success', 'message', and user data if successful
  static Future<Map<String, dynamic>> login(
    String email,
    String password, {
    bool saveCredentials = true,
  }) async {
    try {
      final response = await _dio.post(
        '/api/auth/login',
        data: {'email': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        final userData = response.data;
        await _saveAuthData(userData);
        // Save email and password for auto-fill only if requested
        if (saveCredentials) {
          await _saveCredentials(email, password);
        }
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

  /// Get all places (requires auth token)
  static Future<Map<String, dynamic>> getAllPlaces() async {
    try {
      final response = await _dio.get('/api/places/all');

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to fetch places'};
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(e, 'Failed to fetch places');
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Get all bikes (requires auth token)
  static Future<Map<String, dynamic>> getAllBikes() async {
    try {
      final response = await _dio.get('/api/bikes/all');

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to fetch bikes'};
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(e, 'Failed to fetch bikes');
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  /// Get bikes by place ID (requires auth token)
  static Future<Map<String, dynamic>> getBikesByPlace(int placeId) async {
    try {
      final response = await _dio.get('/api/bikes/place/$placeId');

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {
          'MSG': response.data['MSG'] ?? 'Failed to fetch bikes for this place',
        };
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(
        e,
        'Failed to fetch bikes for this place',
      );
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  static Future<Map<String, dynamic>> uploadFile(
    String fileName,
    String fileData,
    String userId,
  ) async {
    try {
      final response = await _dio.post(
        '/api/upload',
        data: {"fileName": fileName, "fileData": fileData, "userId": userId},
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to upload file'};
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(e, 'Failed to upload file');
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

  static Future<Map<String, dynamic>> createBooking(
    String bikeId,
    String userId,
    String startDateTime,
    String endDateTime,
    String paymentId,
    double totalAmount,
    String aadharcardUrl,
    String drivingLicenseUrl
  ) async {
    try {
      final response = await _dio.post(
        '/api/bookings/create?userId=$userId&bikeId=$bikeId',
        data: {
          "startDateTime": startDateTime,
          "endDateTime": endDateTime,
          "paymentId": paymentId,
          "totalAmount": totalAmount,
          "aadharcardUrl": aadharcardUrl,
          "drivingLicenseUrl": drivingLicenseUrl,
        },
      );

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {
        return {'MSG': response.data['MSG'] ?? 'Failed to create booking'};
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(e, 'Failed to create booking');
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }

static Future<Map<String, dynamic>> getAllBanners() async {
    try {
      final response = await _dio.get('/api/banners/all');

      if (response.statusCode == 200 && response.data['STS'] == '200') {
        return response.data;
      } else {  
        return {
          'MSG': response.data['MSG'] ?? 'Failed to fetch banners',
        };
      }
    } on DioException catch (e) {
      return _handleAuthenticatedError(
        e,
        'Failed to fetch banners',
      );
    } catch (e) {
      return {'MSG': 'An unexpected error occurred'};
    }
  }






  /// Helper method to handle errors for authenticated requests
  static Map<String, dynamic> _handleAuthenticatedError(
    DioException e,
    String defaultMessage,
  ) {
    String errorMessage = defaultMessage;
    if (e.response?.statusCode == 401) {
      errorMessage = 'Unauthorized. Please login again';
    } else if (e.response?.statusCode == 403) {
      errorMessage = 'Access forbidden. Insufficient permissions';
    } else if (e.response?.statusCode == 500) {
      errorMessage = 'Server error. Please try again later';
    } else if (e.type == DioExceptionType.connectionTimeout) {
      errorMessage = 'Connection timeout. Check your internet connection';
    } else if (e.type == DioExceptionType.connectionError) {
      errorMessage = 'No internet connection';
    }

    return {'MSG': errorMessage};
  }

  /// Save authentication data to local storage
  static Future<void> _saveAuthData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();

    // Extract token from various possible locations in the response
    String? token;
    if (userData['token'] != null) {
      token = userData['token'];
    } else if (userData['CONTENT'] != null &&
        userData['CONTENT']['token'] != null) {
      token = userData['CONTENT']['token'];
    } else if (userData['access_token'] != null) {
      token = userData['access_token'];
    }

    await prefs.setString(_tokenKey, token ?? '');
    await prefs.setString(_userDataKey, jsonEncode(userData));

    print(
      '💾 Auth data saved - Token: ${token != null ? "${token.substring(0, 10)}..." : "null"}',
    );
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

  /// Get user role from stored data
  static Future<String?> getUserRole() async {
    final userData = await getUserData();
    if (userData != null && userData['CONTENT'] != null) {
      return userData['CONTENT']['userRole'];
    }
    return null;
  }

  /// Check if user is admin
  static Future<bool> isAdmin() async {
    final role = await getUserRole();
    return role == 'ROLE_ADMIN';
  }

  /// Check if user is regular user
  static Future<bool> isUser() async {
    final role = await getUserRole();
    return role == 'ROLE_USER';
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
    print('🧹 Saved credentials cleared');
  }

  /// Check if credentials are saved
  static Future<bool> hasCredentialsSaved() async {
    final email = await getSavedEmail();
    final password = await getSavedPassword();
    return email != null &&
        password != null &&
        email.isNotEmpty &&
        password.isNotEmpty;
  }

  /// Update the stored auth token
  static Future<void> updateToken(String newToken) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, newToken);
    print('🔄 Auth token updated');
  }

  /// Check if the stored token is valid (basic check)
  static Future<bool> isTokenValid() async {
    final token = await getToken();
    if (token == null || token.isEmpty) {
      return false;
    }

    // You can add more sophisticated token validation here
    // For example, checking expiration date if it's a JWT token
    return true;
  }

  /// Refresh token headers manually (useful for testing)
  static Future<void> refreshTokenHeaders() async {
    final token = await getToken();
    if (token != null && token.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer $token';
      print('🔄 Token headers refreshed manually');
    }
  }

  /// Debug method to check token status
  static Future<void> debugTokenStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_tokenKey);
    final userData = prefs.getString(_userDataKey);

    print('🔍 DEBUG TOKEN STATUS:');
    print('Token exists: ${token != null}');
    print('Token length: ${token?.length ?? 0}');
    print(
      'Token preview: ${token != null && token.length > 10 ? "${token.substring(0, 10)}..." : token}',
    );
    print('User data exists: ${userData != null}');
    print('Is logged in: ${await isLoggedIn()}');
  }

  /// Test method to verify token is being added to headers
  static Future<Map<String, dynamic>> testTokenHeader() async {
    try {
      print('🧪 Testing token header...');
      await debugTokenStatus();

      await _dio.get(
        '/api/test-auth',
      ); // This endpoint may not exist, that's ok
      return {'success': true, 'message': 'Token header test completed'};
    } on DioException catch (e) {
      print(
        '🧪 Test completed with DioException (expected if endpoint doesn\'t exist)',
      );
      print('Request headers were: ${e.requestOptions.headers}');
      return {
        'success': true,
        'message': 'Token header test completed with error (check logs)',
      };
    } catch (e) {
      return {'success': false, 'message': 'Test failed: $e'};
    }
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

  /// Clear only authentication tokens and user data, preserve saved credentials
  static Future<void> clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userDataKey);
    print('🔄 Auth data cleared, credentials preserved');
  }
}

/// Interceptor to automatically add auth token to requests
class AuthTokenInterceptor extends Interceptor {
  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Get the token from SharedPreferences using the public method
    final token = await AuthService.getToken();

    // Add token to Authorization header if it exists
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
      print(
        "🔐 Token added to request: ${options.path} - Token: ${token.substring(0, 10)}...",
      );
    } else {
      print("⚠️ No token found for request: ${options.path}");
    }

    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Handle 401 Unauthorized - could trigger logout if needed
    if (err.response?.statusCode == 401) {
      print("🚫 Unauthorized request - token may be invalid or expired");
      // You could add automatic logout here if needed:
      // AuthService.logout();
    }
    super.onError(err, handler);
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
