<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");

$email = $_POST['email'];
$password = sha1($_POST['password']);

$sqllogin = "SELECT * FROM tbl_users WHERE user_email = '$email' AND
user_password = '$password' AND user_otp = '1'";
$result = mysqli_query($conn,$sqllogin);
$count = mysqli_num_rows($result);

if ($count >= 1) {
while ($row = $result->fetch_assoc()) {
        $userlist = array();
        $userlist['id'] = $row['user_id'];
        $userlist['email'] = $row['user_email'];
        $userlist['name'] = $row['user_name'];
        $userlist['phone'] = $row['user_phone'];
        $userarray['password'] = $_POST['password'];
        $userarray['otp'] = $row['user_otp'];
        $userarray['datereg'] = $row['user_datereg'];
        $response = array('status' => 'success', 'data' => $userlist);
        sendJsonResponse($response);
    }
}else{
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
}

function sendJsonResponse($sentArray){
    header('Content‐Type: application/json');
    echo json_encode($sentArray);
}
?>
