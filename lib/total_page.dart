import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TotalPage extends StatelessWidget {
  final String ownerUid;
  final String karigarName;

  const TotalPage({
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
        title: const Text('કુલ કામ / ભાવ'),
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

          double totalDiamonds = 0;
          double totalWork = 0;

          for (final doc in workDocs) {
            final data = doc.data();

            final diamonds =
                _toDouble(data['diamonds']);

            final rate =
                _toDouble(data['rate']);

            totalDiamonds += diamonds;
            totalWork += diamonds * rate;
          }

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

              double totalWithdrawal = 0;

              for (final doc in withdrawalDocs) {
                totalWithdrawal +=
                    _toDouble(doc.data()['amount']);
              }

              final balance =
                  totalWork - totalWithdrawal;

              return RefreshIndicator(
                onRefresh: () async {
                  await Future<void>.delayed(
                    const Duration(
                      milliseconds: 300,
                    ),
                  );
                },
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(18),
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 32,
                              child: Icon(
                                Icons.person,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              karigarName,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    _totalCard(
                      icon: Icons.diamond,
                      title: 'કુલ હીરા',
                      value:
                          totalDiamonds.toStringAsFixed(0),
                    ),

                    _totalCard(
                      icon: Icons.currency_rupee,
                      title: 'કુલ કામ',
                      value: _money(totalWork),
                    ),

                    _totalCard(
                      icon: Icons.payments,
                      title: 'કુલ ઉપાડ',
                      value:
                          _money(totalWithdrawal),
                    ),

                    const SizedBox(height: 8),

                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(20),
                        child: Column(
                          children: [
                            const Text(
                              'બાકી રકમ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _money(balance),
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight:
                                    FontWeight.bold,
                                color: balance >= 0
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    Card(
                      child: Padding(
                        padding:
                            const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'હિસાબ',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            _accountRow(
                              'કુલ કામ',
                              _money(totalWork),
                            ),
                            _accountRow(
                              'કુલ ઉપાડ',
                              _money(
                                totalWithdrawal,
                              ),
                            ),
                            const Divider(),
                            _accountRow(
                              'બાકી',
                              _money(balance),
                              bold: true,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _totalCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
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
            fontSize: 16,
          ),
        ),
        trailing: Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _accountRow(
    String title,
    String value, {
    bool bold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 17,
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
