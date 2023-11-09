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
  final formKey = GlobalKey<FormState>();
  bool _isFavortite = false;
  bool _isEdit = false;
  bool _isDelete = false;
  bool _isAddCart = false;
  bool _isShowMoreDescription = false;
  late Product product;
  Position? location;
  DateTime? dateTime;
  int qty = 0;

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _imageController = TextEditingController();

  @override
  void initState() {
    _getLocation();
    product = widget.product;
    _isFavortite = widget.isFavortite;
    _isAddCart = widget.isAddCart;
    qty = widget.qty;
    super.initState();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    _descriptionController.dispose();
    _imageController.dispose();
    super.dispose();
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

  void showAlertEdit() {
    _titleController.text = product.title;
    _priceController.text = "${product.price}";
    _categoryController.text = product.category;
    _descriptionController.text = product.description;
    _imageController.text = product.image;
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Edit product'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          maxLines: 2,
                          controller: _titleController,
                          onSaved: ((newValue) {
                            product.title = newValue!.trim();
                          }),
                          validator: (String? str) {
                            if (str!.isEmpty) {
                              return "Please input title";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Title",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: const Icon(
                              Icons.title,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          keyboardType: TextInputType.number,
                          controller: _priceController,
                          onSaved: ((newValue) {
                            double d = double.parse(newValue!.trim());
                            product.price = double.parse(d.toStringAsFixed(2));
                          }),
                          validator: (String? str) {
                            if (str!.isEmpty) {
                              return "Please input price";
                            }
                            if (double.parse(str) < 0) {
                              return "Please price error";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Price",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: const Icon(
                              Icons.payments,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _categoryController,
                          onSaved: ((newValue) {
                            product.category = newValue!.trim();
                          }),
                          validator: (String? str) {
                            if (str!.isEmpty) {
                              return "Please input category";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Category",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: const Icon(
                              Icons.category,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _imageController,
                          onSaved: ((newValue) {
                            product.image = newValue!.trim();
                          }),
                          validator: (String? str) {
                            if (str!.isEmpty) {
                              return "Please input URL";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Image URL",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: const Icon(
                              Icons.link,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          maxLines: 5,
                          controller: _descriptionController,
                          onSaved: ((newValue) {
                            product.description = newValue!.trim();
                          }),
                          validator: (String? str) {
                            if (str!.isEmpty) {
                              return "Please input title";
                            }
                            return null;
                          },
                          decoration: InputDecoration(
                            labelText: "Description",
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            prefixIcon: const Icon(
                              Icons.description,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              actions: [
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        formKey.currentState!.save();
                        _isEdit = true;
                        setState(() {
                          product = product;
                        });
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Save')),
                TextButton(
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('Cancel')),
              ],
            ));
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
                    Text("Delete ${product.title}"),
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
      // ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      //   content: Center(child: Text("Getting location")),
      // ));
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
                showAlertEdit();
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
              product.image,
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
                    product.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${product.price}',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingBarIndicator(
                        rating: product.rating.rate,
                        itemCount: 5,
                        itemSize: 20,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "${product.rating.rate}",
                        style: const TextStyle(
                          fontSize: 16,
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
                        "Sold ${product.rating.count} pieces",
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
                            product.category,
                            style: const TextStyle(
                                fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ]),
                  ),
                  const Divider(),
                  const SizedBox(height: 8),
                  Flexible(
                    child: Text(
                      product.description,
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
