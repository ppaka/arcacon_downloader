import 'dart:io';

import 'package:arcacon_downloader/screen/first_page.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/ffprobe_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter/material.dart';

downloadToPath(
  String con,
  List<String> arcaconTrueUrl,
  int index,
  List<String> arcacon,
  String videoDir,
  String directory,
  DownloadTask result,
  String pyDirectory,
) async {
  if (con.endsWith('.png')) {
    var fileType = '.png';
    var res = await downloadFile(
        arcaconTrueUrl[index],
        (index + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            fileType,
        directory);
    if (res == false) result.errorCount++;
  } else if (con.endsWith('.jpeg')) {
    var fileType = '.jpeg';
    var res = await downloadFile(
        arcaconTrueUrl[index],
        (index + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            fileType,
        directory);
    if (res == false) result.errorCount++;
  } else if (con.endsWith('.jpg')) {
    var fileType = '.jpg';
    var res = await downloadFile(
        arcaconTrueUrl[index],
        (index + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            fileType,
        directory);
    if (res == false) result.errorCount++;
  } else if (con.endsWith('.gif')) {
    var fileType = '.gif';
    var res = await downloadFile(
        arcaconTrueUrl[index],
        (index + 1)
                .toString()
                .padLeft(arcacon.length.toString().length, '0')
                .toString() +
            fileType,
        directory);
    if (res == false) result.errorCount++;
  } else if (con.endsWith('.mp4')) {
    var fileType = '.mp4';
    var fileName = (index + 1)
        .toString()
        .padLeft(arcacon.length.toString().length, '0')
        .toString();
    var convertedFileName =
        '${(index + 1).toString().padLeft(arcacon.length.toString().length, '0')}.gif';
    var res = await downloadFile(
        arcaconTrueUrl[index], fileName + fileType, videoDir);
    if (res == false) {
      result.errorCount++;
    } else {
      var outputPalettePath = '${videoDir}palette.png';

      if (Platform.isAndroid || Platform.isIOS) {
        var fps = 25.0;

        var l = await FFprobeKit.execute(
            "-v 0 -of compact=p=0 -select_streams 0 -show_entries stream=r_frame_rate '${videoDir + fileName + fileType}'");
        var output = await l.getOutput();
        if (output != null) {
          output = output.replaceAll("r_frame_rate=", "");
          var double1 = double.parse(output.split('/')[0]);
          var double2 = double.parse(output.split('/')[1]);
          fps = double1 / double2;
          debugPrint("프레임: $output ($fps)");
        }

        while (fps > 50) {
          fps = fps / 2;
          debugPrint("프레임 변경: $fps");
        }

        await FFmpegKit.executeWithArguments(
          [
            '-y',
            '-i',
            videoDir + fileName + fileType,
            '-vf',
            'scale=100:-1:flags=lanczos,palettegen',
            '-hide_banner',
            '-loglevel',
            'error',
            '${videoDir}palette.png'
          ],
        ).then(
          (session) async {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              debugPrint(
                  "$fileName$fileType 팔레트 추출 성공 ${returnCode!.getValue()}");
            } else if (ReturnCode.isCancel(returnCode)) {
              debugPrint(
                  "$fileName$fileType 팔레트 추출 취소 ${returnCode!.getValue()}");
            } else {
              debugPrint(
                  "$fileName$fileType 팔레트 추출 오류 ${returnCode!.getValue()}");
            }
          },
        );
        await FFmpegKit.executeWithArguments(
          [
            '-y',
            '-i',
            videoDir + fileName + fileType,
            '-i',
            '${videoDir}palette.png',
            '-filter_complex',
            'scale=100:-1:flags=lanczos[x];[x][1:v]paletteuse',
            '-hide_banner',
            '-loglevel',
            'error',
            '-r',
            fps.toString(),
            directory + convertedFileName
          ],
        ).then(
          (session) async {
            final returnCode = await session.getReturnCode();

            if (ReturnCode.isSuccess(returnCode)) {
              debugPrint(
                  "$fileName$fileType gif 변환 성공 ${returnCode!.getValue()}");
            } else if (ReturnCode.isCancel(returnCode)) {
              debugPrint(
                  "$fileName$fileType gif 변환 취소 ${returnCode!.getValue()}");
            } else {
              debugPrint(
                  "$fileName$fileType gif 변환 오류 ${returnCode!.getValue()}");
              result.errorCount++;
            }
          },
        );
      } else {
        var processRes = await Process.run(
          'python',
          [
            '${pyDirectory}convert.py',
            videoDir + fileName + fileType,
            directory + convertedFileName,
            outputPalettePath
          ],
        );
        debugPrint(processRes.stdout.toString());
        debugPrint(processRes.stderr.toString());
        debugPrint(processRes.exitCode.toString());
      }

      if (await File(outputPalettePath).exists()) {
        try {
          await File(outputPalettePath).delete(recursive: false);
        } catch (ex) {
          debugPrint("오류: 팔레트 파일을 제거할 수 없음\n$ex");
        }
      }
    }
  }
}
