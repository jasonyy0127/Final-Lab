import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:barter_it/MainPage/Seller/sellerorderdetailspage.dart';
import 'package:barter_it/Model/order.dart';
import 'package:barter_it/Model/user.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class SellerOrderPage extends StatefulWidget {
  final User user;
  const SellerOrderPage({super.key, required this.user});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  String status = "Loading...";
  List<Order> orderList = <Order>[];
  late double screenHeight, screenWidth, cardwidth;

  @override
  void initState() {
    super.initState();
    loadsellerorders();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Your Sale/s"),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: Container(
        child: orderList.isEmpty
            ? Container()
            : Column(
                children: [
                  SizedBox(
                    width: screenWidth,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      child: Row(
                        children: [
                          Flexible(
                              flex: 7,
                              child: Row(
                                children: [
                                  // CachedNetworkImage(
                                  //     imageBuilder: (context, imageProvider) =>
                                  //         Container(
                                  //           height: 50,
                                  //           width: 50,
                                  //           decoration: BoxDecoration(
                                  //             borderRadius:
                                  //                 const BorderRadius.all(
                                  //                     Radius.circular(100)),
                                  //             image: DecorationImage(
                                  //               image: imageProvider,
                                  //               fit: BoxFit.cover,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //     imageUrl:
                                  //         "https://uumitproject.com/barterIt/assets/profile_pics/${widget.user.id}.png",
                                  //     placeholder: (context, url) =>
                                  //         const LinearProgressIndicator(),
                                  //     errorWidget: (context, url, error) =>
                                  //         const Icon(
                                  //           Icons.image_not_supported,
                                  //           size: 64,
                                  //         )),
                                  const CircleAvatar(
                                    backgroundImage: AssetImage(
                                      "assets/images/user.png",
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text(
                                    "Hello ${widget.user.name}!",
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              )),
                          Expanded(
                            flex: 3,
                            child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.notifications),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.search),
                                    onPressed: () {},
                                  ),
                                ]),
                          )
                        ],
                      ),
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Your Current Order/s (${orderList.length})",
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.menu),
                          onPressed: () {},
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                      child: ListView.builder(
                          itemCount: orderList.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              onTap: () async {
                                Order myorder =
                                    Order.fromJson(orderList[index].toJson());
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (content) =>
                                            SellerOrderDetailsPage(
                                              order: myorder,
                                            )));
                                loadsellerorders();
                              },
                              leading: CircleAvatar(
                                  child: Text((index + 1).toString())),
                              title: Text(
                                  "Receipt: ${orderList[index].orderBill}"),
                              trailing: const Icon(Icons.arrow_forward),
                              subtitle: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Order ID: ${orderList[index].orderId}"),
                                        Text(
                                            "Status: ${orderList[index].orderStatus}")
                                      ]),
                                  Column(
                                    children: [
                                      Text(
                                        "RM ${double.parse(orderList[index].orderPaid.toString()).toStringAsFixed(2)}",
                                        style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text("")
                                    ],
                                  )
                                ],
                              ),
                            );
                          })),
                ],
              ),
      ),
    );
  }

  void loadsellerorders() {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/seller/load_seller_order.php"),
        body: {"sellerid": widget.user.id}).then((response) {
      log(response.body);
      //orderList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          orderList.clear();
          var extractdata = jsondata['data'];
          extractdata['orders'].forEach((v) {
            orderList.add(Order.fromJson(v));
          });
        } else {
          Timer(
            const Duration(seconds: 2),
            () {
              Navigator.of(context).pop();
              Fluttertoast.showToast(
                  msg: "No order available",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 1,
                  fontSize: 16.0);
              // status = "Please register an account first";
              // setState(() {});
            },
          );
        }
        setState(() {});
      }
    });
  }
}
