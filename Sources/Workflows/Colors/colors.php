<?php
include_once('workflows.php');
$w = new Workflows;
$q = $argv[1];
$mode = $argv[2];
$input = preg_replace('/[^a-zA-Z]/', '', $q);
if($q == ''){
	$w->result(
		'tylereich.colors picker',
		"pick|$mode",
		'Color Picker',
		'Action this item to reveal the OS X color picker',
		'icon.png',
		'yes'
	);
	echo $w->toxml();
	return;
}
$modes = array('hex','hsl','name','rgb','rgb_pcnt');
$rgba;
$names = array(
	'f0f8ff'=>'aliceblue','faebd7'=>'antiquewhite','00ffff'=>'aqua','7fffd4'=>'aquamarine','f0ffff'=>'azure','f5f5dc'=>'beige','ffe4c4'=>'bisque','000000'=>'black','ffebcd'=>'blanchedalmond','0000ff'=>'blue','8a2be2'=>'blueviolet','a52a2a'=>'brown','deb887'=>'burlywood','ea7e5d'=>'burntsienna','5f9ea0'=>'cadetblue','7fff00'=>'chartreuse','d2691e'=>'chocolate','ff7f50'=>'coral','6495ed'=>'cornflowerblue','fff8dc'=>'cornsilk','dc143c'=>'crimson','00ffff'=>'cyan','00008b'=>'darkblue','008b8b'=>'darkcyan','b8860b'=>'darkgoldenrod','a9a9a9'=>'darkgray','006400'=>'darkgreen','a9a9a9'=>'darkgrey','bdb76b'=>'darkkhaki','8b008b'=>'darkmagenta','556b2f'=>'darkolivegreen','ff8c00'=>'darkorange','9932cc'=>'darkorchid','8b0000'=>'darkred','e9967a'=>'darksalmon','8fbc8f'=>'darkseagreen','483d8b'=>'darkslateblue','2f4f4f'=>'darkslategray','2f4f4f'=>'darkslategrey','00ced1'=>'darkturquoise','9400d3'=>'darkviolet','ff1493'=>'deeppink','00bfff'=>'deepskyblue','696969'=>'dimgray','696969'=>'dimgrey','1e90ff'=>'dodgerblue','b22222'=>'firebrick','fffaf0'=>'floralwhite','228b22'=>'forestgreen','ff00ff'=>'fuchsia','dcdcdc'=>'gainsboro','f8f8ff'=>'ghostwhite','ffd700'=>'gold','daa520'=>'goldenrod','808080'=>'gray','008000'=>'green','adff2f'=>'greenyellow','808080'=>'grey','f0fff0'=>'honeydew','ff69b4'=>'hotpink','cd5c5c'=>'indianred','4b0082'=>'indigo','fffff0'=>'ivory','f0e68c'=>'khaki','e6e6fa'=>'lavender','fff0f5'=>'lavenderblush','7cfc00'=>'lawngreen','fffacd'=>'lemonchiffon','add8e6'=>'lightblue','f08080'=>'lightcoral','e0ffff'=>'lightcyan','fafad2'=>'lightgoldenrodyellow','d3d3d3'=>'lightgray','90ee90'=>'lightgreen','d3d3d3'=>'lightgrey','ffb6c1'=>'lightpink','ffa07a'=>'lightsalmon','20b2aa'=>'lightseagreen','87cefa'=>'lightskyblue','778899'=>'lightslategray','778899'=>'lightslategrey','b0c4de'=>'lightsteelblue','ffffe0'=>'lightyellow','00ff00'=>'lime','32cd32'=>'limegreen','faf0e6'=>'linen','ff00ff'=>'magenta','800000'=>'maroon','66cdaa'=>'mediumaquamarine','0000cd'=>'mediumblue','ba55d3'=>'mediumorchid','9370db'=>'mediumpurple','3cb371'=>'mediumseagreen','7b68ee'=>'mediumslateblue','00fa9a'=>'mediumspringgreen','48d1cc'=>'mediumturquoise','c71585'=>'mediumvioletred','191970'=>'midnightblue','f5fffa'=>'mintcream','ffe4e1'=>'mistyrose','ffe4b5'=>'moccasin','ffdead'=>'navajowhite','000080'=>'navy','fdf5e6'=>'oldlace','808000'=>'olive','6b8e23'=>'olivedrab','ffa500'=>'orange','ff4500'=>'orangered','da70d6'=>'orchid','eee8aa'=>'palegoldenrod','98fb98'=>'palegreen','afeeee'=>'paleturquoise','db7093'=>'palevioletred','ffefd5'=>'papayawhip','ffdab9'=>'peachpuff','cd853f'=>'peru','ffc0cb'=>'pink','dda0dd'=>'plum','b0e0e6'=>'powderblue','800080'=>'purple','ff0000'=>'red','bc8f8f'=>'rosybrown','4169e1'=>'royalblue','8b4513'=>'saddlebrown','fa8072'=>'salmon','f4a460'=>'sandybrown','2e8b57'=>'seagreen','fff5ee'=>'seashell','a0522d'=>'sienna','c0c0c0'=>'silver','87ceeb'=>'skyblue','6a5acd'=>'slateblue','708090'=>'slategray','708090'=>'slategrey','fffafa'=>'snow','00ff7f'=>'springgreen','4682b4'=>'steelblue','d2b48c'=>'tan','008080'=>'teal','d8bfd8'=>'thistle','ff6347'=>'tomato','40e0d0'=>'turquoise','ee82ee'=>'violet','f5deb3'=>'wheat','ffffff'=>'white','f5f5f5'=>'whitesmoke','ffff00'=>'yellow','9acd32'=>'yellowgreen'
);
switch($mode){
	case 'hex':
	preg_match('/[0-9A-Fa-f]*/', $q, $match);
	$rgba = hex($match[0]);
	break;
	
	case 'hsl':
	$input = preg_replace('/[^0-9.,-]/', '', $q);
	$input = explode(',',$input);
	$rgba = hsl(
		$input[0],
		$input[1],
		$input[2],
		$input[3]
	);
	break;
	
	case 'rgb':
	$input = preg_replace('/[^0-9%.,-]/', '', $q);
	$input = explode(',',$input);
	$rgba = rgb(
		$input[0],
		$input[1],
		$input[2],
		$input[3]
	);
	break;
	
	case 'name':
	$input = preg_replace('/[^a-zA-Z]/', '', $q);
	if($input){
		$rgba = name($input);
	}else{
		$w->result(
			'tylereich.colors picker',
			'color-pick',
			'Color Picker',
			'Action this item to reveal the OS X color picker',
			'icon.png',
			'yes'
		);
		echo $w->toxml();
		return;
	}
	break;
	
	case 'pick':
	$pick = explode('|', $q);
	if($pick[0] == 'pick'){
		$rgba = explode(',', `osascript -e 'tell application "Finder"' -e 'activate' -e 'choose color' -e 'end tell'`);
		for($i=0;$i<count($rgba);$i++){
			$rgba[$i] /= 65535;
		}
		$r = $rgba[0];
		$g = $rgba[1];
		$b = $rgba[2];
		$return;
		switch($pick[1]){
			case 'hex':
			$return = tohex($r,$g,$b);
			break;
			case 'hsl':
			$return = tohsl($r,$g,$b);
			break;
			case 'rgb':
			$return = torgb($r,$g,$b);
			break;
			case 'name':
			$return = torgb($r,$g,$b);
			break;
		}
		`osascript -e 'tell application "Alfred 2" to search "$return"'`;
	}else{
		echo $q;
	}
	return;
	break;
}
if($rgba == false){
	$w->result(
		'tylereich.colors-noresults',
		'',
		'No matching colors were found',
		'Make sure you spelled your query correctly.',
		'icon.png',
		'no'
	);
	echo $w->toxml();
	return;
}
$r = $rgba[0];
$g = $rgba[1];
$b = $rgba[2];
$a = $rgba[3];
$hexraw = tohexraw($r,$g,$b,$a);

