import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/exchange_rate_service.dart';
import '../../data/theme_preference_service.dart';
import '../../models/currency.dart';
import '../../models/currency_presets.dart';
import '../../utils/currency_utils.dart';
import '../../utils/input_validators.dart';
import '../../utils/summary_generator.dart';
import '../widgets/action_buttons.dart';
import '../widgets/build_header.dart';
import '../widgets/component_price_card.dart';
import '../widgets/psu_card.dart';
import '../widgets/summary_card.dart';
import '../widgets/totals_card.dart';

class BuildCalculatorPage extends StatefulWidget {
  const BuildCalculatorPage({super.key});

  @override
  State<BuildCalculatorPage> createState() => _BuildCalculatorPageState();
}

class _BuildCalculatorPageState extends State<BuildCalculatorPage> {
  final Map<String, TextEditingController> _componentControllers = {
    'cpu': TextEditingController(),
    'gpu': TextEditingController(),
    'ram': TextEditingController(),
    'storage': TextEditingController(),
    'motherboard': TextEditingController(),
    'case': TextEditingController(),
    'psu': TextEditingController(),
    'accessories': TextEditingController(),
  };

  final TextEditingController _cpuTdpController = TextEditingController();
  final TextEditingController _gpuTdpController = TextEditingController();

  final ThemePreferenceService _themePrefs = ThemePreferenceService();
  final ExchangeRateService _exchangeRateService = ExchangeRateService();
  final InputValidators _validators = const InputValidators();

  double _totalUsd = 0;
  int _recommendedPsu = 0;
  bool _isDarkMode = false;
  bool _isLoadingRates = false;
  bool _summaryCopied = false;
  bool _autoCalculate = false;
  bool _showBuildSummary = true;
  String? _rateError;

