/// Represents a user in the application.
class UserModel {
  /// The email address of the user.
  final String email;

  /// The display name of the user.
  final String name;

  /// The URL to the user's avatar image, if available.
  final String? avatarUrl;

  /// Creates a [UserModel] instance.
  UserModel({required this.email, required this.name, this.avatarUrl});

  /// Creates a [UserModel] from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      email: json['email'] ?? '',
      name: json['name'] ?? '',
      avatarUrl: json['avatarUrl'],
    );
  }

  /// Converts the [UserModel] to a JSON map.
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'avatarUrl': avatarUrl,
    };
  }
}

/// Represents an item or product in the marketplace.
class ItemModel {
  /// The unique identifier of the item.
  final int? id;

  /// The title or name of the item.
  final String title;

  /// The detailed description of the item.
  /// Maps to the 'description' field in the API JSON.
  final String body;

  /// The URL of the item's image.
  final String? image;

  /// The price of the item.
  final double? price;

  /// The category of the item from the API.
  final String? realCategory;

  /// The current status of the item (e.g., 'In Stock', 'Low Stock').
  /// This is currently mocked based on the ID.
  final String status;

  /// The date associated with the item (e.g., created date).
  /// This is currently mocked.
  final DateTime? date;

  /// Creates an [ItemModel] instance.
  ItemModel({
    this.id,
    required this.title,
    required this.body,
    this.image,
    this.price,
    this.realCategory,
    this.status = 'Open',
    this.date,
  });

  /// Creates an [ItemModel] from a JSON map.
  /// Handles mapping 'description' to [body] and initializes mock fields.
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'],
      title: json['title'] ?? '',
      body: json['description'] ?? '', // Map description to body
      image: json['image'],
      price: (json['price'] as num?)?.toDouble(),
      realCategory: json['category'],
      status: (json['id'] ?? 0) % 2 == 0 ? 'In Stock' : 'Low Stock', // Mock status for products
      date: DateTime.now().subtract(Duration(days: (json['id'] ?? 0) % 10)),
    );
  }

  /// Returns the category of the item. 
  /// Falls back to 'General' if [realCategory] is null.
  String get category => realCategory ?? 'General';

  /// Converts the [ItemModel] to a JSON map.
  /// Maps [body] back to 'description'.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': body, // Map body back to description
      'image': image,
      'price': price,
      'category': realCategory,
    };
  }
  
  /// Creates a copy of this [ItemModel] with the given fields replaced with new values.
  ItemModel copyWith({
    int? id,
    String? title,
    String? body,
    String? status,
    DateTime? date,
  }) {
    return ItemModel(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      status: status ?? this.status,
      date: date ?? this.date,
    );
  }
}
