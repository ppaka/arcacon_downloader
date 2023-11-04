import 'dart:io';

import 'package:arcacon_downloader/common/utils/download.dart';
import 'package:arcacon_downloader/common/utils/show_toast.dart';
import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

Future<void> onPressStartDownload(String url, int? index) async {
  DownloadTask result;
  if (index == null) {
    result = await singleStartDownload(url, null);
  } else {
    result = await singleStartDownload(url, index);
  }

  if (result.result == Result.success) {
    if (result.errorCount == 0) {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg: "다운로드가 완료되었어요\nDownload 폴더를 확인해보세요!",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.indigoAccent,
          textColor: Colors.white,
        );
      } else {
        showToast(
          Colors.indigoAccent,
          Icons.check_rounded,
          "다운로드가 완료되었어요\nDownload 폴더를 확인해보세요!",
          Colors.white,
          null,
        );
      }
    } else {
      if (Platform.isAndroid || Platform.isIOS) {
        Fluttertoast.showToast(
          msg:
              "${result.errorCount}개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.green,
          textColor: Colors.white,
        );
      } else {
        showToast(
          Colors.green,
          Icons.check_rounded,
          "${result.errorCount}개의 오류가 발생했지만... 다운로드 작업을 완료했어요\nDownloads 폴더를 확인해보세요!",
          Colors.white,
          null,
        );
      }
    }
  } else if (result.result == Result.connectError) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "해당 주소로 이동할 수 없습니다...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.error_rounded,
        "해당 주소로 이동할 수 없습니다...",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.noPermission) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
          msg: "허용되지 않은 권한이 있어요...",
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT,
          backgroundColor: Colors.deepOrangeAccent,
          textColor: Colors.white);
    } else {
      showToast(
        Colors.deepOrangeAccent,
        Icons.warning_rounded,
        "허용되지 않은 권한이 있어요...",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.alreadyRunning) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "이미 다운로드가 진행중인 아카콘입니다!",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.notifications_rounded,
        "이미 다운로드가 진행중인 아카콘입니다!",
        Colors.white,
        null,
      );
    }
  } else if (result.result == Result.pipError) {
    if (Platform.isAndroid || Platform.isIOS) {
      Fluttertoast.showToast(
        msg: "파이썬 pip 모듈을 설치하는데 오류가 발생했습니다...",
        gravity: ToastGravity.BOTTOM,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: Colors.red,
        textColor: Colors.white,
      );
    } else {
      showToast(
        Colors.red,
        Icons.error_outline_rounded,
        "파이썬 pip 모듈을 설치하는데 오류가 발생했습니다...",
        Colors.white,
        null,
      );
    }
  }
}
