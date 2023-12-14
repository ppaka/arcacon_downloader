import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter/material.dart';

class DownloadAllElevatedButton extends StatefulWidget {
  const DownloadAllElevatedButton({
    super.key,
    required this.onPressed,
    required this.arcaconId,
  });

  final Function onPressed;
  final int arcaconId;

  @override
  State<DownloadAllElevatedButton> createState() =>
      _DownloadAllElevatedButtonState();
}

class _DownloadAllElevatedButtonState extends State<DownloadAllElevatedButton> {
  @override
  Widget build(BuildContext context) {
    if (runningTasks.containsKey(widget.arcaconId)) {
      var task = runningTasks[widget.arcaconId];
      if (task != null) {
        var total = task.itemCount.toDouble();
        var current = (task.completeCount + task.errorCount).toDouble();
        debugPrint("$current / $total");

        var height = 40.0;

        if ((current / total).isNaN) {
          return LinearProgressIndicator(
            minHeight: height,
            borderRadius: BorderRadius.circular(height / 2),
            value: null,
          );
        }

        return LinearProgressIndicator(
          minHeight: height, //높이 조절
          borderRadius: BorderRadius.circular(height / 2), // 동그란 수치 조절
          value: current / total,
        );
      }
    }

    return ElevatedButton(
      onPressed: () {
        widget.onPressed();
      },
      child: const Text('모두 다운로드'),
    );
  }
}
