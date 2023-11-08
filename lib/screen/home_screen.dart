// ignore_for_file: iterable_contains_unrelated_type

import 'package:face_store/model/product.dart';
import 'package:face_store/screen/product_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:skeleton_loader/skeleton_loader.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  String title = "Home";
  List<Product> products = [];
  List<Cart> carts = [];
  List<Favortite> favorites = [];
  double priceTotal = 0.00;
  bool _isCheckAll = false;
  int countChecked = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    updateUI();
    _tabController = TabController(
        length: 3, vsync: this); // Adjust the length as per your tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> updateUI() async {
    List<Product>? temp = await Product.getProducts();
    if (temp != null) {
      setState(() {
        products = temp;
        _isLoading = false;
      });
    }
  }

  int qtyCart(int productID) {
    if (carts.any((item) => item.id == productID)) {
      return carts[carts.indexWhere((item) => item.id == productID)].qty;
    }
    return 0;
  }

  Widget gridView() {
    if (products.isNotEmpty) {
      return Expanded(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: RefreshIndicator(
            onRefresh: () async {
              // updateUI();
            },
            child: GridView.builder(
              shrinkWrap: true,
              physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics()),
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200,
                childAspectRatio: 0.725,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () async {
                    ProductDetail? temp = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ProductScreen(
                                product: products[index],
                                isFavortite: favorites.any(
                                    (item) => item.id == products[index].id),
                                isAddCart: carts.any(
                                    (item) => item.id == products[index].id),
                                qty: qtyCart(products[index].id),
                              )),
                    );
                    if (temp != null) {
                      if (temp.isFavorite!) {
                        if (favorites.every((item) => item.id != temp.id)) {
                          setState(() {
                            favorites.add(Favortite(
                              id: temp.id,
                              latLng: temp.latLng!,
                              dateTime: temp.dateTime!,
                            ));
                          });
                        }
                      } else {
                        setState(() {
                          favorites.removeWhere((item) => item.id == temp.id);
                        });
                      }
                      if (temp.isEdit!) {
                        setState(() {
                          products[index] = temp.product!;
                        });
                      }
                      if (temp.isDelete!) {
                        setState(() {
                          products.removeWhere((item) => item.id == temp.id);
                        });
                      }
                      if (temp.isAddCart! && temp.qty! > 0) {
                        carts.add(
                            Cart(id: temp.id, qty: temp.qty!, selected: false));
                      } else {
                        setState(() {
                          carts.removeWhere((item) => item.id == temp.id);
                        });
                      }
                    }
                  },
                  child: Card(
                    elevation: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 150, // Fixed height for the image
                          width:
                              double.infinity, // Width to cover the entire card
                          child: Image.network(
                            products[index].image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                              child: Text("Error loading image"),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Flexible(
                                    child: Text(
                                      products[index].title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Text(
                                  "\$${products[index].price}",
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              Icon(favorites.any(
                                      (item) => item.id == products[index].id)
                                  ? Icons.favorite
                                  : null)
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("No data"),
            ElevatedButton(
              onPressed: () {
                updateUI();
              },
              child: const Text("Refresh"),
            ),
          ],
        ),
      );
    }
  }

  void showAlertDeleteCart(Product product) {
    showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
              title: const Text('Delete cart'),
              content: StatefulBuilder(
                  builder: (BuildContext context, StateSetter setState) {
                // return Column(mainAxisSize: MainAxisSize.max, children: []);
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Delete: ${product.title}"),
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
                      setState(() {
                        carts.removeWhere((item) => item.id == product.id);
                      });
                      updateTotal();
                      Navigator.pop(context);
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

  Widget listViewCart() {
    if (carts.isNotEmpty) {
      List<Widget> list = [];
      for (var product in products) {
        if (carts.any((item) => item.id == product.id)) {
          var cart = carts.firstWhere((i) => i.id == product.id);
          var l = GestureDetector(
            onTap: () async {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.4),
                    spreadRadius: 0.5,
                    blurRadius: 1,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.image,
                      fit: BoxFit.cover,
                      width: 67,
                      height: 100,
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: SizedBox(
                      width: 100,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: const TextStyle(fontSize: 18),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            children: [
                              Text(
                                "\$${product.price}",
                                style: const TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(children: [
                                IconButton(
                                    onPressed: () {
                                      if (cart.qty > 1) {
                                        setState(() {
                                          if (cart.qty > 0) {
                                            cart.qty--;
                                          }
                                        });
                                        updateTotal();
                                      } else {
                                        showAlertDeleteCart(product);
                                      }
                                    },
                                    icon: const Icon(Icons.remove)),
                                Text(
                                  "${cart.qty}",
                                  style: const TextStyle(fontSize: 20),
                                ),
                                IconButton(
                                    onPressed: () {
                                      setState(() {
                                        cart.qty++;
                                      });
                                      updateTotal();
                                    },
                                    icon: const Icon(Icons.add))
                              ]),
                              Row(
                                children: [
                                  IconButton(
                                    iconSize: 30,
                                    color: Colors.red,
                                    onPressed: () {
                                      showAlertDeleteCart(product);
                                    },
                                    icon: const Icon(Icons.delete),
                                  ),
                                  Checkbox(
                                      value: cart.selected,
                                      onChanged: (bool? value) {
                                        setState(() {
                                          carts[carts.indexWhere(
                                                  (item) => item.id == cart.id)]
                                              .selected = value ?? false;
                                        });
                                        updateTotal();
                                      })
                                ],
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
          list.add(l);
        }
      }

      return Column(
        children: [
          const Divider(),
          carts.isNotEmpty
              ? Padding(
                  padding: const EdgeInsets.only(right: 15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      const Text(
                        "Select all",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(width: 5),
                      Checkbox(
                          value: _isCheckAll,
                          onChanged: (bool? value) {
                            setState(() {
                              _isCheckAll = value ?? false;
                              if (_isCheckAll) {
                                for (var c in carts) {
                                  c.selected = true;
                                }
                              } else {
                                for (var c in carts) {
                                  c.selected = false;
                                }
                              }
                            });
                            updateTotal();
                          }),
                    ],
                  ),
                )
              : const SizedBox(),
          Expanded(
              child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: RefreshIndicator(
              onRefresh: () async {},
              child: ListView(
                shrinkWrap: true,
                physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics()),
                children: list,
              ),
            ),
          )),
        ],
      );
    }
    return const Center(child: Text("No data"));
  }

  Widget listViewFavorite() {
    List<Widget> list = [];
    for (var product in products) {
      if (favorites.any((item) => item.id == product.id)) {
        var favorite = favorites.firstWhere((i) => i.id == product.id);
        var l = GestureDetector(
          onTap: () async {},
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.4),
                  spreadRadius: 0.5,
                  blurRadius: 1,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.image,
                    fit: BoxFit.cover,
                    width: 67,
                    height: 100,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: SizedBox(
                    width: 100,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.left,
                          style: const TextStyle(fontSize: 18),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        Row(
                          children: [
                            Text(
                              "\$${product.price}",
                              style: const TextStyle(fontSize: 20),
                            ),
                          ],
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            IconButton(
                              iconSize: 30,
                              onPressed: () {
                                DateFormat('yyyy-MM-dd HH:mm:ss')
                                    .format(favorite.dateTime);
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('Detail'),
                                          content: StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            // return Column(mainAxisSize: MainAxisSize.max, children: []);
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text(
                                                    "DateTime: ${DateFormat('yyyy-MM-dd HH:mm:ss').format(favorite.dateTime)}"),
                                                Text(
                                                    "Lat: ${favorite.latLng.latitude}"),
                                                Text(
                                                    "Lng: ${favorite.latLng.longitude}")
                                              ],
                                            );
                                          }),
                                          actions: [
                                            TextButton(
                                                style: TextButton.styleFrom(
                                                  foregroundColor: Colors.white,
                                                  backgroundColor: Colors.grey,
                                                ),
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                child: const Text('Cancel')),
                                          ],
                                        ));
                              },
                              icon: const Icon(Icons.more_horiz),
                            ),
                            IconButton(
                              iconSize: 30,
                              color: Colors.red,
                              onPressed: () {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                          title: const Text('Delete'),
                                          content: StatefulBuilder(builder:
                                              (BuildContext context,
                                                  StateSetter setState) {
                                            // return Column(mainAxisSize: MainAxisSize.max, children: []);
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Text("Remove ${product.title}"),
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
                                                  setState(() {
                                                    favorites.removeWhere(
                                                        (item) =>
                                                            item.id ==
                                                            product.id);
                                                  });
                                                  Navigator.pop(context);
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
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        );
        list.add(l);
      }
    }
    if (list.isNotEmpty) {
      return Expanded(
          child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: RefreshIndicator(
          onRefresh: () async {},
          child: ListView(
            shrinkWrap: true,
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            children: list,
          ),
        ),
      ));
    }

    return const Center(child: Text("No data"));
  }

  void updateTotal() {
    if (carts.isNotEmpty) {
      priceTotal = 0;
      countChecked = 0;
      for (var i in carts) {
        if (i.selected) {
          countChecked++;
          priceTotal = priceTotal +
              (products[products.indexWhere((product) => product.id == i.id)]
                      .price *
                  i.qty);
        }
      }
      if (countChecked == carts.length) {
        setState(() {
          _isCheckAll = true;
        });
      } else {
        setState(() {
          _isCheckAll = false;
        });
      }
    } else {
      priceTotal = 0.00;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        bottom: _selectedIndex == 1
            ? AppBar(
                title: Row(
                  children: [
                    const Text(
                      "Total    ",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Text(
                      "\$${priceTotal.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.redAccent),
                    ),
                  ],
                ),
                actions: [
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(),
                    child: Text("Buy ($countChecked)"),
                  ),
                  const SizedBox(width: 10),
                ],
              )
            : null,
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _isLoading ? gridLoader() : gridView(),
          _isLoading ? listLoader() : listViewCart(),
          _isLoading ? listLoader() : listViewFavorite(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        // selectedFontSize: 15,
        // selectedIconTheme: IconThemeData(
        //     color: _selectedIndex != 2 ? Colors.white : Colors.red, size: 35),
        // selectedItemColor: _selectedIndex != 2 ? Colors.white : Colors.red,
        // unselectedItemColor: Colors.white70,
        // iconSize: 24,
        currentIndex: _selectedIndex,
        onTap: (int index) {
          setState(() {
            _selectedIndex = index;
            _tabController.index = index;
            if (index == 0) {
              title = "Home";
            } else if (index == 1) {
              title = "Carts";
              updateTotal();
            } else {
              title = "Favorites";
            }
          });
        },
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget gridLoader() {
    var loader = SingleChildScrollView(
      child: SkeletonGridLoader(
        builder: Card(
          color: Colors.transparent,
          child: GridTile(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  width: 50,
                  height: 10,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                Container(
                  width: 70,
                  height: 10,
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ),
        items: 8,
        itemsPerRow: 2,
        period: const Duration(seconds: 2),
        highlightColor: Colors.deepPurple,
        direction: SkeletonDirection.ltr,
        childAspectRatio: 1,
      ),
    );
    return loader;
  }

  Widget listLoader() {
    var loader = Expanded(
      child: RefreshIndicator(
        onRefresh: () async {
          // updateUI();
        },
        child: SingleChildScrollView(
          child: SkeletonLoader(
            builder: Container(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: <Widget>[
                  const CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      children: <Widget>[
                        Container(
                          width: double.infinity,
                          height: 10,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          height: 12,
                          color: Colors.white,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            items: 10,
            period: const Duration(seconds: 2),
            highlightColor: Colors.deepPurple,
            direction: SkeletonDirection.ltr,
          ),
        ),
      ),
    );
    return loader;
  }
}
