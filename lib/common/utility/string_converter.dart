import 'package:html_unescape/html_unescape.dart';

String convertEncodedTitleForList(String titleText) {
  for (int j = 0; j < titleText.length; j++) {
    if (titleText.contains('<span class="__cf_email__"')) {
      var lastIndex = titleText.lastIndexOf('<span class="__cf_email__"');
      var endIndex = titleText.lastIndexOf('</span>') + 7;
      var emailSource = titleText.substring(lastIndex, endIndex);

      var valueStartIndex = emailSource.lastIndexOf('data-cfemail="') + 14;
      var valueEndIndex = emailSource.lastIndexOf('">[email&nbsp;protected]');

      var encodedString = emailSource.substring(valueStartIndex, valueEndIndex);
      var email = "",
          r = int.parse(encodedString.substring(0, 2), radix: 16),
          n = 0,
          enI = 0;
      for (n = 2; encodedString.length - n > 0; n += 2) {
        enI = int.parse(encodedString.substring(n, n + 2), radix: 16) ^ r;
        email += String.fromCharCode(enI);
      }

      titleText = titleText.substring(0, lastIndex) +
          email +
          titleText.substring(endIndex);
    }
  }

  return titleText;
}

String convertHtmlEscapedString(String escapedString) {
  var converted = HtmlUnescape().convert(escapedString);
  return converted;
}

String convertEncodedTitleForDownload(String titleText) {
  for (int j = 0; j < titleText.length; j++) {
    if (titleText.contains('<a href="/cdn-cgi/l/email-protection"')) {
      var lastIndex =
          titleText.lastIndexOf('<a href="/cdn-cgi/l/email-protection"');
      var endIndex = titleText.lastIndexOf('</a>') + 4;
      var emailSource = titleText.substring(lastIndex, endIndex);

      var valueStartIndex = emailSource.lastIndexOf('data-cfemail="') + 14;
      var valueEndIndex =
          emailSource.lastIndexOf('">[email&nbsp;protected]</a>');

      var encodedString = emailSource.substring(valueStartIndex, valueEndIndex);
      var email = "",
          r = int.parse(encodedString.substring(0, 2), radix: 16),
          n = 0,
          enI = 0;
      for (n = 2; encodedString.length - n > 0; n += 2) {
        enI = int.parse(encodedString.substring(n, n + 2), radix: 16) ^ r;
        email += String.fromCharCode(enI);
      }

      titleText = titleText.substring(0, lastIndex) +
          email +
          titleText.substring(endIndex);
    }
  }

  return HtmlUnescape().convert(titleText);
}
