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

        if ((current / total).isNaN) {
          return const LinearProgressIndicator(
            value: null,
          );
        }

        return LinearProgressIndicator(
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
