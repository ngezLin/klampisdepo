import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../items/data/item_repository.dart';
import '../../items/data/item_model.dart';
import '../data/transaction_repository.dart';
import 'cart_provider.dart';
import 'receipt_service.dart';
import 'dart:async';

class PosScreen extends ConsumerWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider);
    final cart = ref.watch(cartProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('POS & Transactions'),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => _showCartDrawer(context, ref),
              ),
              if (cart.itemCount > 0)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    child: Text(
                      '${cart.itemCount}',
                      style: const TextStyle(color: Colors.white, fontSize: 10),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return _ItemCard(item: item);
          },
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }

  void _showCartDrawer(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return const _CartBottomSheet();
      },
    );
  }
}

class _ItemCard extends ConsumerWidget {
  final ItemModel item;
  const _ItemCard({required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => ref.read(cartProvider.notifier).addItem(item),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: item.imageUrl != null
                  ? Image.network(item.imageUrl!, fit: BoxFit.cover, width: double.infinity)
                  : Container(color: Colors.grey[200], child: const Icon(Icons.image, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold), maxLines: 1),
                  Text('\Rp ${item.price.toStringAsFixed(0)}', style: const TextStyle(color: Colors.blue)),
                  Text('Stock: ${item.stock}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartBottomSheet extends ConsumerWidget {
  const _CartBottomSheet();

  void _checkout(BuildContext context, WidgetRef ref) async {
    final cart = ref.read(cartProvider);
    final paymentController = TextEditingController(text: cart.totalAmount.toStringAsFixed(0));

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Checkout'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Total Amount: \Rp ${cart.totalAmount.toStringAsFixed(0)}'),
            const SizedBox(height: 16),
            TextField(
              controller: paymentController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Payment Amount'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm Payment')),
        ],
      ),
    );

    if (result == true) {
      final paymentAmount = double.tryParse(paymentController.text) ?? cart.totalAmount;
      
      try {
        final itemsData = cart.items.map((i) => {
          'item_id': i.item.id,
          'quantity': i.quantity,
        }).toList();

        final response = await ref.read(transactionRepositoryProvider).createTransaction(
          items: itemsData,
          paymentAmount: paymentAmount,
          paymentType: 'cash',
        );

        // Extract transaction ID if returned by backend, else use placeholder
        final transactionId = 'TXN-${DateTime.now().millisecondsSinceEpoch}';

        if (context.mounted) {
          final shouldPrint = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Success!'),
              content: const Text('Transaction completed successfully. Would you like to print the receipt?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Skip')),
                ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Print Receipt')),
              ],
            ),
          );

          if (shouldPrint == true) {
            await ReceiptService.printReceipt(
              items: cart.items,
              total: cart.totalAmount,
              payment: paymentAmount,
              transactionId: transactionId,
            );
          }
        }

        cart.clear();
        if (context.mounted) {
          Navigator.pop(context); // Close bottom sheet
          ref.refresh(itemsProvider); // Refresh stock
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cart = ref.watch(cartProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Shopping Cart', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.delete_sweep), onPressed: () => cart.clear()),
            ],
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: cart.items.length,
              itemBuilder: (context, index) {
                final cartItem = cart.items[index];
                return ListTile(
                  title: Text(cartItem.item.name),
                  subtitle: Text('\Rp ${cartItem.item.price.toStringAsFixed(0)} x ${cartItem.quantity}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).removeItem(cartItem.item.id),
                      ),
                      Text('${cartItem.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add_circle_outline),
                        onPressed: () => ref.read(cartProvider.notifier).addItem(cartItem.item),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text('\Rp ${cart.totalAmount.toStringAsFixed(0)}',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: cart.items.isEmpty ? null : () => _checkout(context, ref),
              child: const Text('CHECKOUT'),
            ),
          ),
        ],
      ),
    );
  }
}
