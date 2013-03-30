<?php


// Library autoloader
define('ROOT', dirname($_SERVER['SCRIPT_NAME']).'/');
function __autoload($className)
{
	include ROOT.'libs/'.$className.'.php';
}


// Loading application config
$app = new e4WorkflowApp(ROOT);
echo $app->run($argv);


// e4Workflow library
class e4WorkflowApp
{
	public $root = false;
	public $appDefaultCommand = false;
	public $appCommands = array();

	public $name = 'global';
	public $id = 'global';
	public $version = 1.0;
	public $ttl = 3600;

	public $defaults = array();
	protected $defaultsHash;

	public $cachePath = false;
	protected $configLoaded = false;
	public $configPath = false;

	public function __construct($root=false, $path='appConfig.json')
	{
		$this->root = $root ?: dirname($_SERVER['SCRIPT_NAME']).'/';

		if (($e4Config = file_get_contents($root.$path)) === false)
			throw new Exception('Config file "'.$path.'" not found', 1);
		if (($e4Config = json_decode($e4Config, true)) === false)
			throw new Exception('Invalid config file syntax', 1);

		// Loading app informations
		$this->setName($e4Config['app']['name'], $e4Config['app']['id']);
		$this->setVersion($e4Config['app']['version']);
		$this->setCacheTTL($e4Config['app']['cacheTTL']);

		// Loading default configuration
		if (count($e4Config['defaults']) > 0)
			foreach ($e4Config['defaults'] AS $key => $value)
				$this->addDefault($key, $value);

		// Loading app commands
		if (count($e4Config['commands']) > 0)
			foreach ($e4Config['commands'] AS $info)
				$this->addCommand($info['id'], $info);

		// Callback functions on application exit
		register_shutdown_function(array($this, 'exportConfig'));
		register_shutdown_function(array($this, 'clearCacheFiles'));
	}
	public function setName($name, $id)
	{
		$this->name = trim($name);

		$this->id = $id ?: strtolower(str_replace(' ', '', $this->name));
	 	$this->cachePath = $_SERVER['HOME'].'/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data/'.$this->id.'/';
	 	$this->configPath = $_SERVER['HOME'].'/Library/Application Support/Alfred 2/Workflow Data/'.$this->id.'/';

	 	@mkdir($this->cachePath, 0777, true);
	 	@mkdir($this->configPath, 0777, true);
	}
	public function setVersion($version=1)
	{
		$this->version = trim($version);
	}
	public function setCacheTTL($ttl=3600)
	{
		$this->ttl = $ttl ?: 3600;
	}
	public function addCommand($key, $configs)
	{
		$configs['icon'] = $configs['icon'] ?: 'icon.png';
		$configs['valid'] = $configs['valid'] ? 'yes' : 'no';
		if ($configs['default'] === true)
			$this->appDefaultCommand = $configs['id'];
		$this->appCommands[$key] = $configs;
	}

	public function run($argv)
	{
		array_shift($argv);
		$query = trim($argv[0]) ?: '';

		$objects = array();
		$out = array();

		// Reading and executing input query
		if ($argv[1] != 'default' && count($this->appCommands) > 0)
			foreach ($this->appCommands AS $key => $config)
				if (!$query || preg_match('/^'.preg_quote(substr($query, 0, strlen($key)), '/').'/i', $key))
					$objects[] = $this->loadCommander($key, $query);


		// Filter results and running requests
		if (!count($objects) && $this->appDefaultCommand !== false)
			$out = $this->loadCommander($this->appDefaultCommand, $query)->run($query, $argv);
		elseif (count($objects) == 1 && ($data = $objects[0]->getQueryMatch()) !== false)
			$out = $objects[0]->run($data[1], $argv);
		elseif (count($objects) > 0)
			foreach($objects AS $object)
				$out[] = $object->getCommandSuggest();


		// Transform output array to XML
		if (!is_array($out))
			return $out;
		
		$xmlObject = new SimpleXMLElement("<items></items>");
		$tmpTypes = array(
			'uid' => 'addAttribute',
			'arg' => 'addAttribute',
			'valid' => 'addAttribute',
			'autocomplete' => 'addAttribute');
		foreach($out AS $rows)
		{
			$objItem = $xmlObject->addChild('item');
			foreach ($rows AS $key => $value)
				$objItem->{ $tmpTypes[$key] ?: 'addChild' }($key, $value);
		}
		return $xmlObject->asXML();
	}