  Currency _selectedCurrency = supportedCurrencies.first;
  Map<String, double> _exchangeRates = {'USD': 1.0};

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final theme = await _themePrefs.loadThemePreference();
    setState(() => _isDarkMode = theme);
    await _fetchExchangeRates();
  }

  Future<void> _fetchExchangeRates() async {
    setState(() {
      _isLoadingRates = true;
      _rateError = null;
    });

    try {
      final rates = await _exchangeRateService.fetchRates();
      setState(() {
        _exchangeRates = rates;
        _isLoadingRates = false;
      });
    } on ExchangeRateException catch (error) {
      // When live rates fail we fall back to USD-only so the UI still works.
      setState(() {
        _rateError = error.message;
        _exchangeRates =
            _exchangeRateService.fallbackRates(supportedCurrencies);
        _isLoadingRates = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: _isDarkMode
          ? ThemeData.dark(useMaterial3: true)
          : ThemeData.light(useMaterial3: true),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isDarkMode
                  ? [Colors.grey[900]!, Colors.grey[800]!]
                  : [Colors.blue[50]!, Colors.white],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                BuildHeader(
                  isDarkMode: _isDarkMode,
                  currencies: supportedCurrencies,
                  selectedCurrency: _selectedCurrency,
                  onCurrencyChanged: _handleCurrencyChange,
                  onRefreshRates: _fetchExchangeRates,
                  onToggleTheme: _toggleTheme,
                  isLoadingRates: _isLoadingRates,
                ),
                if (_rateError != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        '⚠️ $_rateError (using fallback rates)',
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ),
                  ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.only(
                      left: 16,
                      right: 16,
                      top: MediaQuery.of(context).size.width < 600 ? 8 : 0,
                      bottom: 16,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800),
                        child: Column(
                          children: [
                            ComponentPriceCard(
                              isDarkMode: _isDarkMode,
                              currency: _selectedCurrency,
                              controllers: _componentControllers,
                              autoCalculate: _autoCalculate,
                              showBuildSummary: _showBuildSummary,
                              onAutoCalculateChanged: _handleAutoCalcChanged,
                              onShowSummaryChanged: _handleSummaryToggle,
                              onFieldChanged: _handleFieldChanged,
                              validators: _validators,
                            ),
                            const SizedBox(height: 16),
                            PsuCard(
                              isDarkMode: _isDarkMode,
                              cpuTdpController: _cpuTdpController,
                              gpuTdpController: _gpuTdpController,
                              validators: _validators,
                              onChanged: _handleFieldChanged,
                            ),
                            const SizedBox(height: 24),
                            ActionButtons(
                              canCalculate: _canCalculate,
                              onCalculate: _calculateTotal,
                              onReset: _resetAll,
                            ),
                            const SizedBox(height: 24),
                            if (_totalUsd > 0) ...[
                              SizedBox(
                                width: double.infinity,
                                child: TotalsCard(
                                  currencySymbol: _selectedCurrency.symbol,
                                  totalDisplayValue:
                                      _currencyUtils.convertFromUsd(_totalUsd),
                                  totalUsd: _totalUsd,
                                  showUsdEquivalent:
                                      _selectedCurrency.code != 'USD',
                                  recommendedPsu: _recommendedPsu,
                                ),
                              ),
                              if (_showBuildSummary) ...[
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: SummaryCard(
                                    isDarkMode: _isDarkMode,
                                    summaryText: _buildSummaryText(),
                                    onCopy: _copySummary,
                                    summaryCopied: _summaryCopied,
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

  CurrencyUtils get _currencyUtils => CurrencyUtils(
        selectedCurrency: _selectedCurrency,
        exchangeRates: _exchangeRates,
      );

  void _toggleTheme() {
    setState(() => _isDarkMode = !_isDarkMode);
    _themePrefs.saveThemePreference(_isDarkMode);
  }

  void _handleCurrencyChange(Currency currency) {
    setState(() => _selectedCurrency = currency);
    if (_totalUsd > 0) _calculateTotal();
  }

  void _handleAutoCalcChanged(bool value) {
    setState(() => _autoCalculate = value);
    if (value && _canCalculate) _calculateTotal();
  }

  void _handleSummaryToggle(bool value) {
    setState(() => _showBuildSummary = value);
  }

  void _handleFieldChanged() {
    setState(() {});
    if (_autoCalculate && _hasMeaningfulData()) {
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted && _canCalculate) {
          _calculateTotal();
        }
      });
    }
  }

  bool get _canCalculate => _isValidInput() && _hasMeaningfulData();

  bool _isValidInput() {
    final priceControllers = _componentControllers.values.toList();
    final allControllers = [
      ...priceControllers,
      _cpuTdpController,
      _gpuTdpController,
    ];

    for (var i = 0; i < allControllers.length; i++) {
      final controller = allControllers[i];
      final isPrice = i < priceControllers.length;
      if (_validators.validate(controller.text, isPrice: isPrice) != null) {
        return false;
      }
    }
    return true;
  }

  bool _hasMeaningfulData() {
    return _componentControllers.values
        .any((controller) => _parse(controller.text) > 0);
  }

  void _calculateTotal() {
    final totalInSelectedCurrency = _componentControllers.values
        .map((controller) => _parse(controller.text))
        .fold<double>(0, (sum, value) => sum + value);

    final totalUsd = _currencyUtils.convertToUsd(totalInSelectedCurrency);
    final cpuTdp = int.tryParse(_cpuTdpController.text) ?? 0;
    final gpuTdp = int.tryParse(_gpuTdpController.text) ?? 0;
    final hasTdp = cpuTdp > 0 || gpuTdp > 0;

    final bufferedWattage =
        ((100 + cpuTdp + gpuTdp) * 1.2).round(); // Adds 20% headroom.
    final recommended = hasTdp ? ((bufferedWattage / 50).ceil() * 50) : 0;

    setState(() {
      _totalUsd = totalUsd;
      _recommendedPsu = recommended;
      _summaryCopied = false;
    });
  }

  Map<String, double> _componentPriceMap() {
    final map = <String, double>{};
    _componentControllers.forEach((name, controller) {
      map[_titleCase(name)] = _parse(controller.text);
    });
    return map;
  }

  String _buildSummaryText() {
    final generator = BuildSummaryGenerator(
      currency: _selectedCurrency,
      totalUsd: _totalUsd,
      convertedTotal: _currencyUtils.convertFromUsd(_totalUsd),
      componentPrices: _componentPriceMap(),
      cpuTdpText: _cpuTdpController.text,
      gpuTdpText: _gpuTdpController.text,
      recommendedPsu: _recommendedPsu,
    );

    return generator.build();
  }

  void _copySummary() {
    final summary = _buildSummaryText();
    Clipboard.setData(ClipboardData(text: summary));
    setState(() => _summaryCopied = true);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _summaryCopied = false);
      }
    });

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

  void _resetAll() {
    for (final controller in _componentControllers.values) {
      controller.clear();
    }
    _cpuTdpController.clear();
    _gpuTdpController.clear();

    setState(() {
      _totalUsd = 0;
      _recommendedPsu = 0;
      _summaryCopied = false;
      _autoCalculate = false;
    });
  }

  double _parse(String text) => double.tryParse(text) ?? 0;

  String _titleCase(String input) =>
      input.isEmpty ? input : '${input[0].toUpperCase()}${input.substring(1)}';

  @override
  void dispose() {
    for (final controller in _componentControllers.values) {
      controller.dispose();
    }
    _cpuTdpController.dispose();
    _gpuTdpController.dispose();
    super.dispose();
  }
}
