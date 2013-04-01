<?php
/**
 * Alfred Workflow Helper
 *
 * Provides several useful functions for retrieving, parsing and formatting data
 * to be used with Alfred 2 Workflows.
 *
 * @author David Ferguson (@jdfwarrior)
 * @author Ryan Parman (http://ryanparman.com)
 */

namespace Alfred;

use Exception;
use RuntimeException;
use SimpleXMLElement;
use Alfred\Storage\Plist;
use Alfred\Utilities as Util;
use Symfony\Component\Filesystem\Filesystem;
use Symfony\Component\Process\Process;

class Workflow
{
	/**
	 * @type array The formatted results to return.
	 */
	private $results = array();

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

	public function __construct() {}

	/**
	 * Converts an associative array into XML.
	 *
	 * @param  string|array $data An associative array or a JSON string.
	 * @return string             An XML representation of the array.
	 */
	public function toXML($data = null)
	{
		// Conver JSON into an associative array.
		if (is_string($data))
		{
			$data = json_decode($data, true);
		}

		// Use existing results if available.
		if (!empty($this->results))
		{
			$data = $this->results;
		}
		else
		{
			return false;
		}

		// Produce XML
		$items = new SimpleXMLElement("<items></items>");

		foreach ($data as $item)
		{
			$xitem = $items->addChild('item');

			foreach ($item as $key => $value)
			{
				switch ($key)
				{
					case 'icon':
						$kind = substr($value, 0, 8);
						if (in_array($kind, array('filetype', 'fileicon'), true))
						{
							$xitem->$key->addAttribute('type', $kind);
							$v = substr($value, 9);
							$xitem->$key = $v;
						}
						else
						{
							$xitem->$key = $value;
						}
						break;

					case 'valid' :
						if ($value === 'yes' || $value === 'no')
						{
							$xitem->addAttribute('valid', $value);
						}
						elseif (is_bool($value))
						{
							$xitem->addAttribute('valid', ($value ? 'yes' : 'no'));
						}
						break;

					default:
						$xitem->addAttribute($key, $value);
						$xitem->$key = $value;
						break;
				}
			}
		}

		return $items->asXML();
	}

	/**
	 * Search the local drive using `mdfind`.
	 *
	 * @param  string $query The file pattern to find.
	 * @return array         An array of file system paths containing matches.
	 */
	public function mdfind($query)
	{
		return explode(PHP_EOL, Util::run("mdfind \"${query}\""));
	}

	/**
	 * Helper function that just makes it easier to pass values into a function
	 * and create an array result to be passed back to Alfred
	 *
	 * The following array keys and values are available options:
	 *   - arg:          Argument that will be passed on.
	 *   - autocomplete: Autocomplete value for the result item.
	 *   - icon:         Icon to use for the result item.
	 *   - sub:          Subtitle text for the result item.
	 *   - title:        Title of the result item.
	 *   - uid:          Unique ID of the result. MUST be unique.
	 *   - valid:        Whether or not the result item can be actioned.
	 *
	 * @param  array $opts The array of options to pass-in.
	 * @return array       Data to be passed back to Alfred.
	 */
	public function result($opts)
	{
		// Default settings
		$default = array(
			'uid'          => null,
			'arg'          => null,
			'title'        => null,
			'subtitle'     => null,
			'icon'         => null,
			'valid'        => 'yes',
			'autocomplete' => null,
			'type'         => null,
		);

		// Merge options on top
		$options = array_merge($default, $opts);

		// Clean-up
		if (is_null($options['type']))
		{
			unset($options['type']);
		}

		// Add to results
		array_push($this->results, $options);

		// Return the merged options
		return $options;
	}
}
