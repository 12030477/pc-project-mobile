/// PC Build Budget Helper - Flutter Mobile Application
///
/// This application helps users calculate the total cost of PC components
/// and recommends appropriate PSU wattage based on CPU and GPU TDP values.
/// Features include multi-currency support, real-time exchange rates,
/// dark/light mode, and responsive design for mobile and desktop.
///
/// @author Mantach
/// @version 1.0.0

library pc_build_budget_helper;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Application entry point
///
/// Initializes and runs the Flutter application with MyApp as the root widget.
void main() {
  runApp(const MyApp());
}

/// Root application widget
///
/// Configures the MaterialApp with light and dark themes, Material Design 3,
/// and sets up the home page. The app supports system theme detection.
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

/// Main home page widget
///
/// Stateful widget that contains the primary UI for component price input,
/// PSU calculation, and currency conversion.
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => MyHomePageState();
}

/// Currency data model
///
/// Represents a currency with its ISO code, display name, and symbol.
/// Used for currency selection and conversion throughout the app.
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

/// State management for the home page
///
/// Manages all user input controllers, calculation state, currency conversion,
/// theme preferences, and exchange rate fetching.
class MyHomePageState extends State<MyHomePage> {
  // Text controllers for component price inputs
  final TextEditingController cpuController = TextEditingController();
  final TextEditingController gpuController = TextEditingController();
  final TextEditingController ramController = TextEditingController();
  final TextEditingController storageController = TextEditingController();
  final TextEditingController motherboardController = TextEditingController();
  final TextEditingController caseController = TextEditingController();
  final TextEditingController psuController = TextEditingController();
  final TextEditingController accessoriesController = TextEditingController();

  // Text controllers for TDP (Thermal Design Power) inputs
  final TextEditingController cpuTdpController = TextEditingController();
  final TextEditingController gpuTdpController = TextEditingController();

  // Calculation results
  /// Total build cost in USD (base currency for calculations)
  double totalCost = 0.0;

  /// Recommended PSU wattage based on component TDP values
  int recommendedPsu = 0;

  /// Current theme mode (dark/light)
  bool isDarkMode = false;

  /// Supported currencies list
  ///
  /// Contains 15+ currencies with their ISO codes, names, and symbols.
  /// Used for currency selection dropdown and conversion calculations.
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

  /// Currently selected currency for display and conversion
  Currency selectedCurrency =
      const Currency(code: 'USD', name: 'US Dollar', symbol: '\$');

  /// Exchange rates map (currency code -> rate relative to USD)
  /// USD is always 1.0, other currencies are relative to USD
  Map<String, double> exchangeRates = {};

  /// Loading state for exchange rate API calls
  bool isLoadingRates = false;

  /// Error message if exchange rate fetching fails
  String? rateError;

  /// Whether the summary was just copied (for showing snackbar)
  bool summaryCopied = false;

  /// Whether to auto-calculate as user types
  bool autoCalculate = false;

  /// Whether to show the build summary card
  bool showBuildSummary = true;

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

