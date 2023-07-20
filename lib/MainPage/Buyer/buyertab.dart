import 'dart:convert';

import 'package:barter_it/MainPage/Buyer/buyerdetailspage.dart';
import 'package:barter_it/MainPage/Buyer/buyerorderhistory.dart';
import 'package:barter_it/MainPage/Buyer/buyerorderpage.dart';
import 'package:barter_it/Model/item.dart';
import 'package:barter_it/Model/user.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

import 'buyercartpage.dart';

class BuyerTab extends StatefulWidget {
  const BuyerTab({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;
  @override
  State<BuyerTab> createState() => _BuyerTabState();
}

class _BuyerTabState extends State<BuyerTab> {
  String maintitle = "Buyer";
  List<Item> itemList = <Item>[];
  late double screenHeight, screenWidth;
  late int axiscount = 2;
  String selectedOption = '';
  String option = '';
  int numofpage = 1, curpage = 1;
  int numberofresult = 0;
  var color;
  int cartqty = 0;
  int numberofcartitem = 0;
  String selectedType = "Tool";
  List<String> itemlist = [
    "Tool",
    "Clothing",
    "Food",
    "Other",
  ];

  TextEditingController searchController = TextEditingController();
  @override
  void initState() {
    super.initState();
    loadBuyerItems();
    print("Buyer");
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
        actions: [
          IconButton(
            onPressed: () {
              showfilterDialog();
            },
            icon: const Icon(Icons.filter_alt_outlined),
          ),
          IconButton(
              onPressed: () {
                showsearchDialog();
              },
              icon: const Icon(Icons.search)),
          TextButton.icon(
            icon: const Icon(
              Icons.shopping_cart,
            ), // Your icon here
            label: Text(numberofcartitem.toString()), // Your text here
            onPressed: () async {
              if (numberofcartitem > 0) {
                await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (content) => BuyerCartPage(
                              user: widget.user,
                            )));
                loadBuyerItems();
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("No item in cart")));
              }
            },
          ),
          PopupMenuButton(
              // add icon, by default "3 dot" icon
              // icon: Icon(Icons.book)
              itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("My Order"),
              ),
              const PopupMenuItem<int>(
                value: 1,
                child: Text("History"),
              ),
            ];
          }, onSelected: (value) async {
            if (value == 0) {
              if (widget.user.id.toString() == "na") {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text("Please login/register an account")));
                return;
              }
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (content) => BuyerOrderPage(
                            user: widget.user,
                          )));
            } else if (value == 1) {
              await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (content) => BuyerOrderHistory(
                            user: widget.user,
                          )));
            } else if (value == 2) {}
          }),
        ],
      ),
      body: itemList.isEmpty
          ? const Center(
              child: Text("No Data"),
            )
          : Column(children: [
              Container(
                height: 24,
                color: Theme.of(context).colorScheme.primary,
                alignment: Alignment.center,
                child: Text(
                  "$numberofresult Items On Sale",
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
                              onTap: () async {
                                Item userItem =
                                    Item.fromJson(itemList[index].toJson());
                                await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (content) => BuyerDetailsPage(
                                              user: widget.user,
                                              buyeritem: userItem,
                                              page: curpage,
                                            )));
                                loadBuyerItems();
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
                      ))),
              SizedBox(
                height: 50,
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: numofpage,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (context, index) {
                    //build the list for textbutton with scroll
                    if ((curpage - 1) == index) {
                      //set current page number active
                      color = Colors.red;
                    } else {
                      color = Colors.black;
                    }
                    return TextButton(
                        onPressed: () {
                          curpage = index + 1;
                          if (searchController.text.isNotEmpty) {
                            searchItem(searchController.text);
                          } else if (selectedOption.isNotEmpty &&
                              option.isNotEmpty) {
                            filterItem(option);
                          } else {
                            loadBuyerItems();
                          }
                        },
                        child: Text(
                          (index + 1).toString(),
                          style: TextStyle(color: color, fontSize: 18),
                        ));
                  },
                ),
              ),
            ]),
    );
  }

  void loadBuyerItems() {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/load_buyer_item.php"),
        body: {
          "cartuserid": widget.user.id,
          "pageno": curpage.toString()
        }).then((response) {
      //print(response.body);
      //log(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          numofpage = int.parse(jsondata['numofpage']); //get number of pages
          numberofresult = int.parse(jsondata['numberofresult']);
          var extractdata = jsondata['data'];
          cartqty = int.parse(jsondata['cartqty'].toString());
          numberofcartitem = int.parse(jsondata['numberofcartitem'].toString());
          extractdata['items'].forEach((v) {
            itemList.add(Item.fromJson(v));
          });
        }
        setState(() {});
      }
    });
  }

  void showsearchDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          titlePadding: EdgeInsets.all(0),
          title: _getCloseButton(context),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            const Text(
              "Enter search keyword",
              style: TextStyle(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                  fontStyle: FontStyle.normal),
              textAlign: TextAlign.center,
            ),
            TextField(
                controller: searchController,
                decoration: const InputDecoration(
                    labelText: 'Search',
                    labelStyle: TextStyle(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(width: 2.0),
                    ))),
            const SizedBox(
              height: 10,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  flex: 3,
                  child: Container(),
                ),
                Expanded(
                  flex: 4,
                  child: Container(
                    alignment: Alignment.center,
                    child: ElevatedButton(
                      onPressed: () {
                        String search = searchController.text;
                        searchItem(search);
                        Navigator.of(context).pop();
                      },
                      child: const Text("Search"),
                    ),
                  ),
                ),
                Expanded(
                    flex: 3,
                    child: TextButton(
                        onPressed: clearSearch,
                        child: const Text(
                          "clear",
                          style: TextStyle(
                              color: Colors.red,
                              decoration: TextDecoration.underline),
                        ))),
              ],
            )
          ]),
        );
      },
    );
  }

  void searchItem(String search) {
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/load_buyer_item.php"),
        body: {
          "cartuserid": widget.user.id,
          "search": search,
          "pageno": curpage.toString()
        }).then((response) {
      // print(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        if (jsondata['status'] == "success") {
          numofpage = int.parse(jsondata['numofpage']); //get number of pages
          numberofresult = int.parse(jsondata['numberofresult']);
          var extractdata = jsondata['data'];
          cartqty = int.parse(jsondata['cartqty'].toString());
          numberofcartitem = int.parse(jsondata['numberofcartitem'].toString());
          extractdata['items'].forEach((v) {
            itemList.add(Item.fromJson(v));
          });
        }
        setState(() {});
      }
    });
  }

  void showfilterDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return AlertDialog(
            shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10.0))),
            titlePadding: EdgeInsets.all(0),
            title: _getCloseButton(context),
            content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Sort By",
                    style: TextStyle(
                        color: Colors.black,
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        fontStyle: FontStyle.normal),
                    textAlign: TextAlign.center,
                  ),
                  RadioListTile(
                    value: '1',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        option = '1';
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Alphabet: A to Z'),
                  ),
                  RadioListTile(
                    value: '2',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        option = '2';
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Alphabet: Z to A'),
                  ),
                  RadioListTile(
                    value: '3',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        option = '3';
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Price: Low to High'),
                  ),
                  RadioListTile(
                    value: '4',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        option = '4';
                        selectedOption = value!;
                      });
                    },
                    title: const Text('Price: High to Low'),
                  ),
                  RadioListTile(
                    value: '5',
                    groupValue: selectedOption,
                    onChanged: (value) {
                      setState(() {
                        option = '5';
                        selectedOption = value!;
                      });
                    },
                    title: SizedBox(
                      height: 60,
                      child: DropdownButton(
                        //sorting dropdownoption
                        // Not necessary for Option 1
                        value: selectedType,
                        onChanged: (newValue) {
                          setState(() {
                            selectedType = newValue!;
                            print(selectedType);
                          });
                        },
                        items: itemlist.map((selectedType) {
                          return DropdownMenuItem(
                            value: selectedType,
                            child: Text(
                              selectedType,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Expanded(
                        flex: 3,
                        child: Container(),
                      ),
                      Expanded(
                        flex: 4,
                        child: Container(
                            alignment: Alignment.center,
                            child: ElevatedButton(
                              onPressed: () {
                                filterItem(option);
                                Navigator.of(context).pop();
                              },
                              child: const Text("Apply"),
                            )),
                      ),
                      Expanded(
                          flex: 3,
                          child: TextButton(
                              onPressed: () {
                                setState(() {
                                  selectedOption = '';
                                  option = '';
                                });
                                clearFilter;
                              },
                              child: const Text(
                                "clear",
                                style: TextStyle(
                                    color: Colors.red,
                                    decoration: TextDecoration.underline),
                              ))),
                    ],
                  )
                ]),
          );
        });
      },
    );
  }

  void filterItem(String option) {
    print(option);
    http.post(
        Uri.parse(
            "https://uumitproject.com/barterIt/buyer/load_buyer_item.php"),
        body: {
          "cartuserid": widget.user.id,
          "option": option,
          "type": selectedType,
          "pageno": curpage.toString()
        }).then((response) {
      //print(response.body);
      itemList.clear();
      if (response.statusCode == 200) {
        var jsondata = jsonDecode(response.body);
        print(response.body);
        if (jsondata['status'] == "success") {
          numofpage = int.parse(jsondata['numofpage']); //get number of pages
          numberofresult = int.parse(jsondata['numberofresult']);
          var extractdata = jsondata['data'];
          cartqty = int.parse(jsondata['cartqty'].toString());
          numberofcartitem = int.parse(jsondata['numberofcartitem'].toString());
          extractdata['items'].forEach((v) {
            itemList.add(Item.fromJson(v));
          });
        } else {
          Fluttertoast.showToast(
              msg: "No filter selected",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 1,
              fontSize: 16.0);
          if (searchController.text.isNotEmpty) {
            searchItem(searchController.text);
          } else {
            loadBuyerItems();
          }
        }
        setState(() {});
      }
    });
  }

  _getCloseButton(context) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        alignment: FractionalOffset.topRight,
        child: GestureDetector(
          child: const Icon(
            Icons.clear,
            color: Colors.red,
            size: 36,
          ),
          onTap: () {
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  clearSearch() {
    searchController.clear();
  }

  clearFilter() {
    selectedOption = '';
  }
}
