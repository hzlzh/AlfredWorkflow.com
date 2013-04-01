<?php
/**
 * Alfred Plist Storage Adapter
 *
 * @author David Ferguson (@jdfwarrior)
 * @author Ryan Parman (http://ryanparman.com)
 */

namespace Alfred\Storage;

use Exception;
use RuntimeException;
use Alfred\Exception\JsonException;
use Alfred\Storage\Base as StorageBase;
use Alfred\Storage\StorageInterface;
use Alfred\Utilities as Util;
use Seld\JsonLint\JsonParser;
use Symfony\Component\Process\Process;

class Plist extends StorageBase implements StorageInterface
{
	/**
	 * @type string The name of the .plist file to write to.
	 */
	public $plist = null;

	/**
	 * Constructs a new instance of this class.
	 *
	 * @param string $bundle_id The bundle ID for this workflow.
	 * @param string $plist     The identifier for the .plist file to write to (e.g., "info" instead of "info.plist").
	 */
	public function __construct($bundle_id, $plist)
	{
		parent::__construct();
		$this->plist = $plist . '.plist';
	}

	/**
	 * {@inheritdoc}
	 */
	public function setValue($key, $value)
	{
		try
		{
			$value = json_encode($value);
			$this->handleJsonExceptions();
		}
		catch (JsonException $e)
		{
			throw $e;
		}

		$plist = $this->getStoragePath();
		Util::run("defaults write \"${plist}\" ${key} \"${value}\"");
	}

	/**
	 * {@inheritdoc}
	 */
	public function setValues($data)
	{
		foreach ($data as $key => $value)
		{
			$this->setValue($key, $value);
		}
	}

	/**
	 * {@inheritdoc}
	 */
	public function getValue($key)
	{
		$parser = new JsonParser();
		$plist = $this->getStoragePath();
		$value = Util::run("defaults read \"${plist}\" ${key}");

		try
		{
			$parser->lint($json);
			return $parser->parse($json);
		}
		catch (Exception $e)
		{
			throw $e;
		}
	}
}
