import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_module_1/features/auth/views/KaloriSayfasi.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> fruits = [
    'Anjou',
    'Apple',
    'Avocado',
    'Banana',
    'Cantaloupe',
    'Galia-Melon',
    'Golden-Delicious',
    'Granny-Smith',
    'Green-Bell-Pepper',
    'Honeydew-Melon',
    'Kaiser',
    'Kiwi',
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
    'Red-Delicious',
    'Royal-Gala',
    'Solid-Potato',
    'Watermelon',
    'Yellow-Bell-Pepper'
  ];
  final List<String> vegetables = [
    'Asparagus',
    'Aubergine',
    'Beef-Tomato',
    'Brown-Cap-Mushroom',
    'Cabbage',
    'Carrots',
    'Conference',
    'Cucumber',
    'Floury-Potato',
    'Leek',
    'Regular-Tomato',
    'Red-Bell-Pepper',
    'Sweet-Potato',
    'Vine-Tomato',
    'Yellow-Onion',
    'Zucchini'
  ];

  List<String> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: 'Ürün ara...',
            border: InputBorder.none,
            hintStyle: TextStyle(color: Colors.white70),
          ),
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Align(
            alignment: Alignment.center,
            child: Text(
              "Alerjenizin olduğu besinleri seçiniz",
              style: TextStyle(
                fontSize: 20,
                // color: titleColor, // Bu renk değişkeni yok, istediğiniz rengi ekleyin.
              ),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView(
              children: [
                _buildCheckboxList('Meyveler', fruits),
                _buildCheckboxList('Sebzeler', vegetables),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  _saveSelectedItemsToFirestore();
                },
                child: const Text('Kaydet'),
              ),
              const SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const KaloriSayfasi(),
                    ),
                  );
                },
                child: const Text('Devam'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxList(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 10),
        Column(
          children: items
              .where((item) =>
                  item.toLowerCase().contains(searchQuery.toLowerCase()))
              .map((item) {
            return CheckboxListTile(
              title: Text(item),
              value: selectedItems.contains(item),
              onChanged: (value) {
                setState(() {
                  if (value!) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
                _saveSelectedItemsToFirestore(); // Firestore'a güncel veriyi kaydet
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  String searchQuery = '';

  void _saveSelectedItemsToFirestore() {
    String? uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) {
      FirebaseFirestore.instance.collection('selectedItems').doc(uid).set({
        'fruits':
            fruits.where((fruit) => selectedItems.contains(fruit)).toList(),
        'vegetables': vegetables
            .where((vegetable) => selectedItems.contains(vegetable))
            .toList(),
      }).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Seçilen öğeler Firestore\'a kaydedildi')));
      }).catchError((error) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Hata: $error')));
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Kullanıcı girişi yapılmadı')));
    }
  }
}
