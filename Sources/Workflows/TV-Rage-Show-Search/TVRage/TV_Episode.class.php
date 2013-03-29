<?php

	/**
	 * TV_Episode class. Class for single tv episode for a TV show.
	 *
	 * @package PHP::TVRage
	 * @author Ryan Doherty <ryan@ryandoherty.com>
	 **/
	class TV_Episode extends TVRage {

		/**
		 * The season number
		 *
		 * @access public
		 * @var integer|string
		 */
		public $season;

		/**
		 * The episode number for the season
		 *
		 * @access public
		 * @var integer|string
		 */
		public $number;

		/**
		 * The episode title
		 *
		 * @access public
		 * @var string
		 */
		public $title;

		/**
		 * First air date of the episode measured in number of seconds from the epoch
		 *
		 * @access public
		 * @var int
		 */
		public $airDate;

        /**
         * URL to episode on TVrage.com
         *
         * @access public
         * @var string
         */
        public $url;

		/**
		 * Constructor
		 *
		 * @access public
		 * @return void
		 * @param simplexmlobject $config simplexmlobject created from tvrage.com's xml data for the tv episode
		 **/
		function __construct($config) {
			list($this->season, $this->number) = array_pad(explode('x', (string)$config->number, 2), 2, null);
            $this->season = (int)$this->season;
            $this->number = (int)$this->number;
			$this->airDate = strtotime((string)$config->airdate);
			$this->title = (string)$config->title;
            $this->url = (string)$config->url;
		}
	}
?>
