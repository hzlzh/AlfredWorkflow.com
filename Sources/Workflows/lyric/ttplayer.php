<?php

function SingleDecToHex($dec)  {
    $tmp="";
    $dec=$dec%16;
    if($dec<10) return $tmp.$dec;
    $arr=array("A","B","C","D","E","F");
    return $tmp.$arr[$dec-10];
}

function SetToHexString($str)  {
    if(!$str) return false;
    $tmp="";
    for($i=0;$i<strlen($str);$i++)
    {
        $ord=ord($str[$i]);
        $tmp.=SingleDecToHex(($ord-$ord%16)/16);
        $tmp.=SingleDecToHex($ord%16);
    }
    return $tmp;
}

function conv($num) {
    $tp = bcmod($num,4294967296);

    if(bccomp($num,0)>=0 && bccomp($tp,2147483648)>0)
        $tp=bcadd($tp,-4294967296);
    if(bccomp($num,0) < 0 && bccomp($tp,2147483648)<0)
        $tp=bcadd($tp,4294967296);

    return $tp;
}

function ShowListCode($str) {
    $s = strtolower($str);
    $keys = array(" ","'","(",")","[","]",",",".","'","\""," ", "`", "~", "!", "@", "#", "$", "%", "^", "&", "*", "(", ")", "-", "_", "=", "+", ",", "<", ".", ">", "/", "?", ";", ":", "\"", "[", "{", "]", "}", "\\", "|", "€","　", "。", "，", "、", "；", "：", "？", "！", "…", "—", "·","ˉ", "¨", "‘", "’", "“", "”", "々", "～", "‖", "∶", "＂", "＇","｀", "｜", "〃", "〔", "〕", "〈", "〉", "《", "》", "「", "」", "『", "』", "．", "〖", "〗", "【", "】", "（", "）", "［", "］","｛", "｝", "≈", "≡", "≠", "＝", "≤", "≥", "＜", "＞", "≮", "≯", "∷", "±","＋", "－", "×", "÷", "／", "∫", "∮", "∝", "∞", "∧", "∨", "∑", "∏", "∪","∩", "∈", "∵", "∴", "⊥", "∥", "∠", "⌒", "⊙", "≌", "∽", "√", "§", "№","☆", "★", "○", "●", "◎", "◇", "◆", "□", "℃", "‰", "■", "△", "▲", "※", "→","←", "↑", "↓", "〓", "¤", "°", "＃", "＆", "＠", "＼", "︿", "＿", "￣", "―","♂", "♀", "Ⅰ", "Ⅱ", "Ⅲ", "Ⅳ", "Ⅴ", "Ⅵ", "Ⅶ", "Ⅷ", "Ⅸ", "Ⅹ", "Ⅺ","Ⅻ", "⒈", "⒉", "⒊", "⒋", "⒌", "⒍", "⒎", "⒏", "⒐", "⒑", "⒒", "⒓","⒔", "⒕", "⒖", "⒗", "⒘", "⒙", "⒚", "⒛", "㈠", "㈡", "㈢", "㈣", "㈤","㈥", "㈦", "㈧", "㈨", "㈩", "①", "②", "③", "④", "⑤", "⑥", "⑦", "⑧", "⑨", "⑩","⑴", "⑵", "⑶", "⑷", "⑸", "⑹", "⑺", "⑻", "⑼", "⑽", "⑾", "⑿", "⒀","⒁", "⒂", "⒃", "⒄", "⒅", "⒆", "⒇", "┌", "┍", "┎", "┏", "┐", "┑", "┒","┓", "─", "┄", "┈", "└", "┕", "┖", "┗", "┘", "┙", "┚", "┛", "━", "┅", "┉","├", "┝", "┞", "┟", "┠", "┡", "┢", "┣", "│", "┆", "┊", "┤", "┥", "┦", "┧", "┨","┩", "┪", "┫", "┃", "┇", "┋", "┬", "┭", "┮", "┯", "┰", "┱", "┲", "┳", "┴", "┵","┶", "┷", "┸", "┹", "┺", "┻", "┼", "┽", "┾", "┿", "╀", "╁", "╂", "╃", "╄", "╅","╆", "╇", "╈", "╉", "╊", "╋");
    foreach ($keys as $key) {
        $s=str_replace($key,"",$s);
    }
    return SetToHexString(iconv('UTF-8','UTF-16LE',$s));
}

function DownloadCode($Id,$artist,$title) {
    $Id=(int)$Id;
    $utf8Str=SetToHexString($artist.$title);
    $length=strlen($utf8Str)/2;
    for($i=0;$i<=$length-1;$i++)
        eval('$song['.$i.'] = 0x'.substr($utf8Str,$i*2,2).';');
    $tmp2=0;
    $tmp3=0;
    $tmp1 = ($Id & 0x0000FF00) >> 8; //右移8位后为0x0000015F 

    if ( ($Id & 0x00FF0000) == 0 ) {
        $tmp3 = 0x000000FF & ~$tmp1; //CL 0x000000E7 
    }else {
        $tmp3 = 0x000000FF & (($Id & 0x00FF0000) >> 16); //右移16位后为0x00000001 
    }
    $tmp3 = $tmp3 | ((0x000000FF & $Id) << 8); //tmp3 0x00001801 
    $tmp3 = $tmp3 << 8; //tmp3 0x00180100 
    $tmp3 = $tmp3 | (0x000000FF & $tmp1); //tmp3 0x0018015F 
    $tmp3 = $tmp3 << 8; //tmp3 0x18015F00 
    if ( ($Id & 0xFF000000) == 0 ) {
        $tmp3 = $tmp3 | (0x000000FF & (~$Id)); //tmp3 0x18015FE7 
    } else {
        $tmp3 = $tmp3 | (0x000000FF & ($Id >> 24)); //右移24位后为0x00000000 
    }
    $i=$length-1;
    while($i >= 0){
        $char = $song[$i];
        if($char >= 0x80) $char = $char - 0x100;
        $tmp1 = ($char + $tmp2) & 0x00000000FFFFFFFF;
        $tmp2 = ($tmp2 << ($i%2 + 4)) & 0x00000000FFFFFFFF;
        $tmp2 = ($tmp1 + $tmp2) & 0x00000000FFFFFFFF;
        $i -= 1;
    }
    $i=0;
    $tmp1=0;
    while($i<=$length-1){
        $char = $song[$i];
        if($char >= 128) $char = $char - 256;
        $tmp7 = ($char + $tmp1) & 0x00000000FFFFFFFF;
        $tmp1 = ($tmp1 << ($i%2 + 3)) & 0x00000000FFFFFFFF;
        $tmp1 = ($tmp1 + $tmp7) & 0x00000000FFFFFFFF;
        $i += 1;
    }
    $t = conv($tmp2 ^ $tmp3);
    $t = conv(($t+($tmp1 | $Id)));
    $t = conv(bcmul($t , ($tmp1 | $tmp3)));
    $t = conv(bcmul($t , ($tmp2 ^ $Id)));

    if(bccomp($t , 2147483648)>0)
    $t = bcadd($t , -4294967296);
    return $t;
}

if ($argv[1] == 'sh') {
    echo ShowListCode($argv[2]);
} else if ($argv[1] == 'dl') {
    echo DownloadCode($argv[2], $argv[3], $argv[4]);
}
?>