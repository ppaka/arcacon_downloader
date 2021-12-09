import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SecondPage extends StatefulWidget {
  const SecondPage({Key? key}) : super(key: key);

  @override
  State<SecondPage> createState() => _SecondPageState();
}

class _SecondPageState extends State<SecondPage> {
  final Completer<WebViewController> _controller =
      Completer<WebViewController>();

  late WebViewController _viewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
        body: Center(
          child: WebView(
            initialUrl: "https://arca.live/e/?p=1",
            javascriptMode: JavascriptMode.unrestricted,
            onWebViewCreated: (WebViewController webViewController) {
              _viewController = webViewController;
              _controller.complete(webViewController);
            },
          ),
        ),
        appBar: AppBar(
          title: const Text('웹에서 찾기'),
        ),
        floatingActionButton: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton(
                  tooltip: '클립보드에 복사',
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blueGrey,
                  child: const Icon(Icons.content_copy),
                  onPressed: () async {
                    var str = await _viewController.currentUrl();
                    Clipboard.setData(ClipboardData(text: str));
                    Fluttertoast.showToast(
                        msg: "페이지 주소가 클립보드에 복사되었습니다",
                        gravity: ToastGravity.BOTTOM,
                        toastLength: Toast.LENGTH_SHORT,
                        backgroundColor: Colors.blueGrey);
                  }),
              const Padding(padding: EdgeInsets.only(top: 10)),
              FutureBuilder<WebViewController>(
                  future: _controller.future,
                  builder: (BuildContext context,
                      AsyncSnapshot<WebViewController> controller) {
                    if (controller.hasData) {
                      return FloatingActionButton(
                          tooltip: '뒤로가기',
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blueAccent,
                          child: const Icon(Icons.arrow_back),
                          onPressed: () {
                            controller.data!.goBack();
                          });
                    }
                    return Container();
                  })
            ]));
  }
}
