import 'package:flutter/material.dart';
import 'package:flutter_module_1/common/colors.dart';
import 'package:flutter_module_1/features/home/views/home.dart';

class SignUpInfo extends StatefulWidget {
  const SignUpInfo({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;

  @override
  State<SignUpInfo> createState() => _SignUpInfoState();
}

class _SignUpInfoState extends State<SignUpInfo> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isAllFieldsFilled = false;

  @override
  void dispose() {
    _nameController.dispose();
    _surnameController.dispose();
    super.dispose();
  }

  void _checkAllFieldsFilled() {
    setState(() {
      _isAllFieldsFilled =
          _nameController.text.isNotEmpty && _surnameController.text.isNotEmpty;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/sign_up.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              padding: const EdgeInsets.all(
                15,
              ),
              decoration: const BoxDecoration(
                color: containerColor,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Form(
                autovalidateMode: AutovalidateMode.onUserInteraction,
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                        alignment: Alignment.centerLeft,
                        child: const Text(
                          "Sign Up",
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 24,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          controller: _nameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ad gereklidir";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Ad",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: borderColor,
                              ),
                            ),
                          ),
                          onChanged: (_) => _checkAllFieldsFilled(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: TextFormField(
                          controller: _surnameController,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Soyad gereklidir";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Soyad",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(4),
                              borderSide: const BorderSide(
                                color: borderColor,
                              ),
                            ),
                          ),
                          onChanged: (_) => _checkAllFieldsFilled(),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 5,
                        ),
                        child: MaterialButton(
                          onPressed: () {
                            if (_isAllFieldsFilled) {
                              // Sağlık Durumu butonuna tıklandığında sadece Home ekranına geçiş yap
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Home(),
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Lütfen tüm alanları doldurunuz.',
                                  ),
                                ),
                              );
                            }
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                          color: Colors.grey, // Mavi renk yerine gri renk
                          minWidth: double.infinity,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                            ),
                            child: Text(
                              "Sağlık Durumu",
                              style: TextStyle(
                                color: containerColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
