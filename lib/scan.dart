import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class ScanPage extends StatefulWidget {
  @override
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController controller;

  String name = "";
  String designation = "";
  String image = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 250,
            width: 250,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
            ),
          ),
          SizedBox(height: 20,),
          name.isNotEmpty
              ? Container(
                  height: 200,
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
                                  child: Text(
                                    name,
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
                                  child: Text(
                                    designation,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                  ),
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
                )
              : Container(),
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      Map<String, dynamic> object = json.decode(scanData);
      print(object);
      setState(() {
        if (object.containsKey('name')) name = object['name'].toString();
        if (object.containsKey('designation')) designation = object['designation'].toString();
        if (object.containsKey('image')) image = object['image'].toString();
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
