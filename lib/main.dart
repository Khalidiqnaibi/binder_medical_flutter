// lib/main.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String homeUrl = 'https://www.bindersoftware.com/Binder_medical'; // replace with your hosted site or local dev url

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Binder Mobile',
      theme: ThemeData.light(),
      home: WebviewScreen(homeUrl: homeUrl),
    );
  }
}

class WebviewScreen extends StatefulWidget {
  final String homeUrl;
  WebviewScreen({required this.homeUrl});
  @override
  _WebviewScreenState createState() => _WebviewScreenState();
}

class _WebviewScreenState extends State<WebviewScreen> {
  InAppWebViewController? webViewController;
  final Dio dio = Dio();

  @override
  void initState() {
    super.initState();
  }

  Future<void> _requestStoragePermission() async {
    if (Platform.isAndroid) {
      await Permission.storage.request();
      if (await Permission.manageExternalStorage.isDenied) {
        // optionally request MANAGE_EXTERNAL_STORAGE via user prompt (settings).
      }
    }
  }

  Future<String> _getDownloadDir() async {
    if (Platform.isAndroid) {
      final dir = await getExternalStorageDirectory();
      return dir?.path ?? (await getApplicationDocumentsDirectory()).path;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      return dir.path;
    }
  }

  Future<void> _downloadFile(String url, {String? suggestedName}) async {
    try {
      await _requestStoragePermission();
      final dir = await _getDownloadDir();
      final fileName = suggestedName ?? url.split('/').last.split('?').first;
      final savePath = '$dir/$fileName';
      final resp = await dio.download(url, savePath,
          onReceiveProgress: (rec, total) {
        // you can show progress UI here
      });
      if (resp.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Downloaded to: $savePath')),
        );
      } else {
        throw Exception('Download failed: ${resp.statusCode}');
      }
    } catch (e) {
      print('download error: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Download failed')));
    }
  }

  /// Native file picker (returns list of file URIs and then posts them back to the webview if needed)
  Future<List<Uri>?> _pickFiles({bool allowMultiple = false}) async {
    final res = await FilePicker.platform.pickFiles(allowMultiple: allowMultiple, withReadStream: true);
    if (res == null) return null;
    return res.paths.map((p) => p != null ? Uri.file(p) : null).whereType<Uri>().toList();
  }

  @override
  Widget build(BuildContext context) {
    final initialOptions = InAppWebViewGroupOptions(
      crossPlatform: InAppWebViewOptions(
        javaScriptEnabled: true,
        useOnDownloadStart: true,
        mediaPlaybackRequiresUserGesture: false,
        allowFileAccessFromFileURLs: true,
        allowUniversalAccessFromFileURLs: true,
      ),
      android: AndroidInAppWebViewOptions(
        useHybridComposition: true,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: Uri.parse(widget.homeUrl)),
          initialOptions: initialOptions,
          onWebViewCreated: (controller) async {
            webViewController = controller;

            // Set up JS handler so your web page can call native file picker
            await controller.addJavaScriptHandler(handlerName: 'flutterFileUpload', callback: (args) async {
              // args can include allowed types etc.
              final picked = await _pickFiles(allowMultiple: false);
              if (picked == null) return { 'success': false };
              // For one-off simple flows you might want to upload files here via Dio to your server,
              // then call a JS function to provide the uploaded file URL back to the page.
              return { 'success': true, 'files': picked.map((u) => u.toString()).toList() };
            });
          },

          // Android: intercept file chooser
          androidOnShowFileChooser: (controller, params) async {
            // params contains acceptTypes, whether multiple allowed etc
            final allowMultiple = params.allowMultiple;
            final types = params.acceptTypes;
            final picked = await _pickFiles(allowMultiple: allowMultiple ?? false);
            if (picked == null || picked.isEmpty) return FileChooserResult(uris: []);
            // Return URIs to webview (Android will map these into input elements)
            return FileChooserResult(uris: picked);
          },

          // handle downloads
          onDownloadStartRequest: (controller, req) async {
            final url = req.url.toString();
            // optionally confirm
            final suggested = url.split('/').last.split('?').first;
            final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                      title: Text('Download file?'),
                      content: Text(suggested),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: Text('Cancel')),
                        TextButton(onPressed: () => Navigator.pop(context, true), child: Text('Download')),
                      ],
                    ));
            if (confirm == true) {
              await _downloadFile(url, suggestedName: suggested);
            }
          },

          onConsoleMessage: (controller, consoleMsg) {
            debugPrint('JS: ${consoleMsg.message}');
          },

          onLoadStop: (controller, url) async {
            debugPrint('loaded: $url');
          },
        ),
      ),
    );
  }
}
