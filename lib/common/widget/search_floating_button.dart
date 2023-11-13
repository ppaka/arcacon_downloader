import 'dart:io';

import 'package:arcacon_downloader/common/utility/custom_tab.dart';
import 'package:flutter/material.dart';

class SearchFloatingActionButton extends StatelessWidget {
  const SearchFloatingActionButton({super.key});

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        if (Platform.isAndroid || Platform.isIOS) {
          launchURL(context, 'https://arca.live/e/?p=1');
        } else {
          launchURLtoBrowser(context, 'https://arca.live/e/?p=1');
        }
      },
      mini: true,
      heroTag: UniqueKey().toString(),
      child: const Icon(Icons.search),
    );
  }
}
