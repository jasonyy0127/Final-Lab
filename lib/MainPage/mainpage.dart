import 'package:barter_it/MainPage/Buyer/buyertab.dart';
import 'package:barter_it/MainPage/Profile/profiletab.dart';
import 'package:barter_it/MainPage/Seller/sellertab.dart';
import 'package:flutter/material.dart';

import '../Model/user.dart';

class MainPage extends StatefulWidget {
  const MainPage({
    Key? key,
    required this.user,
  }) : super(key: key);

  final User user;

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  late List<Widget> tabchildren;
  int _currentIndex = 2;
  String maintitle = "Profile";

  @override
  void initState() {
    super.initState();
    print("Profile");
    tabchildren = [
      BuyerTab(user: widget.user),
      SellerTab(user: widget.user),
      ProfileTab(user: widget.user),
    ];
  }

  @override
  void dispose() {
    super.dispose();
    print("dispose");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: tabchildren[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(
                Icons.payment,
              ),
              label: "Buyer"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
              ),
              label: "Seller"),
          BottomNavigationBarItem(
              icon: Icon(
                Icons.person,
              ),
              label: "Profile")
        ],
      ),
    );
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
      if (_currentIndex == 0) {
        maintitle = "Buyer";
      }
      if (_currentIndex == 1) {
        maintitle = "Seller";
      }
      if (_currentIndex == 2) {
        maintitle = "Profile";
      }
    });
  }
}