  /// Loads the saved theme preference from local storage
  ///
  /// Retrieves the user's preferred theme (dark/light) from SharedPreferences
  /// and updates the app state accordingly.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isDarkMode = prefs.getBool('isDarkMode') ?? false;
    });
  }

  /// Saves the theme preference to local storage
  ///
  /// Persists the user's theme choice (dark/light) to SharedPreferences
  /// so it can be restored on app restart.
  ///
  /// [value] - true for dark mode, false for light mode
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  /// Fetches real-time exchange rates from the API
  ///
  /// Makes an HTTP GET request to exchangerate-api.com to retrieve
  /// the latest exchange rates. Falls back to default rates (1.0) if
  /// the API call fails, allowing offline functionality.
  ///
  /// API Endpoint: https://api.exchangerate-api.com/v4/latest/USD
  /// Timeout: 10 seconds
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

  /// Sets default exchange rates as fallback
  ///
  /// Called when the API fails or is unavailable. Sets all currency rates
  /// to 1.0, which effectively shows USD equivalent values.
  /// This ensures the app remains functional offline.
  void _setDefaultRates() {
    // Set all currencies to 1.0 as fallback (will show USD equivalent)
    for (var currency in currencies) {
      exchangeRates[currency.code] = 1.0;
    }
  }

  /// Converts an amount from USD to the selected currency
  ///
  /// Takes a USD amount and multiplies it by the current exchange rate
  /// for the selected currency.
  ///
  /// [amountInUSD] - The amount in USD to convert
  /// Returns the converted amount in the selected currency
  double convertToCurrency(double amountInUSD) {
    final rate = exchangeRates[selectedCurrency.code] ?? 1.0;
    return amountInUSD * rate;
  }

  /// Gets the symbol for the currently selected currency
  ///
  /// Returns the currency symbol (e.g., '$', '€', '£') for display purposes.
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
                              ],
                            ),
                            const Spacer(),
                            // Currency selector - comfortable size near buttons
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 4),
                              constraints: const BoxConstraints(
                                minHeight: 40,
                                maxHeight: 40,
                              ),
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
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
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                  size: 18,
                                ),
                                dropdownColor: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
                                menuMaxHeight: 200,
                                borderRadius: BorderRadius.circular(12),
                                style: TextStyle(
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
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
                                backgroundColor: isDarkMode
                                    ? Colors.grey[800]
                                    : Colors.white,
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
                                        fontSize:
                                            MediaQuery.of(context).size.width <
                                                    900
                                                ? 18
                                                : 20,
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
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
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                    dropdownColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
                                    menuMaxHeight: 200,
                                    borderRadius: BorderRadius.circular(12),
                                    style: TextStyle(
                                      color: isDarkMode
                                          ? Colors.white
                                          : Colors.black,
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
                                    onPressed: isLoadingRates
                                        ? null
                                        : _fetchExchangeRates,
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
                                    isDarkMode
                                        ? Icons.light_mode
                                        : Icons.dark_mode,
                                    size: 24,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isDarkMode = !isDarkMode;
                                    });
                                    _saveThemePreference(isDarkMode);
                                  },
                                  style: IconButton.styleFrom(
                                    backgroundColor: isDarkMode
                                        ? Colors.grey[800]
                                        : Colors.white,
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
                      bottom: 16.0,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            Card(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final isMobile =
                                            MediaQuery.of(context).size.width <
                                                600;

                                        if (isMobile) {
                                          // Mobile: Title on top, checkboxes side by side
                                          return Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.shopping_cart,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Component Prices',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.grey[900],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                children: [
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Checkbox(
                                                          value: autoCalculate,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              autoCalculate =
                                                                  value ??
                                                                      false;
                                                              if (autoCalculate &&
                                                                  _isValidInput()) {
                                                                calculateTotal();
                                                              }
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.blue,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        Flexible(
                                                          child: Tooltip(
                                                            message:
                                                                'Automatically calculate total as you type',
                                                            child: Text(
                                                              'Auto-calculate',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white70
                                                                    : Colors.grey[
                                                                        700],
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Flexible(
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Checkbox(
                                                          value:
                                                              showBuildSummary,
                                                          onChanged: (value) {
                                                            setState(() {
                                                              showBuildSummary =
                                                                  value ?? true;
                                                            });
                                                          },
                                                          activeColor:
                                                              Colors.blue,
                                                          materialTapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        Flexible(
                                                          child: Tooltip(
                                                            message:
                                                                'Show build summary after calculation',
                                                            child: Text(
                                                              'Show Summary',
                                                              style: TextStyle(
                                                                fontSize: 13,
                                                                color: isDarkMode
                                                                    ? Colors
                                                                        .white70
                                                                    : Colors.grey[
                                                                        700],
                                                              ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        } else {
                                          // Desktop/Tablet: Side by side
                                          return Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  const Icon(
                                                      Icons.shopping_cart,
                                                      color: Colors.blue),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    'Component Prices',
                                                    style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: isDarkMode
                                                          ? Colors.white
                                                          : Colors.grey[900],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Checkbox(
                                                    value: autoCalculate,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        autoCalculate =
                                                            value ?? false;
                                                        if (autoCalculate &&
                                                            _isValidInput()) {
                                                          calculateTotal();
                                                        }
                                                      });
                                                    },
                                                    activeColor: Colors.blue,
                                                  ),
                                                  Tooltip(
                                                    message:
                                                        'Automatically calculate total as you type',
                                                    child: Text(
                                                      'Auto-calculate',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isDarkMode
                                                            ? Colors.white70
                                                            : Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Checkbox(
                                                    value: showBuildSummary,
                                                    onChanged: (value) {
                                                      setState(() {
                                                        showBuildSummary =
                                                            value ?? true;
                                                      });
                                                    },
                                                    activeColor: Colors.blue,
                                                  ),
                                                  Tooltip(
                                                    message:
                                                        'Show build summary after calculation',
                                                    child: Text(
                                                      'Show Build Summary',
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: isDarkMode
                                                            ? Colors.white70
                                                            : Colors.grey[700],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          );
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 16),
                                    _buildInputField('CPU', cpuController,
                                        isPrice: true),
                                    _buildInputField('GPU', gpuController,
                                        isPrice: true),
                                    _buildInputField('RAM', ramController,
                                        isPrice: true),
                                    _buildInputField(
                                        'Storage', storageController,
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
                                    onPressed: (_isValidInput() &&
                                            _hasMeaningfulData())
                                        ? calculateTotal
                                        : null,
                                    icon: const Icon(Icons.calculate),
                                    label: const Text('Calculate',
                                        style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: (_isValidInput() &&
                                              _hasMeaningfulData())
                                          ? Colors.blue
                                          : Colors.grey,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
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
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 24),
                            if (totalCost > 0) ...[
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
                                      Builder(
                                        builder: (context) {
                                          final isPhone = MediaQuery.of(context)
                                                  .size
                                                  .width <
                                              480;

                                          if (isPhone &&
                                              selectedCurrency.code != 'USD') {
                                            // Mobile: Stack vertically
                                            return Column(
                                              children: [
                                                Text(
                                                  '${getCurrencySymbol()}${convertToCurrency(totalCost).toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    fontSize: 42,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(height: 12),
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 14,
                                                      vertical: 8),
                                                  decoration: BoxDecoration(
                                                    color: Colors.white
                                                        .withValues(
                                                            alpha: 0.15),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    border: Border.all(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.3),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .compare_arrows,
                                                            size: 12,
                                                            color:
                                                                Colors.white70,
                                                          ),
                                                          const SizedBox(
                                                              width: 4),
                                                          Text(
                                                            'USD Equivalent',
                                                            style: TextStyle(
                                                              fontSize: 11,
                                                              color: Colors
                                                                  .white70,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              letterSpacing:
                                                                  0.3,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Text(
                                                        '\$${totalCost.toStringAsFixed(2)}',
                                                        style: const TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: Colors.white,
                                                          letterSpacing: 0.5,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            );
                                          } else {
                                            // Tablet/Desktop: Side by side
                                            return Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
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
                                                if (selectedCurrency.code !=
                                                    'USD') ...[
                                                  const SizedBox(width: 16),
                                                  Container(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 14,
                                                        vertical: 8),
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withValues(
                                                              alpha: 0.15),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                      border: Border.all(
                                                        color: Colors.white
                                                            .withValues(
                                                                alpha: 0.3),
                                                        width: 1.5,
                                                      ),
                                                    ),
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Row(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: [
                                                            Icon(
                                                              Icons
                                                                  .compare_arrows,
                                                              size: 12,
                                                              color: Colors
                                                                  .white70,
                                                            ),
                                                            const SizedBox(
                                                                width: 4),
                                                            Text(
                                                              'USD Equivalent',
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: Colors
                                                                    .white70,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500,
                                                                letterSpacing:
                                                                    0.3,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(
                                                            height: 4),
                                                        Text(
                                                          '\$${totalCost.toStringAsFixed(2)}',
                                                          style:
                                                              const TextStyle(
                                                            fontSize: 20,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            color: Colors.white,
                                                            letterSpacing: 0.5,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            );
                                          }
                                        },
                                      ),
                                      if (recommendedPsu > 0) ...[
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
                                    ],
                                  ),
                                ),
                              ),
                              if (showBuildSummary) ...[
                                const SizedBox(height: 16),
                                // Build Summary Card
                                Center(
                                  child: SizedBox(
                                    width: double.infinity,
                                    child: ConstrainedBox(
                                      constraints:
                                          const BoxConstraints(maxWidth: 800),
                                      child: Card(
                                        child: Padding(
                                          padding: const EdgeInsets.all(16.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Row(
                                                    children: [
                                                      Icon(
                                                        Icons.description,
                                                        color: isDarkMode
                                                            ? Colors.white
                                                            : Colors.grey[900],
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        'Build Summary',
                                                        style: TextStyle(
                                                          fontSize: 20,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                          color: isDarkMode
                                                              ? Colors.white
                                                              : Colors
                                                                  .grey[900],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  ElevatedButton.icon(
                                                    onPressed:
                                                        _copyBuildSummary,
                                                    icon: Icon(
                                                      summaryCopied
                                                          ? Icons.check
                                                          : Icons.copy,
                                                      size: 18,
                                                    ),
                                                    label: Text(
                                                      summaryCopied
                                                          ? 'Copied!'
                                                          : 'Copy Summary',
                                                      style: const TextStyle(
                                                          fontSize: 14),
                                                    ),
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      backgroundColor:
                                                          summaryCopied
                                                              ? Colors.green
                                                              : Colors.blue,
                                                      foregroundColor:
                                                          Colors.white,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12),
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              Container(
                                                padding:
                                                    const EdgeInsets.all(16),
                                                decoration: BoxDecoration(
                                                  color: isDarkMode
                                                      ? Colors.grey[800]
                                                      : Colors.grey[100],
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  border: Border.all(
                                                    color: isDarkMode
                                                        ? Colors.grey[700]!
                                                        : Colors.grey[300]!,
                                                  ),
                                                ),
                                                child: SelectableText(
                                                  _generateBuildSummary(),
                                                  style: TextStyle(
                                                    fontSize: 14,
                                                    fontFamily: 'monospace',
                                                    color: isDarkMode
                                                        ? Colors.white
                                                        : Colors.black87,
                                                    height: 1.5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 32),
                            ],
                          ],
                        ),
                      ),
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

  /// Builds a reusable input field widget
  ///
  /// Creates a TextField with validation, currency prefix (for price fields),
  /// and appropriate styling based on theme mode.
  ///
  /// [label] - The label text for the input field
  /// [controller] - The TextEditingController for this field
  /// [isPrice] - If true, adds currency symbol prefix and price validation
  /// Returns a styled TextField widget
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
          // Auto-calculate if enabled and there's meaningful data
          if (autoCalculate && _hasMeaningfulData()) {
            Future.delayed(const Duration(milliseconds: 500), () {
              if (mounted) {
                calculateTotal();
              }
            });
          }
        },
      ),
    );
  }

  /// Validates input field values
  ///
  /// Checks if the input is a valid number and within reasonable ranges.
  /// Returns an error message string if validation fails, null otherwise.
  ///
  /// [value] - The input string to validate
  /// [isPrice] - If true, validates as a price (0-99999), otherwise as TDP (0-1000)
  /// Returns error message or null if valid
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

  /// Checks if all input fields have valid values
  ///
  /// Validates all text controllers to ensure no validation errors exist.
  /// Used to enable/disable the Calculate button.
  ///
  /// Returns true if all inputs are valid, false otherwise
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

  /// Checks if there's meaningful data to calculate
  ///
  /// Returns true if at least one component price is entered.
  /// Used to prevent auto-calculate from triggering with empty data.
  ///
  /// Returns true if there's at least one component price, false otherwise
  bool _hasMeaningfulData() {
    final componentPrices = [
      getValue(cpuController.text),
      getValue(gpuController.text),
      getValue(ramController.text),
      getValue(storageController.text),
      getValue(motherboardController.text),
      getValue(caseController.text),
      getValue(psuController.text),
      getValue(accessoriesController.text),
    ];

    // Check if at least one component has a price > 0
    return componentPrices.any((price) => price > 0);
  }

  /// Calculates the total build cost and recommended PSU wattage
  ///
  /// Sums all component prices (converted to USD internally),
  /// then calculates recommended PSU based on CPU and GPU TDP values.
  /// Formula: (100W base + CPU TDP + GPU TDP) * 1.2 (20% buffer), rounded to nearest 50W.
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

      // Only calculate PSU if at least one TDP value is entered
      final int cpuTdp = int.tryParse(cpuTdpController.text) ?? 0;
      final int gpuTdp = int.tryParse(gpuTdpController.text) ?? 0;

      if (cpuTdp > 0 || gpuTdp > 0) {
        final int totalWattage = ((100 + cpuTdp + gpuTdp) * 1.2).round();
        recommendedPsu = ((totalWattage / 50).ceil() * 50);
      } else {
        recommendedPsu = 0; // Don't show PSU recommendation if no TDP entered
      }

      // Reset copied state when new calculation is done
      summaryCopied = false;
    });
  }

  /// Parses a string value to a double
  ///
  /// Safely converts text input to a numeric value.
  /// Returns 0.0 if the string is empty or cannot be parsed.
  ///
  /// [text] - The string to parse
  /// Returns the parsed double value or 0.0
  double getValue(String text) {
    if (text.isEmpty) return 0.0;
    return double.tryParse(text) ?? 0.0;
  }

  /// Resets all input fields and calculation results
  ///
  /// Clears all text controllers and resets totalCost and recommendedPsu
  /// to their initial values. Used by the Reset button.
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
      summaryCopied = false;
      autoCalculate = false;
    });
  }

  /// Generates a formatted build summary text
  ///
  /// Creates a nicely formatted text summary of the build including
  /// all component prices, totals, and PSU recommendation.
  ///
  /// Returns a formatted string with all build details
  String _generateBuildSummary() {
    final buffer = StringBuffer();
    final dateTime = DateTime.now();

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('   PC BUILD SUMMARY');
    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln(
        'Date: ${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}');
    buffer.writeln(
        'Currency: ${selectedCurrency.code} (${selectedCurrency.name})');
    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('COMPONENT PRICES:');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');

    final components = [
      {'name': 'CPU', 'price': getValue(cpuController.text)},
      {'name': 'GPU', 'price': getValue(gpuController.text)},
      {'name': 'RAM', 'price': getValue(ramController.text)},
      {'name': 'Storage', 'price': getValue(storageController.text)},
      {'name': 'Motherboard', 'price': getValue(motherboardController.text)},
      {'name': 'Case', 'price': getValue(caseController.text)},
      {'name': 'PSU', 'price': getValue(psuController.text)},
      {'name': 'Accessories', 'price': getValue(accessoriesController.text)},
    ];

    for (var component in components) {
      final price = component['price'] as double;
      if (price > 0) {
        final name = component['name'] as String;
        buffer.writeln(
            '${name.padRight(15)}: ${getCurrencySymbol()}${price.toStringAsFixed(2)}');
      }
    }

    buffer.writeln('');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('TOTAL BUILD COST:');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
        '${getCurrencySymbol()}${convertToCurrency(totalCost).toStringAsFixed(2)}');
    if (selectedCurrency.code != 'USD') {
      buffer.writeln('(USD Equivalent: \$${totalCost.toStringAsFixed(2)})');
    }
    buffer.writeln('');

    if (cpuTdpController.text.isNotEmpty || gpuTdpController.text.isNotEmpty) {
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      buffer.writeln('POWER REQUIREMENTS:');
      buffer.writeln('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
      if (cpuTdpController.text.isNotEmpty) {
        buffer.writeln('CPU TDP: ${cpuTdpController.text}W');
      }
      if (gpuTdpController.text.isNotEmpty) {
        buffer.writeln('GPU TDP: ${gpuTdpController.text}W');
      }
      if (recommendedPsu > 0) {
        buffer.writeln('');
        buffer.writeln('Recommended PSU: ${recommendedPsu}W');
      }
      buffer.writeln('');
    }

    buffer.writeln('═══════════════════════════════════════');
    buffer.writeln('Generated by PC Build Budget Helper');
    buffer.writeln('═══════════════════════════════════════');

    return buffer.toString();
  }

  /// Copies the build summary to clipboard
  ///
  /// Copies the formatted build summary to the device clipboard
  /// and shows a confirmation message to the user.
  void _copyBuildSummary() {
    final summary = _generateBuildSummary();
    Clipboard.setData(ClipboardData(text: summary));

    setState(() {
      summaryCopied = true;
    });

    // Reset the copied state after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          summaryCopied = false;
        });
      }
    });

    // Show snackbar confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Text('Build summary copied to clipboard!'),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  @override

  /// Disposes of all text controllers to prevent memory leaks
  ///
  /// Called when the widget is removed from the widget tree.
  /// Properly cleans up all TextEditingController instances.
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
