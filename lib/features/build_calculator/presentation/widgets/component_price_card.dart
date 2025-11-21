import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../build_calculator/utils/input_validators.dart';
import '../../../../../features/build_calculator/models/currency.dart';

typedef VoidCallbackBool = void Function(bool value);
typedef TextChanged = void Function();

class ComponentPriceCard extends StatelessWidget {
  const ComponentPriceCard({
    super.key,
    required this.isDarkMode,
    required this.currency,
    required this.controllers,
    required this.autoCalculate,
    required this.showBuildSummary,
    required this.onAutoCalculateChanged,
    required this.onShowSummaryChanged,
    required this.onFieldChanged,
    required this.validators,
  });

  final bool isDarkMode;
  final Currency currency;
  final Map<String, TextEditingController> controllers;
  final bool autoCalculate;
  final bool showBuildSummary;
  final VoidCallbackBool onAutoCalculateChanged;
  final VoidCallbackBool onShowSummaryChanged;
  final TextChanged onFieldChanged;
  final InputValidators validators;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(context),
            const SizedBox(height: 16),
            ..._buildInputs(),
          ],
        ),
      ),
    );
  }

  Widget _header(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;
    final title = Row(
      children: [
        const Icon(Icons.shopping_cart, color: Colors.blue),
        const SizedBox(width: 8),
        Text(
          'Component Prices',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.grey[900],
          ),
        ),
      ],
    );

    final options = Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        _checkbox(
          value: autoCalculate,
          label: 'Auto-calculate',
          tooltip: 'Automatically calculate total as you type',
          onChanged: onAutoCalculateChanged,
        ),
        _checkbox(
          value: showBuildSummary,
          label: 'Show Summary',
          tooltip: 'Show build summary after calculation',
          onChanged: onShowSummaryChanged,
        ),
      ],
    );

    if (isMobile) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          title,
          const SizedBox(height: 12),
          options,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        title,
        options,
      ],
    );
  }

  Widget _checkbox({
    required bool value,
    required String label,
    required String tooltip,
    required VoidCallbackBool onChanged,
  }) {
    return Tooltip(
      message: tooltip,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Checkbox(
            value: value,
            onChanged: (newValue) => onChanged(newValue ?? false),
            activeColor: Colors.blue,
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: isDarkMode ? Colors.white70 : Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildInputs() {
    return [
      _builderField('CPU', controllers['cpu']!),
      _builderField('GPU', controllers['gpu']!),
      _builderField('RAM', controllers['ram']!),
      _builderField('Storage', controllers['storage']!),
      _builderField('Motherboard', controllers['motherboard']!),
      _builderField('Case', controllers['case']!),
      _builderField('PSU', controllers['psu']!),
      _builderField('Accessories', controllers['accessories']!),
    ];
  }

  Widget _builderField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixText: '${currency.symbol} ',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          errorText: validators.validate(controller.text, isPrice: true),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(10),
        ],
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (_) => onFieldChanged(),
      ),
    );
  }
}
