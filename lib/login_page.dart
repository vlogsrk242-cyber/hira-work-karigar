import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  final factoryController = TextEditingController();

  bool loading = false;

  Future<void> login() async {
    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final factoryNumber = factoryController.text.trim();

    if (name.isEmpty || mobile.isEmpty || factoryNumber.isEmpty) {
      showMessage('બધી માહિતી ભરો');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final result = await FirebaseFirestore.instance
          .collection('karigars')
          .where('name', isEqualTo: name)
          .where('mobile', isEqualTo: mobile)
          .where('factoryNumber', isEqualTo: factoryNumber)
          .limit(1)
          .get();

      if (!mounted) return;

      if (result.docs.isNotEmpty) {
        final karigar = result.docs.first.data();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => KarigarHomePage(
              karigarId: result.docs.first.id,
              karigarName: karigar['name'] ?? name,
            ),
          ),
        );
      } else {
        showMessage('માહિતી મળતી નથી');
      }
    } catch (e) {
      showMessage('Online database સાથે જોડાવામાં ભૂલ થઈ');
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    factoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કારીગર Login'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Hira Work Karigar',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),

            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'કારીગરનું નામ',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: mobileController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'મોબાઇલ નંબર',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: factoryController,
              decoration: const InputDecoration(
                labelText: 'કારખાના નંબર',
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: loading ? null : login,
                child: loading
                    ? const CircularProgressIndicator()
                    : const Text(
                        'Login',
                        style: TextStyle(fontSize: 18),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class KarigarHomePage extends StatelessWidget {
  final String karigarId;
  final String karigarName;

  const KarigarHomePage({
    super.key,
    required this.karigarId,
    required this.karigarName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કારીગર Dashboard'),
      ),
      body: Center(
        child: Text(
          'નમસ્તે $karigarName',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
