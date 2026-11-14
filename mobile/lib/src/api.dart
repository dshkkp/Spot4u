import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'models.dart';

abstract interface class Spot4uApi {
  Future<List<Campus>> campuses();
  Future<SearchResult> search(SearchCriteria criteria);
}

class ApiException implements Exception {
  const ApiException(this.message);
  final String message;

  @override
  String toString() => message;
}

class HttpSpot4uApi implements Spot4uApi {
  HttpSpot4uApi({String? baseUrl, http.Client? client})
    : baseUrl = (baseUrl ?? defaultBaseUrl).replaceFirst(RegExp(r'/$'), ''),
      _client = client ?? http.Client();

  final String baseUrl;
  final http.Client _client;

  static String get defaultBaseUrl {
    const configured = String.fromEnvironment('SPOT4U_API_URL');
    if (configured.isNotEmpty) return configured;
    if (kIsWeb) return '/';
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8000'
        : 'http://localhost:8000';
  }

  @override
  Future<List<Campus>> campuses() async {
    final data = await _sendRequest(() => _client.get(Uri.parse('$baseUrl/api/v1/campuses')));
    return (data as List<dynamic>)
        .map((value) => Campus.fromJson(value as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<SearchResult> search(SearchCriteria criteria) async {
    final data = await _sendRequest(
      () => _client.post(
        Uri.parse('$baseUrl/api/v1/search'),
        headers: const {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(criteria.toJson()),
      ),
    );
    return SearchResult.fromJson(data as Map<String, dynamic>);
  }

  Future<dynamic> _sendRequest(Future<http.Response> Function() request) async {
    try {
      final response = await request().timeout(const Duration(seconds: 15));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw const ApiException('Сервер вернул ошибку. Попробуйте ещё раз.');
      }
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on ApiException {
      rethrow;
    } on TimeoutException {
      throw const ApiException('Сервер не ответил вовремя. Проверьте соединение.');
    } on Object {
      throw const ApiException('Не удалось связаться с сервером. Проверьте соединение.');
    }
  }
}
