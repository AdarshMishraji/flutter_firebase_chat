import 'package:regex_validator/src/regex_patterns.dart';
import 'package:regex_validator/src/regex_validator.dart';

extension StringExtensions on String {
  /// Username regex
  /// Requires minimum 3 character
  /// Allowing "_" and "." in middle of name
  bool isUsername() => RegVal.hasMatch(this, RegexPatterns.username);

  /// Email regex
  bool isEmail() => RegVal.hasMatch(this, RegexPatterns.email);

  /// URL regex
  /// Eg:
  /// - https://medium.com/@diegoveloper/flutter-widget-size-and-position-b0a9ffed9407
  /// - https://www.youtube.com/watch?v=COYFmbVEH0k
  /// - https://stackoverflow.com/questions/53913192/flutter-change-the-width-of-an-alertdialog/57688555
  bool isUrl() => RegVal.hasMatch(this, RegexPatterns.url);

  /// Phone Number regex
  /// Must started by either, "0", "+", "+XX <X between 2 to 4 digit>", "(+XX <X between 2 to 3 digit>)"
  /// Can add whitespace separating digit with "+" or "(+XX)"
  /// Example: 05555555555, +555 5555555555, (+123) 5555555555, (555) 5555555555, +5555 5555555555
  bool isPhone() => RegVal.hasMatch(this, RegexPatterns.phone);

  /// Hexadecimal regex
  bool isHex() => RegVal.hasMatch(this, RegexPatterns.hexadecimal);

  /// Image vector regex
  bool isVector() => RegVal.hasMatch(this, RegexPatterns.vector);

  /// Image regex
  bool isImage() => RegVal.hasMatch(this, RegexPatterns.image);

  /// Audio regex
  bool isAudio() => RegVal.hasMatch(this, RegexPatterns.audio);

  /// Video regex
  bool isVideo() => RegVal.hasMatch(this, RegexPatterns.video);

  /// Txt regex
  bool isTxt() => RegVal.hasMatch(this, RegexPatterns.txt);

  /// Document regex
  bool isDoc() => RegVal.hasMatch(this, RegexPatterns.doc);

  /// Excel regex
  bool isExcel() => RegVal.hasMatch(this, RegexPatterns.excel);

  /// PPT regex
  bool isPPT() => RegVal.hasMatch(this, RegexPatterns.ppt);

  /// Document regex
  bool isApk() => RegVal.hasMatch(this, RegexPatterns.apk);

  /// PDF regex
  bool isPdf() => RegVal.hasMatch(this, RegexPatterns.pdf);

  /// HTML regex
  bool isHtml() => RegVal.hasMatch(this, RegexPatterns.html);

  /// DateTime regex (UTC)
  /// Unformatted date time (UTC and Iso8601)
  /// Example: 2020-04-27 08:14:39.977, 2020-04-27T08:14:39.977, 2020-04-27 01:14:39.977Z
  bool isDateTimeUTC() => RegVal.hasMatch(this, RegexPatterns.basicDateTime);

  /// Binary regex
  /// Consist only 0 & 1
  bool isBinary() => RegVal.hasMatch(this, RegexPatterns.binary);

  /// MD5 regex
  bool isMD5() => RegVal.hasMatch(this, RegexPatterns.md5);

  /// SHA1 regex
  bool isSHA1() => RegVal.hasMatch(this, RegexPatterns.sha1);

  /// SHA256 regex
  bool isSHA256() => RegVal.hasMatch(this, RegexPatterns.sha256);

  /// SSN (Social Security Number) regex
  bool isSSN() => RegVal.hasMatch(this, RegexPatterns.ssn);

  /// IPv4 regex
  bool isIPV4() => RegVal.hasMatch(this, RegexPatterns.ipv4);

  /// IPv6 regex
  bool isIPV6() => RegVal.hasMatch(this, RegexPatterns.ipv6);

  /// ISBN 10 & 13 regex
  bool isISBN() => RegVal.hasMatch(this, RegexPatterns.isbn);

  /// Github repository regex
  bool isGithub() => RegVal.hasMatch(this, RegexPatterns.github);

  /// Passport No. regex
  bool isPassport() => RegVal.hasMatch(this, RegexPatterns.passport);

  /// Currency regex
  bool isCurrency() => RegVal.hasMatch(this, RegexPatterns.currency);

  /// Numeric Only regex (No Whitespace & Symbols)
  bool isNumeric() => RegVal.hasMatch(this, RegexPatterns.numericOnly);

  /// Alphabet Only regex (No Whitespace & Symbols)
  bool isAlphabet() => RegVal.hasMatch(this, RegexPatterns.alphabetOnly);

  /// Password (Easy) Regex
  /// Allowing all character except 'whitespace'
  /// Minimum character: 8
  bool isPasswordEasy() => RegVal.hasMatch(this, RegexPatterns.passwordEasy);

  /// Password (Easy) Regex
  /// Allowing all character
  /// Minimum character: 8
  bool isPasswordEasyWithspace() =>
      RegVal.hasMatch(this, RegexPatterns.passwordEasyAllowedWhitespace);

  /// Password (Normal) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal1() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal1);

  /// Password (Normal) Regex
  /// Allowing all character
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal1Withspace() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal1AllowedWhitespace);

  /// Password (Normal) Regex
  /// Allowing LETTER and NUMBER only
  /// Must contains at least: 1 letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal2() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal2);

  /// Password (Normal) Regex
  /// Allowing LETTER and NUMBER only
  /// Must contains: 1 letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal2Withspace() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal2AllowedWhitespace);

  /// Password (Normal) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal3() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal3);

  /// Password (Normal) Regex
  /// Allowing all character
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter & 1 number
  /// Minimum character: 8
  bool isPasswordNormal3Withspace() =>
      RegVal.hasMatch(this, RegexPatterns.passwordNormal3AllowedWhitespace);

  /// Password (Hard) Regex
  /// Allowing all character except 'whitespace'
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)
  /// Minimum character: 8
  bool isPasswordHard() => RegVal.hasMatch(this, RegexPatterns.passwordHard);

  /// Password (Hard) Regex
  /// Allowing all character
  /// Must contains at least: 1 uppercase letter, 1 lowecase letter, 1 number, & 1 special character (symbol)
  /// Minimum character: 8
  bool isPasswordHardWithspace() =>
      RegVal.hasMatch(this, RegexPatterns.passwordHardAllowedWhitespace);
}
