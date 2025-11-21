import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class SummaryCard extends StatelessWidget {
  const SummaryCard({
    super.key,
    required this.isDarkMode,
    required this.summaryText,
    required this.onCopy,
    required this.summaryCopied,
  });

  final bool isDarkMode;
  final String summaryText;
  final VoidCallback onCopy;
  final bool summaryCopied;

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      color: isDarkMode ? Colors.white : Colors.grey[900],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Build Summary',
                      style: TextStyle(
                        fontSize: isMobile ? 18 : 20,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.grey[900],
                      ),
                    ),
                  ],
                ),
                isMobile ? _mobileCopyButton() : _desktopCopyButton(),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isDarkMode ? Colors.grey[700]! : Colors.grey[300]!,
                ),
              ),
              child: SelectableText(
                summaryText,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'monospace',
                  color: isDarkMode ? Colors.white : Colors.black87,
                  height: 1.5,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _mobileCopyButton() {
    return IconButton(
      onPressed: onCopy,
      icon: Icon(
        summaryCopied ? Icons.check_circle : Icons.copy,
        size: 22,
        color: summaryCopied ? Colors.green : Colors.blue,
      ),
      tooltip: summaryCopied ? 'Copied!' : 'Copy Summary',
      style: IconButton.styleFrom(
        backgroundColor: summaryCopied
            ? Colors.green.withValues(alpha: 0.1)
            : Colors.blue.withValues(alpha: 0.1),
        padding: const EdgeInsets.all(8),
      ),
    );
  }

  Widget _desktopCopyButton() {
    return ElevatedButton.icon(
      onPressed: onCopy,
      icon: Icon(summaryCopied ? Icons.check : Icons.copy, size: 18),
      label: Text(summaryCopied ? 'Copied!' : 'Copy Summary'),
      style: ElevatedButton.styleFrom(
        backgroundColor: summaryCopied ? Colors.green : Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
