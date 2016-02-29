<p style="color:red">This directory is for sending emails from ingame! So not much is going on here... you can leave!</p>
<?php

	$type =  strip_tags($_POST["type"]);
	$from =  strip_tags($_POST["from"]);
	$thereason =  strip_tags($_POST["thereason"]);
	$person =  strip_tags($_POST["reportonperson"]);
	$sip =  strip_tags($_POST["serverip"]); 
	$sport =  strip_tags($_POST["serverport"]);
	$reportid =  strip_tags($_POST["idreport"]);
	$date =  strip_tags($_POST["thedate"]);
	$host =  strip_tags($_POST["host"]);
	
	$to = strip_tags($_POST["sendto"]);
	
	$headers = "From: XxLMM13xX@gmail.com\r\n";
	$headers .= "Reply-To: XxLMM13xX@gmail.com\r\n";
	$headers .= "MIME-Version: 1.0\r\n";
	$headers .= "Content-Type: text/html; charset=ISO-8859-1\r\n";
	
	if($type=="Bug")
	{
		$subject = 'Automated Bug Report From: ' . $from;

		$message = '<html><body>';
		$message .= '<b>Reporting Player:</b> ' . $from . '<br />';
		$message .= '<b>Bug Problem:</b> ' . $thereason . '<br />';
		$message .= '<b>Reported on:</b> ' . $date . '<br />';
		$message .= '<b>Report ID:</b> ' . $reportid . '<br />';
		$message .= '<b>Server Name:</b> ' . $host . '<br />';
		$message .= '<b>Server IP:</b> ' . $sip . ':' . $sport .'<br />';
		$message .= "</body></html>";
		
	}
	else
	{
		$subject = 'Automated Player Report From: ' . $from;

		$message = '<html><body>';
		$message .= '<b>Reporting Player:</b> ' . $from . '<br />';
		$message .= '<b>Reported Player:</b> ' . $person . '<br />';
		$message .= '<b>Reported on:</b> ' . $date . '<br />';
		$message .= '<b>Report Reason:</b> ' . $thereason . '<br />';
		$message .= '<b>Report ID:</b> ' . $reportid . '<br />';
		$message .= '<b>Server Name:</b> ' . $host . '<br />';
		$message .= '<b>Server IP:</b> ' . $sip . ':' . $sport .'<br />';
		$message .= "</body></html>";
	}
	mail($to, $subject, $message, $headers);
?>