import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:qr_flutter/qr_flutter.dart';

class GeneratePage extends StatefulWidget {
  @override
  _GeneratePageState createState() => _GeneratePageState();
}

class _GeneratePageState extends State<GeneratePage> {
  GlobalKey qrImageKey = GlobalKey();

  final _nameController = new TextEditingController();
  final _designationController = new TextEditingController();

  String qrData = "";
  String image =
      "https://lh3.googleusercontent.com/a-/AAuE7mA_eGeE2dMEvLvwXRw4ZcsFF46tl6e3JZ-45UKrE7I";

  @override
  void initState() {
    _nameController.text = "Shoeb Surve";
    _designationController.text = "Senior Software Developer";

    qrData = generateQR(_nameController.text, _designationController.text);

    PermissionHandler().requestPermissions([PermissionGroup.storage]);

    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _designationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.grey[50],
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            RepaintBoundary(
              key: qrImageKey,
              child: Container(
                height: 390,
                child: Stack(
                  children: <Widget>[
                    Center(
                      child: Card(
                        margin: EdgeInsets.only(top: 30),
                        child: Container(
                          margin: EdgeInsets.only(top: 20),
                          padding: EdgeInsets.symmetric(
                              vertical: 30, horizontal: 20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              Container(
                                width: 300,
                                height: 40,
                                child: TextField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter your name',
                                  ),
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              ),
                              Container(
                                width: 300,
                                height: 30,
                                child: TextField(
                                  controller: _designationController,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Enter your designation',
                                  ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                ),
                              ),
                              QrImage(
                                data: qrData,
                                version: QrVersions.auto,
                                size: 200.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: ClipRRect(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        child: CachedNetworkImage(
                          imageUrl: image,
                          placeholder: (context, url) =>
                              CircularProgressIndicator(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.error),
                          height: 70,
                          width: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            GestureDetector(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(Icons.refresh),
                  SizedBox(width: 10),
                  Text(
                    'Generate my code',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              onTap: () {
                verifyRecords();
              },
            ),
            SizedBox(
              height: 20,
            ),
            GestureDetector(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(Icons.share),
                  SizedBox(width: 10),
                  Text(
                    'Share my code',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
              onTap: () {
                shareQRCode();
              },
            ),
          ],
        ),
      ),
    );
  }

  void verifyRecords() {
    var name = _nameController.text;
    var designation = _designationController.text;

    if (name.isEmpty) {
      return;
    }

    if (designation.isEmpty) {
      return;
    }

    setState(() {
      qrData =  generateQR(name, designation);
    });
  }

  String generateQR(String name, String designation) {
    return json
        .encode({'name': name, 'designation': designation, 'image': image});
  }

  void shareQRCode() async {
    try {
      RenderRepaintBoundary boundary =
          qrImageKey.currentContext.findRenderObject();
      var image = await boundary.toImage(pixelRatio: 3.0);
      ByteData byteData = await image.toByteData(format: ImageByteFormat.png);
      Uint8List pngBytes = byteData.buffer.asUint8List();
      final tempDir = await getExternalStorageDirectory();
      final file = await new File('${tempDir.path}/image.png').create();
      await file.writeAsBytes(pngBytes);

      await FlutterShare.shareFile(
        title: 'Connection',
        text: 'Connect me on event',
        filePath: file.path.toString(),
      );
    } catch (e) {
      print(e.toString());
    }
  }
}
