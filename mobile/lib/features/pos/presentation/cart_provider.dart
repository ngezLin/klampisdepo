import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../items/data/item_model.dart';

class CartItem {
  final ItemModel item;
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  double get subtotal => item.price * quantity;
}

class CartNotifier extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  
  double get totalAmount => _items.values.fold(0, (sum, item) => sum + item.subtotal);
  
  int get itemCount => _items.values.fold(0, (sum, item) => sum + item.quantity);

  void addItem(ItemModel item) {
    if (_items.containsKey(item.id)) {
      _items[item.id]!.quantity += 1;
    } else {
      _items[item.id] = CartItem(item: item);
    }
    notifyListeners();
  }

  void removeItem(int itemId) {
    if (_items.containsKey(itemId)) {
      if (_items[itemId]!.quantity > 1) {
        _items[itemId]!.quantity -= 1;
      } else {
        _items.remove(itemId);
      }
      notifyListeners();
    }
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }
}

final cartProvider = ChangeNotifierProvider<CartNotifier>((ref) {
  return CartNotifier();
});
