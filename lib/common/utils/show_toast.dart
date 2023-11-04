import 'package:arcacon_downloader/screen/base_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(Color color, IconData icon, String text, Color textColor,
    Duration? duration) {
  duration ??= const Duration(seconds: 2);

  Widget toast = Container(
    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(25.0),
      color: color,
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: textColor,
        ),
        const SizedBox(
          width: 12.0,
        ),
        Text(
          text,
          style: TextStyle(
            color: textColor,
          ),
        ),
      ],
    ),
  );

  fToast.removeCustomToast();

  fToast.showToast(
    child: toast,
    gravity: ToastGravity.BOTTOM,
    toastDuration: duration,
  );
}
