
import 'package:flutter/material.dart';
import '../widgets/pbkdf2_generator_tab.dart';
import '../widgets/pbkdf2_verifier_tab.dart';

class Pbkdf2Screen extends StatelessWidget {
  const Pbkdf2Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('PBKDF2 Utility'),
          centerTitle: true,
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.key_outlined),
                text: 'Generator',
              ),
              Tab(
                icon: Icon(Icons.verified_user_outlined),
                text: 'Verifier',
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            Pbkdf2GeneratorTab(),
            Pbkdf2VerifierTab(),
          ],
        ),
      ),
    );
  }
}
