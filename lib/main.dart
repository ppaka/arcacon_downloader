import 'dart:io';
import 'package:window_size/window_size.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import './screen/base_page.dart';
import './theme/style.dart';

void main() {
  LicenseRegistry.addLicense(() async* {
    final license = await rootBundle.loadString('google_fonts/OFL.txt');
    yield LicenseEntryWithLineBreaks(['google_fonts'], license);
  });
  runApp(const ArcaconDownloader());
  if (!Platform.isAndroid && !Platform.isIOS) {
    setWindowTitle("아카콘 다운로더");
  }
}

class ArcaconDownloader extends StatelessWidget {
  const ArcaconDownloader({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: '아카콘 다운로더',
      theme: material3Test(),
      darkTheme: material3TestDark(),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const BasePage(title: '아카콘 다운로더'),
    );
  }
}
