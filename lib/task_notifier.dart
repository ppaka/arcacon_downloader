import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class TaskNotifier extends StateNotifier<Map<int, DownloadTask>> {
  TaskNotifier() : super({});

  bool containsKey(int key) {
    return state.containsKey(key);
  }

  void add(int key, DownloadTask item) {
    if (!containsKey(key)) {
      Map<int, DownloadTask> task = {key: item};
      state = {...state, ...task};
    } else {
      Map<int, DownloadTask> myState = {...state};
      myState[key] = item;
      state = myState;
    }
  }

  void remove(int findKey) {
    if (containsKey(findKey)) {
      Map<int, DownloadTask> myState = {...state};
      myState.removeWhere((key, value) => key == findKey);
      state = myState;
    } else {
      return;
    }
  }
}

final taskStateProvider =
    StateNotifierProvider<TaskNotifier, Map<int, DownloadTask>>((ref) {
  return TaskNotifier();
});
