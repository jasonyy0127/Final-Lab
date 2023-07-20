<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$orderid = $_POST['orderid'];
$status = $_POST['status'];
$address = $_POST['address'];
$lat = $_POST['lat'];
$long = $_POST['long'];

if ($status == 'Completed'){
    $order_history = 1;
}else{
    $order_history = 0;
}

$sqlupdate = "UPDATE `tbl_orders` SET `order_status`='$status', `order_pickupaddress` = '$address', `order_long` = '$long', `order_lat` = '$lat', `order_history` = '$order_history' WHERE order_id = '$orderid'";

if ($conn->query($sqlupdate) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
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

?>