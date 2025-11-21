import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../build_calculator/utils/input_validators.dart';

class PsuCard extends StatelessWidget {
  const PsuCard({
    super.key,
    required this.isDarkMode,
    required this.cpuTdpController,
    required this.gpuTdpController,
    required this.validators,
    required this.onChanged,
  });

  final bool isDarkMode;
  final TextEditingController cpuTdpController;
  final TextEditingController gpuTdpController;
  final InputValidators validators;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.battery_charging_full, color: Colors.orange),
                const SizedBox(width: 8),
                Text(
                  'PSU Calculator',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDarkMode ? Colors.white : Colors.grey[900],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField('CPU TDP (Watts)', cpuTdpController),
            _buildField('GPU TDP (Watts)', gpuTdpController),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[100],
          errorText: validators.validate(controller.text, isPrice: false),
        ),
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
          LengthLimitingTextInputFormatter(6),
        ],
        style: TextStyle(
          color: isDarkMode ? Colors.white : Colors.black,
        ),
        onChanged: (_) => onChanged(),
      ),
    );
  }
}
