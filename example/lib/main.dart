// example/lib/main.dart
import 'package:flutter/material.dart';
import 'package:bio_secure/bio_secure.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _bioSecure = BioSecure();
  String _status = 'Not initialized';
  String _storedValue = '';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeSecureStorage();
  }

  Future<void> _initializeSecureStorage() async {
    try {
      final status = await _bioSecure.initialize();
      setState(() {
        _status = 'Initialized\n'
            'Biometric: ${status.biometricType}\n'
            'Secure Enclave: ${status.secureEnclaveAvailable}';
        _isInitialized = true;
      });
    } on BioSecureException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _storeValue() async {
    try {
      await _bioSecure.secureStore('test_key', 'Hello, Secure World!');
      setState(() {
        _status = 'Value stored successfully';
      });
    } on BioSecureException catch (e) {
      setState(() {
        _status = 'Store error: ${e.message}';
      });
    }
  }

  Future<void> _retrieveValue() async {
    try {
      final value = await _bioSecure.secureRetrieve('test_key');
      setState(() {
        _storedValue = value ?? 'No value found';
      });
    } on BioSecureException catch (e) {
      setState(() {
        _status = 'Retrieve error: ${e.message}';
      });
    }
  }

  Future<void> _deleteValue() async {
    try {
      await _bioSecure.secureDelete('test_key');
      setState(() {
        _status = 'Value deleted successfully';
        _storedValue = '';
      });
    } on BioSecureException catch (e) {
      setState(() {
        _status = 'Delete error: ${e.message}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('BioSecure Example'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Status: $_status',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              Text(
                'Stored value: $_storedValue',
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isInitialized ? _storeValue : null,
                child: const Text('Store Value'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isInitialized ? _retrieveValue : null,
                child: const Text('Retrieve Value'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: _isInitialized ? _deleteValue : null,
                child: const Text('Delete Value'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}