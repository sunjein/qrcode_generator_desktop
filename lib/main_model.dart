import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:path/path.dart';

class MainModel extends ChangeNotifier {
  String text = '';
  Color fgColor = Colors.black;
  Color bgColor = Colors.white;
  String eclDropdownValue = '15%';
  int errorcorrectlevel = QrErrorCorrectLevel.M;
  String qrtypeDropdownValue = 'URL';

  void updateText(String inputtext) {
    text = inputtext;
    notifyListeners();
  }

  void updateFgColor(Color newcolor) async {
    fgColor = newcolor;
    notifyListeners();
  }

  void updateBgColor(Color newcolor) {
    bgColor = newcolor;
    notifyListeners();
  }

  void updateErrorCorrectLevel(String newValue) {
    eclDropdownValue = newValue;
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

  void updateQrtype(String newValue) {
    qrtypeDropdownValue = newValue;
    notifyListeners();
  }

  Future<bool> saveToFile(controller) async {
    String? outputFilePath = await FilePicker.platform.saveFile(
      dialogTitle: 'ファイルの保存先を選択',
      fileName: 'QRコード.png',
    );
    if (outputFilePath != null) {
      await controller.captureAndSave(dirname(outputFilePath),
          fileName: basename(outputFilePath));
      return true;
    }
    return false;
  }
}
