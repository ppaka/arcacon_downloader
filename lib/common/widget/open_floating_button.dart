import 'dart:io';

import 'package:arcacon_downloader/common/models/preview_arcacon.dart';
import 'package:arcacon_downloader/common/route/con_page.dart';
import 'package:arcacon_downloader/common/utils/show_toast.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class OpenFloatingActionButton extends StatelessWidget {
  const OpenFloatingActionButton({
    super.key,
    required this.textController,
  });

  final TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (textController.text.isEmpty) {
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
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ConPage(
                item: PreviewArcaconItem(textController.text, "", "", "", ""),
              ),
            ),
          );
        }
      },
      mini: true,
      heroTag: UniqueKey().toString(),
      child: const Icon(Icons.open_in_new),
    );
  }
}
