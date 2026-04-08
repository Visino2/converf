import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// A fullscreen in-app WebView that handles the social OAuth flow.
/// It monitors navigation events and calls [onCallback] when it detects
/// that the browser has landed on the Converf frontend callback URL
/// (converf-fe.netlify.app/auth/...) so the app can process the token
/// without it ever being rendered in an external browser.
class SocialAuthWebView extends StatefulWidget {
  const SocialAuthWebView({
    super.key,
    required this.authUrl,
    required this.onCallback,
    required this.onCancel,
  });

  /// The full Google / Apple OAuth redirect URL to load.
  final String authUrl;

  /// Called when the backend redirects back to the Converf frontend
  /// with the auth callback URL (contains `token`, `id`, or `error`).
  final void Function(Uri callbackUri) onCallback;

  /// Called when the user taps the close / back button.
  final VoidCallback onCancel;

  @override
  State<SocialAuthWebView> createState() => _SocialAuthWebViewState();
}

class _SocialAuthWebViewState extends State<SocialAuthWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _callbackHandled = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (!mounted) return;
            setState(() => _isLoading = true);
            _checkForCallback(url);
          },
          onPageFinished: (url) {
            if (!mounted) return;
            setState(() => _isLoading = false);
            _checkForCallback(url);
          },
          onNavigationRequest: (request) {
            _checkForCallback(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(widget.authUrl));
  }

  void _checkForCallback(String url) {
    if (_callbackHandled) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Intercept any navigation to the Converf callback path.
    // The backend redirects to either the Netlify preview or the production domain.
    final isCallbackHost = uri.host == 'converf-fe.netlify.app' || 
                         uri.host == 'converf.io' || 
                         uri.host == 'www.converf.io';
    final isCallbackPath = uri.path == '/auth/callback';

    if (isCallbackHost && isCallbackPath) {
      _callbackHandled = true;
      // Give the WebView a moment to register before we pop it.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Navigator.of(context).pop();
        }
        widget.onCallback(uri);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: widget.onCancel,
        ),
        title: const Text(
          'Sign In',
          style: TextStyle(
            color: Colors.black,
            fontSize: 17,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
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
