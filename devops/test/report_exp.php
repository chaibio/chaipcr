<?php

include 'database.php.inc';

$pind=0;
if($debug) printTime(++$pind);

if($debug) echo "<br/>Is bulk is: $is_bulk<br/>And request is:" . $_REQUEST['isBulk'];

$stamp = $_REQUEST['ts'];
$deviceid = $_REQUEST['deviceid'];
$ip = $_REQUEST['ip'];
if(!$ip) $ip=' ';

$c = $_REQUEST['c'];
if(!$c) $c=-1;
$msg="Test";
$msg = $_REQUEST['msg'];
if(!$msg) $msg='NA';

mysql_connect( $hostname, $username, $password ) OR DIE ( 'Unable to connect to database! Please try again later.' );
mysql_select_db($dbname);

if($debug) printTime(90);

$rec_index = 0;

$query5 = "insert into $usertable (timest, deviceid, c, msg,ip) VALUES ('$stamp', '$deviceid', '$c', '$msg', '$ip' );";

if($debug) echo "query5=$query5";

$result2 = mysql_query($query5);
if($debug) printTime(92);
if($debug) echo $result2;

echo "<result>success</result>";
// if speed more than 0 and there is an ale
function printTime($pind)
{
	$timeTaken = time() - $_SERVER['REQUEST_TIME'];
	echo "<br/>This script took $timeTaken to until index" . $pind . "<br/>";
}
?> 