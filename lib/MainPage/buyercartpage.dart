import 'package:flutter/material.dart';

import '../Model/user.dart';

class BuyerCartPage extends StatefulWidget {
  final User user;

  const BuyerCartPage({super.key, required this.user});

  @override
  State<BuyerCartPage> createState() => _BuyerCartPageState();
}

class _BuyerCartPageState extends State<BuyerCartPage> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
