import 'package:flutter/material.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs_lite.dart';
import 'package:url_launcher/url_launcher.dart' as url_launcher;
import 'package:url_launcher/url_launcher_string.dart';

void launchURL(BuildContext context, String url) async {
  try {
    final theme = Theme.of(context);
    await launchUrl(
      Uri.parse(url),
      options: LaunchOptions(
        barColor: theme.colorScheme.surface,
        onBarColor: theme.colorScheme.onSurface,
        barFixingEnabled: false,
      ),
    );
  } catch (e) {
    // An exception is thrown if browser app is not installed on Android device.
    debugPrint(e.toString());
  }
}

void launchURLtoBrowser(BuildContext context, String url) async {
  try {
    await url_launcher.launchUrl(Uri.parse(url),
        mode: LaunchMode.externalApplication);
  } catch (e) {
    debugPrint(e.toString());
  }
}
