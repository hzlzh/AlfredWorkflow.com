<?php
/**
 * Alfred Workflow Utilities
 *
 * @author Ryan Parman (http://ryanparman.com)
 */

namespace Alfred;

use RuntimeException;
use Symfony\Component\Process\Process;

class Utilities
{
	/**
	 * Runs a command on the shell.
	 *
	 * @param  string  $command The command to run on the shell.
	 * @param  integer $timeout The number of seconds to allow the command to run before it should be
	 *                          considered timed-out. The default value is `120`.
	 * @return string           The output from the command.
	 *
	 * @throws RuntimeException Thrown if the shell returns an error code.
	 */
	public static function run($command, $timeout = 120)
	{
		$process = new Process($command);
		$process->setTimeout($timeout);
		$process->run();

		if (!$process->isSuccessful())
		{
			throw new RuntimeException($process->getErrorOutput());
		}

		return $process->getOutput();
	}
}