if(!($w->read($w->cache()."/$hexraw.png"))){
	$img_rgba = array(
		round($r*255),
		round($g*255),
		round($b*255),
		round(abs($a-1)*127)
	);
	$img = imagecreatefrompng('checker.png');
	$color = imagecolorallocatealpha(
		$img,
		$img_rgba[0],
		$img_rgba[1],
		$img_rgba[2],
		$img_rgba[3]
	);
	imagefilledrectangle($img, 8, 8, 120, 120, $color);
	imagepng($img, $w->cache()."/$hexraw.png");
	imagedestroy($img);
}

if($a == 1){
	$a = false;
}
$hex = tohex($r,$g,$b,$a);
//$hexraw = tohexraw($r,$g,$b,$a);
$hsl = tohsl($r,$g,$b,$a);
$name = toname(tohexraw($r,$g,$b));
$rgb = torgb($r,$g,$b,$a);
$rgb_pcnt = torgb_pcnt($r,$g,$b,$a);
$modes = array(
	'hex'=>$hex,
	'hsl'=>$hsl,
	'name'=>$name,
	'rgb'=>$rgb,
	'rgb_pcnt'=>$rgb_pcnt
);
if(!$a){
	$description = array(
		'hex'=>'Hexadecimal format',
		'hsl'=>'HSL format',
		'name'=>'CSS3 named color',
		'rgb'=>'RGB format',
		'rgb_pcnt'=>'RGB percent format'
	);
}else{
	$description = array(
		'hex'=>'Hexadecimal format',
		'hsl'=>'HSLA format',
		'name'=>'CSS3 named color',
		'rgb'=>'RGBA format',
		'rgb_pcnt'=>'RGBA percent format'
	);
}

