import 'package:arcacon_downloader/screen/arcacon_list.dart';
import 'package:flutter/material.dart';

class CustomPopMenuButton extends StatelessWidget {
  const CustomPopMenuButton(
      {super.key,
      required this.changeSearchFilter,
      required this.changeSortByRank});

  final void Function(SearchFilter filter) changeSearchFilter;
  final void Function(bool bool) changeSortByRank;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        PopupMenuButton(
            tooltip: '',
            icon: const Icon(Icons.filter_list_rounded),
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem<String>(
                    value: '제목',
                    onTap: () => changeSearchFilter(SearchFilter.title),
                    child: const Text('제목')),
                PopupMenuItem<String>(
                    value: '판매자',
                    onTap: () => changeSearchFilter(SearchFilter.nickname),
                    child: const Text('판매자')),
                PopupMenuItem<String>(
                    value: '태그',
                    onTap: () => changeSearchFilter(SearchFilter.tag),
                    child: const Text('태그')),
              ];
            }),
        PopupMenuButton(
            tooltip: '',
            icon: const Icon(Icons.sort_rounded),
            itemBuilder: (context) {
              return <PopupMenuEntry<String>>[
                PopupMenuItem(
                    onTap: () => changeSortByRank(false),
                    child: const Text('등록순')),
                PopupMenuItem(
                    onTap: () => changeSortByRank(true),
                    child: const Text('판매순')),
              ];
            }),
      ],
    );
  }
}
