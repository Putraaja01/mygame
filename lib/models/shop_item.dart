/// Item yang dijual di tab Shop dengan koin. Harga hanya tampil di Shop.
class ShopItem {
  final String id;
  final String name;
  final String description;
  final int price;

  const ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
  });
}
