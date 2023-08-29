import 'package:arcacon_downloader/ReactiveController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskList extends StatefulWidget {
  const TaskList({Key? key}) : super(key: key);

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    Get.put(ReactiveController()); // 반응형 상태 관리 controller 등록
    return Scaffold(
      appBar: AppBar(
        title: const Text("단순 / 반응형 상태관리"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GetX<ReactiveController>(
              // 반응형 상태관리 - 1
              builder: (controller) {
                return ElevatedButton(
                  child: Text(
                    '반응형 1 / 현재 숫자: ${controller.counter.value}', // .value 로 접근
                  ),
                  onPressed: () {
                    controller.increase();
                    // Get.find<ReactiveController>().increase();
                  },
                );
              },
            ),
            Obx(
              // 반응형 상태관리 - 2
              () {
                return ElevatedButton(
                  child: Text(
                    '반응형 2 / 현재 숫자: ${Get.find<ReactiveController>().counter.value}', // .value 로 접근
                  ),
                  onPressed: () {
                    Get.find<ReactiveController>().increase();
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
