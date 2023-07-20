class Order {
  String? orderId;
  String? orderBill;
  String? orderPaid;
  String? buyerId;
  String? sellerId;
  String? orderDate;
  String? orderStatus;
  String? orderPickUpAddress;
  String? orderLat;
  String? orderLong;

  Order(
      {this.orderId,
      this.orderBill,
      this.orderPaid,
      this.buyerId,
      this.sellerId,
      this.orderDate,
      this.orderStatus,
      this.orderPickUpAddress,
      this.orderLat,
      this.orderLong});

  Order.fromJson(Map<String, dynamic> json) {
    orderId = json['order_id'];
    orderBill = json['order_bill'];
    orderPaid = json['order_paid'];
    buyerId = json['buyer_id'];
    sellerId = json['seller_id'];
    orderDate = json['order_date'];
    orderStatus = json['order_status'];
    orderPickUpAddress = json['order_pickupaddress'];
    orderLat = json['order_lat'];
    orderLong = json['order_long'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['order_id'] = orderId;
    data['order_bill'] = orderBill;
    data['order_paid'] = orderPaid;
    data['buyer_id'] = buyerId;
    data['seller_id'] = sellerId;
    data['order_date'] = orderDate;
    data['order_status'] = orderStatus;
    data['order_pickupaddress'] = orderPickUpAddress;
    data['order_lat'] = orderLat;
    data['order_long'] = orderLong;
    return data;
  }
}