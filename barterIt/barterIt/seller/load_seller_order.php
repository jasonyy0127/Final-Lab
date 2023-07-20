<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

if (isset($_POST['sellerid'])){
	$sellerid = $_POST['sellerid'];	
	$sqlcart = "SELECT * FROM `tbl_orders` WHERE seller_id = '$sellerid' AND order_history = '0'";
}
//`order_id`, `order_bill`, `order_paid`, `buyer_id`, `seller_id`, `order_date`, `order_status`

$result = $conn->query($sqlcart);
if ($result->num_rows > 0) {
    $orderitems["orders"] = array();
	while ($row = $result->fetch_assoc()) {
        $orderlist = array();
        $orderlist['order_id'] = $row['order_id'];
        $orderlist['order_bill'] = $row['order_bill'];
        $orderlist['order_paid'] = $row['order_paid'];
        $orderlist['buyer_id'] = $row['buyer_id'];
        $orderlist['seller_id'] = $row['seller_id'];
        $orderlist['order_date'] = $row['order_date'];
        $orderlist['order_status'] = $row['order_status'];
        $orderlist['order_pickupaddress'] = $row['order_pickupaddress'];
        $orderlist['order_lat'] = $row['order_lat'];
        $orderlist['order_long'] = $row['order_long'];
        array_push($orderitems["orders"] ,$orderlist);
    }
    $response = array('status' => 'success', 'data' => $orderitems);
    sendJsonResponse($response);
}else{
     $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}
function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}