<?php

date_default_timezone_set('Europe/London');

include('workflows.php');
include('beanstalkapi.class.php');

class Beanstalk {

	var $workflow;
	var $repos;
	var $api;

	function __construct($creds) {
		
		$this->workflow = new Workflows();
		$this->api = new BeanstalkAPI(
			$creds['company'],
			$creds['username'],
			$creds['password']
		);
		
		$this->repos = self::cache();
	}

	function cache() {

		if(!file_exists('repos.json')){
			touch('repos.json');
		} else {
			if(filemtime('repos.json') < strtotime('- 2 hours')) {
				self::empty_cache();
			}
		}

		if(!$repos = $this->workflow->read('repos.json')) {
			$repos = $this->api->find_all_repositories(1, 1000);
			$this->workflow->write(json_encode($repos), 'repos.json');
		}

		return $repos;
	}

	function empty_cache() {
		unlink('repos.json');
		self::cache();
	}

	function query($args) {
		
		$args = explode(' ', $args);

		$action = $args[0];

		switch($action){
			
			case 'list':
				self::repo_list();
			break;

			case 'search':
				self::repo_search($args);
			break;

			case 'create':
				self::repo_create($args);
			break;

			case 'recache' :
				self::empty_cache();
			break;
		}
	}

	function repo_list() {

		foreach($this->repos as $repo) {
			$this->workflow->result(
				$repo->repository->id, 
				'git clone ' . $repo->repository->repository_url . ' -o Beanstalk', 
				$repo->repository->name, 
				$repo->repository->repository_url, 
				$repo->repository->color_label.'.png'
			);
		}
	
		echo $this->workflow->toxml();
	}

	function repo_search($args) {

		$search_phrase = $args[1];

		$found = 0;
		foreach($this->repos as $repo) {

			$pos = strpos(strtolower($repo->repository->name), strtolower($search_phrase));

			if($pos !== false) {
				$this->workflow->result(
					$repo->repository->id, 
					'git clone ' . $repo->repository->repository_url . ' -o Beanstalk', 
					$repo->repository->name, 
					$repo->repository->repository_url, 
					$repo->repository->color_label.'.png'
				);	
				$found++;		
			}
		}

		if($found == 0) {
			$this->workflow->result(
				'1', 
				'', 
				'Sorry no repos matching "'.$search_phrase.'" were found.', 
				'', 
				'icon.png', 
				''
			);
		}

		echo $this->workflow->toxml();
	}
}