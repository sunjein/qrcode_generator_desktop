import 'dart:io';

import 'package:fluent_ui/fluent_ui.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qrcode/main_model.dart';
import 'package:screenshot/screenshot.dart';
import 'package:window_size/window_size.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    //setWindowTitle('Size Limit Window Test');
    setWindowFrame(const Rect.fromLTWH(100, 100, 800, 500));
    setWindowMinSize(const Size(800, 500));
    setWindowMaxSize(Size.infinite);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FluentApp(
      title: 'Flutter Demo',
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
  List<String> qrtypeList = ['URL', 'WiFi登録', 'メール自動入力', 'SMS', '電話番号'];

  @override
  Widget build(BuildContext context) {
    final text = context.select((MainModel model) => model.text);
    final fgColor = context.select((MainModel model) => model.fgColor);
    final bgColor = context.select((MainModel model) => model.bgColor);
    final eclDropdownValue =
        context.select((MainModel model) => model.eclDropdownValue);
    final qrtypeDropdownValue =
        context.select((MainModel model) => model.qrtypeDropdownValue);
    final errorcorrectlevel =
        context.select((MainModel model) => model.errorcorrectlevel);

    showSimpleDialog(String title, String content) async {
      showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              Button(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.pop(context);
                  })
            ],
          );
        },
      );
    }

    Future showColorPicker() async {
      Widget _colorButton(Color color) {
        return Button(
          child: Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: color),
          ),
          onPressed: () {
            Navigator.pop(context, color);
          },
        );
      }

      var colors = [
        _colorButton(Colors.red),
        _colorButton(Colors.orange),
        _colorButton(Colors.yellow),
        _colorButton(Colors.purple),
        _colorButton(Colors.blue),
        _colorButton(Colors.green),
        _colorButton(Colors.white),
        _colorButton(Colors.grey),
        _colorButton(Colors.black),
      ];
      final color = await showDialog(
        context: context,
        builder: (context) {
          return ContentDialog(
            title: const Text('色を選択'),
            content: Column(
              children: [
                GridView.count(
                  shrinkWrap: true,
                  padding: const EdgeInsets.all(4),
                  crossAxisCount: 6,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  children: colors,
                )
              ],
            ),
            actions: [
              Button(
                  child: const Text('キャンセル'),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
            ],
          );
        },
      );
      return color;
    }

    return ScaffoldPage(
      content: Padding(
        padding: const EdgeInsets.all(1.0),
        child: Row(
          children: [
            Flexible(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(18.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'QR Code Generator',
                      style: TextStyle(fontSize: 30),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        const Text(
                          'QRコードの種類',
                          style: TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        SizedBox(
                          width: 200,
                          child: Combobox(
                            value: qrtypeDropdownValue,
                            items: qrtypeList
                                .map((e) => ComboboxItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              context.read<MainModel>().updateQrtype(newValue!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextBox(
                            maxLines: 3,
                            controller: urlController,
                          ),
                        ),
                        Button(
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
                        SizedBox(
                          width: 80,
                          child: Combobox(
                            value: eclDropdownValue,
                            items: ['7%', '15%', '20%', '30%']
                                .map((e) => ComboboxItem<String>(
                                      value: e,
                                      child: Text(e),
                                    ))
                                .toList(),
                            onChanged: (String? newValue) {
                              context
                                  .read<MainModel>()
                                  .updateErrorCorrectLevel(newValue!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: fgColor,
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                        Button(
                            child: const Text('QRコードの色を選択'),
                            onPressed: () async {
                              final color = await showColorPicker();
                              if (bgColor == color) {
                                showSimpleDialog('警告',
                                    'QRコードの色が背景色と同じまたは非常に近いため、正常に認識できない可能性があります。');
                                // color warning
                              }
                              context.read<MainModel>().updateFgColor(color);
                            }),
                        const SizedBox(
                          width: 20,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(4.0),
                          child: Container(
                            height: 20,
                            width: 20,
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(color: Colors.black),
                            ),
                          ),
                        ),
                        Button(
                            child: const Text('背景色を選択'),
                            onPressed: () async {
                              final color = await showColorPicker();
                              if (fgColor == color) {
                                showSimpleDialog('警告',
                                    'QRコードの色が背景色と同じまたは非常に近いため、正常に認識できない可能性があります。');
                              }
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
                          IconButton(
                            icon: const Icon(FluentIcons.save),
                            onPressed: () async {
                              final saved = await context
                                  .read<MainModel>()
                                  .saveToFile(controller);
                              if (saved) {
                                showSimpleDialog('保存', 'QRコード画像の保存が完了しました。');
                              } else {
                                showSimpleDialog(
                                    '保存されませんでした', 'QRコード画像の保存はキャンセルされました。');
                              }
                            },
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
