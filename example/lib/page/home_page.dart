import 'package:flutter/material.dart';

import 'example_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scroll Preload Demos'),
      ),
      body: ListView(
        children: [
          ListTile(
            title: const Text('ListView Example'),
            subtitle: const Text('Uses ScrollPreloadDetector with ListView'),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ExamplePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
