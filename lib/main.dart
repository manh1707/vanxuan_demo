import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vanxuan/firebase_options.dart';
import 'package:vanxuan/model/document.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class LayoutTable {
  final int rowNumber;
  final int ColumnNumber;

  LayoutTable(this.rowNumber, this.ColumnNumber);
}

class _MyHomePageState extends State<MyHomePage> {
  final dio = Dio();
  List<Table> tableList = [];
  List<LayoutTable> tableLayOut = [];
  Document documentLayout = Document(code: 'Lephat', table: [], type: 'Stock');
  @override
  void initState() {
    super.initState();
  }

  void pushDatatoFirebase() async {
    showDialog(
      context: context,
      builder: (ctx) {
        final textController = TextEditingController();
        return Dialog(
          child: Column(
            children: [
              TextField(
                controller: textController,
                decoration: InputDecoration(hintText: 'Tên của sớ'),
              ),
              SizedBox(height: 12),
              ElevatedButton(
                onPressed: () async {
                  final url =
                      "https://vanxuan-5198f-default-rtdb.asia-southeast1.firebasedatabase.app/data/document.json";
                  try {
                    final result = await http.post(
                      Uri.parse(url),
                      body: json.encode(
                        documentLayout
                            .copyWith(code: textController.text)
                            .toJson(),
                      ),
                    );
                    print(result.body);
                  } catch (e) {
                    print(e);
                  }
                  Navigator.of(ctx).pop();
                },
                child: Text("Xác nhận lưu"),
              )
            ],
          ),
        );
      },
    );
  }

  Future<List<Document>> getDataFirebase() async {
    List<Document> document = [];
    try {
      final url =
          "https://vanxuan-5198f-default-rtdb.asia-southeast1.firebasedatabase.app/data/document.json";

      final result = await http.get(
        Uri.parse(url),
      );
      final converReult = json.decode(result.body) as Map<String, dynamic>;
      document = converReult.values.map((e) => Document.fromJson(e)).toList();
    } catch (e) {
      document = [];
    }
    return document;
  }

  void getDocumentFromFirebase() async {
    // ignore: use_build_context_synchronously
    final result = await showDialog(
        context: context,
        builder: (ctx) {
          return GetDocumentDialog();
        });
    if (result != null) {
      documentLayout = result as Document;
      setState(() {});
    }
  }

  void readJsonFile() async {
    String data = await rootBundle.loadString('assets/data.json');
    final jsonResult = json.decode(data);
    final document = Document.fromJson(jsonResult);
    for (var element in document.table) {
      final tableIndex = document.table.indexOf(element);

      final newCell =
          documentLayout.table[tableIndex].copyWith(cell: element.cell);
      documentLayout.table[tableIndex] = newCell;
    }
    setState(() {});
  }

