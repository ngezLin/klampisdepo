import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/transaction_models.dart';
import '../../../../core/ui/item_image.dart';
import '../../../../core/theme/notification_helper.dart';

class ItemCard extends StatelessWidget {
  final ItemModel item;
  final VoidCallback onTap;

  const ItemCard({super.key, required this.item, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);
    final isOutOfStock = item.isStockManaged && (item.stock <= 0);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          if (isOutOfStock) {
            showTopSnackBar(
              context,
              '⚠️ Stok "${item.name}" sedang habis! Silakan restock terlebih dahulu.',
              backgroundColor: Colors.red[700],
            );
          } else {
            onTap();
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ItemImage(
                    imageUrl: item.imageUrl,
                    fit: BoxFit.cover,
                  ),
                  if (item.isStockManaged)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isOutOfStock 
                              ? Colors.red.withOpacity(0.9)
                              : (item.stock < 5 ? Colors.amber[700] : const Color(0xFF00AA5B)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          isOutOfStock 
                              ? 'Habis' 
                              : (item.stock < 5 ? '${item.stock} Tipis' : '${item.stock} Stok'),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  if (isOutOfStock)
                    Container(
                      color: Colors.black45,
                      child: const Center(
                        child: Text(
                          'HABIS',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    currencyFormat.format(item.price),
                    style: TextStyle(color: Theme.of(context).primaryColor, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
