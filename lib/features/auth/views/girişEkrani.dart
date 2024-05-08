import 'package:flutter/material.dart';

import 'anasayfa.dart';
import 'icerik.dart'; // Icerik.dart dosyasının import edilmesi gerekiyor
import 'sepeteEkle.dart';
import 'sepetim.dart';

class GirisEkrani extends StatelessWidget {
  const GirisEkrani({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Giriş Ekranı'),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Image.asset(
              'assets/images/market.png', // market.png'nin yolunu güncelleyin
              fit: BoxFit.scaleDown,
              width: double.infinity,
            ),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Anasayfa()),
                    );
                  },
                  child: Text(
                    'Ürün Tanı',
                    style: TextStyle(
                        fontSize: 20), // Yazı boyutu 20 olarak ayarlandı
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => SepeteEkle()),
                    );
                  },
                  child: Text(
                    'Sepete Ekle',
                    style: TextStyle(
                        fontSize: 20), // Yazı boyutu 20 olarak ayarlandı
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Sepetim()),
                    );
                  },
                  child: Text(
                    'Sepetimi Gör',
                    style: TextStyle(
                        fontSize: 20), // Yazı boyutu 20 olarak ayarlandı
                  ),
                ),
                ElevatedButton(
                  // Icerik sayfasına yönlendiren buton
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Icerik()),
                    );
                  },
                  child: Text(
                    'İçeriği Gör',
                    style: TextStyle(
                        fontSize: 20), // Yazı boyutu 20 olarak ayarlandı
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
