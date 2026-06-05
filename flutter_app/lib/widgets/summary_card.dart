import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/summarizer_service.dart';

class SummaryCard extends StatelessWidget {
  final SummaryResult result;

  const SummaryCard({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.primaryContainer,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.primary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Icon(Icons.auto_awesome, color: cs.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                'Summary',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              // Language badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: cs.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  result.languageName,
                  style: TextStyle(color: cs.onPrimary, fontSize: 11),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Summary text
          SelectableText(
            result.summary,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: cs.onPrimaryContainer,
                  height: 1.6,
                ),
          ),

          const SizedBox(height: 16),

          // Footer
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: cs.outline),
              const SizedBox(width: 4),
              Text(
                '${result.processingTimeSec}s on-device',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
              ),
              const Spacer(),
              // Copy button
              TextButton.icon(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: result.summary));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Summary copied!'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.copy, size: 14),
                label: const Text('Copy'),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  minimumSize: Size.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
