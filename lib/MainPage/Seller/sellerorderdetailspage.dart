import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:barter_it/Model/order.dart';
import 'package:barter_it/Model/orderdetails.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:open_street_map_search_and_pick/open_street_map_search_and_pick.dart';

class SellerOrderDetailsPage extends StatefulWidget {
  final Order order;
  const SellerOrderDetailsPage({super.key, required this.order});

  @override
  State<SellerOrderDetailsPage> createState() => _SellerOrderDetailsPageState();
}

class _SellerOrderDetailsPageState extends State<SellerOrderDetailsPage> {
  List<OrderDetails> orderdetailsList = <OrderDetails>[];
  late double screenHeight, screenWidth;
  String selectStatus = "New";
  List<String> statusList = [
    "New",
    "Processing",
    "Ready",
  ];
  late User user = User(
      id: "na",
      name: "na",
      email: "na",
      phone: "na",
      datereg: "na",
      password: "na",
      otp: "na");
  String picuploc = "Not selected";
  String pickupLat = "";
  String pickupLong = "";
  String pickupAddress = "";
  bool enabled = false;
  bool submitEnabled = false;

  final TextEditingController _prstateEditingController =
      TextEditingController();
  final TextEditingController _prlocalEditingController =
      TextEditingController();
  late Position _currentPosition;
  String curaddress = "";
  String curstate = "";
  String prlat = "";
  String prlong = "";

