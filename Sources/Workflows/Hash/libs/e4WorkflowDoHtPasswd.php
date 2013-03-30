<?php

class e4WorkflowDoHtPasswd extends e4WorkflowCommands
{
	public function run($inQuery, $args)
	{
		$hash = crypt($inQuery, base64_encode($inQuery));
		if ($args[1] == 'XML')
			return array(array(
				'uid' => 'htpasswd',
				'arg' => $hash,
				'title' => 'htpasswd: '.$hash,
				'icon' => 'icon.png',
				'valid' => 'true'));
		return $hash;
	}
}

?>