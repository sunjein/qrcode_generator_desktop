import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

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
      home: const MyHomePage(title: 'QRコードジェネレータ'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String text = '';
  final urlController = TextEditingController();
  Color fgColor = Colors.black;
  Color bgColor = Colors.white;
  Color pickerColor = Colors.red;
  String dropdownValue = '15%';
  int errorcorrectlevel = QrErrorCorrectLevel.M;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  Future<Color> showColorPickerDialog() async {
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
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
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
                            setState(() {
                              text = urlController.text;
                            });
                          },
                          child: const Text('生成'),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Row(
                      children: [
                        ElevatedButton(
                            child: const Text('QRコードの色を選択'),
                            onPressed: () async {
                              Color color = await showColorPickerDialog();
                              setState(() {
                                fgColor = color;
                              });
                            }),
                        const SizedBox(
                          width: 20,
                        ),
                        ElevatedButton(
                            child: const Text('背景色を選択'),
                            onPressed: () async {
                              Color color = await showColorPickerDialog();
                              setState(() {
                                bgColor = color;
                              });
                            })
                      ],
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
                            setState(() {
                              dropdownValue = newValue!;
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
                            });
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
                    )
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
                      QrImage(
                        data: text,
                        version: QrVersions.auto,
                        foregroundColor: fgColor,
                        backgroundColor: bgColor,
                        errorCorrectionLevel: errorcorrectlevel,
                        //size: 200.0,
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton(
                            onPressed: () {},
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
