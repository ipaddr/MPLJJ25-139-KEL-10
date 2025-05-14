import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GiziKu Home')),
      body: const Center(
        child: Text(
          'Selamat datang di GiziKu!',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
//udingaming123