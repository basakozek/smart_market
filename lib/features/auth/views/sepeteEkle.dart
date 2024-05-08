import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'girişEkrani.dart'; // Eklediğimiz dosya

class SepeteEkle extends StatefulWidget {
  const SepeteEkle({Key? key}) : super(key: key);

  @override
  _SepeteEkleState createState() => _SepeteEkleState();
}

class _SepeteEkleState extends State<SepeteEkle> {
  Map<String, int> selectedItems = {};
  List<String> filteredItemList = [];

  void updateItemCount(String item, int count) {
    setState(() {
      selectedItems[item] = count;
    });
  }

  @override
  void initState() {
    super.initState();
    filteredItemList.addAll(itemList);
  }

  void filterItems(String query) {
    setState(() {
      filteredItemList = itemList
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  void saveSelectedItemsToFirestore() {
    CollectionReference selectedItemsCollection =
        FirebaseFirestore.instance.collection('selectedSepeteEklenenler');

    // Mevcut kullanıcının UID'sini al
    final FirebaseAuth auth = FirebaseAuth.instance;
    String? currentUserUID = auth.currentUser?.uid;

    selectedItemsCollection.add({
      'uid': currentUserUID, // Mevcut kullanıcının UID'sini ekle
      'selectedItems': selectedItems,
      'timestamp': Timestamp.now(),
    }).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sepet başarıyla kaydedildi!')),
      );
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $error')),
      );
    });
  }

  Future<void> _showAlerjiUyari(String item) async {
    // Mevcut kullanıcının UID'sini al
    final FirebaseAuth auth = FirebaseAuth.instance;
    String? currentUserUID = auth.currentUser?.uid;

    // Firestore'dan kullanıcının alerjisi olduğu ürünleri kontrol et
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('selectedItems')
        .doc(currentUserUID)
        .get();

    Map<String, dynamic>? alerjiListesi =
        userSnapshot.data() as Map<String, dynamic>?;

    // Eğer kullanıcının alerjisi olduğu bir ürün varsa ve sepete eklenen ürün
    // alerjisi olan ürünler listesindeyse uyarı göster
    if (alerjiListesi != null) {
      List<String> alerjiFruits = List<String>.from(alerjiListesi['fruits']);
      List<String> alerjiVegetables =
          List<String>.from(alerjiListesi['vegetables']);

      if (alerjiFruits.contains(item) || alerjiVegetables.contains(item)) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Alerji Uyarısı'),
              content: Text(
                  'Seçtiğiniz ürün alerjinize dahil olabilir. Yine de eklemek istiyor musunuz?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Hayır'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    int count = selectedItems.containsKey(item)
                        ? selectedItems[item]!
                        : 0;
                    updateItemCount(item, count + 1);
                  },
                  child: Text('Evet'),
                ),
              ],
            );
          },
        );
      } else {
        // Kullanıcının alerjisi olmadığı ürünse doğrudan ekleyebilir
        int count = selectedItems.containsKey(item) ? selectedItems[item]! : 0;
        updateItemCount(item, count + 1);
      }
    } else {
      // Kullanıcının alerjisi olmadığı ürünse doğrudan ekleyebilir
      int count = selectedItems.containsKey(item) ? selectedItems[item]! : 0;
      updateItemCount(item, count + 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sepete Ekle'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () async {
              final String? selected = await showSearch(
                context: context,
                delegate: _CustomSearchDelegate(),
              );

              if (selected != null && selected.isNotEmpty) {
                filterItems(selected);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var item in filteredItemList)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.remove),
                          onPressed: () {
                            if (selectedItems.containsKey(item)) {
                              int count = selectedItems[item]!;
                              if (count > 0) {
                                updateItemCount(item, count - 1);
                              }
                            }
                          },
                        ),
                        Text(selectedItems.containsKey(item)
                            ? selectedItems[item].toString()
                            : '0'),
                        IconButton(
                          icon: Icon(Icons.add),
                          onPressed: () async {
                            await _showAlerjiUyari(item);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: () {
                saveSelectedItemsToFirestore();
              },
              child: Text('Sepeti Kaydet'),
            ),
            SizedBox(height: 16), // Ekstra boşluk ekleyebilirsiniz
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GirisEkrani()),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Ana Sayfaya Git',
                  style: TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CustomSearchDelegate extends SearchDelegate<String> {
  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Container(); // No need for results in this case
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return ListView(
      children: itemList
          .where((item) => item.toLowerCase().contains(query.toLowerCase()))
          .map<ListTile>((item) {
        return ListTile(
          title: Text(item),
          onTap: () {
            close(context, item);
          },
        );
      }).toList(),
    );
  }
}

List<String> itemList = [
  'Anjou',
  'Asparagus',
  'Aubergine',
  'Avocado',
  'Banana',
  'Beef-Tomato',
  'Brown-Cap-Mushroom',
  'Cabbage',
  'Cantaloupe',
  'Carrots',
  'Conference',
  'Cucumber',
  'Floury-Potato',
  'Galia-Melon',
  'Garlic',
  'Golden-Delicious',
  'Granny-Smith',
  'Green-Bell-Pepper',
  'Honeydew-Melon',
  'Kaiser',
  'Kiwi',
  'Leek',
  'Lemon',
  'Lime',
  'Mango',
  'Nectarine',
  'Orange',
  'Orange-Bell-Pepper',
  'Peach',
  'Pineapple',
  'Pink-Lady',
  'Pomegranate',
  'Red-Bell-Pepper',
  'Red-Delicious',
  'Regular-Tomato',
  'Royal-Gala',
  'Solid-Potato',
  'Sweet-Potato',
  'Vine-Tomato',
  'Watermelon',
  'Yellow-Bell-Pepper',
  'Yellow-Onion',
  'Zucchini',
];
