<?php
$myfile = fopen("./newfile.txt", "a") or die("Unable to open file!");
$data = $_GET["pcname"]
fwrite($myfile, $data);
fclose($myfile);
?>
