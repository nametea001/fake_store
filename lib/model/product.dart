import 'package:face_store/services/networking.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Product {
  int id;
  String title;
  double price;
  String description;
  String category;
  String image;
  Rating rating;
  Product({
    required this.id,
    required this.title,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
    required this.rating,
  });

  static Future<List<Product>?> getProducts() async {
    NetworkHelper networkHelper = NetworkHelper('products', {});
    List<Product> products = [];
    var json = await networkHelper.getData();
    if (json != null) {
      for (Map p in json) {
        Product product = Product(
            id: p['id'],
            title: p['title'],
            price: p['price'].toDouble(),
            description: p['description'],
            category: p['category'],
            image: p['image'],
            rating: Rating(
              rate: (p['rating']['rate']).toDouble(),
              count: p['rating']['count'],
            ));
        products.add(product);
      }
      return products;
    }
    return null;
  }
}

class Rating {
  double rate;
  int count;
  Rating({required this.rate, required this.count});
}

class ProductDetail {
  int id;
  bool? isFavorite;
  bool? isEdit;
  bool? isDelete;
  bool? isAddCart;
  LatLng? latLng;
  Product? product;
  DateTime? dateTime;
  int? qty;

  ProductDetail({
    required this.id,
    this.isFavorite,
    this.isEdit,
    this.isDelete,
    this.isAddCart,
    this.latLng,
    this.dateTime,
    this.product,
    this.qty,
  });
}

class Cart {
  int id;
  int qty;
  bool selected;
  Cart({required this.id, required this.qty, required this.selected});
}

class Favortite {
  int id;
  LatLng latLng;
  DateTime dateTime;
  Favortite({required this.id, required this.latLng, required this.dateTime});
}
