import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite/tflite.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool? _loading = true;
  File? _image;
  final imagePicker = ImagePicker();
  List? _predictions = [];

  @override
  void initState() {
    super.initState();
    loadModel().then((value) {
      setState(() {});
    });
  }

  loadModel() async {
    await Tflite.loadModel(
        model: 'assets/mask_model.tflite', labels: 'assets/labels.txt');
  }

  detectMask(File? image) async {
    // print('detect mask'+ image!.path);
    var prediction = await Tflite.runModelOnImage(
      path: image!.path,
      numResults: 2,
      threshold: 0.6,
      imageMean: 127.5,
      imageStd: 127.5,
    );
    // print(prediction);

    setState(() {
      _predictions = prediction!;
      _loading = false;
      // print(_predictions);
      // print((_predictions![0]['confidence']*100).toStringAsFixed(2));
    });
  }

  void dispose() {
    super.dispose();
  }

  loadImageFromGallery() async {
    var image = await imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) {
      return null;
    } else {
      _image = File(image.path);

      detectMask(_image);
      // print(_image);
    }
  }



  loadImageFromCamera() async {
    var image = await imagePicker.pickImage(source: ImageSource.camera);
    if (image == null) {
      return null;
    } else {
      // setState(() {});
      _image = File(image.path);
      detectMask(_image);
      // print(_image);
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              width: 3.0,
            ),
            CircleAvatar(
              backgroundColor: Colors.white60,
              radius: 17,
              child: Image.asset(
                'assets/mask.png',
                width: 20,
                height: 20,
              ),
            ),
            SizedBox(
              width: 10.0,
            ),
            Text(
              'Mask Detector',
              style: GoogleFonts.roboto(),
            ),
          ],
        ),
        // centerTitle: true,
      ),
      body: Container(
        height: height,
        width: width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  child: Column(
                    children: [
                      Container(
                        height: 140,
                        width: width / 2,
                        // color: Colors.deepPurpleAccent,
                        padding: EdgeInsets.all(10.0),
                        child: Image.asset('assets/scan.png'),
                      ),
                      Text('Scan to Check!',
                          style: GoogleFonts.roboto(
                              fontSize: 14.0, fontWeight: FontWeight.w400))
                    ],
                  ),
                ),
                Container(
                  height: 150,
                  width: width / 2,
                  // color: Colors.white,
                  padding: EdgeInsets.only(left: 20, top: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        // width: double.infinity,
                        height: 40,
                        width: 150,
                        // padding: EdgeInsets.symmetric(horizontal: 70.0),
                        child: MaterialButton(
                          elevation: 5,
                          color: Color.fromRGBO(54, 110, 247, 10),
                          onPressed: () {
                            loadImageFromCamera();
                          },
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Camera',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15,
                      ),
                      Container(
                        // width: double.infinity,
                        height: 40,
                        width: 150,
                        // padding: EdgeInsets.symmetric(horizontal: 70.0),
                        child: MaterialButton(
                          elevation: 5,
                          color: Color.fromRGBO(54, 110, 247, 10),
                          onPressed: () {
                            loadImageFromGallery();
                          },
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: Colors.white, width: 0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Gallery',
                            style: GoogleFonts.roboto(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15,
            ),
            _loading == false
                ? Container(
                    child: Column(
                      children: [
                        Container(
                          height: 300,
                          width: 300,
                          child: Center(child: Image.file(_image!)),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        _predictions![0]['label'].toString().substring(2) ==
                                'Mask'
                            ? Text(
                                "" +
                                    _predictions![0]['label']
                                        .toString()
                                        .substring(2) +
                                    " 🥳",
                                style: GoogleFonts.roboto(
                                  fontSize: 18.0,
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.red,
                                    size: 25,
                                  ),
                                  SizedBox(
                                    width: 5,
                                  ),
                                  Text(
                                    _predictions![0]['label']
                                            .toString()
                                            .substring(2) +
                                        " 😨",
                                    style: GoogleFonts.roboto(
                                      fontSize: 22.0,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                            "Confidence: ${(_predictions![0]['confidence'] * 100).toStringAsFixed(2)}%",
                            style: GoogleFonts.roboto(
                                fontSize: 15.0, fontWeight: FontWeight.w400)),
                      ],
                    ),
                  )
                : Container(
                    height: 0,
                    width: 0,
                  )
          ],
        ),
      ),
    );
  }
}
