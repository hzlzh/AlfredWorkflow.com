<?
require_once('phpQuery.php');
require_once('workflows.php');

$channels = array(
    'MAD' => 'douga-mad-1.html',
    'AMV' => 'douga-mad-1.html',
    'MAD.AMV' => 'douga-mad-1.html',
    'MMD' => 'douga-mmd-1.html', 
    'MMD.3D' => 'douga-mmd-1.html', 
    '二次元鬼畜' => 'douga-kichiku-1.html',
    '期刊' => 'douga-else-1.html',
    '音乐视频' => 'music-video-1.html', 
    '三次元音乐' => 'music-coordinate-1.html',
    'VOCALOID' => 'music-vocaloid-1.html',
    'VOCALOID相关' => 'music-vocaloid-1.html',
    '翻唱' => 'music-Cover-1.html',
    '游戏视频' => 'game-video-1.html',
    '游戏攻略' => 'game-ctary-1.html',
    '游戏解说' => 'game-ctary-1.html',
    'MUGEN' => 'game-mugen-1.html',
    '科普知识' => 'tech-popular-science-1.html',
    '人文地理' => 'tech-geo-1.html',
    '全球科技' => 'tech-future-1.html',
    '野生技术' => 'tech-wild-1.html',
    '生活娱乐' => 'ent-life-1.html',
    '舞蹈' => 'ent-dance-1.html',
    '三次元鬼畜' => 'ent-Kichiku-1.html',
    '影视' => 'ent-telvisn-1.html',
    '新番' => 'bangumi-two-1.html',
    '新番二次元' => 'bangumi-two-1.html',
    '新番三次元' => 'bangumi-three-1.html'
);

function search_channel($channel) {
    $wf = new Workflows();
    $url = 'http://www.bilibili.tv/video/'.$channel;
    $content = $wf->request($url, array(CURLOPT_ENCODING => 1));
    $doc = phpQuery::newDocumentHTML($content);
    $list = $doc->find('li.l1');

    $i = 0;
    foreach ($list as $item) {
        $item = pq($item);
        $link = $item->children('a.title')->attr('href');
        if (strpos($link, 'http') !== 0) {
            $link = 'http://www.bilibili.tv'.$link;
        }
        $title = $item->children('a.title')->text();
        $author = $item->find('a.up')->text();
        $view = $item->find('a.gk > b')->text();
        $comment = $item->find('a.pl > b')->text();
        $bullet = $item->find('a.dm > b')->text();
        $save = $item->find('a.sc > b')->text();
        $date = preg_split('/UP:/', $item->find('div.date')->text());
        $date = $date[1];
        $subtitle = 'UP主:'.$author.' 播放:'.$view.' 评论:'.$comment.' 弹幕:'.$bullet.' 收藏:'.$save.' 日期:'.$date;

        $wf->result(
            $i,
            $link,
            $title,
            $subtitle,
            'icon.png',
            'yes'        
        );
        $i++;
    }

    return $wf->toxml();
}

function search_query($kw) {
    $wf = new Workflows();
    $url = 'http://www.bilibili.tv/search?keyword='.urlencode($kw).'&orderby=&formsubmit=';
    $content = $wf->request($url, array(CURLOPT_ENCODING => 1));
    $doc = phpQuery::newDocumentHTML($content);
    $list = $doc->find('li.l');

    $i = 0;
    foreach ($list as $item) {
        $link = pq($item)->children('a:first')->attr('href');
        if (strpos($link, 'http') !== 0) {
            $link = 'http://www.bilibili.tv'.$link;
        }
        $info = pq($item)->find('div.info > i');
        $author = pq($item)->find('a.upper:first')->text();
        $view = $info->eq(0)->text();
        $comment = $info->eq(1)->text();
        $bullet = $info->eq(2)->text();
        $save = $info->eq(3)->text();
        $date = $info->eq(4)->text();
        $subtitle = 'UP主:'.$author.' 播放:'.$view.' 评论:'.$comment.' 弹幕:'.$bullet.' 收藏:'.$save.' 日期:'.$date;
        $wf->result(
            $i,
            $link,
            pq($item)->find('div.t:first')->text(),
            $subtitle,
            'icon.png',
            'yes'        
        );
        $i++;
    }

    if (count($wf->results()) == 0) {
        $wf->result('0', $url, '在bilibili.tv中搜索', $kw, 'icon.png', 'yes');
    }

    return $wf->toxml();
}

function search($kw) {
    global $channels;
    $channel = $channels[$kw];
    if ($channel) {
        return search_channel($channel);
    }
    else {
        return search_query($kw);
    }
}
?>