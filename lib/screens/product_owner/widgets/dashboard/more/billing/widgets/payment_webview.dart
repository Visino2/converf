import 'dart:async';

import 'package:converf/core/config/config.dart';
import 'package:converf/features/billing/models/billing_models.dart';
import 'package:converf/features/billing/repositories/billing_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Lightweight in-app WebView wrapper for third-party checkout flows
/// (e.g. Paystack). It keeps the user inside the app so the back/close
/// button always works, and it intercepts Paystack's "close" URLs so the
/// on-page "Cancel Payment" control can dismiss the view reliably.
class PaymentWebView extends ConsumerStatefulWidget {
  const PaymentWebView({super.key, required this.initialUrl, this.reference});

  final Uri initialUrl;
  final String? reference;

  @override
  ConsumerState<PaymentWebView> createState() => _PaymentWebViewState();
}

class _PaymentWebViewState extends ConsumerState<PaymentWebView> {
  static const Set<String> _acceptedCallbackHosts = <String>{
    'app.converf.com',
    'converf-fe.netlify.app',
    'converf.com',
    'converf.io',
    'www.converf.io',
  };
  static const Set<String> _successPathKeywords = <String>{
    'billing',
    'payment',
    'subscription',
    'callback',
    'success',
    'complete',
    'verify',
  };
  static const Set<String> _successQueryKeys = <String>{
    'reference',
    'trxref',
    'tx_ref',
    'transaction_id',
    'status',
  };

  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isClosing = false;
  bool _hasVisitedPaystack = false;
  bool _isCheckingPaymentStatus = false;
  Timer? _paymentStatusTimer;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            debugPrint('[BillingWebView] onPageStarted: $url');
            _markPaystackVisit(url);
            _setLoading(true);
          },
          onPageFinished: _handlePageFinished,
          onNavigationRequest: (request) {
            debugPrint('[BillingWebView] onNavigationRequest: ${request.url}');
            _markPaystackVisit(request.url);
            if (_isCloseUrl(request.url)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(widget.initialUrl);

    _startPaymentStatusPolling();
  }

  @override
  void dispose() {
    _paymentStatusTimer?.cancel();
    super.dispose();
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }

  void _startPaymentStatusPolling() {
    final reference = _normalizedReference;
    if (reference == null || reference.isEmpty) return;

    debugPrint('[BillingWebView] polling payment status for $reference');
    _paymentStatusTimer?.cancel();
    _paymentStatusTimer = Timer.periodic(
      const Duration(seconds: 3),
      (_) => unawaited(_checkPaymentStatus(reference)),
    );
    unawaited(_checkPaymentStatus(reference));
  }

  String? get _normalizedReference {
    final value = widget.reference?.trim();
    if (value == null || value.isEmpty) {
      return null;
    }
    return value;
  }

  Future<void> _checkPaymentStatus(String reference) async {
    if (_isClosing || _isCheckingPaymentStatus) return;

    _isCheckingPaymentStatus = true;
    try {
      final transactions = await ref
          .read(billingRepositoryProvider)
          .fetchTransactions(page: 1);
      final normalizedReference = reference.toLowerCase();
      BillingTransaction? transaction;
      for (final item in transactions.data) {
        final itemReference = item.reference?.trim().toLowerCase();
        if (itemReference == normalizedReference) {
          transaction = item;
          break;
        }
      }

      if (transaction == null) return;

      final status = transaction.status?.trim().toLowerCase();
      debugPrint(
        '[BillingWebView] polled transaction status for '
        '$reference => ${status ?? 'unknown'}',
      );

      if (status == 'success' ||
          status == 'successful' ||
          status == 'paid' ||
          status == 'completed' ||
          status == 'complete') {
        _closeView(success: true);
        return;
      }

      if (status == 'failed' ||
          status == 'failure' ||
          status == 'cancelled' ||
          status == 'canceled' ||
          status == 'abandoned') {
        _closeView(success: false);
      }
    } catch (error) {
      debugPrint(
        '[BillingWebView] payment status poll failed for $reference: $error',
      );
    } finally {
      _isCheckingPaymentStatus = false;
    }
  }

  Future<void> _handlePageFinished(String url) async {
    debugPrint('[BillingWebView] onPageFinished: $url');
    _markPaystackVisit(url);

    if (_isCloseUrl(url)) {
      return;
    }

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

    // Intercept Paystack close/cancel signals
    if (_isPaystackCancelUrl(uri)) {
      _closeView(success: false);
      return true;
    }

    // Only treat callbacks on Converf-controlled hosts/schemes as success.
    if (_isSuccessCallback(uri)) {
      _closeView(success: true);
      return true;
    }

    return false;
  }

  bool _isPaystackCancelUrl(Uri uri) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    return host.contains('paystack') &&
        (path.contains('close') || path.contains('cancel'));
  }

  bool _isSuccessCallback(Uri uri) {
    final parameters = <String, String>{
      ...uri.queryParameters.map(
        (key, value) => MapEntry(key.toLowerCase(), value.toLowerCase()),
      ),
      ..._fragmentParameters(uri),
    };
    final status = parameters['status'];

    if (status == 'failed' ||
        status == 'failure' ||
        status == 'cancelled' ||
        status == 'canceled') {
      return false;
    }

    if (_isPaystackSuccessUrl(uri, parameters)) {
      return true;
    }

    if (!_isAcceptedCallbackHost(uri)) return false;

    if (_hasVisitedPaystack) {
      return true;
    }

    final normalizedPath = _normalizedPath(uri);
    if (_successPathKeywords.any(normalizedPath.contains)) {
      return true;
    }

    return parameters.keys.any(_successQueryKeys.contains);
  }

  bool _isPaystackSuccessUrl(Uri uri, Map<String, String> parameters) {
    final host = uri.host.toLowerCase();
    final path = uri.path.toLowerCase();
    final status = parameters['status'];

    if (!host.contains('paystack')) {
      return false;
    }

    if (status == 'success' || status == 'successful' || status == 'paid') {
      return true;
    }

    return path.contains('success') ||
        path.contains('complete') ||
        path.contains('callback');
  }

  bool _isAcceptedCallbackHost(Uri uri) {
    if (uri.scheme.toLowerCase() == 'converf') {
      return true;
    }

    final host = uri.host.toLowerCase();
    if (host.isEmpty) return false;

    final apiHost = Uri.tryParse(AppConfig.apiBaseUrl)?.host.toLowerCase();
    return _acceptedCallbackHosts.contains(host) ||
        host == apiHost ||
        host.endsWith('.converf.com');
  }

  Map<String, String> _fragmentParameters(Uri uri) {
    final fragment = uri.fragment;
    if (!fragment.contains('=')) return const {};

    try {
      return Uri.splitQueryString(
        fragment,
      ).map((key, value) => MapEntry(key.toLowerCase(), value.toLowerCase()));
    } catch (_) {
      return const {};
    }
  }

  String _normalizedPath(Uri uri) {
    if (uri.scheme.toLowerCase() == 'converf' && uri.host.isNotEmpty) {
      return '/${uri.host}${uri.path}'.toLowerCase();
    }
    return uri.path.toLowerCase();
  }

  void _markPaystackVisit(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (uri.host.toLowerCase().contains('paystack')) {
      _hasVisitedPaystack = true;
    }
  }

  void _closeView({bool success = false}) {
    if (_isClosing) return;
    _isClosing = true;
    _paymentStatusTimer?.cancel();
    Navigator.of(context).maybePop(success);
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
          if (_isLoading) const LinearProgressIndicator(minHeight: 2),
          if (_normalizedReference != null)
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: SafeArea(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Complete payment and we will return you to the app automatically.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
