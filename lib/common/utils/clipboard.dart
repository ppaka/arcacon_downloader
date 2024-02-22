import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

Future<String> get _localpath async {
  final directory = await getApplicationCacheDirectory();
  return directory.path;
}

Future<void> copyfile(String key) async {
  Clipboard.setData(ClipboardData(text: "content://$_localpath/$key"));
  return;
}

void copyToClipboard(String text) {
  Clipboard.setData(ClipboardData(text: text));
}
