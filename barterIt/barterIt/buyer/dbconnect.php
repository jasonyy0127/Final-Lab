<?php
$servername = "cloudgate177";
$username = "uumitpro_chonghuiyang";
$password = "Xiaodark0167321292";
$dbname = "uumitpro_barterIT";
    
$conn = new mysqli($servername, $username, $password, $dbname);
if ($conn->connect_error){
    die("Connection failed: " . $conn->connect_error);
}
?>