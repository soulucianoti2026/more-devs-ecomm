import 'package:flutter/material.dart';
import 'package:more_devs_do_zero/features/home/models/products_model.dart';

class QuantitySelector extends StatelessWidget {
  const QuantitySelector({
    super.key,
    required this.product,
    required this.quantity,
    required this.subtotal,
    required this.increment,
    required this.decrement,
  });

  final Products product;
  final int quantity;
  final double subtotal;
  final VoidCallback increment;
  final VoidCallback decrement;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.black12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    decrement();
                    // cartController.decrementFromCart(product.name);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Icon(Icons.remove),
                ),
              ),
              Container(
                width: 64,
                alignment: Alignment.center,
                child: Text(
                  quantity.toString(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Expanded(
                child: TextButton(
                  onPressed: () {
                    increment();
                    // cartController.addToCart(product);
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                  ),
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            'Subtotal: R\$ ${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1F1F1F),
            ),
          ),
        ),
      ],
    );
  }
}
