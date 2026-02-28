import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/transaction_repository.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(transactionHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction History')),
      body: historyAsync.when(
        data: (transactions) => RefreshIndicator(
          onRefresh: () => ref.refresh(transactionHistoryProvider.future),
          child: ListView.separated(
            itemCount: transactions.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final tx = transactions[index];
              final date = DateTime.parse(tx['created_at']).toLocal();
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: tx['status'] == 'completed' ? Colors.green : Colors.red,
                  child: const Icon(Icons.receipt, color: Colors.white, size: 20),
                ),
                title: Text('Transaction #${tx['id']}'),
                subtitle: Text('${date.day}/${date.month} ${date.hour}:${date.minute} - ${tx['paymentType']}'),
                trailing: Text(
                  '\Rp ${tx['total_amount']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                ),
                onTap: () {
                   // Show basic details dialog
                   _showDetails(context, tx);
                },
              );
            },
          ),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showDetails(BuildContext context, dynamic tx) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Transaction #${tx['id']}'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Status: ${tx['status']}'),
              Text('Total: \Rp ${tx['total_amount']}'),
              Text('Payment: \Rp ${tx['paymentAmount']} (${tx['paymentType']})'),
              const Divider(),
              const Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...(tx['items'] as List).map((i) => Text('- ${i['item']['name']} x${i['quantity']}')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }
}

final transactionHistoryProvider = FutureProvider<List<dynamic>>((ref) {
  return ref.watch(transactionRepositoryProvider).getTransactionHistory();
});
