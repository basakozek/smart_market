import 'dart:convert'; // Add this import

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class TarifUret extends StatefulWidget {
  @override
  _TarifUretState createState() => _TarifUretState();
}

class _TarifUretState extends State<TarifUret> {
  final TextEditingController _ingredientsController = TextEditingController();
  final TextEditingController _allergiesController = TextEditingController();
  Map<String, dynamic>? _response; // Change the type of _response to Map

  Future<void> sendRequest(String ingredients, String allergies) async {
    final String apiUrl =
        'https://3b9e-141-196-18-120.ngrok-free.app/tarif_uretimi';
    final String requestData = '$ingredients,$allergies';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/plain'},
        body: requestData,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body); // Parse JSON response
        setState(() {
          _response = responseData;
        });
      } else {
        setState(() {
          _response = {
            'error': 'Server returned status code ${response.statusCode}'
          };
        });
      }
    } catch (error) {
      setState(() {
        _response = {'error': 'Error: $error'};
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tarif Üretme Sayfası'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _ingredientsController,
              decoration: InputDecoration(
                labelText: 'Malzemeler (virgülle ayırınız)',
              ),
            ),
            TextField(
              controller: _allergiesController,
              decoration: InputDecoration(
                labelText: 'Alerjiler (virgülle ayırınız)',
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                final String ingredients = _ingredientsController.text;
                final String allergies = _allergiesController.text;
                sendRequest(ingredients, allergies);
              },
              child: Text('Gönder'),
            ),
            SizedBox(height: 20),
            _response != null
                ? _buildResponseDisplay() // Use a method to build the response UI
                : Container(),
          ],
        ),
      ),
    );
  }

  Widget _buildResponseDisplay() {
    if (_response!.containsKey('error')) {
      return Text(_response!['error']);
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${_response!['title']}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
          Text('Malzemeler'),
          ...(_response!['ingredients'] as List<dynamic>)
              .map<Widget>((item) => Text('* $item'))
              .toList(),
          Text('Yönergeler'),
          ...(_response!['instructions'] as List<dynamic>)
              .map<Widget>((item) => Text('$item'))
              .toList(),
        ],
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: TarifUret(),
  ));
}
