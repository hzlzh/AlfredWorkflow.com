<?php

/**
 * FileCache
 *
 * @author dafei <dafei.net@gmail.com>
 * @version 1.8.1 20120620
 */

	final class FileCache
	{

		private static $_iscache   = true;
		private static $_cachedir  = '/tmp/';
		private static $_cachetime = 3600;

		public static function get($key=false,$d=false)
		{
			if(empty($key) or !self::$_iscache)
			{
				return false;
			}
			$filename  = self::get_filename($key,$d);
			if(!file_exists($filename))
			{
				return false;
			}
			$data = file_get_contents($filename);
			$data = unserialize($data);
			$time = (int)$data['time'];
			$data = $data['data'];
			if($time>time())
			{
				return $data;
			}
			else
			{
				return false;
			}
		}

		public static function set($key=false,$value=false,$t=0,$d=false)
		{
			if(empty($key) or !self::$_iscache)
			{
				return false;
			}
			$t = (int)$t ? (int)$t : self::$_cachetime;
			$filename  = self::get_filename($key,$d);
			if(!self::is_mkdir(dirname($filename)))
			{
				return false;
			}
			$data['time'] = time()+$t;
			$data['data'] = $value;
			$data = serialize($data);
			if(PHP_VERSION >= '5')
			{
				file_put_contents($filename,$data);
			}
			else
			{
				$handle = fopen($filename,'wb');
				fwrite($handle,$data);
				fclose($handle);
			}
			return true;
		}

		public static function un_set($key=false,$d=false)
		{
			if(empty($key))
			{
				return false;
			}
			$filename = self::get_filename($key,$d);
			@unlink($filename);
			return true;
		}

		public static function get_filename($key=false,$d=false)
		{
			if(empty($key))
			{
				return false;
			}
			$dir       = empty($d) ? self::$_cachedir : $d ;
			$key_md5   = md5($key);
			$filename  = rtrim($dir,'/').'/'.substr($key_md5,0,2).'/'.substr($key_md5,2,2).'/'.substr($key_md5,4,2).'/'.$key_md5;
			return $filename;
		}

		public static function is_mkdir($dir='')
		{
			if(empty($dir))
			{
				return false;
			}
			if(!is_writable($dir))
			{
				if(!@mkdir($dir,0777,true))
				{
					return false;
				}
			}
			return true;
		}

	}

?>