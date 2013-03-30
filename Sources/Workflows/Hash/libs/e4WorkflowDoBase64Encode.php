<?php

class e4WorkflowDoBase64Encode extends e4WorkflowCommands
{
	public function run($inQuery, $args)
	{
		$hash = $hash = file_exists($inQuery) ? base64_encode(file_get_contents($inQuery)) : base64_encode($inQuery);
		if ($args[1] == 'XML')
			return array(array(
				'uid' => 'base64_encode',
				'arg' => $hash,
				'title' => 'base64_encode: '.$hash,
				'icon' => 'icon.png',
				'valid' => 'true'));
		return $hash;
	}
}

?>