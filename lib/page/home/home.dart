import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:meteor_music/provider/current_user.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('home'),
      ),
      body: Center(
        child: ElevatedButton(
            onPressed: () {
              context.read<CurrentUser>().clear();
              context.go('/sign_in');
            },
            child: const Text('Sign Out')),
      ),
    );
  }
}
