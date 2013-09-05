<?php
require_once('workflows.php');

// TODO: To support batch query.
// TODO: To use local storage to save a personal list.

class Stock extends Workflows {

    private $types = array('sh', 'sz');
    private $api = array('price'=> 'http://hq.sinajs.cn/list=', 'info' => 'http://suggest3.sinajs.cn/suggest/name=info&key=');
    private $stocks = array();

    /**
    * Description:
    * Wrap the super class's request, to convert the charcode, and process jsonp to a PHP variable
    *
    * @param string - a url that will be requested
    * @return string - the data returned by the remote API
    */
    protected function curl($url) {
        eval(preg_replace('/^(.+)\=/i', '$data = ', iconv("GBK","UTF-8",$this->request($url))));
        return $data;
    }

    /**
    * Description:
    * Retrieve single company's price from SINA's API
    *
    * @param string - a company's code with its exchange flag at the beginning
    * @return null - but store results in a local variable $this->stock
    */
    protected function get_price($no){
        $keys = array('type','code','name', 'opening', 'closing', 'now', 'high', 'low', 'buy', 'sell', 'volume', 'amount', '买一量', '买一价', '买二量', '买二价', '买三量', '买三价', '买四量', '买四价', '买五量', '买五价', '卖一量', '卖一价', '卖二量', '卖二价', '卖三量', '卖三价', '卖四量', '卖四价', '卖五量', '卖五价', 'date', 'time', 'other');
        $stock = $this->curl($this->api['price'] . "$no");
        if($stock != "") {
            $type = substr($no, 0, 2);
            $code = substr($no, 2);
            $values = explode(",", $type.','.$code.','.$stock);
            array_push($this->stocks, array_combine($keys, $values));
        }
    }

    /**
    * Description:
    * Retrieve a list of company with the short form of Pinyin of a company's name
    *
    * @param string - a short form of company name's Pinyin
    * @return array - contains the stock information of at least one conpany
    *         false - if there's no match
    */
    protected function get_info($chars) {
        $keys = array('brief', 'board', 'code', 'Code', 'name', 'pinyin');
        $info = $this->curl($this->api['info'].$chars);

        function combine(&$value, $key, $keys) {
            $arr_values = explode(',', $value);
            if(count($arr_values) == count($keys)) {
                $value = array_combine($keys, $arr_values);
            } else {
                $value = array();
            }
        }

        function filter($data) {
            if(count($data) > 0 && $data['board'] == '11') return $data;
        }

        if($info == "") {
            $rt = array();
        } else {
            $values = explode(";", $info);
            array_walk($values, "combine", $keys);
            $rt = array_filter($values, "filter");
        }

        return $rt;
    }

    /**
    * Description:
    * Output with Workflows' help
    *
    * @return string - xml of alfred recognized format
    *
    */
    protected function output() {
        //  $suggest->id, $suggest->alt, $suggest->title, '作者: '. implode(",", $suggest->author) .' 评分: '. $suggest->rating->average .'/'. $suggest->rating->numRaters .' 标签: '. implode(",", array_map('get_name', $suggest->tags)), 'C5C34466-B858-4F14-BF5E-FD05FA0903DA.png' 
        foreach ($this->stocks as $key => $value) {
            $change = round(($value['now']-$value['closing'])/$value['closing']*10000)/100;
            $change = ($change > 0 ? '+'.$change : $change).'%';
            $volume = floor($value['volume'] / 100);
            $amount = floor($value['amount'] / 10000);
            $arg    = "http://finance.sina.com.cn/realstock/company/".$value['type'].$value['code']."/nc.shtml";
            $this->result(md5($value['name']), $arg, $value['code'].'  '.$value['name'].'  '.$value['now'].' ('.$change.')', '量: '.$volume.'手 额: '. $amount.'万 买: '.$value['buy'].' 卖: '.$value['sell'].' 高: '.$value['high'].' 低: '.$value['low'].' 开: '.$value['opening'].' 收: '.$value['closing'], $value['type'].'.png');
        }
        if(count($this->results()) == 0) {
            $this->result('0','null','没能找到相应的股票','您可能输入了错误的代码，请检查一下吧','tip.png');
        }
        return $this->toxml();
    }

    /**
    * Description:
    * Add one or more stocks to personal list for the purpose of querying in a single request.
    *
    * @param string - comma separated string of code of stock
    * @return notice - system notice center will show the count of successful results.
    *
    */
    public function add($chars) {

    }

    /**
    * Description:
    * Remove one from personal list.
    *
    * @param string - one code of stock
    * @return notice - system notice center will show the notice of success.
    *
    */
    public function remove($chars) {

    }

    /**
    * Description:
    * Show all personal stocks with data stored at local
    *
    * @return string - xml formatted data for alfred
    *
    */
    public function show() {

    }

    /**
    * Description:
    * Get input characters while user typing and choose correct function to deal with
    *
    * @param string - could be a stock code or a short form of a company's name
    * @return string - xml formatted data for alfred showing
    * 
    */
    public function query($chars) {
        if(preg_match('/^\d{6}$/', $chars)) {
            foreach ($this->types as $key => $value) {
                $this->get_price($value.$chars);   
            }
        } else {
            $info = $this->get_info($chars);
            foreach ($info as $key => $value) {
                $this->get_price($value['Code']);
            }
        }
        return $this->output();
    }
}

// $s = new Stock();
// print_r($s->query('s33'));
