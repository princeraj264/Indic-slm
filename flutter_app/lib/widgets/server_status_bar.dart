import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/summarizer_service.dart';

class ServerStatusBar extends StatelessWidget {
  const ServerStatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final service = context.watch<SummarizerService>();
    final isOnline = service.serverOnline;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isOnline
          ? Colors.green.shade700
          : Colors.orange.shade800,
      child: Row(
        children: [
          Icon(
            isOnline ? Icons.circle : Icons.warning_amber_rounded,
            size: 10,
            color: Colors.white,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              isOnline
                  ? '🔒 On-device model active — no internet used'
                  : '⚠️ Local server not running. Start: uvicorn app.main:app --port 8000',
              style: const TextStyle(color: Colors.white, fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }
}
