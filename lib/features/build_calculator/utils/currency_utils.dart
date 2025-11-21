import '../models/currency.dart';

class CurrencyUtils {
  const CurrencyUtils({
    required this.selectedCurrency,
    required this.exchangeRates,
  });

  final Currency selectedCurrency;
  final Map<String, double> exchangeRates;

  double convertFromUsd(double usdAmount) {
    final rate = exchangeRates[selectedCurrency.code] ?? 1.0;
    return usdAmount * rate;
  }

  double convertToUsd(double amountInSelectedCurrency) {
    final rate = exchangeRates[selectedCurrency.code] ?? 1.0;
    if (rate == 0) return 0;
    return amountInSelectedCurrency / rate;
  }

  String get symbol => selectedCurrency.symbol;
}
