import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class MainModel extends ChangeNotifier {
  String text = '';
  Color fgColor = Colors.black;
  Color bgColor = Colors.white;
  String dropdownValue = '15%';
  int errorcorrectlevel = QrErrorCorrectLevel.M;

  void updateText(String inputtext) {
    text = inputtext;
    notifyListeners();
  }

  void updateFgColor(Color newcolor) {
    fgColor = newcolor;
    notifyListeners();
  }

  void updateBgColor(Color newcolor) {
    bgColor = newcolor;
    notifyListeners();
  }

  void updateErrorCorrectLevel(String newValue) {
    dropdownValue = newValue;
    if (newValue == '7%') {
      errorcorrectlevel = QrErrorCorrectLevel.L;
    }
    if (newValue == '15%') {
      errorcorrectlevel = QrErrorCorrectLevel.M;
    }
    if (newValue == '25%') {
      errorcorrectlevel = QrErrorCorrectLevel.Q;
    }
    if (newValue == '30%') {
      errorcorrectlevel = QrErrorCorrectLevel.H;
    }
    notifyListeners();
  }
}
