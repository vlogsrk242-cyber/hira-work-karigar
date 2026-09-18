import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class HistoryPage extends StatelessWidget {
  final String ownerUid;
  final String karigarName;

  const HistoryPage({
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

  DateTime? _parseDate(dynamic value) {
    final text = value?.toString().trim() ?? '';

    if (text.isEmpty) {
      return null;
    }

    final parts = text.split('-');

    if (parts.length == 3) {
      final day = int.tryParse(parts[0]);
      final month = int.tryParse(parts[1]);
      final year = int.tryParse(parts[2]);

      if (day != null &&
          month != null &&
          year != null) {
        return DateTime(year, month, day);
      }
    }

    return DateTime.tryParse(text);
  }

  String _dateText(dynamic value) {
    final text = value?.toString() ?? '';

    if (text.isEmpty) {
      return 'તારીખ નથી';
    }

    return text;
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
        title: const Text('તારીખ પ્રમાણે હિસ્ટરી'),
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
        builder: (context, worksSnapshot) {
          if (worksSnapshot.hasError) {
            return const Center(
              child: Text(
                'કામની માહિતી લાવવામાં ભૂલ થઈ',
              ),
            );
          }

          if (worksSnapshot.connectionState ==
                  ConnectionState.waiting &&
              !worksSnapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final workDocs =
              worksSnapshot.data?.docs ?? [];

          return StreamBuilder<
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
            builder: (context, withdrawalSnapshot) {
              if (withdrawalSnapshot.hasError) {
                return const Center(
                  child: Text(
                    'ઉપાડની માહિતી લાવવામાં ભૂલ થઈ',
                  ),
                );
              }

              if (withdrawalSnapshot.connectionState ==
                      ConnectionState.waiting &&
                  !withdrawalSnapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final withdrawalDocs =
                  withdrawalSnapshot.data?.docs ?? [];

              final history = <Map<String, dynamic>>[];

              for (final doc in workDocs) {
                final data = doc.data();

                final diamonds =
                    _toDouble(data['diamonds']);

                final rate =
                    _toDouble(data['rate']);

                history.add({
                  'type': 'work',
                  'date':
                      (data['date'] ?? '').toString(),
                  'section':
                      (data['section'] ?? '').toString(),
                  'diamonds': diamonds,
                  'rate': rate,
                  'total': diamonds * rate,
                });
              }

              for (final doc in withdrawalDocs) {
                final data = doc.data();

                final amount =
                    _toDouble(data['amount']);

                history.add({
                  'type': 'withdrawal',
                  'date':
                      (data['date'] ?? '').toString(),
                  'section':
                      (data['section'] ?? '').toString(),
                  'amount': amount,
                });
              }

              history.sort((a, b) {
                final dateA =
                    _parseDate(a['date']);

                final dateB =
                    _parseDate(b['date']);

                if (dateA == null &&
                    dateB == null) {
                  return 0;
                }

                if (dateA == null) {
                  return 1;
                }

                if (dateB == null) {
                  return -1;
                }

                return dateB.compareTo(dateA);
              });

              if (history.isEmpty) {
                return const Center(
                  child: Text(
                    'હજુ કોઈ હિસ્ટરી નથી',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: history.length,
                itemBuilder: (context, index) {
                  final item = history[index];

                  final isWork =
                      item['type'] == 'work';

                  final date =
                      _dateText(item['date']);

                  final section =
                      (item['section'] ?? '')
                          .toString();

                  if (isWork) {
                    final diamonds =
                        _toDouble(
                      item['diamonds'],
                    );

                    final rate =
                        _toDouble(item['rate']);

                    final total =
                        _toDouble(item['total']);

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
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Row(
                              children: [
                                const CircleAvatar(
                                  child: Icon(
                                    Icons.assignment,
                                  ),
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Expanded(
                                  child: Text(
                                    date,
                                    style:
                                        const TextStyle(
                                      fontSize: 17,
                                      fontWeight:
                                          FontWeight
                                              .bold,
                                    ),
                                  ),
                                ),
                                const Text(
                                  'કામ',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(
                              height: 20,
                            ),
                            if (section.isNotEmpty)
                              Text(
                                'વિભાગ: $section',
                              ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'હીરા: '
                              '${diamonds.toStringAsFixed(0)}',
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Text(
                              'ભાવ: ${_money(rate)}',
                            ),
                            const SizedBox(
                              height: 7,
                            ),
                            Row(
                              mainAxisAlignment:
                                  MainAxisAlignment
                                      .spaceBetween,
                              children: [
                                const Text(
                                  'કુલ કામ',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                Text(
                                  _money(total),
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final amount =
                      _toDouble(item['amount']);

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
                            CrossAxisAlignment
                                .start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                child: Icon(
                                  Icons.payments,
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              Expanded(
                                child: Text(
                                  date,
                                  style:
                                      const TextStyle(
                                    fontSize: 17,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                              ),
                              const Text(
                                'ઉપાડ',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            height: 20,
                          ),
                          if (section.isNotEmpty)
                            Text(
                              'વિભાગ: $section',
                            ),
                          const SizedBox(height: 8),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .spaceBetween,
                            children: [
                              const Text(
                                'ઉપાડની રકમ',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              Text(
                                _money(amount),
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
              );
            },
          );
        },
      ),
    );
  }
}
