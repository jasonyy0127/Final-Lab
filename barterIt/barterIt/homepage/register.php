<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

require '/home4/uumitpro/PhpMailer/src/Exception.php';
require '/home4/uumitpro/PhpMailer/src/PHPMailer.php';
require '/home4/uumitpro/PhpMailer/src/SMTP.php';

if (!isset($_POST)) {
    $response = array('status' => 'failed', 'data' => null);
    sendJsonResponse($response);
    die();
}
include_once("dbconnect.php");
date_default_timezone_set("Asia/Kuala_Lumpur");

$name = $_POST['name'];
$email = $_POST['email'];
$phone = $_POST['phone'];
$password = sha1($_POST['password']);
$otp = rand(100000,999999);

$date = date("Y/m/d H:i:s");
$na = "na";

$sqlinsert = "INSERT INTO tbl_users ( `user_name`, `user_phone`, `user_email`, `user_password`, `user_otp`, `user_datareg`) VALUES('$name', '$phone', '$email','$password', '$otp', '$date')";

$sqlselect = "SELECT * FROM tbl_users WHERE user_email = '$email'";
$result = mysqli_query($conn,$sqlselect);
$count = mysqli_num_rows($result);

if ($count >= 1){
    $response = array('status' => 'existed', 'data' => null);
    sendJsonResponse($response);
}else{
    if (mysqli_query($conn,$sqlinsert) === TRUE) {
        mailOtp($email,$name,$otp);
        $response = array('status' => 'success', 'data' => null);
        sendJsonResponse($response);
    }else{
        $response = array('status' => 'failed', 'data' => null);
        sendJsonResponse($response);
    }
}

function sendJsonResponse($sentArray){
    header('Content‐Type: application/json');
    echo json_encode($sentArray);
}

function mailOtp($email,$name,$otp){
    $subject = 'BarterIt - Account Verification';
    $body = "
    <html>
    <head>
    <title></title>
    </head>
    <body>
    <h4>Welcome to BarterIt</h4>
    <p>Dear $name,<br>
     Thank you for registering your account with us. To complete your registration, please click on the following button/link<br><br>
     <a href ='https://uumitproject.com/barterIt/homepage/verify.php?email=$email&otp=$otp'><button>Verify your account</button></a><br><br>
     Once your account has been verified, you can open the BarterIt app on your phone and login.<br>
    </body>
    </html>
    ";
    $mail = new PHPMailer(true);
        try {
    
        $mail->isSMTP();                                            //Send using SMTP
        $mail->Host       = 'mail.uumitproject.com';                 //Set the SMTP server to send through
        $mail->SMTPAuth   = true;                                   //Enable SMTP authentication
        $mail->Username   = 'barterit_jason@uumitproject.com';            //SMTP username
        $mail->Password   = 'AK3)^2d*)FS&';                         //SMTP password
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_SMTPS;            //Enable implicit TLS encryption
        $mail->Port       = 465;                                    //TCP port to connect to; use 587 if you have set `SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS`
    
        //Recipients
        $mail->setFrom('barterit_jason@uumitproject.com', 'BarterIt mail notification');
        $mail->addAddress($email, $name);     //Add a recipient
       
       
        //Content
        $mail->isHTML(true);                                  //Set email format to HTML
        $mail->Subject = $subject;
        $mail->Body    = $body;
        $mail->send();
        //echo 'Message has been sent';
    } catch (Exception $e) {
        //echo "Message could not be sent. Mailer Error: {$mail->ErrorInfo}";
    }    
}
?>