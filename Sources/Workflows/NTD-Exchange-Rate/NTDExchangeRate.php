<?php

/**
* Fetch NTD Foreign Exchange Rate from Bank Of Taiwan
* 
* Author: visioncan@gmail.com
* web: http://blog.visioncan.com/
* Version 1.0
* 
* Flag icons made by www.IconDrawer.com
* Workflows Library by David Ferguson (@jdfwarrior)
* 
*/
require_once('workflows.php');

class NTDExchangeRate
{
	const BOT_HOST   = 'http://rate.bot.com.tw';
	const RATE_URL = '/Pages/Static/UIP003.zh-TW.htm';
	const HISTORY_CSV = '/Pages/UIP004/Download0042.ashx?lang=zh-TW&fileType=1&afterOrNot=0&whom=%s&date1=%s&date2=%s';
	const HISTORY_LINK = '/Pages/UIP004/UIP004INQ1.aspx?lang=zh-TW&whom3=%s';
	private $csvDate;               //date of exchange rate
	private $exchangeData;
	private $workflows;
	private $past = 9;              // exchange rate at the number of days in the past
	private $currentCurency = null;
	private $outputItems = array(); // for Alfred
	private $Currency = array(
		'AUD' => array(
			'name' => '澳幣',
			'flag' => 'Australia.png'
		),
		'CAD' => array(
			'name' => '加拿大幣',
			'flag' => 'Canada.png'
		),
		'CHF' => array(
			'name' => '瑞士法郎',
			'flag' => 'Switzerland.png'
		),
		'CNY' => array(
			'name' => '人民幣',
			'flag' => 'China.png'
		),
		'EUR' => array(
			'name' => '歐元',
			'flag' => 'European-Union.png'
		),
		'GBP' => array(
			'name' => '英鎊',
			'flag' => 'United-Kingdom(Great-Britain).png'
		),
		'HKD' => array(
			'name' => '港幣',
			'flag' => 'Hong-Kong.png'
		),
		'IDR' => array(
			'name' => '印尼幣',
			'flag' => 'Indonezia.png'
		),
		'JPY' => array(
			'name' => '日圓',
			'flag' => 'Japan.png'
		),
		'KRW' => array(
			'name' => '韓元',
			'flag' => 'South-Korea.png'
		),
		'MYR' => array(
			'name' => ' 馬來幣',
			'flag' => 'Malaysia.png'
		),
		'NZD' => array(
			'name' => '紐元',
			'flag' => 'New-Zealand.png'
		),
		'PHP' => array(
			'name' => '菲國比索',
			'flag' => 'Philippines.png'
		),
		'SEK' => array(
			'name' => '瑞典幣',
			'flag' => 'Sweden.png'
		),
		'SGD' => array(
			'name' => '新加坡幣',
			'flag' => 'Singapore.png'
		),
		'THB' => array(
			'name' => '泰銖',
			'flag' => 'Thailand.png'
		),
		'USD' => array(
			'name' => '美金',
			'flag' => 'United-States-of-America(USA).png'
		),
		'VND' => array(
			'name' => '越南盾',
			'flag' => 'Viet-Nam.png'
		),
		'ZAR' => array(
			'name' => '南非幣',
			'flag' => 'South-Africa.png'
		),
		'NTD' => array(
			'name' => '新台幣',
			'flag' => 'Taiwan.png'
		)
	);

	//HTML Entity (hex)
	private $emo = array(
		'up' => '&#x1f53c;',
		'down' => '&#x1f53d;'
	);

	public function __construct($currency = null)
	{
		date_default_timezone_set('Asia/Taipei');
		$this->workflows = new Workflows();
		if ($currency == null)
		{
			$this->getAllExchange();
		}
		else if(strlen($currency) == 3 && array_key_exists(strtoupper($currency), $this->Currency))
		{
			$this->currentCurency = strtoupper($currency);
			$this->getExchangeBy($this->currentCurency);
		}
	}

	private function getAllExchange()
	{
		$botHTML = $this->curlGet(self::BOT_HOST . self::RATE_URL);

		$resint1 = preg_match('/id ?= ?["|\']DownloadCsv["|\'] ?.*>/', $botHTML, $match1);
		if ($resint1 !== 0)
		{
			$resint2 = preg_match('/\.href ?= ?\'(.+)\'/', $match1[0], $match2);
			if ($resint1 !== 0)
			{
				$csvUrl = $match2[1];
			}
			else
			{
				$this->printError('NO_MATCH_HREF');
			}
		}
		else
		{
			$this->printError('NO_MATCH_ELEMENT');
		}
		
		//date
		preg_match('/date=(.*):/', $csvUrl, $match_date);
		$this->csvDate = preg_replace('/T/', ' ', $match_date[1]);

		//get csv and convert
		$csvOutput = $this->curlGet(self::BOT_HOST . $csvUrl);
		if ($csvOutput == '很抱歉，本次查詢找不到任何一筆資料！')
		{
			$this->printError('NO_RESULT', $csvOutput);
		}
		else
		{
			$this->exchangeData = $this->convertCsv($csvOutput);
		}
		$botHTML = $csvOutput = null;
		$this->generateExchange();
	}

