<?php 
class QT
{
	private $market;
	private $category;

	function __construct($qtData = false, $market, $category) {
		$this->market = $market;
		$this->category = $category;
		if($qtData) {
			$this->items = $qtData;
		}
	}
	//股票名称
	public function getName(){
		return $this->items[1];
	}
	//获得涨跌幅
	public function getPercent() {
		$ret = $this->items[32];

		if($ret > 0) {
			$ret = '+'.$ret;
		}

		return $ret.'%';
	}
	//得到当前市价
    public function getPrice(){
    	if($this->items[40] && $this->category != 'ZS') {
			return $this->items[40];
		} else {
			return $this->items[3];
		}
	}
    //得到昨收价
    public function getLastClosePrice(){
		return $this->items[4];
	}
    //得到今开盘
    public function getTodayOpenPrice(){
		return $this->items[5];
	}
	//最高
    public function getHighPrice(){
		return $this->items[33];
	}
	//最低
    public function getLowPrice(){
		return $this->items[34];
	}
	//获取状态
	public function getStatus() {
		return $this->items[40];
	}
	//获取普通状态
	public function getErrorStatus() {
		$status = $this->getStatus();
		switch($status) {
			case 'D':
				return '退市';
			case 'S':
				return '停牌';
			case 'U':
				return '未上市';
			case 'Z':
				return '暂停上市';
			break;
		}

		return false;
	}
}

class QTHk extends QT {}

class QTUs extends QT {}

class QTJj extends QT
{
	public function getPrice(){
		return $this->items[3];		
	}

	public function getValueDate() {
		return $this->items[2];
	}

	public function isHBType() {
		return $this->items[18] == '货币型';
	}

	public function getEarnPer() {
		return $this->items[27];
	}

	public function getYearRadio() {
		return $this->items[28].'%';
	}
}