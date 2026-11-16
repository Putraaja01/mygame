import 'package:flutter/material.dart';

import '../data/shop_data.dart';
import '../models/shop_item.dart';
import '../theme.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  String _formatPrice(int price) => 'Rp ${price.toString()}';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'SHOP',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                letterSpacing: 4,
                color: MarsColors.sand,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: shopItems.isEmpty
                  ? _EmptyShop()
                  : ListView.separated(
                      itemCount: shopItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _ShopRow(
                        item: shopItems[i],
                        priceText: _formatPrice(shopItems[i].price),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ShopRow extends StatelessWidget {
  final ShopItem item;
  final String priceText;
  const _ShopRow({required this.item, required this.priceText});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: MarsColors.card,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name,
                    style: const TextStyle(fontSize: 15, color: MarsColors.sand)),
                const SizedBox(height: 2),
                Text(item.description,
                    style: const TextStyle(fontSize: 12, color: MarsColors.muted)),
              ],
            ),
          ),
          Text(priceText, style: const TextStyle(color: MarsColors.accent)),
        ],
      ),
    );
  }
}

class _EmptyShop extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: List.generate(
              4,
              (_) => Container(
                decoration: BoxDecoration(
                  color: MarsColors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: MarsColors.border),
                ),
                child: const Center(
                  child: Icon(Icons.inventory_2_outlined,
                      color: MarsColors.border, size: 32),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Segera hadir. Isi shop akan ditambahkan di dalam game.',
          textAlign: TextAlign.center,
          style: TextStyle(color: MarsColors.muted),
        ),
      ],
    );
  }
}
