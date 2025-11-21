import 'package:flutter/material.dart';

class TotalsCard extends StatelessWidget {
  const TotalsCard({
    super.key,
    required this.currencySymbol,
    required this.totalDisplayValue,
    required this.totalUsd,
    required this.showUsdEquivalent,
    required this.recommendedPsu,
  });

  final String currencySymbol;
  final double totalDisplayValue;
  final double totalUsd;
  final bool showUsdEquivalent;
  final int recommendedPsu;

  @override
  Widget build(BuildContext context) {
    final isPhone = MediaQuery.of(context).size.width < 480;
    final totalText = _totalText(isPhone);

    return Card(
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
            totalText,
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
    );
  }

  Widget _totalText(bool isPhone) {
    final mainText = Text(
      '$currencySymbol${totalDisplayValue.toStringAsFixed(2)}',
      style: const TextStyle(
        fontSize: 42,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );

    if (!showUsdEquivalent) return mainText;

    final usdChip = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.compare_arrows, size: 12, color: Colors.white70),
              const SizedBox(width: 4),
              Text(
                'USD Equivalent',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.white.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '\$${totalUsd.toStringAsFixed(2)}',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );

    if (isPhone) {
      return Column(
        children: [
          mainText,
          const SizedBox(height: 12),
          usdChip,
        ],
      );
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        mainText,
        const SizedBox(width: 16),
        usdChip,
      ],
    );
  }
}
