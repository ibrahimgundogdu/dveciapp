import 'dart:async';
import 'dart:io';

import 'addbasketitem.dart';
import 'package:flutter/material.dart';
import '../widgets/bottomnavbar.dart';
import '../widgets/drawer_menu.dart';
import '../widgets/floating_button.dart';

class Takepicture extends StatefulWidget {
  Takepicture({Key? key, required this.itemCode}) : super(key: key);

  //final CameraDescription camera;
  String itemCode;

  @override
  State<Takepicture> createState() => _TakepictureState();
}

class _TakepictureState extends State<Takepicture> {
  //late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    // _controller = CameraController(
    //   // Get a specific camera from the list of available cameras.
    //   widget.camera,
    //   // Define the resolution to use.
    //   ResolutionPreset.medium,
    // );
    //
    // // Next, initialize the controller. This returns a Future.
    // _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    //_controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,
      drawer: drawerMenu(context, "D-Veci"),
      //floatingActionButton: floatingButton(context),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.miniCenterDocked,
      bottomNavigationBar: bottomWidget(context),
      appBar: AppBar(
        title: const Text(
          'Take a picture',
          style: const TextStyle(
              color: Color(0xFFB79C91),
              fontSize: 14,
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      // You must wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner until the
      // controller has finished initializing.
      body: Text("denene"),
      floatingActionButton: FloatingActionButton(
        // Provide an onPressed callback.
        onPressed: () async {
          // Take the Picture in a try / catch block. If anything goes wrong,
          // catch the error.
          try {
            // Ensure that the camera is initialized.
            await _initializeControllerFuture;

            // Attempt to take a picture and get the file `image`
            // where it was saved.
            //final image = await _controller.takePicture();

            if (!mounted) return;

            // If the picture was taken, display it on a new screen.
            // await Navigator.of(context).push(
            //   // MaterialPageRoute(
            //   //   // builder: (context) => DisplayPictureScreen(
            //   //   //   // Pass the automatically generated path to
            //   //   //   // the DisplayPictureScreen widget.
            //   //   //   // imagePath: image.path,
            //   //   //   // imageName: image.name,
            //   //   //   itemCode: widget.itemCode,
            //   //   // ),
            //   // ),
            // );
          } catch (e) {
            // If an error occurs, log the error to the console.
            print(e);
          }
        },
        child: const Icon(Icons.camera_alt),
      ),
    );
  }
}

class DisplayPictureScreen extends StatelessWidget {
  final String imagePath;
  final String imageName;
  final String itemCode;
  const DisplayPictureScreen(
      {key,
      required this.imagePath,
      required this.imageName,
      required this.itemCode});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Confirm Picture')),
      body: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(child: Image.file(File(imagePath))),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                  elevation: 1,
                  shape: const CircleBorder(
                      side: BorderSide(
                          style: BorderStyle.solid,
                          width: 1,
                          color: Color(0xFFEAEFFF))),
                  padding: EdgeInsets.all(10),
                  backgroundColor: Color(0xFF6E7B89)),
              onPressed: () async {
                Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return AddBasketItem();
                }));
              },
              child: Column(
                children: const [
                  Icon(
                    Icons.save_outlined,
                    color: Colors.white,
                    size: 30.0,
                  ),
                ],
              ),
            ),
          ),
        ],
      )),
    );
  }
}
