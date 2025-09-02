import 'package:flutter/material.dart';
import 'package:voltpay/core/router/go_api_services.dart';

class GoTestScreen extends StatefulWidget {
  const GoTestScreen({super.key});

  @override
  State<GoTestScreen> createState() => _GoTestScreenState();
}

class _GoTestScreenState extends State<GoTestScreen> {
  String message = 'Loading...';

  @override
  void initState() {
    super.initState();
    _loadMessage();
  }

  Future<void> _loadMessage() async {
    try {
      final String result = await GoApiService.fetchMessage();
      setState(() => message = result);
    } catch (e) {
      setState(() => message = 'Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: scheme.onSurface,
      appBar: AppBar(title: const Text('Go Backend API Test')),
      body: Center(child: Text(message)),
    );
  }
}
