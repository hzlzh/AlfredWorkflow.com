<?php
/**
 * Name: 		Stock
 * Author: 		weixinchen(weixinchen@tencent.com)
 * Revised: 	13/10/2015
 * Version:		0.1
 */
require_once("workflows.php");
require_once("filecache.php");

class SmartBox extends Workflows
{
	private $keyword = "";
	private $queryUrl = "http://smartbox.gtimg.cn/s3/?&t=all&format=jsonp&q=";

	function setKeyWord($keyword) {
		$this->keyword = $keyword;
	}

	function search() {
		$qtData = FileCache::get($this->keyword);

		if(!$qtData) {
			$url = $this->queryUrl.urlencode($this->keyword);

			$request_result = $this->request($url);
			$json = json_decode($request_result);
			$qtData = $json->data;
		}

		if(count($qtData) > 0) {
			FileCache::set($this->keyword, $qtData);
			foreach ($qtData as $key => $value) {
				$stock = new Stock($value);
				$this->result($key, $stock->getLink(), $stock->getTitle(), $stock->getSubTitle(), null);
			}
		} else {
			$this->lastPlaceholder();
		}
	}

	function lastPlaceholder() {
		$this->result(0, 'http://gu.qq.com/i', '没有找到股票？进入我的自选股查找', null, null);		
	}
}

class Stock
{
	// 市场: sh|sz|hk|us|jj
	public $market;
	// 市场类类别:
	public $typeName;
	// 代码
	public $code;
	// 详细代码
	public $fullCode;
	// 名称
	public $name;
	// 拼音
	public $pinyin;
	// 类别
	public $category;

	function __construct($data) {
		$result = explode("~", $data);
		$this->market = $result[0];
		$this->code = $result[1];
		$this->fullCode = $this->market.$this->code;
		$this->name = $result[2];
		$this->pinyin = $result[3];
		$this->category = $result[4];

		$this->parse();
	}

	private function parse() {
		if($this->category == 'QH-QH') {
			$this->typeName = '期货';
		} else if($this->category == 'QH-IF') {
			$this->typeName = '股期';
		} else if($this->market == 'us') {
			$this->typeName = '美股';
		} else if($this->market == 'hk') {
			$this->typeName = '港股';
		} else if($this->market == 'jj') {
			$this->typeName = '基金';
		} else if($this->market == 'sh' || $this->market == 'sz') {
			switch($this->category) {
				case 'FJ':
				case 'LOF':
				case 'ETF':
					$this->typeName = '基金';
				break;
				case 'ZS':
				case 'GP-A':
				case 'GP-B':
				case 'ZQ':
				case 'QZ':
				default:
					if($this->market == 'sh') {
						$this->typeName = '上海';
					} else {
						$this->typeName = '深圳';
					}
				break;
			}
		} else {
			$this->typeName = '未知';
		}
	}

	function getTitle() {
		$typeName = $this->typeName;
		$name = $this->name;
		$code = $this->code;

		return "[{$typeName}] {$name} {$code}";
	}

	function getSubTitle() {
		$fullCode = $this->fullCode;
		if($this->pinyin != '*') {
			$pinyin = strtoupper($this->pinyin);
			return "{$fullCode}（{$pinyin}）";
		} else {
			return "{$fullCode}";
		}

	}

	function getLink() {
		return "http://gu.qq.com/".$this->fullCode;
	}

}
?>