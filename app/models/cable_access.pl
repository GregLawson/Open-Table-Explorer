// submit these variables to the server:
$data = array(
'SAAccessLevel' => '2',
'SAPassword' => 'W2402',
);

// send a request to example.com (referer = jonasjohn.de)
list($header, $content) = PostRequest(
"http://192.168.100.1/goform/_aslvl",
"http://192.168.100.1/_aslvl.asp",
$data
);

If you print $header, you will see it say "SUCCESS!"
