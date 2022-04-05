<?php
$myfile = fopen("./newfile.txt", "a") or die("Unable to open file!");
fwrite($myfile, $_GET["pcname"]);
fwrite($myfile, ", ");
fwrite($myfile, $_GET["poweronhours"] . "\n");
fclose($myfile);
?>