import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:undangan_app/webservice/apiUndangan.dart';
import 'model/Undangan.dart';
import 'webservice/apiUndangan.dart';


class QRViewExample extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRViewExampleState();
}

class _QRViewExampleState extends State<QRViewExample> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  String email = '';
  Undangan? undangan;
  ApiUndangan? apiUndangan;

  @override
  void initState() {
    super.initState();
    apiUndangan = ApiUndangan();
  }

  // In order to get hot reload to work we need to pause the camera if the platform
  // is android, or resume the camera if the platform is iOS.
  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    if (result != null) {
      email = result!.code;
    }
    return Scaffold(
      body: Column(
        children: <Widget>[
          if (result == null)
            Expanded(flex: 4, child: _buildQrView(context))
          else
            FutureBuilder<Undangan?>(
              future: apiUndangan!.cekUndangan(email),
              builder:
                  (BuildContext context, AsyncSnapshot<Undangan?> snapshot) {
                if (snapshot.hasData) {
                  print(snapshot.data!.nama);
                  apiUndangan!.updateKehadiran(snapshot.data!);
                  return _profil(snapshot.data!);
                } else if (snapshot.hasError) {
                  print("ERROR SNAPSHOT ${snapshot.error}");
                  return Container(
                      alignment: Alignment.center,
                      margin: EdgeInsets.only(top: 100),
                      child: Text(
                        "Data Tidak Ditemukan",
                        style: TextStyle(fontSize: 20, color: Colors.pink),
                      ));
                } else {
                  return CircularProgressIndicator();
                }
              },
            ),
          Expanded(
            flex: 1,
            child: FittedBox(
              fit: BoxFit.contain,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  if (result != null)
                    Text('Barcode Type: ${describeEnum(result!.format)}  Email: ${result!.code}')
                  else
                    Text('Scan a code'),
                  Container(
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            result = null;
                          });
                        },
                        child: Text("Coba Lagi",),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.pink,
                        ),
                      )),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.toggleFlash();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.pink,
                            ),
                            child: FutureBuilder(
                              future: controller?.getFlashStatus(),
                              builder: (context, snapshot) {
                                return Text('Flash: ${snapshot.data}');
                              },

                            )),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                            onPressed: () async {
                              await controller?.flipCamera();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.pink,
                            ),
                            child: FutureBuilder(
                              future: controller?.getCameraInfo(),
                              builder: (context, snapshot) {
                                if (snapshot.data != null) {
                                  return Text(
                                      'Camera facing ${describeEnum(snapshot.data!)}');
                                } else {
                                  return Text('loading');
                                }
                              },
                            )),
                      )
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.pauseCamera();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.pink,
                          ),
                          child: Text('pause', style: TextStyle(fontSize: 20)),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.all(8),
                        child: ElevatedButton(
                          onPressed: () async {
                            await controller?.resumeCamera();
                          },
                          style: ElevatedButton.styleFrom(
                            primary: Colors.pink,
                          ),
                          child: Text('resume', style: TextStyle(fontSize: 20)),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
        MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.red,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      setState(() {
        result = scanData;
      });
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  Widget _profil(Undangan undangan) {
    return Container(
      padding: EdgeInsets.fromLTRB(6, 6, 6, 6),
      margin: EdgeInsets.fromLTRB(10, 50, 10, 50),
      color: Colors.purple.withOpacity(0.5),
      child: Column(
        children: [
          Text(
            "${undangan.nama}",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
          ),
          SizedBox(height: 25),
          Container(
            child: Image.network("http://192.168.0.27/apiundangan/assets/${undangan.foto}"),
          ),
          SizedBox(height: 25),
          Text("Terima Kasih Anda telah hadir pada acara ini !",style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.white,
          ),)
        ],
      ),
    );
  }
}
