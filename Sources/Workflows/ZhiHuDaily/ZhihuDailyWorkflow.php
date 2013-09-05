<?php
/**
 * a workflow for ZhiHuDaily.
 * @version 0.5
 * @author Bill Cheng(so89898@gmail.com)
 */

require 'vendor/workflows.php';

/**
 * Class ZhiHuWorkFlow
 */
class ZhiHuWorkFlow
{

	/**
     * Present the Zhihu Daily.
     */
    public function show()
    {
    	$webcode = json_decode(file_get_contents('http://news.at.zhihu.com/api/1.2/news/latest'), 1);
		$workflow = new Workflows();
		for($i=0;$i<count($webcode['news']);$i++){
    		$workflow->result($i, $webcode['news'][$i]['share_url'], $webcode['news'][$i]['title'], null, $this->getNewsIconFilePath($webcode['news'][$i]['thumbnail'], null));
		}

		echo $workflow->toxml();
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
        if (!$iconUrl) {
            $iconPath = 'icon.png';
        } else {
            $iconName = basename(($iconUrl));
            $iconDir = $iconDir ?: 'icons/news/';
            $iconPath = $iconDir . DIRECTORY_SEPARATOR . $iconName;

            if (!file_exists($iconPath)) {
                $this->downloadIcon($iconUrl, $iconPath);
            }
            $iconPath = file_exists($iconPath) ? $iconPath : 'icon.png';
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
}
	