<?php
	/**
	 * Base class for interacting with TV shows
	 *
	 * @package PHP::TVRage
	 * @author Ryan Doherty <ryan@ryandoherty.com>
	 */

	class TV_Show extends TVRage {

		/**
		 * TVRage showid
		 *
		 * @access public
		 * @var integer|string
		 */
		public $showId;
/**
		 * Name of the TV show
		 *
		 * @access public
		 * @var string
		 */
		public $name;

        /**
         * URL to TVRage website for show
         *
         * @access public
         * @var string
         */
        public $showLink;

        /**
         * Country
         *
         * @access public
         * @var string
         */
        public $country;

        /**
         * Started date
         *
         * @access public
         * @var int
         */
        public $started;

        /**
         * Ended date
         *
         * @access public
         * @var int
         */
        public $ended;

        /**
         * Number of seasons
         *
         * @access public
         * @var int
         */
        public $seasons;

        /**
         * Status of show
         *
         * @access public
         * @var string
         */
        public $status;

        /**
         * Show classification
         *
         * @access public
         * @var string
         */
        public $classification;

		/**
		 * TV Network the show is on
		 *
		 * @access public
		 * @var string
		 */
		public $network;

		/**
		 * TV show runtime. Various formats (60 minutes, 30 mins)
		 *
		 * @access public
		 * @var string
		 */
		public $runtime;

		/**
		 * Array of genres the tv show is (strings)
		 *
		 * @access public
		 * @var array contains array of genres (strings)
		 */
		public $genres;

		/**
		 * Day of the week the TV show airs (Sunday, Monday, ...)
		 *
		 * @access public
		 * @var string
		 */
		public $airDay;

		/**
		 * Time the tv show airs
		 *
		 * @access public
		 * @var string
		 */
		public $airTime;

		/**
		 * Time the tv show airs in 12 hour time
		 *
		 * @access public
		 * @var string
		 */
		public $twelveHourAirTime;

		/**
		 * Constructor
		 *
		 * @access public
		 * @param SimpleXMLObject $config A simplexmlobject created from tvrage.com's xml data for the tv show
		 * @return void
		 **/
		function __construct($config) {

			$this->showId = (string)$config->showid;
			$this->name = isset($config->showname) ? (string)$config->showname : (string)$config->name;
            $this->showLink = isset($config->showlink) ? (string)$config->showlink : (string)$config->link;
            $this->country = isset($config->origin_country) ? (string)$config->origin_country : (string)$config->country;

            if(isset($config->startdate)) {
                $this->started = strtotime(str_replace('/', ' ', (string)$config->startdate));
            } else {
                $this->started = strtotime(str_replace('/', ' ', (string)$config->started));
            }

            $this->ended = strtotime(str_replace('/', ' ', (string)$config->ended));
            $this->seasons = (string)$config->seasons;
			$this->status = (string)$config->status;
			$this->network = (string)$config->network;
			$this->runtime = (string)$config->runtime;
            $this->classification = (string)$config->classification;
			$this->genres = array();

            foreach($config->genres->genre as $genre) {
                    $this->genres[] = (string)$genre;
            }

            $this->airTime = (string)$config->airtime;
            $this->twelveHourAirTime = (string)DATE("g:i a", STRTOTIME($config->airtime));
            $this->airDay = (string)$config->airday;
		}


		/**
		 * Get a specific episode by season and episode number
		 *
		 * @var int $season required the season number
		 * @var int $episode required the episode number
		 * @return TV_Episode
		 **/
		public function getEpisode($season, $episode) {
			$params = array('action' => 'get_episode',
							'season' => (int)$season,
							'episode' => (int)$episode,
							'show_id' => $this->showId);

			$data = TVRage::request($params);

			if ($data) {
				$xml = simplexml_load_string($data);
				return new TV_Episode($xml->episode);
			} else {
				return false;
			}
		}
	}
?>
