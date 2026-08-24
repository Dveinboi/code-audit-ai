import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app.dart'; 

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase in the true entry point
  await Supabase.initialize(
    url: 'https://svmwfkaxobwzkmwshuzn.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InN2bXdma2F4b2J3emttd3NodXpuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODYwMjM5NDcsImV4cCI6MjEwMTU5OTk0N30.tDc41x1W6eB1uJw_Od8bjis8ZbB04iILpRIs1ks1vzw',
  );

  runApp(const MyApp());
}