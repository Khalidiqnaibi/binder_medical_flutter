import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Flutter Downloader and request necessary permissions
  await FlutterDownloader.initialize(debug: true);

  // Request permissions before proceeding
  bool permissionsGranted = await _requestPermissions();

  if (!permissionsGranted) {
    print("Storage permission denied");
  }

  runApp(MyApp(permissionsGranted: permissionsGranted));
}

// Function to request storage permissions
Future<bool> _requestPermissions() async {
  var status = await Permission.storage.status;
  if (!status.isGranted) {
    var result = await Permission.storage.request();
    return result.isGranted;
  }
  return true;
}

class MyApp extends StatelessWidget {
  final bool permissionsGranted;

  const MyApp({Key? key, required this.permissionsGranted}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WebViewPage(permissionsGranted: permissionsGranted),
    );
  }
}

class WebViewPage extends StatefulWidget {
  final bool permissionsGranted;

  const WebViewPage({Key? key, required this.permissionsGranted}) : super(key: key);

  @override
  _WebViewPageState createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late InAppWebViewController _webViewController;

  @override
  void initState() {
    super.initState();
    _setupDownloader();
  }

  Future<void> _setupDownloader() async {
    // Register the download callback
    FlutterDownloader.registerCallback(downloadCallback as DownloadCallback);
  }

  // Static method to track download progress and status
  static void downloadCallback(String id, DownloadTaskStatus status, int progress) {
    print('Download task ($id) is in status $status with progress $progress%');
  }

  // Handle file downloads by starting the download
  Future<void> _onDownloadStart(String url) async {
    Directory? dir = await getExternalStorageDirectory();

    if (dir == null) {
      print("Failed to get external storage directory");
      return;
    }

    String path = dir.path;

    // Ensure directory exists
    if (!await Directory(path).exists()) {
      print("Directory does not exist: $path");
      return;
    }

    try {
      final taskId = await FlutterDownloader.enqueue(
        url: url,
        savedDir: path,
        showNotification: true, // Show progress in the notification bar
        openFileFromNotification: true, // Open file on notification tap
      );

      print('Download started: $taskId');
    } catch (e) {
      print('Failed to start download: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.permissionsGranted) {
      return Scaffold(
        body: Center(
          child: Text('Storage permission required'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Binder Medical'),
        centerTitle: true,
      ),
      body: InAppWebView(
        initialUrlRequest: URLRequest(
          url: Uri.parse('https://www.bindersoftware.com/Binder_medical'),
        ),
        initialOptions: InAppWebViewGroupOptions(
          crossPlatform: InAppWebViewOptions(
            useOnDownloadStart: true, // Enable the download listener
            javaScriptEnabled: true,
            userAgent: 'random', // Set custom User-Agent
            mediaPlaybackRequiresUserGesture: false, // Allow media playback
          ),
        ),
        onWebViewCreated: (InAppWebViewController controller) {
          _webViewController = controller;
        },
        onDownloadStartRequest: (controller, request) async {
          print("onDownloadStart ${request.url}");
          print('Download Start');
          await _onDownloadStart(request.url.toString());
        },
        onLoadStop: (controller, url) {
          print('Page loaded: $url');
        },
        androidOnGeolocationPermissionsShowPrompt: (InAppWebViewController controller, String origin) async {
          return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: true);
        },
        onReceivedServerTrustAuthRequest: (controller, challenge) async {
          print('Server trust auth request received');
          return ServerTrustAuthResponse(action: ServerTrustAuthResponseAction.PROCEED);
        },
      ),
    );
  }
}
