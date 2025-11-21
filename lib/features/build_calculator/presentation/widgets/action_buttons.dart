import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  const ActionButtons({
    super.key,
    required this.canCalculate,
    required this.onCalculate,
    required this.onReset,
  });

  final bool canCalculate;
  final VoidCallback onCalculate;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: canCalculate ? onCalculate : null,
            icon: const Icon(Icons.calculate),
            label: const Text(
              'Calculate',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: canCalculate ? Colors.blue : Colors.grey,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onReset,
            icon: const Icon(Icons.refresh),
            label: const Text(
              'Reset',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
