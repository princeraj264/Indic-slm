import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/summarizer_service.dart';
import '../widgets/language_chip.dart';
import '../widgets/summary_card.dart';
import '../widgets/server_status_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _chatController = TextEditingController();
  String? _selectedLanguage;

  final List<Map<String, String>> _languages = [
    {'code': 'auto', 'name': 'Auto Detect', 'flag': '🔍'},
    {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
    {'code': 'bn', 'name': 'Bengali', 'flag': '🇧🇩'},
    {'code': 'ta', 'name': 'Tamil', 'flag': '🌺'},
    {'code': 'te', 'name': 'Telugu', 'flag': '🌸'},
    {'code': 'mr', 'name': 'Marathi', 'flag': '🏯'},
    {'code': 'gu', 'name': 'Gujarati', 'flag': '🦁'},
    {'code': 'kn', 'name': 'Kannada', 'flag': '🐘'},
    {'code': 'ml', 'name': 'Malayalam', 'flag': '🥥'},
    {'code': 'en', 'name': 'English', 'flag': '🔤'},
  ];

  @override
  void initState() {
    super.initState();
    _selectedLanguage = 'auto';
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SummarizerService>().checkServerHealth();
    });
  }

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  void _summarize() {
    final text = _chatController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please paste your chat first!')),
      );
      return;
    }
    final langCode = _selectedLanguage == 'auto' ? null : _selectedLanguage;
    context.read<SummarizerService>().summarize(text, languageCode: langCode);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final service = context.watch<SummarizerService>();

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Indic SLM', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            Text('Privacy-First Chat Summarizer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Check server',
            onPressed: () => service.checkServerHealth(),
          ),
        ],
      ),
      body: Column(
        children: [
          // Server status bar
          const ServerStatusBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Language selector
                  Text('Language', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _languages.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final lang = _languages[i];
                        return LanguageChip(
                          flag: lang['flag']!,
                          name: lang['name']!,
                          isSelected: _selectedLanguage == lang['code'],
                          onTap: () => setState(() => _selectedLanguage = lang['code']),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Chat input
                  Text('Paste Your Chat', style: Theme.of(context).textTheme.labelLarge),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: cs.outline),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      controller: _chatController,
                      maxLines: 10,
                      decoration: InputDecoration(
                        hintText: 'Paste WhatsApp, Telegram, or any chat here...\n\nExample:\nRaj: कल मीटिंग है\nPriya: हाँ, 3 बजे\nRaj: ठीक है',
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.all(12),
                        suffixIcon: _chatController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _chatController.clear();
                                  service.reset();
                                  setState(() {});
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Summarize button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: service.isLoading ? null : _summarize,
                      icon: service.isLoading
                          ? const SizedBox(
                              width: 18, height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                          : const Icon(Icons.auto_awesome),
                      label: Text(service.isLoading ? 'Summarizing on device...' : 'Summarize Chat'),
                      style: FilledButton.styleFrom(
                        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Privacy note
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.lock, size: 12, color: cs.outline),
                      const SizedBox(width: 4),
                      Text(
                        'Runs 100% on-device. Your data never leaves this phone.',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: cs.outline),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Result
                  if (service.status == SummaryStatus.success && service.result != null)
                    SummaryCard(result: service.result!),

                  if (service.status == SummaryStatus.error)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cs.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: cs.error),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              service.errorMessage ?? 'Unknown error',
                              style: TextStyle(color: cs.onErrorContainer),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
