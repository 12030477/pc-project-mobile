import 'package:flutter/material.dart';

import '../../../build_calculator/models/currency.dart';

typedef CurrencyChanged = void Function(Currency currency);

class BuildHeader extends StatelessWidget {
  const BuildHeader({
    super.key,
    required this.isDarkMode,
    required this.currencies,
    required this.selectedCurrency,
    required this.onCurrencyChanged,
    required this.onRefreshRates,
    required this.onToggleTheme,
    required this.isLoadingRates,
  });

  final bool isDarkMode;
  final List<Currency> currencies;
  final Currency selectedCurrency;
  final CurrencyChanged onCurrencyChanged;
  final VoidCallback onRefreshRates;
  final VoidCallback onToggleTheme;
  final bool isLoadingRates;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isMobile = width < 600;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: isMobile ? _mobileLayout(context) : _desktopLayout(context),
    );
  }

  Widget _mobileLayout(BuildContext context) {
    return Row(
      children: [
        _logo(),
        const SizedBox(width: 8),
        Expanded(child: _currencyDropdown()),
        const SizedBox(width: 6),
        _refreshButton(),
        const SizedBox(width: 4),
        _themeToggle(),
      ],
    );
  }

  Widget _desktopLayout(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final titleSize = width < 900 ? 18 : 20;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            _logo(),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PC Build Helper',
                  style: TextStyle(
                    fontSize: titleSize.toDouble(),
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
                Text(
                  'Calculate your build budget',
                  style: TextStyle(
                    fontSize: 12,
                    color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ],
        ),
        Row(
          children: [
            SizedBox(width: 150, child: _currencyDropdown()),
            const SizedBox(width: 8),
            _refreshButton(),
            const SizedBox(width: 4),
            _themeToggle(),
          ],
        ),
      ],
    );
  }

  Widget _logo() {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
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
    );
  }

  Widget _currencyDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
        ),
      ),
      child: DropdownButton<Currency>(
        value: selectedCurrency,
        underline: const SizedBox(),
        icon: Icon(
          Icons.arrow_drop_down,
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        dropdownColor: isDarkMode ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
          fontSize: 14,
        ),
        isExpanded: true,
        items: currencies
            .map(
              (currency) => DropdownMenuItem(
                value: currency,
                child: Text('${currency.symbol} ${currency.code}'),
              ),
            )
            .toList(),
        onChanged: (currency) {
          if (currency != null) onCurrencyChanged(currency);
        },
      ),
    );
  }

  Widget _refreshButton() {
    return Tooltip(
      message: 'Refresh exchange rates',
      child: IconButton(
        icon: isLoadingRates
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isDarkMode ? Colors.white70 : Colors.grey[600]!,
                  ),
                ),
              )
            : Icon(
                Icons.refresh,
                size: 20,
                color: isDarkMode ? Colors.white70 : Colors.grey[700],
              ),
        onPressed: isLoadingRates ? null : onRefreshRates,
        style: IconButton.styleFrom(
          backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
          elevation: 2,
          padding: const EdgeInsets.all(10),
          minimumSize: const Size(40, 40),
        ),
      ),
    );
  }

  Widget _themeToggle() {
    return IconButton(
      icon: Icon(
        isDarkMode ? Icons.light_mode : Icons.dark_mode,
        size: 24,
      ),
      onPressed: onToggleTheme,
      style: IconButton.styleFrom(
        backgroundColor: isDarkMode ? Colors.grey[800] : Colors.white,
        elevation: 2,
        padding: const EdgeInsets.all(10),
        minimumSize: const Size(40, 40),
      ),
    );
  }
}
