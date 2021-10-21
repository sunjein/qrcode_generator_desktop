import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:qrcode/main_model.dart';
import 'package:screenshot/screenshot.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      darkTheme: ThemeData.dark(),
      debugShowCheckedModeBanner: false,
      home: ChangeNotifierProvider(
        create: (context) => MainModel(),
        child: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController urlController = TextEditingController();
  final controller = ScreenshotController();
  Color pickerColor = Colors.red;

  void changeColor(Color color) {
    setState(() {
      pickerColor = color;
    });
  }

  void pickFgColor() async {
    Color color = await showColorPickerDialog(context);
  }

  Future<Color> showColorPickerDialog(BuildContext context) async {
    Color color = await showDialog(
        builder: (context) => AlertDialog(
              title: const Text('色を選択してください'),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: pickerColor,
                  onColorChanged: changeColor,
                  showLabel: true,
                  pickerAreaHeightPercent: 0.8,
                  //enableAlpha: false,
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('決定'),
                  onPressed: () {
                    return Navigator.of(context).pop(pickerColor);
                  },
                ),
              ],
            ),
        context: context);
    return color;
  }

  @override
  Widget build(BuildContext context) {
    final text = context.select((MainModel model) => model.text);
    final dropdownValue =
        context.select((MainModel model) => model.dropdownValue);
    final fgColor = context.select((MainModel model) => model.fgColor);
    final bgColor = context.select((MainModel model) => model.bgColor);
    final errorcorrectlevel =
        context.select((MainModel model) => model.errorcorrectlevel);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Generator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            maxLines: 1,
                            decoration: const InputDecoration(
                              hintText: '例）https://example.com',
                              labelText: 'URL',
                            ),
                            controller: urlController,
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            context
                                .read<MainModel>()
                                .updateText(urlController.text);
                          },
                          child: const Text('生成'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text(
                          'QRコードの誤り訂正能力レベル:',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        DropdownButton<String>(
                          value: dropdownValue,
                          onChanged: (String? newValue) {
                            context
                                .read<MainModel>()
                                .updateErrorCorrectLevel(newValue!);
                          },
                          items: <String>['7%', '15%', '25%', '30%']
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            child: const Text('QRコードの色を選択'),
                            onPressed: () async {
                              Color color =
                                  await showColorPickerDialog(context);
                              context.read<MainModel>().updateFgColor(color);
                            }),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            child: const Text('背景色を選択'),
                            onPressed: () async {
                              Color color =
                                  await showColorPickerDialog(context);
                              context.read<MainModel>().updateBgColor(color);
                            })
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Flexible(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Column(
                    children: [
                      Screenshot(
                        controller: controller,
                        child: QrImage(
                          data: text,
                          version: QrVersions.auto,
                          foregroundColor: fgColor,
                          backgroundColor: bgColor,
                          errorCorrectionLevel: errorcorrectlevel,
                          //size: 200.0,
                        ),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () async {
                              String? outputFile =
                                  await FilePicker.platform.saveFile(
                                dialogTitle: 'ファイルの保存先を選択',
                                fileName: 'QRコード.png',
                              );

                              if (outputFile != null) {
                                // !応急処置！path_providerとかで正しくファイル名等を取得する
                                print(outputFile);
                                var filepathList = outputFile.split('/');
                                print(filepathList);
                                String filename =
                                    filepathList[filepathList.length - 1];
                                print(filename);
                                filepathList[filepathList.length - 1] = '';
                                print(filepathList);
                                var filepath = filepathList.join('/');
                                print(filepath);
                                await controller.captureAndSave(filepath,
                                    fileName: filename);
                              }
                              //var _image = MemoryImage(image!);
                              //var picturesPath = await getPicturesPath();
                              //var thetaImage = await File(join(
                              //        picturesPath, 'theta_images', 'test'))
                              //    .create(recursive: true);
                              //await thetaImage
                              //    .writeAsBytes();
                            },
                            child: const Text('画像を保存する'),
                          ),
                        ],
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
