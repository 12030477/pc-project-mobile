import 'currency.dart';

/// Hard-coded list of supported currencies used across the calculator UI.
/// Keeping it in a dedicated file makes it trivial to add/remove currencies
/// without sifting through widget code.
const List<Currency> supportedCurrencies = [
  Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
  Currency(code: 'EUR', name: 'Euro', symbol: '€'),
  Currency(code: 'GBP', name: 'British Pound', symbol: '£'),
  Currency(code: 'JPY', name: 'Japanese Yen', symbol: '¥'),
  Currency(code: 'CAD', name: 'Canadian Dollar', symbol: 'C\$'),
  Currency(code: 'AUD', name: 'Australian Dollar', symbol: 'A\$'),
  Currency(code: 'CHF', name: 'Swiss Franc', symbol: 'Fr'),
  Currency(code: 'CNY', name: 'Chinese Yuan', symbol: '¥'),
  Currency(code: 'INR', name: 'Indian Rupee', symbol: '₹'),
  Currency(code: 'BRL', name: 'Brazilian Real', symbol: 'R\$'),
  Currency(code: 'KRW', name: 'South Korean Won', symbol: '₩'),
  Currency(code: 'MXN', name: 'Mexican Peso', symbol: '\$'),
  Currency(code: 'SAR', name: 'Saudi Riyal', symbol: 'ر.س'),
  Currency(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ'),
  Currency(code: 'ZAR', name: 'South African Rand', symbol: 'R'),
];
