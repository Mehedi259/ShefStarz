import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'api_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../routes/app_pages.dart';

class ApiClient extends GetxService {
  static ApiClient get to => Get.find();

  final http.Client _client = http.Client();
  final _storage = const FlutterSecureStorage();

  dynamic _decodeBody(String body) {
    try {
      if (body.isEmpty) return null;
      return jsonDecode(body);
    } catch (_) {
      return body;
    }
  }

  void _logRequest(
    String method,
    Uri url,
    dynamic body,
    Map<String, String> headers,
  ) {
    Get.log('➡️ [$method] $url');
    Get.log('   HEADERS: $headers');
    if (body != null) Get.log('   BODY: $body');
  }

  void _logResponse(http.Response res) {
    Get.log('⬅️ [${res.statusCode}] ${res.request?.url}');
    if (res.statusCode >= 400) {
      Get.log('🔴 ERROR: ${res.statusCode} - ${res.reasonPhrase}');
      Get.log('   RESPONSE BODY: ${res.body}');
    } else {
      Get.log('   RESPONSE BODY: ${res.body}');
    }
  }

  void _logError(dynamic error, Uri url) {
    Get.log('🔴 EXCEPTION on $url: $error');
  }

  void _showTimeoutError() {
    Get.snackbar(
      'Connection timed out',
      'Please check your internet or try again later.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
      icon: const Icon(Icons.wifi_off, color: Colors.white),
    );
  }

  void _logoutUser() {
    Get.log('🔴 401 Unauthorized globally intercepted. Logging out user...');
    _storage.deleteAll().then((_) {
      Get.offAllNamed(Routes.LOGIN);
    });
  }

