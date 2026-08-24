import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class GithubLoginWebview extends StatefulWidget {
  final String authUrl;
  final String redirectScheme;

  const GithubLoginWebview({
    Key? key,
    required this.authUrl,
    required this.redirectScheme,
  }) : super(key: key);

  @override
  State<GithubLoginWebview> createState() => _GithubLoginWebviewState();
}

class _GithubLoginWebviewState extends State<GithubLoginWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = true;
              });
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() {
                _isLoading = false;
              });
            }
          },
          onNavigationRequest: (NavigationRequest request) {
            // Check if the URL starts with our deep link scheme
            if (request.url.startsWith(widget.redirectScheme)) {
              // We caught the redirect! Pop the screen and return the URL.
              Navigator.of(context).pop(request.url);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      );
      
    _initWebView();
  }

  Future<void> _initWebView() async {
    // Crucial: Wipe the cookies before loading so they have to login every time
    await WebViewCookieManager().clearCookies();
    
    // Load the URL only AFTER cookies are cleared
    _controller.loadRequest(Uri.parse(widget.authUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub Authorization'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
