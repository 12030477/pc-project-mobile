import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PC Build Budget Helper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        cardTheme: CardThemeData(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

// Currency model
class Currency {
  final String code;
  final String name;
  final String symbol;

  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });
}

class MyHomePageState extends State<MyHomePage> {
  final TextEditingController cpuController = TextEditingController();
  final TextEditingController gpuController = TextEditingController();
  final TextEditingController ramController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController motherboardController = TextEditingController();
  final TextEditingController caseController = TextEditingController();
  final TextEditingController psuController = TextEditingController();
  final TextEditingController accessoriesController = TextEditingController();
  final TextEditingController cpuTdpController = TextEditingController();
  final TextEditingController gpuTdpController = TextEditingController();

  double totalCost = 0.0;
  int recommendedPsu = 0;
  bool isDarkMode = false;

  // Currency conversion
  final List<Currency> currencies = const [
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

  Currency selectedCurrency =
      const Currency(code: 'USD', name: 'US Dollar', symbol: '\$');
  Map<String, double> exchangeRates = {};
  bool isLoadingRates = false;
  String? rateError;

  @override
  void initState() {
    super.initState();
    // Initialize with USD rates (1.0 for USD)
    exchangeRates['USD'] = 1.0;
    // Load saved theme preference
    _loadThemePreference();
    // Fetch exchange rates on app start
    _fetchExchangeRates();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      isLoadingRates = true;
      rateError = null;
    });

