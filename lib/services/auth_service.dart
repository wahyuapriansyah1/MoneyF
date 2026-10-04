import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthResult {
  final bool isSuccess;
  final String? token;
  final String message;
  final Map<String, dynamic>? user;
  final Map<String, dynamic>? errors;

  const AuthResult({
    required this.isSuccess,
    this.token,
    required this.message,
    this.user,
    this.errors,
  });
}

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _emailKey = 'auth_user_email';
  static const String _nameKey = 'auth_user_name';

  static const String primaryLoginUrl = 'https://authr4.vercel.app/index.php/api/login';
  static const String fallbackLoginUrl = 'https://authr4.vercel.app/api/login';

  final http.Client _client;

  AuthService({http.Client? client}) : _client = client ?? http.Client();

  /// Melakukan request login ke API Auth eksternal
  Future<AuthResult> login({
    required String email,
    required String password,
  }) async {
    final cleanEmail = email.trim();
    final cleanPassword = password.trim();

    final bodyJson = jsonEncode({
      'email': cleanEmail,
      'password': cleanPassword,
    });

    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    // Mencoba endpoint utama terlebih dahulu, dengan fallback jika 404
    try {
      var response = await _client
          .post(
            Uri.parse(primaryLoginUrl),
            headers: headers,
            body: bodyJson,
          )
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 404) {
        response = await _client
            .post(
              Uri.parse(fallbackLoginUrl),
              headers: headers,
              body: bodyJson,
            )
            .timeout(const Duration(seconds: 15));
      }

      return await _handleAuthResponse(response, cleanEmail);
    } on SocketException {
      return const AuthResult(
        isSuccess: false,
        message: 'Tidak ada koneksi internet. Silakan periksa jaringan Anda.',
      );
    } on TimeoutException {
      return const AuthResult(
        isSuccess: false,
        message: 'Koneksi ke server timeout. Silakan coba lagi.',
      );
    } catch (e) {
      return AuthResult(
        isSuccess: false,
        message: 'Terjadi kesalahan sistem: ${e.toString()}',
      );
    }
  }

  Future<AuthResult> _handleAuthResponse(http.Response response, String fallbackEmail) async {
    Map<String, dynamic> responseData = {};
    try {
      if (response.body.isNotEmpty) {
        responseData = jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {
      // Jika body bukan format JSON standar
    }

    final statusCode = response.statusCode;

    if (statusCode == 200 || statusCode == 201) {
      // Ekstraksi token dari berbagai kemungkinan struktur JSON (token, access_token, data.token)
      String? token;
      Map<String, dynamic>? userData;

      if (responseData['token'] != null) {
        token = responseData['token'].toString();
      } else if (responseData['access_token'] != null) {
        token = responseData['access_token'].toString();
      } else if (responseData['data'] is Map) {
        final data = responseData['data'] as Map<String, dynamic>;
        token = data['token']?.toString() ?? data['access_token']?.toString();
        userData = data['user'] is Map ? data['user'] as Map<String, dynamic> : data;
      }

      // Jika API mengembalikan status 200 sukses namun token ada di message/body
      token ??= responseData['data']?.toString() ?? 'auth_session_token';

      final userObj = userData ?? (responseData['user'] is Map ? responseData['user'] as Map<String, dynamic> : null);
      final userName = userObj?['name']?.toString() ?? 'Pengguna MoneyF';

      await saveToken(
        token,
        email: userObj?['email']?.toString() ?? fallbackEmail,
        name: userName,
      );

      return AuthResult(
        isSuccess: true,
        token: token,
        message: responseData['message']?.toString() ?? 'Login berhasil!',
        user: userObj,
      );
    } else if (statusCode == 403) {
      final msg = responseData['message']?.toString() ??
          'Akun Anda belum diverifikasi. Silakan cek email untuk verifikasi.';
      return AuthResult(
        isSuccess: false,
        message: msg,
      );
    } else if (statusCode == 422) {
      String errorMessage = responseData['message']?.toString() ?? 'Email atau password tidak valid.';
      if (responseData['errors'] is Map) {
        final errors = responseData['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        if (firstError is List && firstError.isNotEmpty) {
          errorMessage = firstError.first.toString();
        }
      }
      return AuthResult(
        isSuccess: false,
        message: errorMessage,
        errors: responseData['errors'] is Map ? responseData['errors'] as Map<String, dynamic> : null,
      );
    } else if (statusCode == 401) {
      return AuthResult(
        isSuccess: false,
        message: responseData['message']?.toString() ?? 'Email atau password yang Anda masukkan salah.',
      );
    } else {
      return AuthResult(
        isSuccess: false,
        message: responseData['message']?.toString() ?? 'Login gagal (Kode: $statusCode). Silakan coba lagi.',
      );
    }
  }

  /// Menyimpan token dan info pengguna ke SharedPreferences
  Future<void> saveToken(
    String token, {
    String? email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
    if (email != null) {
      await prefs.setString(_emailKey, email);
    }
    if (name != null) {
      await prefs.setString(_nameKey, name);
    }
  }

  /// Mengambil token tersimpan
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Mengambil email tersimpan
  Future<String?> getSavedEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_emailKey);
  }

  /// Mengambil nama tersimpan
  Future<String?> getSavedName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_nameKey);
  }

  /// Menghapus token (Logout)
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
  }

  /// Mengecek apakah pengguna sudah login
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }
}
