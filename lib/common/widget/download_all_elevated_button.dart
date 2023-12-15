import 'package:arcacon_downloader/common/utils/onpress_download.dart';
import 'package:arcacon_downloader/taskNotifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DownloadAllElevatedButton extends ConsumerWidget {
  const DownloadAllElevatedButton({
    required this.arcaconUrl,
    super.key,
    required this.arcaconId,
  });

  final String arcaconUrl;
  final int arcaconId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var tasks = ref.watch(taskStateProvider);
    debugPrint('asd');
    if (ref.watch(taskStateProvider.notifier).containsKey(arcaconId)) {
      var thisTask = tasks[arcaconId];
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
          ref,
          arcaconUrl,
          null,
          () {},
        );
      },
      child: const Text('모두 다운로드'),
    );
  }
}
