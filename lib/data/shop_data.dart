import '../models/shop_item.dart';

/// Item shop yang dipakai di dalam game. Harga dalam koin.
final shopItems = <ShopItem>[
  ShopItem(
    id: 'hint',
    name: 'Petunjuk',
    description: 'Menampilkan huruf pertama jawaban pada soal.',
    price: 15,
  ),
  ShopItem(
    id: 'skip',
    name: 'Lewati Soal',
    description: 'Melewati soal ini tanpa mengurangi skor.',
    price: 25,
  ),
];