  void _saveData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('json', json.encode(documentLayout.toJson()));
    print('Success');
  }

  void _getFromLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? result = prefs.getString('json');
    if (result != null) {
      final data = json.decode(result);
      final document = Document.fromJson(data);
      documentLayout = document;
      // for (var element in document.table) {
      //   final tableIndex = document.table.indexOf(element);

      //   final newCell =
      //       documentLayout.table[tableIndex].copyWith(cell: element.cell);
      //   documentLayout.table[tableIndex] = newCell;
      // }
      setState(() {});
    }
  }

  void _addTable() async {
    final result = await showDialog(
      context: context,
      builder: (ctx) {
        final row = TextEditingController();
        final colum = TextEditingController();
        return Dialog(
          child: Column(
            children: [
              TextField(
                controller: row,
                decoration: InputDecoration(hintText: "Số hàng"),
              ),
              TextField(
                controller: colum,
                decoration: InputDecoration(hintText: "Số cột"),
              ),
              const SizedBox(),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop(
                    LayoutTable(
                      int.parse(row.text),
                      int.parse(colum.text),
                    ),
                  );
                },
                child: const Text("Xác nhận"),
              )
            ],
          ),
        );
      },
    );
    if (result != null) {
      final tableLayOut1 = result as LayoutTable;
      tableLayOut.add(tableLayOut1);
      final documentTable = documentLayout.table;

      documentTable.add(
        DocumentTable(
          cell: [
            // ...List.generate(tableLayOut1.rowNumber, (index) => List.generate(tableLayOut1.ColumnNumber,)).toList()
          ],
          type: 'Table',
          attributes: Attributes(
            colNum: tableLayOut1.ColumnNumber,
            rowNum: tableLayOut1.rowNumber,
            colSize: 20,
            rowSize: 20,
          ),
        ),
      );
      documentLayout = documentLayout.copyWith(table: documentTable);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...documentLayout.table
                    .map(
                      (e) => Flexible(
                        flex: e.attributes.colNum,
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Table(
                            border: TableBorder.all(),
                            children: [
                              ...List.generate(
                                e.attributes.rowNum,
                                (rowindex) => TableRow(children: [
                                  ...List.generate(e.attributes.colNum,
                                      (colindex) {
                                    Cell? cell;
                                    try {
                                      cell = e.cell?.singleWhere(
                                        (e) =>
                                            e.row == rowindex &&
                                            e.col == colindex,
                                      );
                                    } catch (e) {
                                      cell = null;
                                    }
                                    final focus = FocusNode();
                                    final textcontroller =
                                        TextEditingController(
                                            text: cell?.latin);
                                    return Container(
                                      alignment: Alignment.center,
                                      height: 40,
                                      child: TextField(
                                        controller: textcontroller,
                                        focusNode: focus,
                                        textAlign: TextAlign.center,
                                        onEditingComplete: () {
                                          focus.unfocus();
                                          print(textcontroller.text);
                                          if (cell != null) {
                                            final indexOfCell =
                                                e.cell!.indexWhere(
                                              (e) =>
                                                  e.row == rowindex &&
                                                  e.col == colindex,
                                            );
                                            e.cell![indexOfCell] =
                                                e.cell![indexOfCell].copyWith(
                                                    latin: textcontroller.text);
                                          } else {
                                            e.cell!.add(
                                              Cell(
                                                  col: colindex,
                                                  row: rowindex,
                                                  latin: textcontroller.text,
                                                  kanji: textcontroller.text),
                                            );
                                          }
                                          print(documentLayout.toJson());
                                        },
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    );
                                  }).toList()
                                ]),
                              )
                            ],
                          ),
                        ),
                      ),
                    )
                    .toList()
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ElevatedButton(
              //     onPressed: _getFromLocalData, child: Text('Đọc file json')),
              // SizedBox(width: 12),
              ElevatedButton(
                  onPressed: pushDatatoFirebase,
                  child: Text('Push to firebase')),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: getDocumentFromFirebase,
                child: Text('Lấy dữ liệu từ firebase'),
              ),
              SizedBox(width: 12),
              ElevatedButton(
                onPressed: () {
                  documentLayout =
                      Document(code: 'Lephat', table: [], type: 'Stock');
                  setState(() {});
                },
                child: Text('Xóa bảng hiện tại'),
              ),
            ],
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTable,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ),
    );
  }
}

class GetDocumentDialog extends StatefulWidget {
  const GetDocumentDialog({super.key});

  @override
  State<GetDocumentDialog> createState() => _GetDocumentDialogState();
}

class _GetDocumentDialogState extends State<GetDocumentDialog> {
  List<Document> documnet = [];
  bool isLoadingData = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getDataFirebase();
  }

  void getDataFirebase() async {
    try {
      isLoadingData = true;
      setState(() {});
      final url =
          "https://vanxuan-5198f-default-rtdb.asia-southeast1.firebasedatabase.app/data/document.json";

      final result = await http.get(
        Uri.parse(url),
      );
      final converReult = json.decode(result.body) as Map<dynamic, dynamic>;

      print(converReult.values);

      documnet = converReult.values
          .map((e) => Document.fromJson(e as Map<String, dynamic>))
          .toList();
      isLoadingData = false;
      setState(() {});
    } catch (e) {
      print(e);
      isLoadingData = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ...documnet
              .map(
                (e) => GestureDetector(
                  onTap: () {
                    Navigator.of(context).pop(e);
                  },
                  child: Container(
                    margin: const EdgeInsets.only(top: 12),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all()),
                    child: Text(e.code),
                  ),
                ),
              )
              .toList(),
          Container(
            margin: const EdgeInsets.all(40),
            child: isLoadingData
                ? const CircularProgressIndicator(
                    color: Colors.white,
                  )
                : const SizedBox(),
          )
        ],
      ),
    );
  }
}
