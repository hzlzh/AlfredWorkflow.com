<?php
/**
 * Alfred Storage Adapter Interface
 *
 * @author Ryan Parman (http://ryanparman.com)
 */

namespace Alfred\Storage;

interface StorageInterface
{
	/**
	 * Stores a single key-value pair.
	 *
	 * @param string       $key   The key to store the data under.
	 * @param string|array $value The data to store. May be a string or an array.
	 */
	public function setValue($key, $value);

	/**
	 * Stores a set of key-value pairs.
	 *
	 * @param array $data The data to store. Must be a single-dimensional associative array of key-value pairs.
	 */
	public function setValues($data);

	/**
	 * Retrieves a value from storage based on the provided key.
	 *
	 * @param  string       $key The key which references the requested data.
	 * @return string|array      The resulting data. If the stored string was JSON, the response will be a decoded array.
	 */
	public function getValue($key);
}
