<?php

	/**
	 * TV shows class, basic searching functionality
	 *
	 * @package PHP::TVDB
	 * @author Ryan Doherty <ryan@ryandoherty.com>
	 */

	class TV_Shows extends TVRage {

		/**
		 * Searches for tv shows based on show name
		 *
		 * @var string $showName the show name to search for
		 * @access public
		 * @return array An array of TV_Show objects matching the show name
		 **/
		public static function search($showName) {
			$params = array('action' => 'search_tv_shows', 'show_name' => $showName);
			$data = TVRage::request($params);

			if($data) {
				$xml = simplexml_load_string($data);
				$shows = array();
				foreach($xml->show as $show) {
					$shows[] = new TV_Show($show);
                }

				return $shows;
			}
		}

		/**
		 * Find a tv show by the id from TVRage
		 *
		 * @return TV_Show|false A TV_Show object or false if not found
		 **/
		public static function findById($showId) {
			$params = array('action' => 'show_by_id', 'id' => $showId);
			$data = self::request($params);

			if ($data) {
				$xml = simplexml_load_string($data);
				$show = new TV_Show($xml);
				return $show;
			} else {
				return false;
			}
		}
	}
?>
