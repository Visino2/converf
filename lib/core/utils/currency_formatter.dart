import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.selection.baseOffset == 0 || newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Remove any non-numeric characters (except for the first period if decimals are allowed, 
    // but here we usually deal with whole numbers for budget)
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    
    if (cleanedText.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final double value = double.parse(cleanedText);
    final formatter = NumberFormat('#,###');
    final String newText = formatter.format(value);

    return newValue.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}
