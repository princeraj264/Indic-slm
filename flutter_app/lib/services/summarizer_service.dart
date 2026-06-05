import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

enum SummaryStatus { idle, loading, success, error }

class SummaryResult {
  final String summary;
  final String detectedLanguage;
  final String languageName;
  final double processingTimeSec;

  SummaryResult({
    required this.summary,
    required this.detectedLanguage,
    required this.languageName,
    required this.processingTimeSec,
  });

  factory SummaryResult.fromJson(Map<String, dynamic> json) => SummaryResult(
        summary: json['summary'],
        detectedLanguage: json['detected_language'],
        languageName: json['language_name'],
        processingTimeSec: (json['processing_time_sec'] as num).toDouble(),
      );
}

class SummarizerService extends ChangeNotifier {
  // Local server — never calls the internet
  static const String _baseUrl = 'http://127.0.0.1:8000';

  SummaryStatus _status = SummaryStatus.idle;
  SummaryResult? _result;
  String? _errorMessage;
  bool _serverOnline = false;

  SummaryStatus get status => _status;
  SummaryResult? get result => _result;
  String? get errorMessage => _errorMessage;
  bool get serverOnline => _serverOnline;
  bool get isLoading => _status == SummaryStatus.loading;

  /// Check if the local inference server is running
  Future<void> checkServerHealth() async {
    try {
      final response = await http
          .get(Uri.parse('$_baseUrl/health'))
          .timeout(const Duration(seconds: 3));
      _serverOnline = response.statusCode == 200;
    } catch (_) {
      _serverOnline = false;
    }
    notifyListeners();
  }

  /// Send chat text to local server for summarization
  Future<void> summarize(String chatText, {String? languageCode}) async {
    _status = SummaryStatus.loading;
    _errorMessage = null;
    _result = null;
    notifyListeners();

    try {
      final body = jsonEncode({
        'chat_text': chatText,
        if (languageCode != null) 'language': languageCode,
        'max_tokens': 300,
      });

      final response = await http
          .post(
            Uri.parse('$_baseUrl/summarize'),
            headers: {'Content-Type': 'application/json'},
            body: body,
          )
          .timeout(const Duration(seconds: 60));

      if (response.statusCode == 200) {
        final json = jsonDecode(utf8.decode(response.bodyBytes));
        _result = SummaryResult.fromJson(json);
        _status = SummaryStatus.success;
      } else {
        _errorMessage = 'Server error: ${response.statusCode}';
        _status = SummaryStatus.error;
      }
    } catch (e) {
      _errorMessage = 'Could not connect to local server.\n'
          'Make sure the backend is running:\n'
          'uvicorn app.main:app --host 0.0.0.0 --port 8000';
      _status = SummaryStatus.error;
    }
    notifyListeners();
  }

  void reset() {
    _status = SummaryStatus.idle;
    _result = null;
    _errorMessage = null;
    notifyListeners();
  }
}
