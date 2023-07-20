import 'dart:convert';
import 'dart:developer';

import 'package:barter_it/MainPage/Buyer/buyerdetailspage.dart';
import 'package:barter_it/Model/item.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class BuyerMorePage extends StatefulWidget {
  final Item buyeritem;
  final User user;
  const BuyerMorePage({super.key, required this.buyeritem, required this.user});
  @override
  State<BuyerMorePage> createState() => _BuyerMorePageState();
}

class _BuyerMorePageState extends State<BuyerMorePage> {
  List<Item> itemList = <Item>[];
  int numberofresult = 0;
  late double screenHeight, screenWidth, cardwitdh;
  late User seller = User(
      id: "na",
      name: "na",
      email: "na",
      phone: "na",
      datereg: "na",
      password: "na",
      otp: "na");

  @override
  void initState() {
    super.initState();
    loadSellerItems();
    loadSeller();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("More from "),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: Column(
        children: [
          SizedBox(
              height: screenHeight / 8,
              width: screenWidth,
              child: Card(
                  shape: Border.all(width: 3),
                  color: const Color.fromARGB(255, 92, 173, 239),
                  child: seller.name == "na"
                      ? const Center(child: Text("Loading..."))
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CachedNetworkImage(
                                imageBuilder: (context, imageProvider) =>
                                    Container(
                                      height: 50,
                                      width: 50,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(100)),
                                        image: DecorationImage(
                                          image: imageProvider,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                imageUrl:
                                    "https://uumitproject.com/barterIt/assets/profile_pics/${seller.id}.png",
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                      Icons.image_not_supported,
                                      size: 64,
                                    )),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Store Owner\n${seller.name}",
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                          ],
                        ))),
          const Divider(),
          itemList.isEmpty
              ? Container()
              : Expanded(
                  child: GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(itemList.length, (index) {
                        return Card(
                          child: InkWell(
                            onTap: () async {
                              Item useritem =
                                  Item.fromJson(itemList[index].toJson());
                              await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (content) => BuyerDetailsPage(
                                            user: widget.user,
                                            buyeritem: useritem,
                                            page: 1,
                                          )));
                              //loaditems();
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
                      })))
        ],
      ),
    );
  }

  void loadSellerItems() {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/load_singleseller.php"),
        body: {
          "sellerid": widget.buyeritem.userId,
        }).then((response) {
      //print(response.body);
      //log(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          var extractdata = jsondata['data'];
          extractdata['items'].forEach((v) {
            itemList.add(Item.fromJson(v));
          });
        }
        setState(() {});
      }
    });
  }

  void loadSeller() {
    http.post(
        Uri.parse("https://uumitproject.com/barterIt/buyer/load_user.php"),
        body: {
          "userid": widget.buyeritem.userId,
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          seller = User.fromJson(jsondata['data']);
        }
      }
      setState(() {});
    });
  }
}
