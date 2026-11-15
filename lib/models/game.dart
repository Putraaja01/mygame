class Game {
  final String id;
  final String title;
  final String genre;
  final String developer;
  final String description;
  final int price;
  final int resellerPrice;

  const Game({
    required this.id,
    required this.title,
    required this.genre,
    required this.developer,
    required this.description,
    required this.price,
    required this.resellerPrice,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'genre': genre,
        'developer': developer,
        'description': description,
        'price': price,
        'resellerPrice': resellerPrice,
      };

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        id: json['id'] as String,
        title: json['title'] as String,
        genre: json['genre'] as String,
        developer: json['developer'] as String,
        description: json['description'] as String,
        price: json['price'] as int,
        resellerPrice: json['resellerPrice'] as int,
      );
}
