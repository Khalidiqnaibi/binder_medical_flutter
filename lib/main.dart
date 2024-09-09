// lib/main.dart

import 'package:flutter/material.dart';
import 'webview_page.dart'; // Import WebViewPage
import 'package:flutter_downloader/flutter_downloader.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FlutterDownloader.initialize(debug: true); // Initialize downloader
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WebView Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Color(0xFF8B8C8E),
        textTheme: TextTheme(
          // Customize text themes if needed
        ),
      ),
      home: const WebViewPage(permissionsGranted: true,), // Set WebViewPage as the main page
    );
  }
}
