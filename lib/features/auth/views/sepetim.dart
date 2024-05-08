import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Sepetim extends StatefulWidget {
  const Sepetim({Key? key}) : super(key: key);

  @override
  _SepetimState createState() => _SepetimState();
}

class _SepetimState extends State<Sepetim> {
  late Map<String, int> sepetItems;
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sepetim'),
      ),
      body: StreamBuilder(
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

          return ListView(
            children: sepetItems.entries.map((entry) {
              return ListTile(
                title: Row(
                  children: [
                    Expanded(
                      child: Text('${entry.key}: ${entry.value}'),
                    ),
                  ],
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

void main() {
  runApp(MaterialApp(
    home: Sepetim(),
  ));
}