  Future<bool> _refreshToken() async {
    final refreshTokenVal = await _storage.read(key: 'refresh_token');
    if (refreshTokenVal == null || refreshTokenVal.isEmpty) return false;

    try {
      final url = Uri.parse('${ApiConfig.baseUrl}users/auth/refresh/'); 
      final res = await _client.post(
        url,
        headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
        body: jsonEncode({'refresh': refreshTokenVal}),
      ).timeout(const Duration(seconds: 15));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['access'] != null) {
          await _storage.write(key: 'access_token', value: data['access']);
          if (data['refresh'] != null) {
            await _storage.write(key: 'refresh_token', value: data['refresh']);
          }
          return true;
        }
      }
    } catch (e) {
      Get.log('🔴 Refresh token error: $e');
    }
    return false;
  }

  Future<Response> getRequest(String path, {bool requiresAuth = true}) async {
    final url = Uri.parse(
      !path.startsWith('http') ? '${ApiConfig.baseUrl}$path' : path,
    );

    final token = await _storage.read(key: 'access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };

    _logRequest('GET', url, null, headers);

    try {
      var res = await _client
          .get(url, headers: headers)
          .timeout(ApiConfig.timeout);

      if (res.statusCode == 401 && requiresAuth) {
        Get.log('🟡 401 Unauthorized captured. Attempting to refresh token...');
        if (await _refreshToken()) {
           final newToken = await _storage.read(key: 'access_token');
           headers['Authorization'] = 'Bearer $newToken';
           Get.log('🔄 Retrying GET Request...');
           res = await _client.get(url, headers: headers).timeout(ApiConfig.timeout);
        } else {
           _logoutUser();
           return const Response(statusCode: 401, statusText: 'Unauthorized');
        }
      }

      _logResponse(res);
      return _handleResponse(res);
    } on TimeoutException {
      _logError('TimeoutException', url);
      _showTimeoutError();
      return const Response(statusCode: 408, statusText: 'Request timeout');
    } on SocketException {
      _logError('SocketException', url);
      return const Response(
        statusCode: 503,
        statusText: 'No internet connection',
      );
    } catch (e) {
      _logError(e, url);
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> postRequest(
    String path,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(
      !path.startsWith('http') ? '${ApiConfig.baseUrl}$path' : path,
    );

    final token = await _storage.read(key: 'access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };

    final encodedData = jsonEncode(data);
    _logRequest('POST', url, encodedData, headers);

    try {
      var res = await _client
          .post(url, headers: headers, body: encodedData)
          .timeout(ApiConfig.timeout);

      if (res.statusCode == 401 && requiresAuth) {
        Get.log('🟡 401 Unauthorized captured. Attempting to refresh token...');
        if (await _refreshToken()) {
           final newToken = await _storage.read(key: 'access_token');
           headers['Authorization'] = 'Bearer $newToken';
           Get.log('🔄 Retrying POST Request...');
           res = await _client.post(url, headers: headers, body: encodedData).timeout(ApiConfig.timeout);
        } else {
           _logoutUser();
           return const Response(statusCode: 401, statusText: 'Unauthorized');
        }
      }

      _logResponse(res);
      return _handleResponse(res);
    } on TimeoutException {
      _logError('TimeoutException', url);
      _showTimeoutError();
      return const Response(statusCode: 408, statusText: 'Request timeout');
    } on SocketException {
      _logError('SocketException', url);
      return const Response(
        statusCode: 503,
        statusText: 'No internet connection',
      );
    } catch (e) {
      _logError(e, url);
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> patchRequest(
    String path,
    dynamic data, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(
      !path.startsWith('http') ? '${ApiConfig.baseUrl}$path' : path,
    );

    final token = await _storage.read(key: 'access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };

    final encodedData = jsonEncode(data);
    _logRequest('PATCH', url, encodedData, headers);

    try {
      var res = await _client
          .patch(url, headers: headers, body: encodedData)
          .timeout(ApiConfig.timeout);

      if (res.statusCode == 401 && requiresAuth) {
        Get.log('🟡 401 Unauthorized captured. Attempting to refresh token...');
        if (await _refreshToken()) {
           final newToken = await _storage.read(key: 'access_token');
           headers['Authorization'] = 'Bearer $newToken';
           Get.log('🔄 Retrying PATCH Request...');
           res = await _client.patch(url, headers: headers, body: encodedData).timeout(ApiConfig.timeout);
        } else {
           _logoutUser();
           return const Response(statusCode: 401, statusText: 'Unauthorized');
        }
      }

      _logResponse(res);
      return _handleResponse(res);
    } on TimeoutException {
      _logError('TimeoutException', url);
      _showTimeoutError();
      return const Response(statusCode: 408, statusText: 'Request timeout');
    } on SocketException {
      _logError('SocketException', url);
      return const Response(
        statusCode: 503,
        statusText: 'No internet connection',
      );
    } catch (e) {
      _logError(e, url);
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> deleteRequest(
    String path, {
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(
      !path.startsWith('http') ? '${ApiConfig.baseUrl}$path' : path,
    );

    final token = await _storage.read(key: 'access_token');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    };

    _logRequest('DELETE', url, null, headers);

    try {
      var res = await _client
          .delete(url, headers: headers)
          .timeout(ApiConfig.timeout);

      if (res.statusCode == 401 && requiresAuth) {
        Get.log('🟡 401 Unauthorized captured. Attempting to refresh token...');
        if (await _refreshToken()) {
           final newToken = await _storage.read(key: 'access_token');
           headers['Authorization'] = 'Bearer $newToken';
           Get.log('🔄 Retrying DELETE Request...');
           res = await _client.delete(url, headers: headers).timeout(ApiConfig.timeout);
        } else {
           _logoutUser();
           return const Response(statusCode: 401, statusText: 'Unauthorized');
        }
      }

      _logResponse(res);
      return _handleResponse(res);
    } on TimeoutException {
      _logError('TimeoutException', url);
      _showTimeoutError();
      return const Response(statusCode: 408, statusText: 'Request timeout');
    } on SocketException {
      _logError('SocketException', url);
      return const Response(
        statusCode: 503,
        statusText: 'No internet connection',
      );
    } catch (e) {
      _logError(e, url);
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> multipartRequest(
    String method,
    String path,
    Map<String, String> fields, {
    File? file,
    String fileKey = 'media',
    List<http.MultipartFile>? extraFiles,
    bool requiresAuth = true,
  }) async {
    final url = Uri.parse(
      !path.startsWith('http') ? '${ApiConfig.baseUrl}$path' : path,
    );

    final token = await _storage.read(key: 'access_token');

    final request = http.MultipartRequest(method, url);
    request.headers.addAll({
      'Accept': 'application/json',
      if (requiresAuth && token != null) 'Authorization': 'Bearer $token',
    });

    request.fields.addAll(fields);

    if (file != null) {
      request.files.add(await http.MultipartFile.fromPath(fileKey, file.path));
    }

    if (extraFiles != null && extraFiles.isNotEmpty) {
      request.files.addAll(extraFiles);
    }

    _logRequest(
      method,
      url,
      fields.toString() + (file != null ? ' (File Attached)' : ''),
      request.headers,
    );

    try {
      final streamedResponse = await request.send().timeout(ApiConfig.timeout);
      var res = await http.Response.fromStream(streamedResponse);

      if (res.statusCode == 401 && requiresAuth) {
        Get.log('🟡 401 Unauthorized captured in Multipart. Attempting to refresh token...');
        if (await _refreshToken()) {
           final newToken = await _storage.read(key: 'access_token');
           
           final retryRequest = http.MultipartRequest(method, url);
           retryRequest.headers.addAll({
             'Accept': 'application/json',
             if (newToken != null) 'Authorization': 'Bearer $newToken',
           });
           retryRequest.fields.addAll(fields);
           if (file != null) {
             retryRequest.files.add(await http.MultipartFile.fromPath(fileKey, file.path));
           }
           
           Get.log('🔄 Retrying MULTIPART Request...');
           final retryStreamedResponse = await retryRequest.send().timeout(ApiConfig.timeout);
           res = await http.Response.fromStream(retryStreamedResponse);
        } else {
           _logoutUser();
           return const Response(statusCode: 401, statusText: 'Unauthorized');
        }
      }

      _logResponse(res);
      return _handleResponse(res);
    } on TimeoutException {
      _logError('TimeoutException', url);
      _showTimeoutError();
      return const Response(statusCode: 408, statusText: 'Request timeout');
    } on SocketException {
      _logError('SocketException', url);
      return const Response(
        statusCode: 503,
        statusText: 'No internet connection',
      );
    } catch (e) {
      _logError(e, url);
      return Response(statusCode: 500, statusText: e.toString());
    }
  }

  Future<Response> putMultipartRequest(
    String path,
    Map<String, String> fields, {
    File? file,
    String fileKey = 'media',
    List<http.MultipartFile>? extraFiles,
    bool requiresAuth = true,
  }) async {
    return multipartRequest(
      'PUT',
      path,
      fields,
      file: file,
      fileKey: fileKey,
      extraFiles: extraFiles,
      requiresAuth: requiresAuth,
    );
  }

  Future<Response> patchMultipartRequest(
    String path,
    Map<String, String> fields, {
    File? file,
    String fileKey = 'media',
    List<http.MultipartFile>? extraFiles,
    bool requiresAuth = true,
  }) async {
    return multipartRequest(
      'PATCH',
      path,
      fields,
      file: file,
      fileKey: fileKey,
      extraFiles: extraFiles,
      requiresAuth: requiresAuth,
    );
  }

  Response _handleResponse(http.Response res) {
    // Note: 401 interception and logout is now handled within each request method directly to allow for token refreshes before logging out!

    return Response(
      statusCode: res.statusCode,
      body: _decodeBody(res.body),
      statusText: res.reasonPhrase,
    );
  }
}
