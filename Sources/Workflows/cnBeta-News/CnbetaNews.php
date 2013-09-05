<?php
/**
 * Class CnbetaNews
 */

class CnbetaNews
{
    const URL_BASE = 'http://www.cnbeta.com/';
    const NEWS_NOT_FOUND_TITLE = '没有找到任何新闻';
    const NEWS_NOT_FOUND_CONTENT = '请尝试访问 cnbeta 网站。';
    const NEWS_ICON_DIR_TOPIC = 'icons/news/topics';
    const NEWS_ICON_DIR_TOP10 = 'icons/news/top10';
    const NEWS_ICON_DEFAULT = 'icon.png';

    /**
     * @var Workflows
     */
    private $workflow;

    /**
     * @var simple_html_dom
     */
    private $htmlDom;

    /**
     * @var string
     */
    private $newsType;

    /**
     * @var bool
     */
    public $showNewsTopicIcon = true;

    /**
     *  Construct.
     */
    public function __construct($newsType)
    {
        $this->workflow = new Workflows();
        $this->newsType = $newsType;
    }

    /**
     * Show News.
     *
     * @return boolean|null
     */
    public function show()
    {
        $options = $this->getOptions();$this->log($options);
        if (empty($options)) {
            return false;
        }

        $url = $method = null;
        extract($options);
        if (!isset($url) or !isset($method)) {
            return false;
        }

        $context = stream_context_create(array(
                'http' => array(
                    'method' => "GET",
                    'timeout' => 10
                )
            )
        );
        $this->htmlDom = file_get_html($url, 0, $context);

        if ($this->htmlDom) {
            call_user_func_array(array($this, $method), array());
        }

        if ( count($this->workflow->results()) == 0 ) {
            $this->workflow->result(
                $method,
                $url,
                static::NEWS_NOT_FOUND_TITLE,
                static::NEWS_NOT_FOUND_CONTENT,
                static::NEWS_ICON_DEFAULT
            );
        }

        echo $this->workflow->toxml();
    }

    /**
     * Get news fetch options.
     *
     * @return array
     */
    private function getOptions()
    {
        $options = array();

        switch ($this->newsType) {
            case 'new':
                $options['url'] = static::URL_BASE;
                $options['method'] = 'getLatests';
                break;
            case 'top10':
            case 'news.top10.week':
                $options['url'] = static::URL_BASE . 'top10.html';
                $options['method'] = 'getWeeklyTopTen';
                break;
            case 'news.top10.month':
                $options['url'] = static::URL_BASE . 'top10.html';
                $options['method'] = 'getMonthlyTopTen';
                break;
            case 'recommend':
                $options['url'] = static::URL_BASE;
                $options['method'] = 'getRecommends';
                break;
            case 'recommend.top10':
            case 'recommend.top10.week':
                $options['url'] = static::URL_BASE . 'top10.html';
                $options['method'] = 'getWeeklyTopTenRecommends';
                break;
            case 'dispute':
            case 'dispute.top10':
            case 'dispute.top10.week':
                $options['url'] = static::URL_BASE . 'top10.html';
                $options['method'] = 'getWeeklyTopTenDisputeNews';
                break;
            case 'dispute.top10.month':
                $options['url'] = static::URL_BASE . 'top10.html';
                $options['method'] = 'getMonthlyTopTenDisputeNews';
                break;
            /*
            case 'cmt':
            case 'comment':
                $options['url'] = static::URL_BASE;
                $options['method'] = 'getComments';
                break;
            */
            default:
        }

        return $options;
    }

    /**
     * Get news icon file path.
     *
     * @param string $iconUrl
     * @param string $iconDir
     *
     * @return string
     */
    private function getNewsIconFilePath($iconUrl = '', $iconDir = null)
    {
        if (!$this->showNewsTopicIcon || !$iconUrl) {
            $iconPath = static::NEWS_ICON_DEFAULT;
        } else {
            $iconName = basename(($iconUrl));
            $iconDir = $iconDir ?: static::NEWS_ICON_DIR_TOPIC;
            $iconPath = $iconDir . DIRECTORY_SEPARATOR . $iconName;

            if (!file_exists($iconPath)) {
                $this->downloadIcon($iconUrl, $iconPath);
            }
            $iconPath = file_exists($iconPath) ? $iconPath : static::NEWS_ICON_DEFAULT;
        }

        return $iconPath;
    }