	public function loadCommander($id, $query)
	{
		$config = $this->appCommands[$id];
		$className = 'e4WorkflowDo'.$config['cmd'];
		return new $className($this, $query, $config);
	}

	public function addDefault($key, $value)
	{
		if (!$this->getDefault($key))
			$this->setDefault($key, $value);
	}
	public function getDefault($key)
	{
		$this->importConfig();
		return $this->defaults[$key];
	}
	public function setDefault($key, $value)
	{
		$this->importConfig();
		$this->defaults[$key] = $value;
	}
	public function importConfig()
	{
		if ($this->cacheLoaded)
			return false;
		$this->cacheLoaded = true;
		$content = @file_get_contents($this->configPath.'config.json');
		$this->defaults = @json_decode($content, true) ?: array();
		$this->defaultsHash = md5($content) ?: '';
		return true;
	}
	public function exportConfig()
	{
		$content = json_encode($this->defaults);
		if (md5($content) == $this->defaultsHash)
			return false;
		file_put_contents($this->configPath.'config.json', $content);
		return true;
	}

	public function sendHTTPRequest($url, $post=null, $ttl=300)
	{
		$cacheFileName = $this->cachePath.'/'.md5($url).'.cache';

		if (file_exists($cacheFileName) && time()-filemtime($cacheFileName) < $ttl)
			return gzuncompress(file_get_contents($cacheFileName));

		$ch = curl_init();
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_HEADER, 0);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_ENCODING, 'UTF-8');
		$response = curl_exec($ch);

		if (curl_getinfo($ch, CURLINFO_HTTP_CODE) != 200 || !$response)
			$response = false;
		else
			file_put_contents($cacheFileName, gzcompress($response));

		curl_close($ch);
		return $response;
	}
	
	public function clearCacheFiles()
	{
		$dp = opendir($this->cachePath);
		while ($name = readdir($dp))
			if (is_file($this->cachePath.$name) && time()-filemtime($this->cachePath.$name) > $this->ttl)
				unlink($this->cachePath.$name);
		closedir($dp);
	}
}

abstract class e4WorkflowCommands
{
	protected $inQuery = '';
	protected $inID = '';
	protected $inConfig = array();

	public function __construct(e4WorkflowApp $app, $query, $config)
	{
		$this->app = $app;
		$this->inQuery = $query;
		$this->inConfig = $config;
		$this->inID = $this->inConfig['id'];
	}
	public function getConfig($key=false)
	{
		return $key ? $this->inConfig[$key] : $this->inConfig;
	}
	public function getQueryMatch()
	{
		if (preg_match('/^'.preg_quote($this->inID).'\s*(.*)\s*$/i', $this->inQuery, $out))
			return $out;
		return false;
	}
	public function getCommandSuggest()
	{
		return array(
			'uid' => $this->inID,
			'arg' => 'none',
			'title' => $this->getCommandSuggestValue('title'),
			'subtitle' => $this->getCommandSuggestValue('subtitle'),
			'autocomplete' => $this->inID.' ',
			'icon' => $this->getCommandSuggestValue('icon'),
			'valid' => $this->getCommandSuggestValue('valid'));
	}
	public function  getCommandSuggestValue($row)
	{
		return $this->inConfig[$row] ?: null;
	}

	public function run($inQuery, $args)
	{
		return array(array(
			'uid' => 'none',
			'arg' => 'none',
			'title' => 'Internal error',
			'subtitle' => 'Uncompleted "'.$this->inID.'" definition!',
			'icon' => 'icon.png',
			'valid' => 'no'));
	}
}

?>