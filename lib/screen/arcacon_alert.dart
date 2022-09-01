import 'package:flutter/material.dart';

import '../utility/custom_tab.dart';

class ArcaconAlert extends StatelessWidget {
  const ArcaconAlert({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('안내'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('더 이상 아카콘 목록 페이지가 제공되지 않습니다'),
            TextButton(
                onPressed: () {
                  launchURL(context,
                      'https://github.com/ppaka/privacypage/blob/main/arcaconAlert.md');
                },
                child: const Text('자세히 보기'))
          ],
        ),
      ),
    );
  }
}
