import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'app.dart'; 
import 'theme_provider.dart';
import 'providers/report_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  // Initialize Supabase in the true entry point
  await Supabase.initialize(
    url: 'https://svmwfkaxobwzkmwshuzn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2bXdma2F4b2J3emttd3NodXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwMjM5NDcsImV4cCI6MjEwMTU5OTk0N30.tDc41x1W6eB1uJw_Od8bjis8ZbB04iILpRIs1ks1vzw',
  );

  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('is_dark_mode') ?? false;
  themeNotifier = ValueNotifier(isDarkMode ? ThemeMode.dark : ThemeMode.light);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ReportProvider()),
      ],
      child: MyApp(themeNotifier: themeNotifier),
    ),
  );
}