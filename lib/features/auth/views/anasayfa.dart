import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'YeniSayfa.dart';

void main() {
  runApp(const Anasayfa());
}

class Anasayfa extends StatelessWidget {
  const Anasayfa({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    return const MaterialApp(debugShowCheckedModeBanner: false, home: Home());
  }
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  File? _selectedImage;
  String? _prediction;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xff1D1E22),
        title: const Text('Image Picker'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          children: [
            MaterialButton(
              color: Colors.blue,
              child: const Text("Pick Image from Gallery",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              onPressed: () {
                _pickImageFromGallery();
              },
            ),
            MaterialButton(
              color: Colors.red,
              child: const Text("Pick Image from Camera",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              onPressed: () {
                _pickImageFromCamera();
              },
            ),
            const SizedBox(
              height: 20,
            ),
            _selectedImage != null
                ? Image.file(_selectedImage!)
                : const Text("Please select an image"),
            MaterialButton(
              color: Colors.green,
              child: const Text("Send Image",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16)),
              onPressed: () {
                _sendImage(_selectedImage);
              },
            ),
            _prediction != null
                ? Text(
                    'Prediction: $_prediction',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  )
                : SizedBox(), // Show prediction if available
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_prediction != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => YeniSayfa(prediction: _prediction!),
                    ),
                  );
                } else {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Uyarı'),
                      content:
                          const Text('Önce bir görüntü seçin ve tahmin yapın.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Tamam'),
                        ),
                      ],
                    ),
                  );
                }
              },
              child: const Text('Sepete Ekle'),
            ),
          ],
        ),
      ),
    );
  }

  Future _pickImageFromGallery() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.camera);

    if (pickedImage == null) return;

    setState(() {
      _selectedImage = File(pickedImage.path);
    });
  }

  Future<void> _sendImage(File? _image) async {
    print('Sending image...');

    if (_image == null) {
      print('No image selected');
      return;
    }

    print('Image path: ${_image.path}');

    final url = 'http://10.0.2.2:5000/predict'; // Update with your server URL

    try {
      final bytes = await _image.readAsBytes(); // Read image as bytes
      final base64Image = base64Encode(bytes); // Encode bytes to base64

      final response = await http.post(
        Uri.parse(url),
        body: jsonEncode({'image': base64Image}),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        final prediction = data['prediction'];
        setState(() {
          _prediction = prediction;
        });
        print('Prediction: $prediction');
      } else {
        print('Failed to send image. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending image: $e');
    }
  }
}
