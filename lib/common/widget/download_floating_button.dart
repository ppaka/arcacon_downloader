import 'dart:io';

import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/common/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class DownloadFloatingActionButton extends StatefulWidget {
  const DownloadFloatingActionButton({super.key, required this.textController});

  final TextEditingController textController;

  @override
  State<DownloadFloatingActionButton> createState() =>
      _DownloadFloatingActionButtonState();
}

class _DownloadFloatingActionButtonState
    extends State<DownloadFloatingActionButton> {
  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (widget.textController.text.isEmpty) {
          if (Platform.isAndroid || Platform.isIOS) {
            Fluttertoast.showToast(
              msg: "주소를 입력해주세요!",
              gravity: ToastGravity.BOTTOM,
              toastLength: Toast.LENGTH_SHORT,
              backgroundColor: Colors.redAccent[400],
              textColor: Colors.white,
            );
          } else {
            showToast(
              Colors.redAccent,
              Icons.warning_rounded,
              "주소를 입력해주세요!",
              Colors.white,
              null,
            );
          }
        } else {
          onPressStartDownload(widget.textController.text, null, () {
            setState(() {});
          });
        }
      },
      mini: false,
      heroTag: UniqueKey().toString(),
      child: const Icon(Icons.download),
    );
  }
}
