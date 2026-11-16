import 'package:flutter/material.dart';

import '../data/library_repository.dart';
import '../data/shop_data.dart';
import '../models/shop_item.dart';
import '../models/user.dart';
import '../theme.dart';

/// Tab Shop: koin dari game ditukar dengan item yang dipakai di dalam game.
class ShopScreen extends StatefulWidget {
  final LibraryRepository repo;
  const ShopScreen({super.key, required this.repo});

  @override
  State<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends State<ShopScreen> {
  AppUser get _user => widget.repo.currentUser!;

  Future<void> _buy(ShopItem item) async {
    try {
      await widget.repo.buyItem(_user, item);
      if (!mounted) return;
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${item.name} berhasil dibeli.')),
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final coins = widget.repo.coinsOf(_user);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('SHOP', style: comicStyle(fontSize: 34, color: MarsColors.ink)),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: comicBox(color: MarsColors.yellow),
              child: Row(
                children: [
                  const Icon(Icons.monetization_on, color: MarsColors.ink, size: 28),
                  const SizedBox(width: 10),
                  Text('KOIN $coins',
                      style: comicStyle(fontSize: 24, color: MarsColors.ink)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: shopItems.isEmpty
                  ? const Center(
                      child: Text('Segera hadir.',
                          style: TextStyle(color: MarsColors.muted)),
                    )
                  : ListView.separated(
                      itemCount: shopItems.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (_, i) {
                        final item = shopItems[i];
                        return _ShopRow(
                          item: item,
                          owned: widget.repo.itemCount(_user, item.id),
                          onBuy: () => _buy(item),
                        );
                      },
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
  final int owned;
  final VoidCallback onBuy;
  const _ShopRow({required this.item, required this.owned, required this.onBuy});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: comicBox(),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: comicStyle(fontSize: 20, color: MarsColors.ink)),
                const SizedBox(height: 2),
                Text(item.description,
                    style: const TextStyle(fontSize: 12, color: MarsColors.muted)),
                const SizedBox(height: 4),
                Text('Dimiliki: $owned',
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w700, color: MarsColors.ink)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            children: [
              Text('${item.price} KOIN',
                  style: comicStyle(fontSize: 15, color: MarsColors.accent)),
              const SizedBox(height: 6),
              FilledButton(onPressed: onBuy, child: const Text('BELI')),
            ],
          ),
        ],
      ),
    );
  }
}