  @override
  void initState() {
    super.initState();
    loadbuyer();
    loadorderdetails();
    _determinePosition();
    selectStatus = widget.order.orderStatus.toString();
    Timer(
        const Duration(seconds: 3),
        () => setState(() {
              enabled = true;
            }));
    if (widget.order.orderLat.toString() == "") {
      picuploc = "Not selected";
    } else {
      picuploc = "Selected";
    }
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Order Details"),
        backgroundColor: const Color.fromARGB(255, 21, 42, 78),
      ),
      body: Column(children: [
        SizedBox(
          height: screenHeight / 5.5,
          child: Card(
              shape: Border.all(width: 3),
              color: const Color.fromARGB(255, 92, 173, 239),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // CachedNetworkImage(
                  //     imageBuilder: (context, imageProvider) => Container(
                  //           margin: const EdgeInsets.all(8),
                  //           height: 100,
                  //           width: 100,
                  //           decoration: BoxDecoration(
                  //             borderRadius:
                  //                 const BorderRadius.all(Radius.circular(100)),
                  //             image: DecorationImage(
                  //               image: imageProvider,
                  //               fit: BoxFit.cover,
                  //             ),
                  //           ),
                  //         ),
                  //     imageUrl:
                  //         "https://uumitproject.com/barterIt/assets/profile_pics/${widget.order.buyerId}.png",
                  //     errorWidget: (context, url, error) => const Icon(
                  //           Icons.image_not_supported,
                  //           size: 64,
                  //         )),
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
                                if (picuploc == "Selected") {
                                  _determinePosition();
                                  loadMapDialog();
                                } else {
                                  Fluttertoast.showToast(
                                      msg: "Location not available",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 1,
                                      fontSize: 16.0);
                                }
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
                      pickupAddress == ""
                          ? widget.order.orderPickUpAddress.toString().isEmpty
                              ? const Center(
                                  child: Text(
                                      "No location selected yet Previously"),
                                )
                              : Center(
                                  child: Column(
                                    children: [
                                      const Text("Pick Up Address:",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      Text(
                                          widget.order.orderPickUpAddress
                                              .toString(),
                                          textAlign: TextAlign.justify),
                                    ],
                                  ),
                                )
                          : Center(
                              child: Column(
                                children: [
                                  const Text("Address:",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(pickupAddress,
                                      textAlign: TextAlign.justify),
                                ],
                              ),
                            ),
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
        SizedBox(
          // color: Colors.red,
          width: screenWidth,
          height: screenHeight * 0.1,
          child: Card(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text("Set Order Status as"),
                  DropdownButton(
                    itemHeight: 60,
                    value: selectStatus,
                    onChanged: (newValue) {
                      setState(() {
                        selectStatus = newValue.toString();
                      });
                    },
                    items: statusList.map((selectStatus) {
                      return DropdownMenuItem(
                        value: selectStatus,
                        child: Text(
                          selectStatus,
                        ),
                      );
                    }).toList(),
                  ),
                  ElevatedButton(
                      onPressed: pickupAddress == "" &&
                              widget.order.orderPickUpAddress.toString().isEmpty
                          ? () {
                              Fluttertoast.showToast(
                                  msg: "No location selected",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 1,
                                  fontSize: 16.0);
                            }
                          : pickupAddress == "" &&
                                  widget.order.orderPickUpAddress
                                      .toString()
                                      .isNotEmpty
                              ? () {
                                  submitRemainStatusDialog();
                                }
                              : submitNewStatusDialog,
                      child: Text("Submit"))
                ]),
          ),
        )
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
            "https://uumitproject.com/barterIt/seller/load_seller_orderdetails.php"),
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
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          height: 800.0,
          child: OpenStreetMapSearchAndPick(
            center:
                LatLong(_currentPosition.latitude, _currentPosition.longitude),
            buttonColor: Colors.blue,
            buttonText: 'Set Current Location',
            onPicked: (pickedData) {
              Navigator.pop(context);
              pickupLat = pickedData.latLong.latitude.toString();
              pickupLong = pickedData.latLong.longitude.toString();
              pickupAddress = pickedData.address.toString();
              picuploc = "Selected";
            },
          ),
        );
      },
    ).then((val) {
      setState(() {});
    });
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    }
    _currentPosition = await Geolocator.getCurrentPosition();

    _getAddress(_currentPosition);
    //return await Geolocator.getCurrentPosition();
  }

  _getAddress(Position pos) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(pos.latitude, pos.longitude);
    if (placemarks.isEmpty) {
      _prlocalEditingController.text = "Not available";
      _prstateEditingController.text = "Not available";
      prlat = "Not available";
      prlong = "Not available";
    } else {
      _prlocalEditingController.text = placemarks[0].locality.toString();
      _prstateEditingController.text =
          placemarks[0].administrativeArea.toString();
      prlat = _currentPosition.latitude.toString();
      prlong = _currentPosition.longitude.toString();
    }
    setState(() {});
  }

  void submitNewStatus(String st) {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/set_orderstatus.php"),
        body: {
          "orderid": widget.order.orderId,
          "status": st,
          "address": pickupAddress,
          "lat": pickupLat,
          "long": pickupLong,
        }).then((response) {
      log(response.body);
      //orderList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
        } else {}
        widget.order.orderStatus = st;
        selectStatus = st;
        setState(() {});
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        Navigator.of(context).pop();
      }
    });
  }

  void submitNewStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Submit new status?",
            style: TextStyle(),
          ),
          content:
              const Text("This step cannot be reverted", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitNewStatus(selectStatus);
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void submitRemainStatus(String st) {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/set_orderstatus.php"),
        body: {
          "orderid": widget.order.orderId,
          "status": st,
          "address": widget.order.orderPickUpAddress,
          "lat": widget.order.orderLat,
          "long": widget.order.orderLong,
        }).then((response) {
      log(response.body);
      //orderList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
        } else {}
        widget.order.orderStatus = st;
        selectStatus = st;
        setState(() {});
        Fluttertoast.showToast(
            msg: "Success",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 1,
            fontSize: 16.0);
        Navigator.of(context).pop();
      }
    });
  }

  void submitRemainStatusDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          title: const Text(
            "Is the pick up location remain unchange?",
            style: TextStyle(),
          ),
          content: const Text("Are you sure?", style: TextStyle()),
          actions: <Widget>[
            TextButton(
              child: const Text(
                "Yes",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
                submitRemainStatus(selectStatus);
              },
            ),
            TextButton(
              child: const Text(
                "No",
                style: TextStyle(),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
