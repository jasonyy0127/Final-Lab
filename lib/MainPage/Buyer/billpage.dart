import 'dart:async';

import 'package:barter_it/Model/user.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class BillPage extends StatefulWidget {
  final User user;

  final double totalprice;

  const BillPage({super.key, required this.user, required this.totalprice});

  @override
  State<BillPage> createState() => _BillPageState();
}

class _BillPageState extends State<BillPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Bill"),
          backgroundColor: const Color.fromARGB(255, 21, 42, 78),
        ),
        body: Center(
          child: WebView(
            initialUrl:
                'https://uumitproject.com/barterIt/buyer/payment.php?sellerid=${widget.user.id}&userid=${widget.user.id}&email=${widget.user.email}&phone=${widget.user.phone}&name=${widget.user.name}&amount=${widget.totalprice}',
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _controller.complete(webViewController);
            },
            onProgress: (int progress) {
              // prg = progress as double;
              // setState(() {});
              // print('WebView is loading (progress : $progress%)');
            },
            onPageStarted: (String url) {
              // print('Page started loading: $url');
            },
            onPageFinished: (String url) {
              //print('Page finished loading: $url');
              setState(() {
                //isLoading = false;
              });
            },
          ),
        ));
  }
}
