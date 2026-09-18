import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WithdrawalPage extends StatelessWidget {
  final String ownerUid;
  final String karigarName;

  const WithdrawalPage({
    super.key,
    required this.ownerUid,
    required this.karigarName,
  });

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(
          value?.toString() ?? '',
        ) ??
        0;
  }

  String _money(double value) {
    return '₹${value.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    if (ownerUid.isEmpty || karigarName.isEmpty) {
      return const Scaffold(
        body: Center(
          child: Text(
            'કારીગરની માહિતી મળી નથી',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('મારો ઉપાડ'),
        centerTitle: true,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('withdrawals')
            .where(
              'ownerUid',
              isEqualTo: ownerUid,
            )
            .where(
              'worker',
              isEqualTo: karigarName,
            )
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'ઉપાડની માહિતી લાવવામાં ભૂલ થઈ',
              ),
            );
          }

          if (snapshot.connectionState ==
                  ConnectionState.waiting &&
              !snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'હજુ કોઈ ઉપાડની માહિતી નથી',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            );
          }

          double totalWithdrawal = 0;

          for (final doc in docs) {
            totalWithdrawal +=
                _toDouble(doc.data()['amount']);
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.payments,
                        size: 42,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'કુલ ઉપાડ',
                        style: TextStyle(
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        _money(totalWithdrawal),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    12,
                    0,
                    12,
                    20,
                  ),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    final date =
                        (data['date'] ?? '').toString();

                    final section =
                        (data['section'] ?? '').toString();

                    final amount =
                        _toDouble(data['amount']);

                    return Card(
                      margin: const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.calendar_month,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    date.isEmpty
                                        ? 'તારીખ નથી'
                                        : date,
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight.bold,
                                    ),
                                  ),
                                ),
                                if (section.isNotEmpty)
                                  Container(
                                    padding:
                                        const EdgeInsets
                                            .symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration:
                                        BoxDecoration(
                                      borderRadius:
                                          BorderRadius
                                              .circular(20),
                                      border:
                                          Border.all(
                                        color: Colors.grey,
                                      ),
                                    ),
                                    child: Text(section),
                                  ),
                              ],
                            ),
                            const Divider(height: 20),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'ઉપાડ',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _money(amount),
                                  style: const TextStyle(
                                    fontSize: 19,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
