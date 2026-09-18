import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WorkPage extends StatelessWidget {
  final String ownerUid;
  final String karigarName;

  const WorkPage({
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
        title: const Text('મારું કામ'),
        centerTitle: true,
      ),
      body: StreamBuilder<
          QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('works')
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
                'કામની માહિતી લાવવામાં ભૂલ થઈ',
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
                'હજુ કોઈ કામની માહિતી નથી',
                style: TextStyle(
                  fontSize: 17,
                ),
              ),
            );
          }

          double totalDiamonds = 0;
          double totalWork = 0;

          for (final doc in docs) {
            final data = doc.data();

            final diamonds =
                _toDouble(data['diamonds']);

            final rate =
                _toDouble(data['rate']);

            totalDiamonds += diamonds;
            totalWork += diamonds * rate;
          }

          return Column(
            children: [
              Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'કુલ હીરા',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              totalDiamonds
                                  .toStringAsFixed(0),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 45,
                        color: Colors.grey,
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              'કુલ કામ',
                              style: TextStyle(
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            Text(
                              _money(totalWork),
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
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

                    final diamonds =
                        _toDouble(data['diamonds']);

                    final rate =
                        _toDouble(data['rate']);

                    final total =
                        diamonds * rate;

                    return Card(
                      margin:
                          const EdgeInsets.only(
                        bottom: 10,
                      ),
                      child: Padding(
                        padding:
                            const EdgeInsets.all(14),
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
                                              .circular(
                                        20,
                                      ),
                                      border:
                                          Border.all(
                                        color:
                                            Colors.grey,
                                      ),
                                    ),
                                    child: Text(
                                      section,
                                    ),
                                  ),
                              ],
                            ),
                            const Divider(
                              height: 20,
                            ),
                            Row(
                              children: [
                                const Icon(
                                  Icons.diamond,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'હીરા: '
                                  '${diamonds.toStringAsFixed(0)}',
                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.currency_rupee,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'ભાવ: '
                                  '${_money(rate)}',
                                  style:
                                      const TextStyle(
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'કુલ કામ',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  _money(total),
                                  style:
                                      const TextStyle(
                                    fontSize: 18,
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
