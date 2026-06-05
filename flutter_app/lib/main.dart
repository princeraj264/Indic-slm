import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'screens/home_screen.dart';
import 'services/summarizer_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const IndicSLMApp());
}

class IndicSLMApp extends StatelessWidget {
  const IndicSLMApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SummarizerService(),
      child: MaterialApp(
        title: 'Indic SLM',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A56DB),
            brightness: Brightness.light,
          ),
          textTheme: GoogleFonts.notoSansTextTheme(),
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A56DB),
            brightness: Brightness.dark,
          ),
          textTheme: GoogleFonts.notoSansTextTheme(
            ThemeData(brightness: Brightness.dark).textTheme,
          ),
        ),
        themeMode: ThemeMode.system,
        home: const HomeScreen(),
      ),
    );
  }
}
