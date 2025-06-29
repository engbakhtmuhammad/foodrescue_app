
import 'package:flutter/material.dart';

import 'Colors.dart';


class ColorNotifier with ChangeNotifier {
  bool _isDark = false;
  set setIsDark(value) {
    _isDark = value;
    notifyListeners();
  }
  get background => _isDark ? BlackColor : WhiteColor;
  get textColor => _isDark ? WhiteColor : BlackColor;
  get containerColor => _isDark ? boxcolor : GreyColor;

}