	private function getExchangeBy($currency)
	{
		$pastDay = date("Ymd", mktime(0, 0, 0, date("m"), date("d") - $this->past, date("Y")));
		$today = date("Ymd");
		$pastCSVUrl = sprintf( self::BOT_HOST . self::HISTORY_CSV, $currency, $pastDay, $today);
		$csvOutput = $this->curlGet($pastCSVUrl);
		$this->exchangeData = $this->convertCsv($csvOutput);
		$this->generateExchange();
	}

	/**
	 * convert Exchange Rate Csv to array
	 * @return array
	 */
	private function convertCsv($csv)
	{
		$result;
		$wholeCSV = str_getcsv($csv, "\n");
		for ($i = 1; $i < sizeof($wholeCSV); $i++) { 
			$row = explode(",", preg_replace('/\s+/', '', $wholeCSV[$i]));
			if ($this->currentCurency == null) {
				$result[array_shift($row)] = array(
					'Buying'  => array_slice($row, 1, 9),
					'Selling' => array_slice($row, 11, 9)
				);
			}else{
				$result[] = array(
					'date'    => array_shift($row),
					'Buying'  => array_slice($row, 2, 9),
					'Selling' => array_slice($row, 12, 9)
				);
			}
			
		}
		return $result;
	}

	/**
	 * get web data
	 * @param  string $url
	 * @return string $output
	 */
	private function curlGet($url)
	{
		$ch = curl_init();
		$options = array(
			CURLOPT_URL => htmlspecialchars_decode($url), 
			CURLOPT_HEADER => false,
			CURLOPT_RETURNTRANSFER => true,
			CURLOPT_USERAGENT => "Google Bot",
			CURLOPT_FOLLOWLOCATION => true
		);
		curl_setopt_array($ch, $options);
		$output = curl_exec($ch);
		$error  = curl_error($ch);
		curl_close($ch);
		if ($error)
		{
			$this->printError('CURL_ERROR', (String)$error);
		}
		else
		{
			return $output;
		}
	}

	/**
	 * Print Error
	 * @param  String $err  Error String type
	 * @param  String $info deisplay error information , default is empty
	 */
	private function printError($err, $info = '')
	{
		$displayErr = '';
		switch ($err) {
			case 'CURL_ERROR':
				$displayErr = 'Fetch Error';
				break;
			case 'NO_MATCH_HREF':
				$displayErr = 'Match Error: not match download link';
				break;
			case 'NO_MATCH_ELEMENT':
				$displayErr = 'Match Error: not match element';
				break;
			case 'NO_RESULT':
				$displayErr = 'Fetch data is Empty';
				break;
		}
		$this->generateError($displayErr . ' ' . $info);
		$this->pxml();
		exit;
	}

	/**
	 * @return string return ios emoji
	 */
	private function emoji($symbol)
	{
		return html_entity_decode($this->emo[$symbol], ENT_NOQUOTES, 'UTF-8');
	}

	private function formateDate($date)
	{
		$d = DateTime::createFromFormat('Ymd', $date);
		return $d->format('Y-m-d');
	}

	private function formatePrice($price)
	{
		return (float)$price == 0 ? '-' :  (float)$price;
	}

	private function comparehHistory($key)
	{
		if ($key < count($this->exchangeData) - 1) {
			return ((float)$this->exchangeData[$key]['Selling'][0] > (float)$this->exchangeData[$key + 1]['Selling'][0]) ? $this->emoji('up') : $this->emoji('down');
		}
	}
	/**
	 * generate Exchange Rate to $this->outputItems for Alfred output
	 */
	private function generateExchange(){
		$ind = 0;
		if ($this->currentCurency == null)
		{
			foreach ($this->exchangeData as $key => $val)
			{
				$this->outputItems[] = array(
					'uid'      => $ind ++,
					'arg'      => $this->formatePrice($val['Selling'][0]),
					'title'    => $this->formatePrice($val['Selling'][0]),
					'subtitle' => $this->Currency[$key]['name'] . ' ' . $key .' | 現金賣出：'. $this->formatePrice($val['Selling'][0]) .' 現金買入：'. $this->formatePrice($val['Buying'][0]),
					'icon'     => 'flags/' . $this->Currency[$key]['flag']
				);
			}
		}
		else
		{
			foreach ($this->exchangeData as $key => $val)
			{
				$this->outputItems[] = array(
					'uid'      => $ind ++,
					'arg'      => sprintf(self::BOT_HOST . self::HISTORY_LINK, $this->currentCurency),
					'title'    => $this->comparehHistory($key) . ' ' . $this->formatePrice($val['Selling'][0]),
					'subtitle' => $this->formateDate($val['date']),
					'icon'     => 'flags/' . $this->Currency[$this->currentCurency]['flag']
				);
			}
		}
		
	}

	private function generateError($err){
		$this->outputItems[] = array(
			'uid'      => '0',
			'arg'      => $err,
			'title'    => $err,
			'subtitle' => '',
			'icon'     => 'icon.png'
		);
	}

	/**
	 * create xml for Alfred
	 */
	public function pxml()
	{
		echo $this->workflows->toxml( $this->outputItems );
	}
}
?>