foreach($modes as $this_mode=>$result){
	if($result == false){
		continue;
	}
	$w->result(
		"tylereich.colors $mode to $this_mode",
		$result,
		$result,
		$description[$this_mode],
		$w->cache()."/$hexraw.png",
		'yes'
	);
}
echo $w->toxml();

function rgb($r=0,$g=0,$b=0,$a=null){
	if(preg_match('/%/', $r) || preg_match('/%/', $g) || preg_match('/%/', $b)){
		$r = str_replace('%','',$r);
		$g = str_replace('%','',$g);
		$b = str_replace('%','',$b);
		$r /= 100;
		$g /= 100;
		$b /= 100;
	}else{
		$r /= 255;
		$g /= 255;
		$b /= 255;
	}
	if(0 > $r){
		$r = 0;
	}elseif($r > 1){
		$r = 1;
	}
	if(0 > $g){
		$g = 0;
	}elseif($g > 1){
		$g = 1;
	}
	if(0 > $b){
		$b = 0;
	}elseif($b > 1){
		$b = 1;
	}
	if($a!==null){
		if(0 > $a){
			$a = 0;
		}elseif($a > 1){
			$a = 1;
		}
		$a = round($a, 3);
	}else{
		$a = 1;
	}
	$rgba = array($r,$g,$b,$a);
	return $rgba;
}
function hsl($h=0,$s=100,$l=50,$a=null){
	$h /= 360;
	$s /= 100;
	$l /= 100;
	$r; $g; $b;
	if($s == 0){
		$r = $g = $b = $l;
	}else{
		function hue2rgb($p, $q, $t){
            if($t < 0) $t += 1;
            if($t > 1) $t -= 1;
            if($t < 1/6) return $p + ($q - $p) * 6 * $t;
            if($t < 1/2) return $q;
            if($t < 2/3) return $p + ($q - $p) * (2/3 - $t) * 6;
            return $p;
		}
		$q = $l < 0.5 ? $l * (1 + $s) : $l + $s - $l * $s;
		$p = 2 * $l - $q;
		$r = hue2rgb($p, $q, $h + 1/3);
		$g = hue2rgb($p, $q, $h);
		$b = hue2rgb($p, $q, $h - 1/3);
	}
	if($a !== null){
		if(0 > $a){
			$a = 0;
		}elseif($a > 1){
			$a = 1;
		}
		return array($r, $g, $b, $a);
	}
	return array($r, $g, $b, 1);
}
function hex($hex){
	$hex = str_split($hex);
	$count = count($hex);
	if($count<=3){
		for($i=0;$i<3;$i++){
			if(!$hex[$i]){
				$hex[$i] = 0;
			}
		}
		$hex = array(
			$hex[0].$hex[0],
			$hex[1].$hex[1],
			$hex[2].$hex[2]
		);
	}elseif($count<=6){
		for($i=0;$i<6;$i++){
			if(!$hex[$i]){
				$hex[$i] = 0;
			}
		}
		$hex = array(
			$hex[0].$hex[1],
			$hex[2].$hex[3],
			$hex[4].$hex[5]
		);
	}else{
		for($i=0;$i<8;$i++){
			if(!$hex[$i]){
				$hex[$i] = 0;
			}
		}
		$hex = array(
			$hex[0].$hex[1],
			$hex[2].$hex[3],
			$hex[4].$hex[5],
			$hex[6].$hex[7]
		);
	}
	$count = count($hex);
	if($count == 3){
		$rgba = array(
			hexdec($hex[0])/255,
			hexdec($hex[1])/255,
			hexdec($hex[2])/255,
			1
		);
	}elseif($count == 4){
		$rgba = array(
			hexdec($hex[0])/255,
			hexdec($hex[1])/255,
			hexdec($hex[2])/255,
			hexdec($hex[3])/255
		);
	}
	return $rgba;
}
function name($q){
	global $names;
	foreach($names as $hex=>$name){
		if($q == $name){
			return hex($hex);
		}
	}
	foreach($names as $hex=>$name){
		$search = "/^$q/i";
		if(preg_match($search,$name)){
			return hex($hex);
		}
	}
	return false;
}

