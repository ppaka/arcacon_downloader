import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: Column(children: [
        const SizedBox(
          height: 12,
        ),
        Row(
          children: const [
            SizedBox(
              width: 8,
            ),
            Text('다운로드 옵션', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        toggleBtn(context),
        textBtn(context)
      ]),
    );
  }
}

Widget toggleBtn(BuildContext context) {
  return SizedBox(
    height: 52,
    child: Expanded(
      child: Row(
        children: [
          const SizedBox(width: 8),
          Text(
            '폴더에 .nomedia 파일 추가하기',
            textAlign: TextAlign.left,
            style: TextStyle(
                fontWeight: FontWeight.normal,
                color: Theme.of(context).textTheme.titleLarge?.color,
                letterSpacing: 0,
                fontSize: 18),
          ),
          Switch(value: false, onChanged: (value) {})
        ],
      ),
    ),
  );
}

Widget textBtn(BuildContext context) {
  return SizedBox(
    height: 52,
    child: Expanded(
      child: TextButton(
        style: ButtonStyle(
            padding:
                MaterialStateProperty.all<EdgeInsetsGeometry>(EdgeInsets.zero),
            shape: MaterialStateProperty.all<OutlinedBorder>(
                const RoundedRectangleBorder())),
        onPressed: () {
          print('누름');
        },
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.only(left: 8),
              child: Text(
                '최근에 다운로드한 아카콘 폴더에 .nomedia 파일 추가하기',
                textAlign: TextAlign.left,
                style: TextStyle(
                    fontWeight: FontWeight.normal,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                    letterSpacing: 0,
                    overflow: TextOverflow.fade,
                    fontSize: 18),
              ),
            )
          ],
        ),
      ),
    ),
  );
}
