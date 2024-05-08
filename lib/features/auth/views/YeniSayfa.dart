import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class YeniSayfa extends StatefulWidget {
  final String prediction;

  const YeniSayfa({Key? key, required this.prediction}) : super(key: key);

  @override
  _YeniSayfaState createState() => _YeniSayfaState();
}

class _YeniSayfaState extends State<YeniSayfa> {
  bool _isChecked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('İstediğiniz ürünü işaretleyiniz'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Tahmin Edilen Ürün: ${widget.prediction}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            CheckboxListTile(
              title: Text('Sepete Ekle'),
              value: _isChecked,
              onChanged: (bool? value) {
                setState(() {
                  _isChecked = value!;
                  if (_isChecked) {
                    _addProductToFirestore(widget.prediction);
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Ürün Sepete Eklendi'),
                        content: Text(
                            '${widget.prediction} başarıyla sepete eklendi.'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text('Tamam'),
                          ),
                        ],
                      ),
                    );
                  } else {
                    _removeProductFromFirestore(widget.prediction);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addProductToFirestore(String productName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      await firestore.collection('selectedProducts').add({
        'productName': productName,
        'timestamp': Timestamp.now(),
      });
    } catch (e) {
      print('Firestore hatası: $e');
    }
  }

  Future<void> _removeProductFromFirestore(String productName) async {
    try {
      final firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('selectedProducts')
          .where('productName', isEqualTo: productName)
          .get();
      querySnapshot.docs.forEach((doc) {
        doc.reference.delete();
      });
    } catch (e) {
      print('Firestore hatası: $e');
    }
  }
}
