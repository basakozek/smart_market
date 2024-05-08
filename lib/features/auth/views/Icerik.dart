import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Icerik extends StatefulWidget {
  const Icerik({Key? key}) : super(key: key);

  @override
  _IcerikState createState() => _IcerikState();
}

class _IcerikState extends State<Icerik> {
  double? karbonhidrat;
  double? yag;
  double? protein;

  @override
  void initState() {
    super.initState();

    // Mevcut kullanıcının UID'sini al
    String? kullaniciUid = FirebaseAuth.instance.currentUser?.uid;

    if (kullaniciUid != null) {
      // seciliKalori koleksiyonundan verileri al
      FirebaseFirestore.instance
          .collection('seciliKalori')
          .doc(kullaniciUid)
          .get()
          .then((DocumentSnapshot documentSnapshot) {
        if (documentSnapshot.exists) {
          setState(() {
            karbonhidrat = documentSnapshot['karbonhidrat'];
            yag = documentSnapshot['yag'];
            protein = documentSnapshot['protein'];
          });
        } else {
          print('Belirli doküman bulunamadı.');
        }
      }).catchError((error) {
        print('Hata: $error');
      });
    } else {
      print('Kullanıcı oturum açmamış.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Günlük İçerik Bilgisi'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günlük Karbonhidrat Miktarı: ${karbonhidrat != null ? karbonhidrat!.toStringAsFixed(2) : "Bilgi yok"} gram',
            ),
            Text(
              'Günlük Yağ Miktarı: ${yag != null ? yag!.toStringAsFixed(2) : "Bilgi yok"} gram',
            ),
            Text(
              'Günlük Protein Miktarı: ${protein != null ? protein!.toStringAsFixed(2) : "Bilgi yok"} gram',
            ),
          ],
        ),
      ),
    );
  }
}
