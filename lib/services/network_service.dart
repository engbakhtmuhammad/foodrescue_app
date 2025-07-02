import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'error_handling_service.dart';

class NetworkService {
  static const Duration _defaultTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;
  
  // Check network connectivity
  static Future<bool> isConnected() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      return connectivityResult != ConnectivityResult.none;
    } catch (e) {
      return false;
    }
  }

  // Generic HTTP request with error handling and retry
  static Future<http.Response> makeRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
    int? maxRetries,
  }) async {
    // Check connectivity first
    if (!await isConnected()) {
      throw const SocketException('No internet connection');
    }

    return await ErrorHandlingService.retryOperation(
      () => _performRequest(
        method: method,
        url: url,
        headers: headers,
        body: body,
        timeout: timeout ?? _defaultTimeout,
      ),
      maxRetries: maxRetries ?? _maxRetries,
      shouldRetry: (error) => _shouldRetryRequest(error),
    );
  }

  static Future<http.Response> _performRequest({
    required String method,
    required String url,
    Map<String, String>? headers,
    dynamic body,
    required Duration timeout,
  }) async {
    final uri = Uri.parse(url);
    final defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (headers != null) {
      defaultHeaders.addAll(headers);
    }

    http.Response response;

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          response = await http.get(uri, headers: defaultHeaders).timeout(timeout);
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: defaultHeaders,
            body: body is String ? body : json.encode(body),
          ).timeout(timeout);
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: defaultHeaders,
            body: body is String ? body : json.encode(body),
          ).timeout(timeout);
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: defaultHeaders).timeout(timeout);
          break;
        default:
          throw ArgumentError('Unsupported HTTP method: $method');
      }

      // Log request/response in debug mode
      if (kDebugMode) {
        debugPrint('Request: $method $url');
        debugPrint('Response: ${response.statusCode} ${response.body}');
      }

      // Handle HTTP errors
      if (response.statusCode >= 400) {
        await _handleHttpError(response);
      }

      return response;
    } on SocketException catch (e) {
      final error = ErrorHandlingService.handleNetworkError(e);
      await ErrorHandlingService.recordError(e, StackTrace.current);
      throw error;
    } on HttpException catch (e) {
      final error = ErrorHandlingService.handleNetworkError(e);
      await ErrorHandlingService.recordError(e, StackTrace.current);
      throw error;
    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  static Future<void> _handleHttpError(http.Response response) async {
    String message = 'HTTP Error ${response.statusCode}';
    
    try {
      final responseBody = json.decode(response.body);
      if (responseBody is Map && responseBody.containsKey('message')) {
        message = responseBody['message'];
      } else if (responseBody is Map && responseBody.containsKey('error')) {
        message = responseBody['error'];
      }
    } catch (e) {
      // Response body is not JSON, use status code message
    }

    final error = AppError(
      code: 'http_${response.statusCode}',
      message: message,
      details: response.body,
      type: ErrorType.network,
      severity: response.statusCode >= 500 ? ErrorSeverity.high : ErrorSeverity.medium,
    );

    await ErrorHandlingService.recordError(error, StackTrace.current);
    throw error;
  }

  static bool _shouldRetryRequest(dynamic error) {
    // Retry on network errors but not on client errors (4xx)
    if (error is SocketException) return true;
    if (error is HttpException) return true;
    if (error is AppError) {
      return error.type == ErrorType.network && 
             !error.code.startsWith('http_4'); // Don't retry 4xx errors
    }
    return false;
  }

  // Convenience methods
  static Future<http.Response> get(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return makeRequest(
      method: 'GET',
      url: url,
      headers: headers,
      timeout: timeout,
    );
  }

  static Future<http.Response> post(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
  }) {
    return makeRequest(
      method: 'POST',
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  static Future<http.Response> put(
    String url, {
    Map<String, String>? headers,
    dynamic body,
    Duration? timeout,
  }) {
    return makeRequest(
      method: 'PUT',
      url: url,
      headers: headers,
      body: body,
      timeout: timeout,
    );
  }

  static Future<http.Response> delete(
    String url, {
    Map<String, String>? headers,
    Duration? timeout,
  }) {
    return makeRequest(
      method: 'DELETE',
      url: url,
      headers: headers,
      timeout: timeout,
    );
  }

  // Upload file with progress tracking
  static Future<http.StreamedResponse> uploadFile({
    required String url,
    required String filePath,
    required String fieldName,
    Map<String, String>? headers,
    Map<String, String>? fields,
    Function(int sent, int total)? onProgress,
  }) async {
    if (!await isConnected()) {
      throw const SocketException('No internet connection');
    }

    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      
      if (headers != null) {
        request.headers.addAll(headers);
      }
      
      if (fields != null) {
        request.fields.addAll(fields);
      }

      final file = await http.MultipartFile.fromPath(fieldName, filePath);
      request.files.add(file);

      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        await _handleHttpError(response);
      }

      return streamedResponse;
    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      rethrow;
    }
  }

  // Download file with progress tracking
  static Future<void> downloadFile({
    required String url,
    required String savePath,
    Map<String, String>? headers,
    Function(int received, int total)? onProgress,
  }) async {
    if (!await isConnected()) {
      throw const SocketException('No internet connection');
    }

    try {
      final request = http.Request('GET', Uri.parse(url));
      if (headers != null) {
        request.headers.addAll(headers);
      }

      final streamedResponse = await request.send();
      
      if (streamedResponse.statusCode >= 400) {
        final response = await http.Response.fromStream(streamedResponse);
        await _handleHttpError(response);
      }

      final file = File(savePath);
      final sink = file.openWrite();
      
      int received = 0;
      final total = streamedResponse.contentLength ?? 0;

      await for (final chunk in streamedResponse.stream) {
        sink.add(chunk);
        received += chunk.length;
        onProgress?.call(received, total);
      }

      await sink.close();
    } catch (e) {
      await ErrorHandlingService.recordError(e, StackTrace.current);
      rethrow;
    }
  }
}
