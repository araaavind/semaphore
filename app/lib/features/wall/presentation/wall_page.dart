import 'package:flutter/material.dart';

class WallPage extends StatelessWidget {
  static route() => MaterialPageRoute(builder: (context) => const WallPage());

  const WallPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semaphore'),
      ),
    );
  }
}
