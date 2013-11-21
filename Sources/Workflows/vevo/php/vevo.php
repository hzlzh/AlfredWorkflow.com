<?php

/**
 * This class contains all the major functions required 
 * by the VEVO.com Workflow for Alfred 2.
 *
 * @author   Carsten Draeger <carsten@draegerit.de> (@blacklight24)
 * @version  1.0
 */
class Vevo {

	const ICON_DEFAULT = 'icons/icon.png';
	const ICON_EXPLICIT = 'icons/icon_explicit.png';
	const ICON_PREMIERE = 'icons/icon_premiere.png';
	const ICON_EXPLICIT_PREMIERE = 'icons/icon_explicit_premiere.png';

	const API_URL_BASE = "http://api.vevo.com/mobile/v1/";
	
	const URL_APPENDIX_ORDER_MOST_VIEWED_ALL_TIME = "MostViewedAllTime";
	const URL_APPENDIX_ORDER_MOST_VIEWED_THIS_MONTH = "MostViewedThisMonth";
	const URL_APPENDIX_ORDER_MOST_VIEWED_THIS_WEEK = "MostViewedThisWeek";
	const URL_APPENDIX_ORDER_MOST_VIEWED_TODAY = "MostViewedToday";
	const URL_APPENDIX_ORDER_MOST_RECENT = "MostRecent";
	const URL_APPENDIX_ORDER_RANDOM = "Random"; //not working.. currently?

	const VEVO_URL_BASE = "http://www.vevo.com/";
	const VEVO_URL_APPENDIX_VIDEO_WATCH = "watch/";

	const UNICODE_STAR_1 = '"\u2729"';
	const UNICODE_STAR_2 = '"\u272D"';
	const UNICODE_NOTE = '"\u266A"';
	const UNICODE_BULLET = '"\u2022"';

	private $wf;
	private $query;

	private $video_sort_order;
	private $title_sep;
	private $subtitle_sep;

	function __construct( $query = null ) {
		require_once('workflows.php');
		$this->wf = new Workflows();
		
		$this->query = $query;
		$this->video_sort_order = self::URL_APPENDIX_ORDER_MOST_VIEWED_ALL_TIME;
		$this->title_sep = json_decode(self::UNICODE_STAR_1);
		$this->subtitle_sep = json_decode(self::UNICODE_BULLET);
	}

	public function getJsonObject() {
		if ( empty( $this->query ) ):
			$apiurl = self::API_URL_BASE . "video/list.json?";
			$apiurl .= "ispremiere=true"; // list of video premieres when query is empty
		else:
			$term = trim(strtolower($this->query));
			$search = str_replace(array(" "), array("+"), $term);
			
			$apiurl = self::API_URL_BASE . "search/";
			$apiurl .= "videos.json?q=" . $search;
			$apiurl .= "&order=" . $this->video_sort_order;
		endif;

		$json = $this->wf->request($apiurl);
		return json_decode($json, true);
	}

	public function parseJsonVideoSearchResults( $obj = null ) {
		if (!is_null($obj) && $obj && $obj['success']) {
			$results = $obj['result'];

			if (count($results) > 0) {
				$count = 1;
				foreach ($results as $video) {
					$artists_main_arr = $video['artists_main'];
					$artists_ft_arr = $video['artists_featured'];

					$isrc = $video['isrc'];
					$title = $video['title'];
					$url_safe_title = $video['url_safe_title'];
					$viewcount = $video['viewcount'];
					$duration_in_seconds = $video['duration_in_seconds'];
					$explicit = $video['explicit'];
					$premiere = $video['premiere'];
					$image_url = $video['image_url'];

					$artists_main = null;
					$artist_url_safename = null;
					$count_artists_main = 1;
					foreach ($artists_main_arr as $artist) {
						if ($count_artists_main == 1) {
							$artist_url_safename = $artist['url_safename'];
							$artists_main = $artist['name'];
						} else {
							$artists_main = $artists_main . " / " . $artist['name'];
						}

						$count_artists_main++;
					}

					$artists_featured = null;
					$count_artists_featured = 1;
					foreach ($artists_ft_arr as $artist_ft) {
						if (empty($artist_url_safename)) { // in case only featured artist(s) are available
							$artist_url_safename = $artist_ft['url_safename'];
						}

						if ($count_artists_featured == 1) {
							$artists_featured = $artist_ft['name'];
						} else {
							$artists_featured = $artists_featured . ", " . $artist_ft['name'];
						}

						$count_artists_featured++;
					}

					$item_title = $title . " " . $this->title_sep . " " . $artists_main;
					if ($artists_featured) {
						$item_title = $item_title . " ft. " . $artists_featured;
					}

					$item_subtitle = null;					
					if (!empty($duration_in_seconds)) {
						$length = $this->getFormattedLength($duration_in_seconds);
						$item_subtitle = "Length: " . $length;
						$item_subtitle .= " " . $this->subtitle_sep . " ";
					}

					if (!empty($viewcount)) {
						$item_subtitle .= "Views: " . number_format($viewcount, 0, ',', '.');
					}

					if (empty($item_subtitle)) {
						$item_subtitle = "Hit enter to watch this video in your browser.";
					}

					if (!$explicit && !$premiere) {
						$icon = self::ICON_DEFAULT;
					} elseif ($explicit && !$premiere) {
						$icon = self::ICON_EXPLICIT;
					} elseif ($premiere && !$explicit) {
						$icon = self::ICON_PREMIERE;
					} else {
						$icon = self::ICON_EXPLICIT_PREMIERE;
					}

					$url  = self::VEVO_URL_BASE;
					$url .= self::VEVO_URL_APPENDIX_VIDEO_WATCH;
					$url .= $artist_url_safename."/".$url_safe_title."/".$isrc;
					$url .= "?source=instantsearch"; // 'instantsearch' as search-parameter, because that's what it is
					
					$this->wf->result($this->wf->bundle().'.'.$count.'.'.time(), $url, $item_title, $item_subtitle, $icon);
				}
				$count++;
			} else { // empty list
				$this->baseUrlResult('No results', 'Please try a different search term, or press enter to visit the vevo.com website.');
			}
		} else {
			$this->baseUrlResult('API Error!', 'Please try again later or contact the author of this workflow. Press enter to visit the vevo.com website.');
		}
	}

	private function getFormattedLength( $duration_in_seconds = null ) {
		if ( empty( $duration_in_seconds ) ):
			return false;
		else:
			$minutes = floor($duration_in_seconds / 60);
			$seconds = $duration_in_seconds % 60;
			return sprintf('%02d', $minutes) . ":" . sprintf('%02d', $seconds);
		endif;
	}

	private function baseUrlResult($title="No results", $subtitle='Please press enter to visit the vevo.com website.') {
		$this->wf->result($this->wf->bundle().'.nullresult.'.time(), self::VEVO_URL_BASE, $title, $subtitle, self::ICON_DEFAULT);
	}

	private function nullResult($title="No results", $subtitle='Sorry, no results or something went wrong.') {
		$this->wf->result($this->wf->bundle().'.nullresult.'.time(), null, $title, $subtitle, self::ICON_DEFAULT);
	}

	public function getXml() {
		return $this->wf->toxml();
	}
}
?>