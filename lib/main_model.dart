import 'package:file_picker/file_picker.dart';
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

  void updateFgColor(Color newcolor) async {
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

  Future<void> saveToFile(controller) async {
    String? outputFile = await FilePicker.platform.saveFile(
      dialogTitle: 'ファイルの保存先を選択',
      fileName: 'QRコード.png',
    );

    if (outputFile != null) {
      // !応急処置！path_providerとかで正しくファイル名等を取得する
      var filepathList = outputFile.split('/');
      String filename = filepathList[filepathList.length - 1];
      filepathList[filepathList.length - 1] = '';
      var filepath = filepathList.join('/');
      await controller.captureAndSave(filepath, fileName: filename);
    }
    //var _image = MemoryImage(image!);
    //var picturesPath = await getPicturesPath();
    //var thetaImage = await File(join(
    //        picturesPath, 'theta_images', 'test'))
    //    .create(recursive: true);
    //await thetaImage
    //    .writeAsBytes();
  }
}