    try {
      // Using exchangerate-api.com free tier (no API key needed for basic usage)
      final response = await http
          .get(
            Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          exchangeRates = Map<String, double>.from(data['rates']);
          exchangeRates['USD'] = 1.0; // Ensure USD is always 1.0
          isLoadingRates = false;
        });
      } else {
        setState(() {
          isLoadingRates = false;
          rateError = 'Failed to load exchange rates';
          // Set default rates (1.0 for all) to allow offline usage
          _setDefaultRates();
        });
      }
    } catch (e) {
      setState(() {
        isLoadingRates = false;
        rateError = 'Could not connect to exchange rate service';
        // Set default rates for offline usage
        _setDefaultRates();
      });
    }
  }

  void _setDefaultRates() {
    // Set all currencies to 1.0 as fallback (will show USD equivalent)
    for (var currency in currencies) {
      exchangeRates[currency.code] = 1.0;
    }
  }

  double convertToCurrency(double amountInUSD) {
    final rate = exchangeRates[selectedCurrency.code] ?? 1.0;
    return amountInUSD * rate;
  }

  String getCurrencySymbol() {
    return selectedCurrency.symbol;
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // Responsive Header
                Builder(
                  builder: (context) {
                    final screenWidth = MediaQuery.of(context).size.width;
                    final isMobile = screenWidth < 600;
                    final isPhone = screenWidth < 480; // Phones only, not tablets
                    
                    if (isMobile) {
                      // Mobile Layout: Logo on left, Currency + buttons on right
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            // Logo + Builder text (only on phones)
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/pcbuilderhelper.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                if (isPhone) ...[
                                  const SizedBox(width: 8),
                                  Text(
                                    'Builder',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.grey[900],
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            const Spacer(),
                            // Currency selector - comfortable size near buttons
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                              constraints: const BoxConstraints(
                                minHeight: 40,
                                maxHeight: 40,
                              ),
                              decoration: BoxDecoration(
                                color:
                                    isDarkMode ? Colors.grey[800] : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isDarkMode
                                      ? Colors.grey[700]!
                                      : Colors.grey[300]!,
                                ),
                              ),
                              child: DropdownButton<Currency>(
                                value: selectedCurrency,
                                underline: const SizedBox(),
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  size: 18,
                                ),
                                dropdownColor:
                                    isDarkMode ? Colors.grey[800] : Colors.white,
                                menuMaxHeight: 200,
                                borderRadius: BorderRadius.circular(12),
                                style: TextStyle(
                                  color: isDarkMode ? Colors.white : Colors.black,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                items: currencies.map((Currency currency) {
                                  return DropdownMenuItem<Currency>(
                                    value: currency,
                                    child: Text(
                                        '${currency.symbol} ${currency.code}'),
                                  );
                                }).toList(),
                                onChanged: (Currency? newCurrency) {
                                  if (newCurrency != null) {
                                    setState(() {
                                      selectedCurrency = newCurrency;
                                      if (totalCost > 0) {
                                        calculateTotal();
                                      }
                                    });
                                  }
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Refresh + Theme buttons
                            Tooltip(
                              message: 'Refresh exchange rates',
                              child: IconButton(
                                icon: isLoadingRates
                                    ? SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600]!,
                                          ),
                                        ),
                                      )
                                    : Icon(
                                        Icons.refresh,
                                        size: 20,
                                        color: isDarkMode
                                            ? Colors.white70
                                            : Colors.grey[700],
                                      ),
                                onPressed:
                                    isLoadingRates ? null : _fetchExchangeRates,
                                style: IconButton.styleFrom(
                                  backgroundColor: isDarkMode
                                      ? Colors.grey[800]
                                      : Colors.white,
                                  elevation: 2,
                                  padding: const EdgeInsets.all(10),
                                  minimumSize: const Size(40, 40),
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            IconButton(
                              icon: Icon(
                                isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                size: 24,
                              ),
                              onPressed: () {
                                setState(() {
                                  isDarkMode = !isDarkMode;
                                });
                                _saveThemePreference(isDarkMode);
                              },
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    isDarkMode ? Colors.grey[800] : Colors.white,
                                elevation: 2,
                                padding: const EdgeInsets.all(10),
                                minimumSize: const Size(40, 40),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      // Desktop/Tablet Layout: Full navbar
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Logo + Title/Subtitle
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                      width: 2,
                                    ),
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.asset(
                                      'assets/pcbuilderhelper.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'PC Build Helper',
                                      style: TextStyle(
                                        fontSize: MediaQuery.of(context).size.width < 900 ? 18 : 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                      ),
                                    ),
                                    Text(
                                      'Calculate your build budget',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isDarkMode
                                            ? Colors.grey[400]
                                            : Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            // Currency Dropdown + Refresh + Theme
                            Row(
                              children: [
                                // Currency selector
                                Container(
                                  width: 150,
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color:
                                        isDarkMode ? Colors.grey[800] : Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(
                                      color: isDarkMode
                                          ? Colors.grey[700]!
                                          : Colors.grey[300]!,
                                    ),
                                  ),
                                  child: DropdownButton<Currency>(
                                    value: selectedCurrency,
                                    underline: const SizedBox(),
                                    icon: Icon(
                                      Icons.arrow_drop_down,
                                      color: isDarkMode ? Colors.white : Colors.black,
                                    ),
                                    dropdownColor:
                                        isDarkMode ? Colors.grey[800] : Colors.white,
                                    menuMaxHeight: 200,
                                    borderRadius: BorderRadius.circular(12),
                                    style: TextStyle(
                                      color: isDarkMode ? Colors.white : Colors.black,
                                      fontSize: 14,
                                    ),
                                    isExpanded: true,
                                    items: currencies.map((Currency currency) {
                                      return DropdownMenuItem<Currency>(
                                        value: currency,
                                        child: Text(
                                            '${currency.symbol} ${currency.code}'),
                                      );
                                    }).toList(),
                                    onChanged: (Currency? newCurrency) {
                                      if (newCurrency != null) {
                                        setState(() {
                                          selectedCurrency = newCurrency;
                                          if (totalCost > 0) {
                                            calculateTotal();
                                          }
                                        });
                                      }
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Refresh exchange rates button
                                Tooltip(
                                  message: 'Refresh exchange rates',
                                  child: IconButton(
                                    icon: isLoadingRates
                                        ? SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                isDarkMode
                                                    ? Colors.white70
                                                    : Colors.grey[600]!,
                                              ),
                                            ),
                                          )
                                        : Icon(
                                            Icons.refresh,
                                            size: 20,
                                            color: isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[700],
                                          ),
                                    onPressed:
                                        isLoadingRates ? null : _fetchExchangeRates,
                                    style: IconButton.styleFrom(
                                      backgroundColor: isDarkMode
                                          ? Colors.grey[800]
                                          : Colors.white,
                                      elevation: 2,
                                      padding: const EdgeInsets.all(10),
                                      minimumSize: const Size(40, 40),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                IconButton(
                                  icon: Icon(
                                    isDarkMode ? Icons.light_mode : Icons.dark_mode,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isDarkMode = !isDarkMode;
                                    });
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor:
                                        isDarkMode ? Colors.grey[800] : Colors.white,
                                    elevation: 2,
                                    padding: const EdgeInsets.all(10),
                                    minimumSize: const Size(40, 40),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    }
                  },
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16.0,
                      right: 16.0,
                      top: MediaQuery.of(context).size.width < 600 ? 8.0 : 0,
                    ),
                    child: Column(
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.shopping_cart,
                                        color: Colors.blue),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Component Prices',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (isLoadingRates)
                                      SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                            isDarkMode
                                                ? Colors.white70
                                                : Colors.grey[600]!,
                                          ),
                                        ),
                                      )
                                    else if (rateError != null)
                                      Tooltip(
                                        message: rateError!,
                                        child: Icon(
                                          Icons.warning_amber_rounded,
                                          size: 18,
                                          color: Colors.orange,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputField('CPU', cpuController,
                                    isPrice: true),
                                _buildInputField('GPU', gpuController,
                                    isPrice: true),
                                _buildInputField('RAM', ramController,
                                    isPrice: true),
                                _buildInputField('Storage', storageController,
                                    isPrice: true),
                                _buildInputField(
                                    'Motherboard', motherboardController,
                                    isPrice: true),
                                _buildInputField('Case', caseController,
                                    isPrice: true),
                                _buildInputField('PSU', psuController,
                                    isPrice: true),
                                _buildInputField(
                                    'Accessories', accessoriesController,
                                    isPrice: true),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.battery_charging_full,
                                        color: Colors.orange),
                                    const SizedBox(width: 8),
                                    Text(
                                      'PSU Calculator',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isDarkMode
                                            ? Colors.white
                                            : Colors.grey[900],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                _buildInputField(
                                    'CPU TDP (Watts)', cpuTdpController),
                                _buildInputField(
                                    'GPU TDP (Watts)', gpuTdpController),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isValidInput() ? calculateTotal : null,
                                icon: const Icon(Icons.calculate),
                                label: const Text('Calculate',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: _isValidInput()
                                      ? Colors.blue
                                      : Colors.grey,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: resetAll,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Reset',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (totalCost > 0 || recommendedPsu > 0) ...[
                          Card(
                            color: Colors.blue,
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                children: [
                                  const Icon(Icons.check_circle_outline,
                                      size: 60, color: Colors.white),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'Total Build Cost',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${getCurrencySymbol()}${convertToCurrency(totalCost).toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 42,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      if (selectedCurrency.code != 'USD') ...[
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 14, vertical: 8),
                                          decoration: BoxDecoration(
                                            color:
                                                Colors.white.withOpacity(0.15),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Icon(
                                                    Icons.compare_arrows,
                                                    size: 12,
                                                    color: Colors.white70,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    'USD Equivalent',
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: Colors.white70,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      letterSpacing: 0.3,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                '\$${totalCost.toStringAsFixed(2)}',
                                                style: const TextStyle(
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                  const Divider(color: Colors.white54),
                                  const SizedBox(height: 8),
                                  const Text(
                                    'Recommended PSU',
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '${recommendedPsu}W',
                                    style: const TextStyle(
                                      fontSize: 36,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(String label, TextEditingController controller,
      {bool isPrice = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: isPrice ? '${getCurrencySymbol()} ' : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          errorText: _getValidationError(controller.text, isPrice),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(isPrice ? 10 : 6),
        ],
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (value) {
          setState(() {
            // Trigger validation on change
          });
        },
      ),
    );
  }

  String? _getValidationError(String value, bool isPrice) {
    if (value.isEmpty) return null;

    // Check if it's a valid number
    final number = double.tryParse(value);
    if (number == null) {
      return 'Please enter a valid number';
    }

    // Check for reasonable ranges
    if (isPrice) {
      if (number < 0) return 'Price cannot be negative';
      if (number > 99999) return 'Price seems too high';
    } else {
      if (number < 0) return 'TDP cannot be negative';
      if (number > 1000) return 'TDP seems too high';
    }

    return null;
  }

  bool _isValidInput() {
    // Check if any field has validation errors
    final controllers = [
      cpuController,
      gpuController,
      ramController,
      storageController,
      motherboardController,
      caseController,
      psuController,
      accessoriesController,
      cpuTdpController,
      gpuTdpController
    ];

    for (int i = 0; i < controllers.length; i++) {
      final controller = controllers[i];
      final isPrice = i < 8; // First 8 are price fields
      if (_getValidationError(controller.text, isPrice) != null) {
        return false;
      }
    }

    return true;
  }

  void calculateTotal() {
    setState(() {
      // Get values from input fields (assuming they're in selected currency)
      // Convert to USD first, then sum, then convert back if needed
      double totalInSelectedCurrency = getValue(cpuController.text) +
          getValue(gpuController.text) +
          getValue(ramController.text) +
          getValue(storageController.text) +
          getValue(motherboardController.text) +
          getValue(caseController.text) +
          getValue(psuController.text) +
          getValue(accessoriesController.text);

      // Convert to USD for storage (base currency)
      final rateToUSD = exchangeRates[selectedCurrency.code] ?? 1.0;
      totalCost = totalInSelectedCurrency / rateToUSD;

      final int cpuTdp = int.tryParse(cpuTdpController.text) ?? 0;
      final int gpuTdp = int.tryParse(gpuTdpController.text) ?? 0;
      final int totalWattage = ((100 + cpuTdp + gpuTdp) * 1.2).round();
      recommendedPsu = ((totalWattage / 50).ceil() * 50);
    });
  }

  double getValue(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  void resetAll() {
    setState(() {
      cpuController.clear();
      gpuController.clear();
      ramController.clear();
      storageController.clear();
      motherboardController.clear();
      caseController.clear();
      psuController.clear();
      accessoriesController.clear();
      cpuTdpController.clear();
      gpuTdpController.clear();
      totalCost = 0.0;
      recommendedPsu = 0;
    });
  }

  @override
  void dispose() {
    cpuController.dispose();
    gpuController.dispose();
    ramController.dispose();
    storageController.dispose();
    motherboardController.dispose();
    caseController.dispose();
    psuController.dispose();
    accessoriesController.dispose();
    cpuTdpController.dispose();
    gpuTdpController.dispose();
    super.dispose();
  }
}
