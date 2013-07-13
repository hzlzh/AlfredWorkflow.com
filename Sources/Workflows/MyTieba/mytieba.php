<?php
/*========================================================================
#   FileName: mytieba.php
#     Author: Creturn
#      Email: master@creturn.com
#   HomePage: http://www.creturn.com
# LastChange: 2013-07-05 02:24:51
========================================================================*/
require_once('workflows.php');
class App
{
	private static $_instance;
	private $_workflows;
	function __construct(){
		$this->_workflows = new workflows();
	}
	
	public function getInstance()
	{
		if (!self::$_instance instanceof self) {
			self::$_instance = new App();
		}
		return self::$_instance;
	}
	public function request($url)
	{
		return $this->_workflows->request($url);
	}
	public function filterDataList($data)
	{
		$dataList = array();
		preg_match_all('/<div class="i">(.*?)<\/div>/', $data, $dataList);
		return $dataList[1];
	}
	public function getData($keyword)
	{
		//后面可以在这里加入缓存机制
		//缓存路径$this->_workflows->cache();
		$url = 'http://wapp.baidu.com/f?kw=' . $keyword;
		$data = $this->request($url);
		$num = 1;
		foreach( $this->filterDataList($data) as $item ) {
			preg_match('/<p>(.*?)<\/p>/', $item, $time);
			preg_match('/kz=(.*?)&amp;/', $item, $id);
			$time= " " . str_replace('&#160;', ' ', $time[1]);
			preg_match('/<a (.*?)>(.*?)<\/a>/',$item, $title);
			$item = str_replace('&#160;', '', $title[2]);
			$this->_workflows->result($num . '.' . time(), 'http://tieba.baidu.com/p/' . $id[1], $item, $time, 'icon.png');
			$num ++;
		}
		
		return $this->_workflows->toxml();
	}
	public function run($query)
	{
		return $this->getData($query);
	}
}
#echo App::getInstance()->run('大主宰');
?>
