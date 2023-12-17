import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:arcacon_downloader/task_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadAllElevatedButton extends ConsumerStatefulWidget {
  const DownloadAllElevatedButton({
    required this.arcaconUrl,
    super.key,
    required this.arcaconId,
    required this.parentRef,
  });

  final String arcaconUrl;
  final int arcaconId;
  final WidgetRef parentRef;

  @override
  ConsumerState<DownloadAllElevatedButton> createState() =>
      _DownloadAllElevatedButtonState();
}

class _DownloadAllElevatedButtonState
    extends ConsumerState<DownloadAllElevatedButton> {
  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(taskStateProvider);
    return checkState(ref, tasks);
  }

  Widget checkState(WidgetRef ref, Map<int, DownloadTask> tasks) {
    if (tasks.containsKey(widget.arcaconId)) {
      var thisTask = tasks[widget.arcaconId];
      if (thisTask != null) {
        var total = thisTask.itemCount.toDouble();
        var current = (thisTask.completeCount + thisTask.errorCount).toDouble();
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
        onPressStartDownload(
          widget.parentRef,
          widget.arcaconUrl,
          null,
          () {},
        );
      },
      child: const Text('모두 다운로드'),
    );
  }
}
