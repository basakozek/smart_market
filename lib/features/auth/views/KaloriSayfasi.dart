import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'girişEkrani.dart'; // Giriş ekranı dosyasını import ettik

class KaloriSayfasi extends StatefulWidget {
  const KaloriSayfasi({Key? key}) : super(key: key);

  @override
  _KaloriSayfasiState createState() => _KaloriSayfasiState();
}

class _KaloriSayfasiState extends State<KaloriSayfasi> {
  final TextEditingController _yasController = TextEditingController();
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  String? _seciliCinsiyet;
  String? _seciliAktiviteSeviyesi;
  bool _diyabetVarMi = false;
  bool _kolesterolVarMi = false;
  double? _karbonhidrat;
  double? _yag;
  double? _protein;

  double _hesaplaKalori() {
    if (_yasController.text.isEmpty ||
        _boyController.text.isEmpty ||
        _kiloController.text.isEmpty ||
        _seciliCinsiyet == null ||
        _seciliAktiviteSeviyesi == null) {
      // Gerekli bilgiler eksikse hesaplama yapma
      return 0.0;
    }

    // Kullanıcı bilgilerini al
    int yas = int.parse(_yasController.text);
    double boy = double.parse(_boyController.text);
    double kilo = double.parse(_kiloController.text);

    // Hesaplama için sabit değerler
    double bmr = (_seciliCinsiyet == 'Erkek')
        ? 66.47 + (13.75 * kilo) + (5.003 * boy) - (6.755 * yas)
        : 655.1 + (9.563 * kilo) + (1.85 * boy) - (4.676 * yas);
    double aktiviteCarpani = 1.0;

    // Aktivite seviyesine göre çarpanı belirle
    switch (_seciliAktiviteSeviyesi) {
      case 'Hareketsiz':
        aktiviteCarpani = 1.2;
        break;
      case 'Az Hareketli':
        aktiviteCarpani = 1.375;
        break;
      case 'Orta Derecede Aktif':
        aktiviteCarpani = 1.55;
        break;
      case 'Aktif':
        aktiviteCarpani = 1.725;
        break;
    }

    // Günlük kalori ihtiyacını hesapla
    double gerekenKalori = bmr * aktiviteCarpani;

    // Günlük karbonhidrat, yağ ve protein miktarlarını hesapla
    double karbonhidratYuzde = 0.5;
    double yagYuzde = 0.3;
    double proteinYuzde = 0.2;

    // Eğer kişi diyabet veya kolesterol varsa miktarları azalt
    if (_diyabetVarMi && _kolesterolVarMi) {
      karbonhidratYuzde -= 0.1;
      yagYuzde -= 0.1;
      proteinYuzde -= 0.1;
    } else if (_diyabetVarMi || _kolesterolVarMi) {
      karbonhidratYuzde -= 0.05;
      yagYuzde -= 0.05;
      proteinYuzde -= 0.05;
    }

    _karbonhidrat = gerekenKalori * karbonhidratYuzde / 4; // Karbonhidrat: %50
    _yag = gerekenKalori * yagYuzde / 9; // Yağ: %30
    _protein = gerekenKalori * proteinYuzde / 4; // Protein: %20

    return gerekenKalori;
  }

  void _firestoreKaydet(double gerekenKalori) {
    // Kullanıcının UID'sini al
    String? kullaniciUid = FirebaseAuth.instance.currentUser?.uid;

    // Kullanıcı UID'si varsa Firestore'a kayıt yap
    if (kullaniciUid != null) {
      FirebaseFirestore.instance
          .collection('seciliKalori')
          .doc(kullaniciUid)
          .set({
        'uid': kullaniciUid,
        'yas': _yasController.text,
        'boy': _boyController.text,
        'kilo': _kiloController.text,
        'cinsiyet': _seciliCinsiyet,
        'aktiviteSeviyesi': _seciliAktiviteSeviyesi,
        'diyabetVarMi': _diyabetVarMi,
        'kolesterolVarMi': _kolesterolVarMi,
        'gerekenKalori': gerekenKalori,
        'karbonhidrat': _karbonhidrat,
        'yag': _yag,
        'protein': _protein,
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Günlük bilgiler Firestore\'a kaydedildi')));
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $error')));
      });
    } else {
      // Kullanıcı oturum açmamışsa uyarı ver
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı oturum açmamış')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Kalori Hesaplayıcı'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                // Navigator ile GirişEkrani'na git
                context,
                MaterialPageRoute(builder: (context) => GirisEkrani()),
              );
            },
            icon: Icon(Icons.arrow_back),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _yasController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Yaş'),
              ),
              TextFormField(
                controller: _boyController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Boy (cm)'),
              ),
              TextFormField(
                controller: _kiloController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kilo (kg)'),
              ),
              DropdownButtonFormField<String>(
                value: _seciliCinsiyet,
                onChanged: (yeniDeger) {
                  setState(() {
                    _seciliCinsiyet = yeniDeger;
                  });
                },
                items: <String>['Erkek', 'Kadın'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Cinsiyet'),
              ),
              DropdownButtonFormField<String>(
                value: _seciliAktiviteSeviyesi,
                onChanged: (yeniDeger) {
                  setState(() {
                    _seciliAktiviteSeviyesi = yeniDeger;
                  });
                },
                items: <String>[
                  'Hareketsiz',
                  'Az Hareketli',
                  'Orta Derecede Aktif',
                  'Aktif'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration:
                    const InputDecoration(labelText: 'Aktivite Seviyesi'),
              ),
              CheckboxListTile(
                title: const Text('Diyabet Var'),
                value: _diyabetVarMi,
                onChanged: (value) {
                  setState(() {
                    _diyabetVarMi = value!;
                    _hesaplaKalori();
                  });
                },
              ),
              CheckboxListTile(
                title: const Text('Kolesterol Var'),
                value: _kolesterolVarMi,
                onChanged: (value) {
                  setState(() {
                    _kolesterolVarMi = value!;
                    _hesaplaKalori();
                  });
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  double gerekenKalori = _hesaplaKalori();
                  _firestoreKaydet(gerekenKalori);
                },
                child: const Text('Hesapla'),
              ),
              const SizedBox(height: 20),
              if (_karbonhidrat != null &&
                  _yag != null &&
                  _protein !=
                      null) // Karbonhidrat, yağ ve protein bilgisini göster
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Günlük Karbonhidrat Miktarı: ${_karbonhidrat!.toStringAsFixed(2)} gram'),
                    Text(
                        'Günlük Yağ Miktarı: ${_yag!.toStringAsFixed(2)} gram'),
                    Text(
                        'Günlük Protein Miktarı: ${_protein!.toStringAsFixed(2)} gram'),
                  ],
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GirisEkrani()),
                  );
                },
                child: Text('Giriş Ekranına Git'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
