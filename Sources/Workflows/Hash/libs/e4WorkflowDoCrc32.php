<?php

class e4WorkflowDoCrc32 extends e4WorkflowCommands
{
	public function run($inQuery, $args)
	{
		$hash = hash('crc32', $inQuery);
		if ($args[1] == 'XML')
			return array(array(
				'uid' => 'crc32',
				'arg' => $hash,
				'title' => 'crc32: '.$hash,
				'icon' => 'icon.png',
				'valid' => 'true'));
		return $hash;
	}
}

?>