<?php
/**
* Name:         Wordreference.com (© WordReference.com) Workflow for Alfred 2
* Author:       Anthony Kevins
* Revised:      14/06/2013
* Version:      0.3
* Note:         Icon Source: A68 - Freelance Graphics Design (http://a68.pl)
*/

require_once 'workflows.php';
$w = new Workflows('wordreference');
$id = $w->get('api','settings.plist');

if (!$id) {
    $w->result(
        'wordreference-noapi',
        'open http://www.wordreference.com/docs/APIregistration.aspx',
        'You must provide a WordReference API to use the workflow',
        "Get an API using 'getapi', then set it with 'setapi'",
        'icon.png',
        'yes'
    );
    echo $w->toxml();
    die;
}

$langs = urlencode($argv[1]);
$query = urlencode($argv[2]);
$url = "http://api.wordreference.com/0.8/$id/json/$langs/$query";
$translations = $w->request( $url );
$translations = json_decode( $translations );

$lang1 = substr($langs, 0, 2);
$lang2 = substr($langs, -2);
$dir = dirname(__FILE__);
$defaultIcon = 'icon.png';
$lang1Icon = file_exists($dir."/$lang1.png") ? "$lang1.png" : $defaultIcon;

// where translations are stored in the JSON
$translationPositions = array(
    array('term0',    'PrincipalTranslations'),
    array('term0',    'Entries'),
    array('term0',    'AdditionalTranslations'),
    array('original', 'Compounds'),
);

$termIndex = 0;

// for each position check if present and call the walker
foreach ($translationPositions as $pos) {
    if (isset($translations->{$pos[0]}->{$pos[1]})) {
        foreach ($translations->{$pos[0]}->{$pos[1]} as $translation) {
            foreach ($translation as $trkey => $tr) {
                if ($trkey === "Note") continue;

                $uid = "wordref-$langs-$query-".$termIndex++;
                $icon = $trkey === 'OriginalTerm' ? $lang1Icon : $defaultIcon;

                $w->result($uid, "$langs/$query", $tr->term, "{$tr->POS} {$tr->sense}", $icon, 'yes');
            }
        }
    }
}

echo $w->toxml();
