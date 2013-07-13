<?php
/**
 * Alfred Base Storage Adapter
 *
 * @author David Ferguson (@jdfwarrior)
 * @author Ryan Parman (http://ryanparman.com)
 */

namespace Alfred\Storage;

use Alfred\Exception\JsonException;
use Alfred\Utilities as Util;
use Symfony\Component\Filesystem\Filesystem;

abstract class Base
{
	const CACHE_PATH = '/Library/Caches/com.runningwithcrayons.Alfred-2/Workflow Data';
	const DATA_PATH = '/Library/Application Support/Alfred 2/Workflow Data';

	/**
	 * @type string The cache directory for the workflow.
	 */
	private $cache = null;

	/**
	 * @type string The data directory for the workflow.
	 */
	private $data = null;

	/**
	 * @type string The bundle ID for the workflow.
	 */
	private $bundle = null;

	/**
	 * @type string The working directory for the workflow.
	 */
	private $path = null;

	/**
	 * @type string The current user's `$HOME` directory.
	 */
	private $home = null;

	/**
	 * Gets the value of the specified property.
	 *
	 * @param  string $name The name of the property.
	 * @return mixed        The data stored in the property.
	 */
	public function __get($name)
	{
		return $this->$name;
	}

	/**
	 * Gets the value of the specified property.
	 *
	 * @param  string $name  The name of the property.
	 * @param  mixed  $value The value to store.
	 * @return mixed         The data stored in the property.
	 */
	public function __set($name, $value)
	{
		$this->$name = $value;
		return $this->$name;
	}

	/**
	 * Instantiates the class.
	 *
	 * @param string $bundle_id The bundle ID to give to the workflow.
	 */
	public function __construct($bundle_id)
	{
		$fs = new Filesystem;

		$this->path = Util::run('pwd');
		$this->home = Util::run('printf $HOME');
		$this->bundle = $bundle_id;

		if (!is_null($bundle_id))
		{
			$this->bundle = $bundle_id;
		}

		$this->cache = $this->home . self::CACHE_PATH . '/' . $this->bundle;
		$this->data  = $this->home . self::DATA_PATH . '/' . $this->bundle;

		if (!file_exists($this->cache))
		{
			$fs->mkdir($this->cache);
		}

		if (!file_exists($this->data))
		{
			$fs->mkdir($this->data);
		}
	}

	/**
	 * Determines the best location for writing the .plist data.
	 *
	 * @return string The file system path to write the plist data to.
	 */
	public function getStoragePath()
	{
		foreach (array($this->path, $this->data, $this->cache) as $path)
		{
			if (file_exists($path . '/' . $this->plist))
			{
				return $path . '/' . $this->plist;
			}
		}

		return $this->data . '/' . $this->plist;
	}

	/**
	 * Handles throwing JSON-related exceptions, if any.
	 *
	 * @throws JsonException
	 */
	public function handleJsonExceptions()
	{
		switch (json_last_error())
		{
			case JSON_ERROR_NONE:
				break;

			case JSON_ERROR_DEPTH:
				throw new JsonException('Maximum stack depth exceeded.');
				break;

			case JSON_ERROR_STATE_MISMATCH:
				throw new JsonException('Underflow or the modes mismatch.');
				break;

			case JSON_ERROR_CTRL_CHAR:
				throw new JsonException('Unexpected control character found.');
				break;

			case JSON_ERROR_SYNTAX:
				throw new JsonException('Syntax error; Malformed JSON.');
				break;

			case JSON_ERROR_UTF8:
				throw new JsonException('Malformed UTF-8 characters; Possibly incorrectly encoded.');
				break;

			default:
				throw new JsonException('Unknown JSON encoding error.');
				break;
		}
	}
}
