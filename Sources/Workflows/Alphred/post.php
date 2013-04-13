<?php
require_once('workflows.php');
$w = new Workflows();
$q=$argv;

$q= explode(" ",$argv[1],2);
if($q[0]=='token'):
	$w->set( 'token', $q[1], 'settings.plist' );
	echo 'Token added'; 
else:
	$post['text']=$argv[1];
	$token =  $w->get( 'token', 'settings.plist' );
	$url='https://alpha-api.app.net/stream/0/posts';
	$headers=array(
    	'Content-Type: application/json',
    	'Authorization: Bearer '.$token,
    	);
	connect(1,$url,$headers,$post);
endif;




function connect($type=1,$url,$headers,$query){
        $ch = curl_init();
         curl_setopt($ch, CURLOPT_URL,$url);
        if($type==1){
            curl_setopt($ch, CURLOPT_POST, 1);
            if(isset($query)){
                curl_setopt($ch, CURLOPT_POSTFIELDS,json_encode($query));
            }
        }
        curl_setopt($ch, CURLOPT_HTTPHEADER,$headers);
        curl_setopt($ch, CURLOPT_RETURNTRANSFER, TRUE);
        $output=json_decode(curl_exec($ch));
        curl_close ($ch);

        if(isset($output->error)){
            $error = $output->error;
            echo 'Error Posting';
        }else{
        	echo 'Posted';
        }
    }
