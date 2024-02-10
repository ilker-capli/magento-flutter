import 'package:flutter/material.dart';
import 'package:magento_flutter/utils.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../app_config.dart';

class CartTabs extends StatefulWidget {
  const CartTabs({super.key});

  @override
  State<CartTabs> createState() => _CartTabsState();
}

class _CartTabsState extends State<CartTabs> {
  WebViewController? controller;

  @override
  void initState() {
    super.initState();
    _initController();
  }

  void _initController() async {
    final config = await AppConfig.forEnvironment();
    try {
      controller = WebViewController()
        ..loadRequest(
          Uri.parse("${config.apiUrl}/checkout/cart/"),
        );
    } catch (e) {
      printLongString(e.toString());
      /*
      setState(() {
        controller = null;
      });
      */
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Shopping Cart"),
      ),
      body: _loadSpecificViewForDesktop(),
    );
  }

  Widget _loadSpecificViewForDesktop() {
    if (controller != null) {
      return WebViewWidget(controller: controller!);
    } else {
      _initController();
      return const Center(
        child: Text("Can't Found WebView"),
      );
    }
  }
}
