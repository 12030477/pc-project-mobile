import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/currency.dart';

/// Fetches live exchange rates and provides safe fallbacks.
class ExchangeRateService {
  ExchangeRateService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  static const _endpoint = 'https://api.exchangerate-api.com/v4/latest/USD';

  /// Retrieves exchange rates from the public API.
  /// Throws an [ExchangeRateException] when the response is invalid or
  /// something goes wrong at the network layer.
  Future<Map<String, double>> fetchRates() async {
    try {
      final response = await _client
          .get(Uri.parse(_endpoint))
          .timeout(const Duration(seconds: 15));

      if (response.statusCode != 200) {
        throw ExchangeRateException(
            'Failed with status ${response.statusCode}');
      }

      final body = json.decode(response.body);
      final rates = Map<String, double>.from(body['rates'] ?? {});

      final eurRate = rates['EUR'] ?? 0.0;
      if (eurRate <= 0 || eurRate == 1.0) {
        throw ExchangeRateException('Received suspicious currency data');
      }

      rates['USD'] = 1.0;
      return rates;
    } catch (error) {
      throw ExchangeRateException(error.toString());
    }
  }

  /// Generates a fallback map that keeps the UI functional offline.
  Map<String, double> fallbackRates(List<Currency> currencies) {
    final rates = <String, double>{};
    for (final currency in currencies) {
      rates[currency.code] = 1.0;
    }
    rates['USD'] = 1.0;
    return rates;
  }
}

class ExchangeRateException implements Exception {
  final String message;

  ExchangeRateException(this.message);

  @override
  String toString() => 'ExchangeRateException: $message';
}