function tohexraw($r,$g,$b,$a=false){
	$hex = array(
		dechex(round($r*255)),
		dechex(round($g*255)),
		dechex(round($b*255))
	);
	if($a !== false){
		$hex[] = dechex(round($a*255));
	}
	$count = count($hex);
	for($i=0;$i<$count;$i++){
		if(strlen($hex[$i])<2){
			$hex[$i] = '0'.$hex[$i];
		}
	}
	$hex = implode('',$hex);
	return $hex;
}
function tohex($r,$g,$b,$a=false){
	$hex = tohexraw($r,$g,$b,$a);
	return "#$hex";
}
function tohsl($r=0,$g=0,$b=0,$a=false){
	$max = max($r,$g,$b);
	$min = min($r,$g,$b);
	$h = $s = $l = ($max + $min) / 2;
	if($max == $min){
		$h = $s = 0;
	}else{
		$d = $max - $min;
		$s = $l > 0.5 ? $d / (2 - $max - $min) : $d / ($max + $min);
		switch($max){
			case $r: $h = ($g - $b) / $d + ($g < $b ? 6 : 0); break;
			case $g: $h = ($b - $r) / $d + 2; break;
			case $b: $h = ($r - $g) / $d + 4; break;
		}
		$h /= 6;
	}
	$h = round($h * 360);
	$s = round($s * 100,1);
	$l = round($l * 100,1);
	
	if($a !== false){
		$a = round($a, 3);
		return "hsl($h, $s%, $l%, $a)";
	}
	return "hsl($h, $s%, $l%)";;
}
function toname($hex){
	global $names;
	if($names[$hex]){
		return $names[$hex];
	}else{
		return false;
	}
}
function torgb($r=0,$g=0,$b=0,$a=false){
	$r = round($r*255);
	$g = round($g*255);
	$b = round($b*255);
	if($a !== false){
		$a = round($a, 3);
		return "rgba($r, $g, $b, $a)";
	}
	return "rgb($r, $g, $b)";
}
function torgb_pcnt($r=0,$g=0,$b=0,$a=false){
	$r = round($r*100,1);
	$g = round($g*100,1);
	$b = round($b*100,1);
	if($a !== false){
		$a = round($a, 3);
		return "rgba($r%, $g%, $b%, $a)";
	}
	return "rgb($r%, $g%, $b%)";
}
?>