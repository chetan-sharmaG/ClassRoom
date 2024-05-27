import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ErpView extends StatefulWidget {
  const ErpView({super.key});

  @override
  State<ErpView> createState() => _ErpViewState();
}

class _ErpViewState extends State<ErpView> {
  WebViewController controller = WebViewController()
    ..loadRequest(Uri.parse('https://pgc.myclassboard.com'))
    ..setJavaScriptMode(JavaScriptMode.disabled);
  String? message;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('ClassRoom ERP'),
        ),
        body: WebViewWidget(controller: controller));
  }
}
