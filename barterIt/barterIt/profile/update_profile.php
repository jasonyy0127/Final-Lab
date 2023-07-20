<?php
if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}

include_once("dbconnect.php");

$userid = $_POST['id'];
$username = $_POST['name'];
$useremail = $_POST['email'];
$userphone = $_POST['phone'];

if (isset($_POST['image'])) {
    $image = $_POST['image'];
    $userid = $_POST['userid'];
    
    $decoded_string = base64_decode($image);
	$path = '../assets/profile_pics/'.$userid.'.png';
	file_put_contents($path, $decoded_string);
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
    // $decoded_string = base64_decode($encoded_string);
    // $path = '../assets/profileimages/' . $userid . '.png';
    // if (file_put_contents($path, $decoded_string)){
    //     $response = array('status' => 'success', 'data' => null);
    //     sendJsonResponse($response);
    // }else{
    //     $response = array('status' => 'failed', 'data' => null);
    //     sendJsonResponse($response);
    // }
    die();
}else if (isset($_POST['oldpass'])) {
    $oldpass = sha1($_POST['oldpass']);
    $newpass = sha1($_POST['newpass']);
    $userid = $_POST['userid'];
    $sqllogin = "SELECT * FROM tbl_users WHERE user_id = '$userid' AND user_password = '$oldpass'";
    $result = $conn->query($sqllogin);
    if ($result->num_rows > 0) {
    	$sqlupdate = "UPDATE tbl_users SET user_password ='$newpass' WHERE user_id = '$userid'";
            if ($conn->query($sqlupdate) === TRUE) {
                $response = array('status' => 'success', 'data' => null);
                sendJsonResponse($response);
            } else {
                $response = array('status' => 'failed', 'data' => null);
                sendJsonResponse($response);
            }
    }else{
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
}else{

$sqlupdate = "UPDATE `tbl_users` SET `user_name`='$username',`user_email`='$useremail',`user_phone`='$userphone' WHERE user_id = '$userid'";

if ($conn->query($sqlupdate) === TRUE) {
	$response = array('status' => 'success', 'data' => null);
    sendJsonResponse($response);
}else{
	$response = array('status' => 'failed', 'data' => null);
	sendJsonResponse($response);
}}

function sendJsonResponse($sentArray)
{
    header('Content-Type: application/json');
    echo json_encode($sentArray);
}

?>