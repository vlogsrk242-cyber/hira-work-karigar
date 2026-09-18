import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'work_page.dart';

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
    if (loading) return;

    final name = nameController.text.trim();
    final mobile = mobileController.text.trim();
    final factoryNumber = factoryController.text.trim();

    if (name.isEmpty ||
        mobile.isEmpty ||
        factoryNumber.isEmpty) {
      showMessage('બધી માહિતી ભરો');
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      if (auth.currentUser == null) {
        await auth.signInAnonymously();
      }

      final result = await firestore
          .collection('karigars')
          .where('name', isEqualTo: name)
          .where('mobile', isEqualTo: mobile)
          .where(
            'factoryNumber',
            isEqualTo: factoryNumber,
          )
          .limit(1)
          .get();

      if (!mounted) return;

      if (result.docs.isEmpty) {
        showMessage(
          'નામ, મોબાઇલ નંબર અથવા કારખાના નંબર મળતા નથી',
        );
        return;
      }

      final doc = result.docs.first;
      final karigar = doc.data();

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => KarigarHomePage(
            karigarId: doc.id,
            ownerUid:
                karigar['ownerUid']?.toString() ?? '',
            karigarName:
                karigar['name']?.toString() ?? name,
            mobile:
                karigar['mobile']?.toString() ?? mobile,
            factoryNumber:
                karigar['factoryNumber']?.toString() ??
                    factoryNumber,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      if (e.code == 'operation-not-allowed') {
        showMessage(
          'Anonymous Login Firebaseમાં ચાલુ નથી',
        );
      } else if (e.code == 'network-request-failed') {
        showMessage(
          'Internet connection તપાસો',
        );
      } else {
        showMessage(
          'Login કરવામાં ભૂલ થઈ',
        );
      }
    } on FirebaseException catch (e) {
      if (!mounted) return;

      if (e.code == 'permission-denied') {
        showMessage(
          'Firebase Permission બંધ છે',
        );
      } else {
        showMessage(
          'કારીગરની માહિતી મેળવવામાં ભૂલ થઈ',
        );
      }
    } catch (e) {
      if (!mounted) return;

      showMessage(
        'Login કરવામાં ભૂલ થઈ',
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
        ),
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 50),

              const Icon(
                Icons.diamond,
                size: 70,
              ),

              const SizedBox(height: 15),

              const Text(
                'Hira Work Karigar',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 35),

              TextField(
                controller: nameController,
                textCapitalization:
                    TextCapitalization.words,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'કારીગરનું નામ',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                maxLength: 10,
                decoration: const InputDecoration(
                  labelText: 'મોબાઇલ નંબર',
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                  counterText: '',
                ),
              ),

              const SizedBox(height: 15),

              TextField(
                controller: factoryController,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => login(),
                decoration: const InputDecoration(
                  labelText: 'કારખાના નંબર',
                  prefixIcon: Icon(Icons.business),
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
                      ? const SizedBox(
                          width: 25,
                          height: 25,
                          child:
                              CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'LOGIN',
                          style: TextStyle(
                            fontSize: 18,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class KarigarHomePage extends StatelessWidget {
  final String karigarId;
  final String ownerUid;
  final String karigarName;
  final String mobile;
  final String factoryNumber;

  const KarigarHomePage({
    super.key,
    required this.karigarId,
    required this.ownerUid,
    required this.karigarName,
    required this.mobile,
    required this.factoryNumber,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('કારીગર Dashboard'),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              if (!context.mounted) return;

              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                  builder: (_) => const LoginPage(),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 30,
                        child: Icon(
                          Icons.person,
                          size: 32,
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              karigarName,
                              style: const TextStyle(
                                fontSize: 21,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              'કારખાના નંબર: $factoryNumber',
                            ),
                            Text(
                              'મોબાઇલ: $mobile',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              DashboardTile(
                icon: Icons.diamond,
                title: 'હીરા',
                subtitle: 'તમારા હીરાની માહિતી',
                onTap: () {
                  showComingSoon(context);
                },
              ),

              DashboardTile(
                icon: Icons.assignment,
                title: 'કામ',
                subtitle: 'તમારું કામ અને તારીખ',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => WorkPage(
                        ownerUid: ownerUid,
                        karigarName: karigarName,
                      ),
                    ),
                  );
                },
              ),

              DashboardTile(
                icon: Icons.currency_rupee,
                title: 'કુલ કામ / ભાવ',
                subtitle: 'કામની કુલ રકમ',
                onTap: () {
                  showComingSoon(context);
                },
              ),

              DashboardTile(
                icon: Icons.payments,
                title: 'ઉપાડ',
                subtitle: 'તમારા ઉપાડની માહિતી',
                onTap: () {
                  showComingSoon(context);
                },
              ),

              DashboardTile(
                icon: Icons.history,
                title: 'તારીખ પ્રમાણે હિસ્ટરી',
                subtitle: 'કામ અને ઉપાડની હિસ્ટરી',
                onTap: () {
                  showComingSoon(context);
                },
              ),

              DashboardTile(
                icon: Icons.picture_as_pdf,
                title: 'PDF / Share',
                subtitle: 'તમારી હિસ્ટરીનો PDF',
                onTap: () {
                  showComingSoon(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text(
            'આ વિભાગ આગળ Firebase database સાથે જોડાશે',
          ),
        ),
      );
  }
}

class DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const DashboardTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 8,
        ),
        leading: CircleAvatar(
          child: Icon(icon),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 18,
        ),
        onTap: onTap,
      ),
    );
  }
}
