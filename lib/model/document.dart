// To parse this JSON data, do
//
//     final document = documentFromJson(jsonString);

import 'dart:convert';

class Document {
  Document({
    required this.type,
    required this.code,
    required this.table,
  });

  final String type;
  final String code;
  final List<DocumentTable> table;

  Document copyWith({
    String? type,
    String? code,
    List<DocumentTable>? table,
  }) =>
      Document(
        type: type ?? this.type,
        code: code ?? this.code,
        table: table ?? this.table,
      );

  factory Document.fromRawJson(String str) =>
      Document.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Document.fromJson(Map<String, dynamic> json) => Document(
        type: json["type"],
        code: json["code"],
        table: List<DocumentTable>.from(
            json["table"].map((x) => DocumentTable.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "code": code,
        "table": List<dynamic>.from(table.map((x) => x.toJson())),
      };
}

class DocumentTable {
  DocumentTable({
    required this.type,
    required this.attributes,
    this.cell,
  });

  final String type;
  final Attributes attributes;
  final List<Cell>? cell;

  DocumentTable copyWith({
    String? type,
    Attributes? attributes,
    List<Cell>? cell,
  }) =>
      DocumentTable(
        type: type ?? this.type,
        attributes: attributes ?? this.attributes,
        cell: cell ?? this.cell,
      );

  factory DocumentTable.fromRawJson(String str) =>
      DocumentTable.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory DocumentTable.fromJson(Map<String, dynamic> json) => DocumentTable(
        type: json["type"],
        attributes: Attributes.fromJson(json["attributes"]),
        cell: json["cell"] != null
            ? List<Cell>.from(json["cell"].map((x) => Cell.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "attributes": attributes.toJson(),
        "cell": cell != null
            ? List<dynamic>.from(cell!.map((x) => x.toJson()))
            : [],
      };
}

class Attributes {
  Attributes({
    required this.colNum,
    required this.rowNum,
    required this.colSize,
    required this.rowSize,
  });

  final int colNum;
  final int rowNum;
  final int colSize;
  final int rowSize;

  Attributes copyWith({
    int? colNum,
    int? rowNum,
    int? colSize,
    int? rowSize,
  }) =>
      Attributes(
        colNum: colNum ?? this.colNum,
        rowNum: rowNum ?? this.rowNum,
        colSize: colSize ?? this.colSize,
        rowSize: rowSize ?? this.rowSize,
      );

  factory Attributes.fromRawJson(String str) =>
      Attributes.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Attributes.fromJson(Map<String, dynamic> json) => Attributes(
        colNum: json["colNum"],
        rowNum: json["rowNum"],
        colSize: json["colSize"],
        rowSize: json["rowSize"],
      );

  Map<String, dynamic> toJson() => {
        "colNum": colNum,
        "rowNum": rowNum,
        "colSize": colSize,
        "rowSize": rowSize,
      };
}

class Cell {
  Cell({
    required this.col,
    required this.row,
    required this.latin,
    required this.kanji,
  });

  final int col;
  final int row;
  final String latin;
  final String kanji;

  Cell copyWith({
    int? col,
    int? row,
    String? latin,
    String? kanji,
  }) =>
      Cell(
        col: col ?? this.col,
        row: row ?? this.row,
        latin: latin ?? this.latin,
        kanji: kanji ?? this.kanji,
      );

  factory Cell.fromRawJson(String str) => Cell.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory Cell.fromJson(Map<String, dynamic> json) => Cell(
        col: json["col"],
        row: json["row"],
        latin: json["latin"],
        kanji: json["kanji"],
      );

  Map<String, dynamic> toJson() => {
        "col": col,
        "row": row,
        "latin": latin,
        "kanji": kanji,
      };
}
