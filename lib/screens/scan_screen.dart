import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import '../appstate.dart';


class ScanScreen extends StatefulWidget {
  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  File? _image;

  final picker = ImagePicker();

  String? _imagePath; // Store the image path

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);

        _imagePath = pickedFile.path; // Store the path

        _saveImagePath(_imagePath!);
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _saveImagePath(String imagePath) async {
    final directory = await getApplicationDocumentsDirectory();

    final filePath = path.join(directory.path, 'last_image_path.txt');

    final file = File(filePath);

    await file.writeAsString(imagePath);
  }

  Future<String?> _getLastImagePath() async {
    try {
      final directory = await getApplicationDocumentsDirectory();

      final filePath = path.join(directory.path, 'last_image_path.txt');

      final file = File(filePath);

      return await file.readAsString();
    } catch (e) {
      return null; // Handle file not found or other errors
    }
  }

  @override
  void initState() {
    super.initState();

    _loadLastImagePath();
  }

  Future<void> _loadLastImagePath() async {
    final savedPath = await _getLastImagePath();

    if (savedPath != null) {
      setState(() {
        _image = File(savedPath);

        _imagePath = savedPath;
      });
    }
  }

  void _resetImage() {
    setState(() {
      _image = null;

      _imagePath = null;

      _saveImagePath(''); // Clear the saved path
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5DC),
        title: const Text('Scan', style: TextStyle(color: Colors.green)),
        elevation: 0.0,
      ),
      body: Container(
        color: Colors.grey[300],
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              GestureDetector(
                onTap: _image != null ? _resetImage : getImage, // Toggle action

                child: _image == null
                    ? Image.asset('assets/images/TapToOpenCam.png', height: 500)
                    : Image.file(_image!, height: 500, fit: BoxFit.fitHeight),
              ),
              const SizedBox(height: 20),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _image != null ? () {
                  appState.currentImagePath = _imagePath!;
                  Navigator.pushNamed(context, '/scan_result');
                } : null, // Disable if no image

                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: const TextStyle(fontSize: 20),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),

                child:
                    const Text('Scan', style: TextStyle(color: Colors.white)),
              ),
              if (_imagePath != null) // Display the file path

                Padding(
                  padding: const EdgeInsets.only(top: 16.0),
                  child: Text(
                    'Image Path: $_imagePath',
                    style: const TextStyle(fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
