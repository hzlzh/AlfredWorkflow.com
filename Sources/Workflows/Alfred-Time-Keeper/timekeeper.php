<?php
function readDayTime($file) {
      $file_handle = fopen($file, "rb");
      $start = 0;
      $time = 0;
      while (!feof($file_handle) ) {
         $line = fgets($file_handle);
         $line = substr($line,0,-1);
         if ($line != "") {
            $parts = split(":",$line);
            if(strcmp($parts[1],"start") == 0) {
               $start = (int) $parts[0];
            } else {
            $time += ((int) $parts[0]) - $start;
            $start = 0;
         }
      }
   }
   if($start != 0) {
      $time += time() - $start;
   }
   fclose($file_handle);
   return($time);
}

function timeTostring($time) {
   $min = floor($time / 60);
   $time = $time - $min*60;
   $hour = floor($min/60);
   $min = $min - $hour * 60;
   return(sprintf("%02d:%02d:%02d",$hour,$min,$time));
}
?>