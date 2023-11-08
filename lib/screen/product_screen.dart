// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:face_store/model/product.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ProductScreen extends StatefulWidget {
  final Product product;
  final bool isFavortite;
  final bool isAddCart;
  final int qty;
  const ProductScreen({
    super.key,
    required this.product,
    required this.isFavortite,
    required this.isAddCart,
    required this.qty,
  });

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _isFavortite = false;
  bool _isEdit = false;
  bool _isDelete = false;
  bool _isAddCart = false;
  bool _isShowMoreDescription = false;
  Product? product;
  Position? location;
  DateTime? dateTime;
  int qty = 0;

  @override
  void initState() {
    _getLocation();
    product = widget.product;
    _isFavortite = widget.isFavortite;
    _isAddCart = widget.isAddCart;
    qty = widget.qty;
    super.initState();
  }

  Future<void> _getLocation() async {
    bool serviceEnabled = false;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error("Location services are disabled.");
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error("Location permissions are denied.");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          "Location permissions are permanently denied, we cannot request permissions.");
    }

    location = await Geolocator.getCurrentPosition();
  }

  void showAlertDelete() {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Delete ${product!.title}"),
                  ],
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      _isDelete = true;
                      Navigator.pop(context);
                      popScreen();
                    },
                    child: const Text('Delete')),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            ));
  }

  void popScreen() {
    LatLng? latLng;
    try {
      latLng = LatLng(location!.latitude, location!.longitude);
    } catch (err) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Center(child: Text("Get location Fail")),
      ));
      Timer(const Duration(seconds: 1), () {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      });
    }
    Navigator.pop(
        context,
        ProductDetail(
          id: widget.product.id,
          isFavorite: _isFavortite,
          isEdit: _isEdit,
          isDelete: _isDelete,
          isAddCart: _isAddCart,
          product: product,
          latLng: latLng,
          dateTime: dateTime,
          qty: qty,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurple,
        leading: IconButton(
          onPressed: () async {
            popScreen();
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        actions: [
          PopupMenuButton(
            color: Colors.white,
            onSelected: (String value) {
              if (value == "edit") {
              } else {
                showAlertDelete();
              }
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem<String>(
                    value: "edit",
                    child: Row(
                      children: [
                        Icon(Icons.edit),
                        SizedBox(width: 10),
                        Text("Edit")
                      ],
                    )),
                const PopupMenuItem<String>(
                    value: "delete",
                    child: Row(
                      children: [
                        Icon(Icons.delete),
                        SizedBox(width: 10),
                        Text("Delete")
                      ],
                    ))
              ];
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Image.network(
              widget.product.image,
              height: MediaQuery.of(context).size.height / 2,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  const Center(child: Text("Error")),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${widget.product.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: widget.product.rating.rate,
                        itemCount: 5,
                        itemSize: 25,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${widget.product.rating.rate}",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 7),
                      const Text(
                        "|",
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        "Sold ${widget.product.rating.count} pieces",
                        style: const TextStyle(
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      IconButton(
                        onPressed: () async {
                          try {
                            if (location != null) {
                              setState(() {
                                _isFavortite = !_isFavortite;
                              });
                              if (_isFavortite) {
                                dateTime = DateTime.now();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Center(child: Text("Add to favortites")),
                                ));
                                Timer(const Duration(seconds: 1), () {
                                  ScaffoldMessenger.of(context)
                                      .hideCurrentSnackBar();
                                });
                              }
                            } else {
                              setState(() {
                                _isFavortite = false;
                              });
                            }
                          } catch (err) {
                            setState(() {
                              _isFavortite = false;
                            });
                            ScaffoldMessenger.of(context)
                                .showSnackBar(const SnackBar(
                              content: Center(
                                  child: Text(
                                      "Location permissions are permanently denied, we cannot request permissions.")),
                            ));
                          }
                        },
                        // icon: Icon(_isFavortite
                        //     ? Icons.favorite
                        //     : Icons.favorite_outline)
                        icon: _isFavortite
                            ? const Icon(
                                Icons.favorite,
                                color: Colors.redAccent,
                              )
                            : const Icon(Icons.favorite_outline),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            "Category",
                            style: TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.product.category,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      widget.product.description,
                      maxLines: _isShowMoreDescription ? null : 3,
                      overflow:
                          _isShowMoreDescription ? null : TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                setState(() {
                  _isShowMoreDescription = !_isShowMoreDescription;
                });
              },
              child: Column(
                children: [
                  const Divider(),
                  (_isShowMoreDescription
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Show less",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.deepOrange),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.expand_less,
                              color: Colors.deepOrange,
                            )
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Show more",
                              style: TextStyle(
                                  fontSize: 18, color: Colors.deepOrange),
                            ),
                            SizedBox(width: 10),
                            Icon(
                              Icons.expand_more,
                              color: Colors.deepOrange,
                            )
                          ],
                        )),
                  const Divider(),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
          child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            IconButton(
                onPressed: () {
                  setState(() {
                    if (qty > 0) {
                      qty--;
                    }
                  });
                },
                icon: const Icon(Icons.remove)),
            Text(
              "$qty",
              style: const TextStyle(fontSize: 20),
            ),
            IconButton(
                onPressed: () {
                  setState(() {
                    qty++;
                  });
                },
                icon: const Icon(Icons.add))
          ]),
          _isAddCart
              ? ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _isAddCart = false;
                    });
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.upload,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Remove from cart",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  ))
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _isAddCart = true;
                      if (qty == 0) {
                        qty++;
                      }
                    });
                  },
                  child: const Row(
                    children: [
                      Icon(
                        Icons.shopping_cart,
                        color: Colors.white,
                      ),
                      SizedBox(width: 5),
                      Text(
                        "Add to cart",
                        style: TextStyle(color: Colors.white),
                      )
                    ],
                  )),
        ],
      )),
    );
  }
}
