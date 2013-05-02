<?php
/**
 * a workflow for cnBeta.
 * @version 1.0
 * @author David Lin(voidman.me@gmail.com)
 */

require 'vendor/simple_html_dom.php';
require 'vendor/workflows.php';
require 'CnbetaNews.php';

$newsType = 'new';
$query = $query ?: $newsType;

if ($query) {
    if (in_array($query, array(
        'new',
        'top10',
        'news.top10.week',
        'news.top10.month',
        'recommend',
        'recommend.top10',
        'recommend.top10.week',
        'dispute',
        'dispute.top10',
        'dispute.top10.week',
        'dispute.top10.month',
        //'cmt',
        //'comment',
    ))) {
        $newsType = $query;
        $cnbetaNews = new CnbetaNews($newsType);
        //$cnbetaNews->showNewsTopicIcon = false;
        $cnbetaNews->show();
    } elseif ($query == 'help') {
        $workflow = new Workflows();
        $workflow->result(1, null, "new", "显示 cnbeta 最新文章", 'icon.png');
        $workflow->result(2, null, "top10 / news.top10.week", "显示 cnbeta 本周十大人气文章", 'icon.png');
        $workflow->result(3, null, "news.top10.month", "显示 cnbeta 本月十大人气文章", 'icon.png');
        $workflow->result(4, null, "recommend", "显示 cnbeta 编辑推荐文章", 'icon.png');
        $workflow->result(5, null, "recommend.top10 / recommend.top10.week", "显示 cnbeta 本周十大推荐新闻", 'icon.png');
        $workflow->result(6, null, "dispute / dispute.top10 / dispute.top10.week", "显示 cnbeta 本周十大争议文章", 'icon.png');
        $workflow->result(7, null, "dispute.top10.month", "显示 cnbeta 本月十大争议文章", 'icon.png');
        echo $workflow->toxml();
    }
}