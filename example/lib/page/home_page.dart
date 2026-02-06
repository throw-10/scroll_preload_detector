import 'package:flutter/material.dart';

import 'list_view_example_page.dart';
import 'sliver_example_page.dart';

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
                  builder: (context) => const ListViewExamplePage(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('Sliver Example'),
            subtitle: const Text(
              'Uses SliverPreloadTrigger with complex CustomScrollView',
            ),
            trailing: const Icon(Icons.arrow_forward),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SliverExamplePage(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
