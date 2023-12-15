import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskNotifier extends StateNotifier<Map<int, DownloadTask>> {
  TaskNotifier(this.ref) : super({});

  bool containsKey(int key) {
    return state.containsKey(key);
  }

  void add(int key, DownloadTask item) {
    state[key] = item;
  }

  void remove(int key) {
    state.remove(key);
  }

  final Ref ref;
}

final taskStateProvider =
    StateNotifierProvider<TaskNotifier, Map<int, DownloadTask>>((ref) {
  return TaskNotifier(ref);
});
