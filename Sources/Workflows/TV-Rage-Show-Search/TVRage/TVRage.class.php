<?php
	/**
	 * Base TVRage library class, provides universal functions and variables
	 *
	 * @package PHP::TVRage
	 * @author Ryan Doherty <ryan@ryandoherty.com>
	 **/

	class TVRage {

		/**
		 * Base url for api requests
		 */

		CONST apiUrl = 'http://services.tvrage.com/feeds/';

		/**
		 * Fetches data via curl and returns result
		 *
		 * @access protected
		 * @param $url string The url to fetch data from
		 * @return string The data
		 **/
		static function fetchData($url) {
			$ch = curl_init($url);
			curl_setopt($ch, CURLOPT_HEADER, 1);
			curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);

			$response = curl_exec($ch);

			$httpCode = curl_getinfo($ch ,CURLINFO_HTTP_CODE);
			$headerSize = curl_getinfo($ch,CURLINFO_HEADER_SIZE);
            $data = substr( $response, $headerSize );
			curl_close($ch);

			if($httpCode != 200) {
			    return false;
			}

			return $data;
		}


		/**
		 * Fetches data from TVRage api based on action
		 *
		 * @access protected
		 * @param $params An array containing parameters for the request to tvrage.com
		 * @return string The data from tvrage.com
		 **/
		static function request($params) {

			switch($params['action']) {

				case 'show_by_id':
					$id = $params['id'];
					$url = self::apiUrl.'showinfo.php?sid='.$id;
					$data = self::fetchData($url);
					return $data;
				break;

				case 'get_episode':
					$showId = $params['show_id'];
                    $season = $params['season'];
                    $episode = $params['episode'];
					$url = self::apiUrl.'episodeinfo.php?sid='.$showId.'&ep='.$season.'x'.$episode;
					$data = self::fetchData($url);
					return $data;
				break;

				case 'search_tv_shows':
					$showName = urlencode($params['show_name']);
					$url = self::apiUrl."full_search.php?show=$showName";
					$data = self::fetchData($url);
					return $data;
				break;

				default:
					return false;
				break;
			}
		}
	}
?>
