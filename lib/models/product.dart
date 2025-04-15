class Product {
  final int productId;
  final int productTypeId;
  final String nameProduct;
  final double price;
  final String avatarImageProduct;
  final String title;
  final int quantityOrder;
  final int numberOfViews;
  final int quantity;
  final double discount;
  final String shortDescription;
  final String fullDescription;
  final int status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final dynamic productType; // Có thể thay đổi kiểu nếu cần
  final dynamic productImages; // Có thể thay đổi kiểu nếu cần
  final dynamic productReviews; // Có thể thay đổi kiểu nếu cần
  final dynamic orderDetails; // Có thể thay đổi kiểu nếu cần

  Product({
    required this.productId,
    required this.productTypeId,
    required this.nameProduct,
    required this.price,
    required this.avatarImageProduct,
    required this.title,
    required this.quantityOrder,
    required this.numberOfViews,
    required this.quantity,
    required this.discount,
    required this.shortDescription,
    required this.fullDescription,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.productType,
    this.productImages,
    this.productReviews,
    this.orderDetails,
  });

  // Factory constructor để chuyển từ Map thành Product
  factory Product.fromJson(Map<dynamic, dynamic> json) {
    return Product(
      productId: json['productId'] as int,
      productTypeId: json['productTypeId'] as int,
      nameProduct: json['nameProduct'] as String,
      price: (json['price'] as num).toDouble(),
      avatarImageProduct: json['avartarImageProduct'] as String,
      title: json['title'] as String,
      quantityOrder: json['quantityOrder'] as int,
      numberOfViews: json['number_of_views'] as int,
      quantity: json['quantity'] as int,
      discount: (json['discount'] as num).toDouble(),
      shortDescription: json['shortDescription'] as String,
      fullDescription: json['fullDescription'] as String,
      status: json['status'] as int,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      productType: json['productType'],
      productImages: json['productImages'],
      productReviews: json['productReviews'],
      orderDetails: json['orderDetails'],
    );
  }

  // Phương thức để chuyển Product thành Map (nếu cần lưu trữ hoặc gửi dữ liệu)
  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'productTypeId': productTypeId,
      'nameProduct': nameProduct,
      'price': price,
      'avartarImageProduct': avatarImageProduct,
      'title': title,
      'quantityOrder': quantityOrder,
      'number_of_views': numberOfViews,
      'quantity': quantity,
      'discount': discount,
      'shortDescription': shortDescription,
      'fullDescription': fullDescription,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'productType': productType,
      'productImages': productImages,
      'productReviews': productReviews,
      'orderDetails': orderDetails,
    };
  }
}