    /**
     * Download news icon.
     *
     * @param $url      string
     * @param $savePath string
     */
    private function downloadIcon($url, $savePath)
    {
        $dir = dirname($savePath);
        if (!file_exists($dir)) {
            mkdir($dir, 0755, true);
        }

        $context = stream_context_create(array(
                'http' => array(
                    'method' => "GET",
                    'timeout' => 30
                )
            )
        );
        file_put_contents($savePath, file_get_contents($url, 0, $context));
    }

    /**
     * Get the latest news.
     *
     * @return boolean
     */
    private function getLatests()
    {
        if (!$this->htmlDom) {
            return false;
        }

        foreach ($this->htmlDom->find('div.newslist') as $element) {

            $title = $element->find('strong', 0)->plaintext;
            $title = iconv('GB18030', 'UTF-8', trim($title));

            $url = static::URL_BASE . ltrim($element->find('a', 0)->href, '/');

            $id = 0;
            if (preg_match("/articles\/([0-9]+).htm/", $url, $matches)) {
                $id = $matches[1];
            }

            $content = $element->find('dd.desc > span', 0)->plaintext;
            $content = iconv('GB18030', 'UTF-8', trim($content));

            $content = trim(preg_replace("/感谢.+的投递/", '', $content));

            // Get news topic icon local file path.
            $iconUrl = $element->find('dd.desc > a > img', 0)->src;
            $iconPath = $this->getNewsIconFilePath($iconUrl);

            if ($title) {
                $this->workflow->result(
                    $id,
                    $url,
                    $title,
                    $content,
                    $iconPath
                );
            }
        }

        return true;
    }

    private function getWeeklyTopTen()
    {
        return $this->getTopTenNews(1);
    }

    private function getMonthlyTopTen()
    {
        return $this->getTopTenNews(4);
    }

    private function getRecommends()
    {
        if (!$this->htmlDom) {
            return false;
        }

        foreach ($this->htmlDom->find('div#ERBox > dl') as $element) {

            $urlNode = $element->find('a', 0);

            $title = $urlNode->plaintext;
            $title = iconv('GB18030', 'UTF-8', trim($title));

            $content = $element->find('dd', 0)->plaintext;
            $content = iconv('GB18030', 'UTF-8', trim($content));

            $url = static::URL_BASE . ltrim($urlNode->href, '/');

            $id = 0;
            if (preg_match("/articles\/([0-9]+).htm/", $url, $matches)) {
                $id = $matches[1];
            }

            $iconPath = $this->getNewsIconFilePath();

            if ($title) {
                $this->workflow->result(
                    $id,
                    $url,
                    $title,
                    $content,
                    $iconPath
                );
            }
        }

        return true;
    }

    private function getWeeklyTopTenRecommends()
    {
        return $this->getTopTenNews(2);
    }

    private function getWeeklyTopTenDisputeNews()
    {
        return $this->getTopTenNews(0);
    }

    private function getMonthlyTopTenDisputeNews()
    {
        return $this->getTopTenNews(3);
    }

    /**
     * Get top10 type news.
     *
     * @param $index int
     * @return boolean
     */
    private function getTopTenNews($index)
    {
        if (!$this->htmlDom) {
            return false;
        }

        $i = 0;
        foreach ($this->htmlDom->find('div.newslist') as $element) {
            if ($i != $index) {
                $i++;
                continue;
            } else {
                $iconUrl = static::URL_BASE . ltrim($element->find('dd.desc > img', 0)->src, '/');
                $iconPath = $this->getNewsIconFilePath($iconUrl, static::NEWS_ICON_DIR_TOP10);

                foreach ($element->find('p') as $e) {
                    $urlNode = $e->find('a', 0);

                    $title = $urlNode->plaintext;
                    $title = iconv('GB18030', 'UTF-8', trim($title));
                    $content = '';

                    $url = static::URL_BASE . ltrim($urlNode->href, '/');

                    $id = 0;
                    if (preg_match("/articles\/([0-9]+).htm/", $url, $matches)) {
                        $id = $matches[1];
                    }

                    if ($title) {
                        $this->workflow->result(
                            $id,
                            $url,
                            $title,
                            $content,
                            $iconPath
                        );
                    }
                }

                break;
            }
        }

        return true;
    }

    /**
     * Debug Log.
     *
     * @param $var mixed
     * @return void
     */
    private function log($var)
    {
        file_put_contents('log.txt', json_encode($var).PHP_EOL, FILE_APPEND);
    }

}