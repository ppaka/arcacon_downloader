import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SecondPage extends StatelessWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    WebViewController? _controller;
    return Scaffold(
      body: Center(
        child: WebView(
          initialUrl: "https://m.naver.com",
          javascriptMode: JavascriptMode.unrestricted,
          onWebViewCreated: (WebViewController webViewController) {
            _controller = webViewController;
          },
        ),
      ),
      appBar: AppBar(
        title: const Text('title'),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Text("COPY",
            style: TextStyle(color: Colors.white, fontSize: 12)),
        onPressed: () {
          var str = _controller?.currentUrl().toString();
          Clipboard.setData(ClipboardData(text: str));
        },
      ),
    );
  }
}
