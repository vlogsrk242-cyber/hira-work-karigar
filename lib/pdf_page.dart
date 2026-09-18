import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PdfPage extends StatelessWidget {
  final String ownerUid;
  final String karigarName;

  const PdfPage({
    super.key,
    required this.ownerUid,
    required this.karigarName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF / Share'),
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('works')
            .where('ownerUid', isEqualTo: ownerUid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'માહિતી લાવવામાં ભૂલ થઈ',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final myWorks = docs.where((doc) {
            final data = doc.data();
            return (data['worker'] ?? '').toString() == karigarName;
          }).toList();

          double totalDiamonds = 0;
          double totalWork = 0;

          for (final doc in myWorks) {
            final data = doc.data();

            totalDiamonds +=
                double.tryParse(
                      (data['diamonds'] ?? 0).toString(),
                    ) ??
                    0;

            totalWork +=
                double.tryParse(
                      (data['total'] ?? 0).toString(),
                    ) ??
                    0;
          }

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.picture_as_pdf,
                          size: 55,
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'મારી કામની માહિતી',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('કારીગર'),
                            Text(karigarName),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('કુલ હીરા'),
                            Text(
                              totalDiamonds
                                  .toStringAsFixed(0),
                            ),
                          ],
                        ),
                        const Divider(),
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('કુલ કામ'),
                            Text(
                              '₹${totalWork.toStringAsFixed(2)}',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'PDF બનાવવાનું આગળના સ્ટેપમાં જોડશું',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text(
                      'PDF બનાવો',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Share option આગળના સ્ટેપમાં જોડશું',
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text(
                      'Share કરો',
                      style: TextStyle(fontSize: 17),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
