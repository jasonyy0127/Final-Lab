import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:barter_it/Model/order.dart';
import 'package:barter_it/Model/orderdetails.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
// ignore: depend_on_referenced_packages
import 'package:http/http.dart' as http;

class BuyerOrderHistoryDetails extends StatefulWidget {
  final Order order;
  const BuyerOrderHistoryDetails({super.key, required this.order});

  @override
  State<BuyerOrderHistoryDetails> createState() =>
      _BuyerOrderHistoryDetailsState();
}

class _BuyerOrderHistoryDetailsState extends State<BuyerOrderHistoryDetails> {
  List<OrderDetails> orderdetailsList = <OrderDetails>[];
  late double screenHeight, screenWidth;
  late User user = User(
      id: "na",
      name: "na",
      email: "na",
      phone: "na",
      datereg: "na",
      password: "na",
      otp: "na");
  String picuploc = "Not selected";
  bool enabled = false;

  @override
  void initState() {
    super.initState();
    loadbuyer();
    loadorderdetails();
    Timer(
        const Duration(seconds: 3),
        () => setState(() {
              enabled = true;
            }));
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order History"),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: Column(children: [
        SizedBox(
          height: screenHeight / 5.5,
          child: Card(
              shape: Border.all(width: 3),
              color: const Color.fromARGB(255, 92, 173, 239),
              child: Row(mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    width: screenWidth * 0.3,
                    child: Image.asset(
                      "assets/images/user.png",
                    ),
                  ),
                  Column(
                    children: [
                      user.id == "na"
                          ? const Center(
                              child: Text("Loading..."),
                            )
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(8, 16, 8, 16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Buyer name: ${user.name}",
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                  Text("Phone: ${user.phone}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                      )),
                                  Text("Order ID: ${widget.order.orderId}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                      )),
                                  Text(
                                    "Total Paid: RM ${double.parse(widget.order.orderPaid.toString()).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text("Status: ${widget.order.orderStatus}",
                                      style: const TextStyle(
                                        fontSize: 14,
                                      )),
                                ],
                              ),
                            )
                    ],
                  )
                ],
              )),
        ),
        Container(
            padding: const EdgeInsets.all(8),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton(
                        onPressed: enabled
                            ? () {
                                loadMapDialog();
                              }
                            : null,
                        child: const Text("See Pickup Location")),
                  ],
                ),
                SizedBox(
                  height: 80,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Text("Pick Up Address:",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(widget.order.orderPickUpAddress.toString(),
                                textAlign: TextAlign.justify),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )),
        orderdetailsList.isEmpty
            ? Container()
            : Expanded(
                flex: 7,
                child: ListView.builder(
                    itemCount: orderdetailsList.length,
                    itemBuilder: (context, index) {
                      return Card(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Row(children: [
                            CachedNetworkImage(
                              width: screenWidth / 3,
                              fit: BoxFit.cover,
                              imageUrl:
                                  "https://uumitproject.com/barterIt/assets/items/${orderdetailsList[index].itemId}.1.png",
                              placeholder: (context, url) =>
                                  const LinearProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    orderdetailsList[index].itemName.toString(),
                                    style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Quantity: ${orderdetailsList[index].orderdetailQty}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Paid: RM ${double.parse(orderdetailsList[index].orderdetailPaid.toString()).toStringAsFixed(2)}",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            )
                          ]),
                        ),
                      );
                    })),
      ]),
    );
  }

  void loadbuyer() {
    http.post(
        Uri.parse("https://uumitproject.com/barterIt/buyer/load_user.php"),
        body: {
          "userid": widget.order.buyerId,
        }).then((response) {
      log(response.body);
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == 'success') {
          user = User.fromJson(jsondata['data']);
        }
      }
      setState(() {});
    });
  }

  void loadorderdetails() {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/load_buyer_orderdetails.php"),
        body: {
          "buyerid": widget.order.buyerId,
          "orderbill": widget.order.orderBill,
          "sellerid": widget.order.sellerId
        }).then((response) {
      log(response.body);
      //orderList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          var extractdata = jsondata['data'];
          extractdata['orderdetails'].forEach((v) {
            orderdetailsList.add(OrderDetails.fromJson(v));
          });
        } else {
          // status = "Please register an account first";
          // setState(() {});
        }
        setState(() {});
      }
    });
  }

  void loadMapDialog() {
    MapController mapcontroller = MapController(
      initPosition: GeoPoint(
        latitude: double.parse(widget.order.orderLat.toString()),
        longitude: double.parse(widget.order.orderLong.toString()),
      ),
      areaLimit: BoundingBox(
        east: 10.4922941,
        north: 47.8084648,
        south: 45.817995,
        west: 5.9559113,
      ),
    );
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return OSMFlutter(
          controller: mapcontroller,
          userTrackingOption: const UserTrackingOption(
            enableTracking: true,
            unFollowUser: false,
          ),
          initZoom: 13,
          minZoomLevel: 8,
          maxZoomLevel: 15,
          enableRotationByGesture: true,
          userLocationMarker: UserLocationMaker(
            personMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin,
                color: Colors.blue,
                size: 150,
              ),
            ),
            directionArrowMarker: const MarkerIcon(
              icon: Icon(
                color: Colors.red,
                Icons.pin_drop,
                size: 150,
              ),
            ),
          ),
        );
      },
    ).then((val) {
      setState(() {});
    });
  }
}
