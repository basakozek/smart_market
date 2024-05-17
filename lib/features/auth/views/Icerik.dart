import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_module_1/features/auth/views/icerik.dart' as icerik;
import 'package:flutter_module_1/features/auth/views/sepetim.dart' as sepetim;

void main() {
  runApp(MaterialApp(
    home: icerik.Icerik(),
  ));
}

class Icerik extends StatefulWidget {
  const Icerik({Key? key}) : super(key: key);

  @override
  _IcerikState createState() => _IcerikState();
}

class _IcerikState extends State<Icerik> {
  double? toplamKarbonhidrat;
  double? toplamProtein;
  double? toplamYag;

  @override
  void initState() {
    super.initState();
    getIcerikBilgisi();
  }

  void getIcerikBilgisi() {
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
            toplamKarbonhidrat = documentSnapshot['karbonhidrat'];
            toplamYag = documentSnapshot['yag'];
            toplamProtein = documentSnapshot['protein'];
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
        title: Text('Günlük İçerik Bilgisi ve Sepet'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Günlük Karbonhidrat Miktarı: ${toplamKarbonhidrat != null ? toplamKarbonhidrat!.toStringAsFixed(2) : "Bilgi yok"} gram',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              'Günlük Yağ Miktarı: ${toplamYag != null ? toplamYag!.toStringAsFixed(2) : "Bilgi yok"} gram',
              style: TextStyle(color: Colors.black),
            ),
            Text(
              'Günlük Protein Miktarı: ${toplamProtein != null ? toplamProtein!.toStringAsFixed(2) : "Bilgi yok"} gram',
              style: TextStyle(color: Colors.black),
            ),
            SizedBox(height: 20),
            Text(
              'Sepetinizdeki Ürünler:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Sepetim(
                toplamKarbonhidrat: toplamKarbonhidrat,
                toplamProtein: toplamProtein,
                toplamYag: toplamYag,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sepetim extends StatefulWidget {
  final double? toplamKarbonhidrat;
  final double? toplamProtein;
  final double? toplamYag;

  const Sepetim(
      {Key? key,
      required this.toplamKarbonhidrat,
      required this.toplamProtein,
      required this.toplamYag})
      : super(key: key);

  @override
  _SepetimState createState() => _SepetimState();
}

class _SepetimState extends State<Sepetim> {
  late Map<String, int> sepetItems;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('selectedSepeteEklenenler')
          .where('uid', isEqualTo: currentUser!.uid)
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Hata: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('Sepetiniz boş.'),
          );
        }

        sepetItems = {};

        snapshot.data!.docs.forEach((document) {
          Map<String, dynamic> data = document.data() as Map<String, dynamic>;
          data['selectedItems'].forEach((key, value) {
            if (sepetItems.containsKey(key)) {
              sepetItems[key] = sepetItems[key]! + (value as int);
            } else {
              sepetItems[key] = value as int;
            }
          });
        });

        // Toplam miktarları hesapla
        double sepetKarbonhidrat = 0;
        double sepetProtein = 0;
        double sepetYag = 0;

        sepetItems.forEach((item, count) {
          // Ürünlerin miktarını topla
          sepetKarbonhidrat += calculateKarbonhidrat(item, count);
          sepetProtein += calculateProtein(item, count);
          sepetYag += calculateYag(item, count);
        });

        // Kalan miktarları hesapla
        double kalanKarbonhidrat =
            (widget.toplamKarbonhidrat ?? 0) - sepetKarbonhidrat;
        double kalanProtein = (widget.toplamProtein ?? 0) - sepetProtein;
        double kalanYag = (widget.toplamYag ?? 0) - sepetYag;

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: sepetItems.length,
                itemBuilder: (context, index) {
                  final item = sepetItems.keys.elementAt(index);
                  final count = sepetItems[item];

                  return ListTile(
                    title: Text('$item: $count'),
                  );
                },
              ),
            ),
            Divider(),
            Text(
              'Toplam Karbonhidrat: ${sepetKarbonhidrat.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.indigo),
            ),
            Text(
              'Toplam Protein: ${sepetProtein.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.indigo),
            ),
            Text(
              'Toplam Yağ: ${sepetYag.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.indigo),
            ),
            Divider(),
            Text(
              'Kalan Karbonhidrat: ${kalanKarbonhidrat.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.red),
            ),
            Text(
              'Kalan Protein: ${kalanProtein.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.red),
            ),
            Text(
              'Kalan Yağ: ${kalanYag.toStringAsFixed(2)} gram',
              style: TextStyle(color: Colors.red),
            ),
          ],
        );
      },
    );
  }

  // Her ürün için karbonhidrat miktarını hesapla
  double calculateKarbonhidrat(String itemName, int itemCount) {
    double carbPerItem = 0;

    switch (itemName) {
      case 'Armut':
        carbPerItem = 30.46;
        break;
      case 'Kuşkonmaz':
        carbPerItem = 0.21;
        break;
      case 'Patlıcan':
        carbPerItem = 4.98;
        break;
      case 'Avokado':
        carbPerItem = 11.94;
        break;
      case 'Muz':
        carbPerItem = 38.83;
        break;
      case 'Domates':
        carbPerItem = 4.28;
        break;
      case 'Kahverengi Şapkalı Mantar':
        carbPerItem = 0.49;
        break;
      case 'Lahana':
        carbPerItem = 33.28;
        break;
      case 'Kavun':
        carbPerItem = 19.74;
        break;
      case 'Havuç':
        carbPerItem = 3.83;
        break;
      case 'Konferans Armutu':
        carbPerItem = 30.46;
        break;
      case 'Salatalık':
        carbPerItem = 2.17;
        break;
      case 'Yemeklik Patates':
        carbPerItem = 33.23;
        break;
      case 'Galya Kavunu':
        carbPerItem = 11.84;
        break;
      case 'Sarımsak':
        carbPerItem = 71.12;
        break;
      case 'Üzüm':
        carbPerItem = 23.91;
        break;
      case 'Kivi':
        carbPerItem = 10.5;
        break;
      case 'Pırasa':
        carbPerItem = 4.72;
        break;
      case 'Mango':
        carbPerItem = 30.98;
        break;
      case 'Mantar':
        carbPerItem = 0.43;
        break;
      case 'Soğan':
        carbPerItem = 1.68;
        break;
      case 'Portakal':
        carbPerItem = 18.9;
        break;
      case 'Şeftali':
        carbPerItem = 8.63;
        break;
      case 'Armut':
        carbPerItem = 30.46;
        break;
      case 'Bezelye':
        carbPerItem = 8.56;
        break;
      case 'Ananas':
        carbPerItem = 11.75;
        break;
      case 'Erik':
        carbPerItem = 22.88;
        break;
      case 'Çilek':
        carbPerItem = 0.77;
        break;
      case 'Kırmızı Dolmalık Biber':
        carbPerItem = 5.5;
        break;
      case 'Karpuz':
        carbPerItem = 23.96;
        break;
      case 'Kabağı':
        carbPerItem = 1.11;
        break;
      case 'Bal Kabağı':
        carbPerItem = 0.66;
        break;
      default:
        break;
    }

    return carbPerItem * itemCount;
  }

  // Her ürün için protein miktarını hesapla
  double calculateProtein(String itemName, int itemCount) {
    double proteinPerItem = 0;

    switch (itemName) {
      case 'Armut':
        proteinPerItem = 0.64;
        break;
      case 'Kuşkonmaz':
        proteinPerItem = 1.48;
        break;
      case 'Patlıcan':
        proteinPerItem = 1.2;
        break;
      case 'Avokado':
        proteinPerItem = 1.96;
        break;
      case 'Muz':
        proteinPerItem = 1.29;
        break;
      case 'Domates':
        proteinPerItem = 1.1;
        break;
      case 'Kahverengi Şapkalı Mantar':
        proteinPerItem = 2.5;
        break;
      case 'Lahana':
        proteinPerItem = 1.28;
        break;
      case 'Kavun':
        proteinPerItem = 1.55;
        break;
      case 'Havuç':
        proteinPerItem = 1.09;
        break;
      case 'Konferans Armutu':
        proteinPerItem = 0.64;
        break;
      case 'Salatalık':
        proteinPerItem = 0.59;
        break;
      case 'Yemeklik Patates':
        proteinPerItem = 3.63;
        break;
      case 'Galya Kavunu':
        proteinPerItem = 0.88;
        break;
      case 'Sarımsak':
        proteinPerItem = 0.5;
        break;
      case 'Üzüm':
        proteinPerItem = 0.81;
        break;
      case 'Kivi':
        proteinPerItem = 0.98;
        break;
      case 'Pırasa':
        proteinPerItem = 1.4;
        break;
      case 'Mango':
        proteinPerItem = 0.82;
        break;
      case 'Mantar':
        proteinPerItem = 2.9;
        break;
      case 'Soğan':
        proteinPerItem = 1.1;
        break;
      case 'Portakal':
        proteinPerItem = 1.19;
        break;
      case 'Şeftali':
        proteinPerItem = 0.91;
        break;
      case 'Armut':
        proteinPerItem = 0.64;
        break;
      case 'Bezelye':
        proteinPerItem = 5.42;
        break;
      case 'Ananas':
        proteinPerItem = 0.54;
        break;
      case 'Erik':
        proteinPerItem = 0.89;
        break;
      case 'Çilek':
        proteinPerItem = 0.37;
        break;
      case 'Kırmızı Dolmalık Biber':
        proteinPerItem = 1.0;
        break;
      case 'Karpuz':
        proteinPerItem = 1.82;
        break;
      case 'Kabağı':
        proteinPerItem = 1.58;
        break;
      case 'Bal Kabağı':
        proteinPerItem = 1.07;
        break;
      default:
        break;
    }

    return proteinPerItem * itemCount;
  }

  // Her ürün için yağ miktarını hesapla
  double calculateYag(String itemName, int itemCount) {
    double fatPerItem = 0;

    switch (itemName) {
      case 'Armut':
        fatPerItem = 0.16;
        break;
      case 'Kuşkonmaz':
        fatPerItem = 0.16;
        break;
      case 'Patlıcan':
        fatPerItem = 0.2;
        break;
      case 'Avokado':
        fatPerItem = 30.1;
        break;
      case 'Muz':
        fatPerItem = 0.54;
        break;
      case 'Domates':
        fatPerItem = 0.2;
        break;
      case 'Kahverengi Şapkalı Mantar':
        fatPerItem = 0.1;
        break;
      case 'Lahana':
        fatPerItem = 0.1;
        break;
      case 'Kavun':
        fatPerItem = 0.38;
        break;
      case 'Havuç':
        fatPerItem = 0.24;
        break;
      case 'Konferans Armutu':
        fatPerItem = 0.16;
        break;
      case 'Salatalık':
        fatPerItem = 0.11;
        break;
      case 'Yemeklik Patates':
        fatPerItem = 0.1;
        break;
      case 'Galya Kavunu':
        fatPerItem = 0.28;
        break;
      case 'Sarımsak':
        fatPerItem = 0.5;
        break;
      case 'Üzüm':
        fatPerItem = 0.16;
        break;
      case 'Kivi':
        fatPerItem = 0.6;
        break;
      case 'Pırasa':
        fatPerItem = 0.23;
        break;
      case 'Mango':
        fatPerItem = 0.38;
        break;
      case 'Mantar':
        fatPerItem = 0.1;
        break;
      case 'Soğan':
        fatPerItem = 0.1;
        break;
      case 'Portakal':
        fatPerItem = 0.12;
        break;
      case 'Şeftali':
        fatPerItem = 0.25;
        break;
      case 'Armut':
        fatPerItem = 0.16;
        break;
      case 'Bezelye':
        fatPerItem = 0.4;
        break;
      case 'Ananas':
        fatPerItem = 0.12;
        break;
      case 'Erik':
        fatPerItem = 0.28;
        break;
      case 'Çilek':
        fatPerItem = 0.2;
        break;
      case 'Kırmızı Dolmalık Biber':
        fatPerItem = 0.3;
        break;
      case 'Karpuz':
        fatPerItem = 0.15;
        break;
      case 'Kabağı':
        fatPerItem = 0.2;
        break;
      case 'Bal Kabağı':
        fatPerItem = 0.1;
        break;
      default:
        break;
    }

    return fatPerItem * itemCount;
  }
}
