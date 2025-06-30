import 'package:flutter/services.dart';

class WordLimitFormatter extends TextInputFormatter {
  final int maxWords;

  WordLimitFormatter(this.maxWords);

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final wordCount = newValue.text.trim().split(RegExp(r'\s+')).length;
    return wordCount <= maxWords ? newValue : oldValue;
  }
}