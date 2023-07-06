import 'dart:convert';

import 'package:barter_it/MainPage/editsellerdetails.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../Model/item.dart';
import '../Model/user.dart';
import 'newitempage.dart';

class SellerTab extends StatefulWidget {
  const SellerTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;
  @override
  State<SellerTab> createState() => _SellerTabState();
}

class _SellerTabState extends State<SellerTab> {
  late double screenHeight, screenWidth;
  late int axiscount = 2;
  late List<Widget> tabchildren;
  String maintitle = "Seller";
  List<Item> itemList = <Item>[];

  @override
  void initState() {
    super.initState();
    loadSellerItems(context);
    print("Seller");
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 600) {
      axiscount = 3;
    } else {
      axiscount = 2;
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(maintitle),
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: itemList.isEmpty
          ? const Center(
              child: Text("No Data"),
            )
          : RefreshIndicator(
              onRefresh: () async {
                loadSellerItems(context);
              },
              child: Column(children: [
                Container(
                  height: 24,
                  color: Colors.red,
                  alignment: Alignment.center,
                  child: Text(
                    "${itemList.length} Item Found",
                    style: const TextStyle(color: Colors.white, fontSize: 18),
                  ),
                ),
                Expanded(
                    child: GridView.count(
                        crossAxisCount: axiscount,
                        children: List.generate(
                          itemList.length,
                          (index) {
                            return Card(
                              child: InkWell(
                                onLongPress: () {
                                  onDeleteDialog(index);
                                },
                                onTap: () async {
                                  Item selleritem =
                                      Item.fromJson(itemList[index].toJson());
                                  await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (content) =>
                                              EditSellerDetails(
                                                user: widget.user,
                                                selleritem: selleritem,
                                              )));
                                  loadSellerItems(context);
                                },
                                child: Column(children: [
                                  CachedNetworkImage(
                                    width: screenWidth,
                                    fit: BoxFit.cover,
                                    imageUrl:
                                        "https://uumitproject.com/barterIt/assets/items/${itemList[index].itemId}.1.png",
                                    placeholder: (context, url) =>
                                        const LinearProgressIndicator(),
                                    errorWidget: (context, url, error) =>
                                        const Icon(Icons.error),
                                  ),
                                  Text(
                                    itemList[index].itemName.toString(),
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  Text(
                                    "RM ${double.parse(itemList[index].itemPrice.toString()).toStringAsFixed(2)}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  Text(
                                    "${itemList[index].itemQty} available",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ]),
                              ),
                            );
                          },
                        )))
              ]),
            ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Colors.blueAccent,
          onPressed: () async {
            await Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (content) => NewItemPage(
                          user: widget.user,
                        )));
            loadSellerItems(context);
          },
          child: const Text(
            "+",
            style: TextStyle(fontSize: 32),
          )),
    );
  }

  Future loadSellerItems(context) async {
    if (widget.user.id == "na") {
      setState(() {
        // titlecenter = "Unregistered User";
      });
      return;
    }

    var url = "https://uumitproject.com/barterIt/seller/load_item.php";
    var response =
        await http.post(Uri.parse(url), body: {"userid": widget.user.id});

    // print(response.body);
    //log(response.body);
    itemList.clear();
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "success") {
        var extractdata = jsondata['data'];
        extractdata['items'].forEach((v) {
          itemList.add(Item.fromJson(v));
        });
        print(itemList[0].itemQty);
        print(itemList[0].itemName);
      }
      setState(() {});
    }
  }

  void onDeleteDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext deletecontext) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: Text(
            "Delete ${itemList[index].itemName}?",
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                deleteItem(context, index);
                Navigator.of(deletecontext).pop();
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(deletecontext).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteItem(context, int index) async {
    var url = "https://uumitproject.com/barterIt/seller/delete_item.php";
    var response = await http.post(Uri.parse(url),
        body: {"userid": widget.user.id, "itemid": itemList[index].itemId});
    print(response.body);
    if (response.statusCode == 200) {
      var jsondata = jsonDecode(response.body);
      if (jsondata['status'] == "success") {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Delete Success")));
        loadSellerItems(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text("Failed")));
      }
    }
  }
}
