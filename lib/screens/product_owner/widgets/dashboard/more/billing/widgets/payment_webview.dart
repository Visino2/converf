import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Lightweight in-app WebView wrapper for third‑party checkout flows
/// (e.g. Paystack). It keeps the user inside the app so the back/close
/// button always works, and it intercepts Paystack's "close" URLs so the
/// on-page "Cancel Payment" control can dismiss the view reliably.
class PaymentWebView extends StatefulWidget {
  const PaymentWebView({super.key, required this.initialUrl});

  final Uri initialUrl;

  @override
  State<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends State<PaymentWebView> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: _handlePageFinished,
          onNavigationRequest: (request) {
            if (_isCloseUrl(request.url)) {
              _closeView();
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.initialUrl);
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  Future<void> _handlePageFinished(String url) async {
    _setLoading(false);
    final uri = Uri.tryParse(url);
    if (uri == null) return;

    // Paystack uses window.close() when the user taps "Cancel Payment".
    // In a WebView that call is ignored, so we override it to redirect
    // to a known close URL that we intercept above.
    if (uri.host.contains('paystack')) {
      await _controller.runJavaScript(
        "window.close = function(){ window.location.href='https://checkout.paystack.com/close'; };",
      );
    }
  }

  bool _isCloseUrl(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    
    // Intercept Paystack close/cancel signals
    if (host.contains('paystack') && (path.contains('close') || path.contains('cancel'))) {
      return true;
    }

    // Intercept backend success/callback patterns to return to app automatically
    if (path.contains('callback') || 
        path.contains('success') || 
        path.contains('verify') || 
        path.contains('complete')) {
      return true;
    }

    return false;
  }

  void _closeView() {
    if (_isClosing) return;
    _isClosing = true;
    Navigator.of(context).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: _closeView,
        ),
        title: const Text(
          'Complete Payment',
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
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
