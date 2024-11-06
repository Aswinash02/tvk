import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:tvk_customer/error_screen.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late InAppWebViewController webViewController;
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              InAppWebView(
                initialUrlRequest:
                    URLRequest(url: Uri.parse("https://tvkproducts.in/")),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (mounted) {
                    setState(() {
                      isLoading = true;
                    });
                  }
                },
                onLoadStop: (controller, url) async {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                onLoadError: (controller, url, code, message) {
                  if (mounted) {
                    setState(() {
                      isLoading = false;
                    });
                  }
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ErrorScreen(
                        errorMessage: 'Failed to load page: $message',
                        onRetry: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const WebViewScreen()),
                          );
                        },
                      ),
                    ),
                  );
                },
                initialOptions: InAppWebViewGroupOptions(
                  crossPlatform: InAppWebViewOptions(
                    useOnDownloadStart: true,
                    transparentBackground: true,
                  ),
                ),
              ),
              if (isLoading)
                const Center(
                  child: CupertinoActivityIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Do you want to exit the WebView?'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Yes'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
