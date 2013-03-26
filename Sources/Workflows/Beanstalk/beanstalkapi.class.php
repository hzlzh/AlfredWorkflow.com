<?php

/**
 * PHP class for connecting to the Beanstalk API
 *
 * @link http://api.beanstalkapp.com/
 * @version 0.10.1
 */
class BeanstalkAPI {
	/**
	 * Beanstalk account configuration
	 *
	 * Either enter your account name, username and password below,
	 * or pass details when creating object ie. new BeanstalkAPI('account', 'user', 'pass');
	 */

	private $account_name	= '';		// Beanstalk account name (first segment of your beanstalk URL - http://example.beanstalkapp.com)
	private $username		= '';		// Beanstalk username
	private $password		= '';		// Beanstalk password
	
	public $error_code = '';
	public $error_string = '';
	
	public $curl_info = array();		// Stores info from last request
	
	public $format = 'json';			// XML or JSON
	

	// ------------------------------------------------------------------------

	/**
	 * Constructor
	 *
	 * @param string $account_name [optional]
	 * @param string $username [optional]
	 * @param string $password [optional]
	 * @param string $format [optional] Defaults to json
	 * @return void
	 */
	public function __construct($account_name = null, $username = null, $password = null, $format = 'json') {
		if(!is_null($account_name))
			$this->account_name = $account_name;
		
		if(!is_null($username))
			$this->username = $username;
		
		if(!is_null($password))
			$this->password = $password;
		
		if(empty($this->account_name) || empty($this->username) || empty($this->password))
			throw new InvalidArgumentException("Account name, username and password required");
		
		$this->format = strtolower($format) == 'json' ? 'json' : 'xml';
	}


	//
	// Account
	//

	/**
	 * Returns Beanstalk account details.
	 *
	 * @link http://api.beanstalkapp.com/account.html
	 * @return SimpleXMLElement|array
	 */
	public function get_account_details() {
		return $this->_execute_curl("account." . $this->format);
	}

	/**
	 * Allows a user to update their account details by sending specific parameters
	 *
	 * @link http://api.beanstalkapp.com/account.html
	 * @param array $params Accepts - name, timezone
	 * @return SimpleXMLElement|array
	 */
	public function update_account_details($params = array()) {
		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement("<account></account>");
			
			if(isset($params['name']))
				$xml->addChild('name', $params['name']);
		
			if(isset($params['timezone']))
				$xml->addChild('time_zone', $params['timezone']); // Inconsistency in API?
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('account' => array());
			
			if(isset($params['name']))
				$data_array['account']['name'] = $params['name'];
			
			if(isset($params['timezone']))
				$data_array['account']['time_zone'] = $params['timezone'];
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("account." . $this->format, NULL, "PUT", $data);
	}


	//
	// Plans
	//

	/**
	 * Returns Beanstalk account plans
	 *
	 * @link http://api.beanstalkapp.com/plan.html
	 * @return SimpleXMLElement|array
	 */
	public function find_all_plans() {
		return $this->_execute_curl("plans." . $this->format);
	}


	//
	// Users
	//

	/**
	 * Returns Beanstalk account user list.
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 30, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_all_users($page = 1, $per_page = 30) {
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
				
		return $this->_execute_curl("users." . $this->format . "?page=" . $page . "&per_page=" . $per_page);
	}

	/**
	 * Returns a Beanstalk account user based on a specific user ID
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @param integer $user_id		required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_user($user_id) {
		if(empty($user_id))
			throw new InvalidArgumentException("User ID required");
		else
			return $this->_execute_curl("users", $user_id . "." . $this->format);
	}

	/**
	 * Returns Beanstalk user currently being used to access the API
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @return SimpleXMLElement|array
	 */
	public function find_current_user() {
		return $this->_execute_curl("users", "current." . $this->format);
	}

	/**
	 * Create a new Beanstalk user
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @param string $login
	 * @param string $email
	 * @param string $first_name
	 * @param string $last_name
	 * @param string $password
	 * @param int $admin [optional]
	 * @param string $timezone [optional]
	 * @return SimpleXMLElement|array
	 */
	public function create_user($login, $email, $first_name, $last_name, $password, $admin = 0, $timezone = NULL) {
		if(empty($login) || empty($email) || empty($first_name) || empty($last_name) || empty($password))
			throw new InvalidArgumentException("Some required fields missing");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<user></user>');
			
			$xml->addChild('login', $login);
			$xml->addChild('email', $email);
			$xml->addChild('first_name', $first_name);
			$xml->addChild('last_name', $last_name);
			$xml->addChild('password', $password);
			$xml->addChild('admin', $admin); // Should change to optional?
			
			if(!is_null($timezone))
				$xml->addChild('timezone', $timezone);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('user' => array());
			
			$data_array['user']['login'] = $login;
			$data_array['user']['email'] = $email;
			$data_array['user']['first_name'] = $first_name;
			$data_array['user']['last_name'] = $last_name;
			$data_array['user']['password'] = $password;
			$data_array['user']['admin'] = $admin;
			
			if(isset($timezone))
				$data_array['user']['timezone'] = $timezone;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("users." . $this->format, NULL, "POST", $data);
	}

	/**
	 * Update an existing user
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @param integer $user_id
	 * @param array $params Accepts - email, first_name, last_name, password, admin, timezone
	 * @return SimpleXMLElement|array
	 */
	public function update_user($user_id, $params = array()) {
		if(empty($user_id))
			throw new InvalidArgumentException("User ID required");
		
		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<user></user>');
			
			if(isset($params['email']))
				$xml->addChild('email', $params['email']);
			
			if(isset($params['first_name']))
				$xml->addChild('first_name', $params['first_name']);
			
			if(isset($params['last_name']))
				$xml->addChild('last_name', $params['last_name']);
			
			if(isset($params['password']))
				$xml->addChild('password', $params['password']);
			
			if(isset($params['admin']))
				$xml->addChild('admin', $params['admin']);
			
			if(isset($params['timezone']))
				$xml->addChild('timezone', $params['timezone']);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('user' => array());
			
			if(isset($params['email']))
				$data_array['user']['email'] = $params['email'];
			
			if(isset($params['first_name']))
				$data_array['user']['first_name'] = $params['first_name'];
			
			if(isset($params['last_name']))
				$data_array['user']['last_name'] = $params['last_name'];
			
			if(isset($params['password']))
				$data_array['user']['password'] = $params['password'];
			
			if(isset($params['admin']))
				$data_array['user']['admin'] = $params['admin'];
			
			if(isset($params['timezone']))
				$data_array['user']['timezone'] = $params['timezone'];
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("users", $user_id . "." . $this->format, "PUT", $data);
	}

	/**
	 * Delete a user
	 *
	 * @link http://api.beanstalkapp.com/user.html
	 * @param integer $user_id
	 * @return SimpleXMLElement|array
	 */
	public function delete_user($user_id) {
		if(empty($user_id))
			throw new InvalidArgumentException("User ID required");

		return $this->_execute_curl("users", $user_id . "." . $this->format, "DELETE");
	}


	//
	// Invitations
	//

	/**
	 * Return an invitation
	 * 
	 * @link http://api.beanstalkapp.com/invitation.html
	 * @param integer $invitation_id
	 * @return SimpleXMLElement|array
	 */
	public function find_invitation($invitation_id)
	{
		if(empty($invitation_id))
			throw new InvalidArgumentException("Invitation ID required");
		
		return $this->_execute_curl("invitations", $invitation_id . "." . $this->format);
	}

	/**
	 * Create an invitation - creates a User and Invitation
	 * 
	 * @link http://api.beanstalkapp.com/invitation.html
	 * @param string $email
	 * @param string $first_name
	 * @param string $last_name
	 * @return SimpleXMLElement|array
	 */
	public function create_invitation($email, $first_name, $last_name)
	{
		if(empty($email) || empty($first_name) || empty($last_name))
			throw new InvalidArgumentException("Some required fields missing");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<invitation></invitation>');
			
			$user = $xml->addChild('user');
			
			$user->addChild('email', $email);
			$user->addChild('first_name', $first_name);
			$user->addChild('last_name', $last_name);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('invitation' => array());
			
			$data_array['invitation']['user'] = array();
			
			$data_array['invitation']['user']['email'] = $email;
			$data_array['invitation']['user']['first_name'] = $first_name;
			$data_array['invitation']['user']['last_name'] = $last_name;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("invitations." . $this->format, NULL, "POST", $data);
	}


	//
	// Public Keys
	//

	/**
	 * Return all public keys for current user - or for a specified user (if using admin account)
	 *
	 * @link http://api.beanstalkapp.com/public_key.html
	 * @param integer $user_id [optional]
	 * @return SimpleXMLElement|array
	 */
	public function find_all_public_keys($user_id = NULL) {
		if(!is_null($user_id))
			return $this->_execute_curl("public_keys." . $this->format . "?user_id=" . $user_id);
		else
			return $this->_execute_curl("public_keys." . $this->format);
	}

	/**
	 * Return a single public key
	 *
	 * @link http://api.beanstalkapp.com/public_key.html
	 * @param integer $key_id
	 * @return SimpleXMLElement|array
	 */
	public function find_single_public_key($key_id) {
		if(empty($key_id))
			throw new InvalidArgumentException("Public key ID required");
		
		return $this->_execute_curl("public_keys", $key_id . "." . $this->format);
	}

	/**
	 * Create a new public key - creates for current user unless specified (must be admin)
	 *
	 * @link http://api.beanstalkapp.com/public_key.html
	 * @param string $content
	 * @param string $name [optional]
	 * @param integer $user_id [optional] Defaults to current user
	 * @return SimpleXMLElement|array
	 */
	public function create_public_key($content, $name = NULL, $user_id = NULL) {
		if(empty($content))
			throw new InvalidArgumentException("Key content required");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<public_key></public_key>');
			
			$xml->addChild('content', $content);
			
			if(!is_null($name))
				$xml->addChild('name', $name);
			
			if(!is_null($user_id))
				$xml->addChild('user_id', $user_id);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('public_key' => array());
			
			$data_array['public_key']['content'] = $content;
			
			if(!is_null($name))
				$data_array['public_key']['name'] = $name;
			
			if(!is_null($user_id))
				$data_array['public_key']['user_id'] = $user_id;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("public_keys." . $this->format, NULL, "POST", $data);
	}

	/**
	 * Update a public key - can only update own keys unless admin
	 *
	 * @link http://api.beanstalkapp.com/public_key.html
	 * @param integer $key_id
	 * @param array $params Accepts - content, name
	 * @return SimpleXMLElement|array
	 */
	public function update_public_key($key_id, $params = array()) {
		if(empty($key_id))
			throw new InvalidArgumentException("Public key ID required");
		
		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<public_key></public_key>');
			
			if(!is_null($params['content']))
				$xml->addChild('content', $params['content']);
			
			if(!is_null($params['name']))
				$xml->addChild('name', $params['name']);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('public_key' => array());
			
			if(!is_null($params['content']))
				$data_array['public_key']['content'] = $params['content'];
			
			if(!is_null($params['name']))
				$data_array['public_key']['name'] = $params['name'];
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("public_keys", $key_id . "." . $this->format, "PUT", $data);
	}

	/**
	 * Delete a public key - can only delete own keys unless admin
	 *
	 * @link http://api.beanstalkapp.com/public_key.html
	 * @param integer $key_id
	 * @return SimpleXMLElement|array
	 */
	public function delete_public_key($key_id) {
		if(empty($key_id))
			throw new InvalidArgumentException("Public key ID required");
		
		return $this->_execute_curl("public_keys", $key_id . "." . $this->format, "DELETE");
	}


	//
	// Feed Keys
	//

	/**
	 * Find the Feed Key for current API user
	 * Used to construct address to RSS/Atom feed for account/repo
	 *
	 * @link http://api.beanstalkapp.com/feed_key.html
	 * @return SimpleXMLElement|array
	 */
	public function find_current_user_feed_key()
	{
		return $this->_execute_curl("feed_key." . $this->format);
	}


	//
	// Repositories
	//

	/**
	 * Returns Beanstalk account repository list
	 *
	 * @link http://api.beanstalkapp.com/repository.html
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 30, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_all_repositories($page = 1, $per_page = 30) {
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		return $this->_execute_curl("repositories." . $this->format . "?page=" . $page . "&per_page=" . $per_page);
	}

	/**
	 * Returns a Beanstalk account repository based on a specific repository ID
	 *
	 * @link http://api.beanstalkapp.com/repository.html
	 * @param integer $repo_id		required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_repository($repo_id) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		else
			return $this->_execute_curl("repositories", $repo_id . "." . $this->format);
	}
	
	/**
	 * Returns an array of the repository's branches - git only
	 *
	 * @link http://api.beanstalkapp.com/repository.html
	 * @param integer $repo_id
	 * @return SimpleXMLElement|array
	 */
	public function find_repository_branches($repo_id) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		else
			return $this->_execute_curl("repositories", $repo_id . "/branches." . $this->format);
	}

        /**
         * Returns an array of the repository's tags - git only
         *
         * @link http://api.beanstalkapp.com/repository.html
         * @param integer $repo_id
         * @return SimpleXMLElement|array
         */
        public function find_repository_tags($repo_id) {
                if(empty($repo_id))
                        throw new InvalidArgumentException("Repository ID required");
                else
                        return $this->_execute_curl("repositories", $repo_id . "/tags." . $this->format);
        }

	/**
	 * Create a repository
	 *
	 * @link http://api.beanstalkapp.com/repository.html
	 * @param string $name
	 * @param string $type_id [optional] Can be git or subversion
	 * @param string $title
	 * @param bool $create_structure [optional]
	 * @param string $color_label [optional] Accepts - red, orange, yellow, green, blue, pink, grey
	 * @return SimpleXMLElement|array
	 */
	public function create_repository($name, $type_id = "subversion", $title, $create_structure = true, $color_label = "grey") {
		if(empty($name) || empty($title))
			throw new InvalidArgumentException("Repository name and title required");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<repository></repository>');
		
			$xml->addChild('name', $name);
		
			if(!is_null($type_id))
				$xml->addChild('type_id', $type_id);
		
			$xml->addChild('title', $title);
		
			if(!is_null($create_structure))
				$xml->addChild('create_structure', $create_structure);
		
			if(!is_null($color_label))
				$xml->addChild('color_label', "label-" . $color_label);
		
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('repository' => array());
			
			$data_array['repository']['name'] = $name;
			
			if(!is_null($type_id))
				$data_array['repository']['type_id'] = $type_id;
			
			$data_array['repository']['title'] = $title;
			
			if(!is_null($create_structure))
				$data_array['repository']['create_structure'] = $create_structure;
			
			if(!is_null($color_label))
				$data_array['repository']['color_label'] = "label-" . $color_label;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("repositories." . $this->format, NULL, "POST", $data);
	}

	/**
	 * Update an existing repository
	 *
	 * @link http://api.beanstalkapp.com/repository.html
	 * @param integer $repo_id
	 * @param array $params Accepts - name, title, color_label (red, orange, yellow, green, blue, pink, grey)
	 * @return SimpleXMLElement|array
	 */
	public function update_repository($repo_id, $params = array()) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");

		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<repository></repository>');
			
			if(isset($params['name']))
				$xml->addChild('name', $params['name']);
			
			if(isset($params['title']))
				$xml->addChild('title', $params['title']);
			
			if(isset($params['color-label']))
				$xml->addChild('color_label', "label-" . $params['color_label']);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('repository' => array());
			
			if(isset($params['name']))
				$data_array['repository']['name'] = $params['name'];
			
			if(isset($params['title']))
				$data_array['repository']['title'] = $params['title'];
			
			if(isset($params['color_label']))
				$data_array['repository']['color_label'] = "label-" . $params['color_label'];
			
			$data = json_encode($data_array);
		}

		return $this->_execute_curl("repositories", $repo_id . "." . $this->format, "PUT", $data);
	}


	//
	// Repository Import
	//

	/**
	 * Find an import - also returns the status of the import
	 * 
	 * @link http://api.beanstalkapp.com/repository_import.html
	 * @return SimpleXMLElement|array
	 */
	public function find_import($import_id)
	{
		if(empty($import_id))
			throw new Exception("Import ID required");
		
		return $this->_execute_curl("repository_imports", $import_id . "." . $this->format);
	}

	/**
	 * Import an SVN dump into a repository
	 * 
	 * @link http://api.beanstalkapp.com/repository_import.html
	 * @param integer $repo_id
	 * @param string $import_url
	 * @return SimpleXMLElement|array
	 */
	public function create_import($repo_id, $import_url)
	{
		if(empty($repo_id) || empty($import_url))
			throw new InvalidArgumentException("Repository ID and import URL required");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<repository_import></repository_import>');
			
			$xml->addChild('uri', $import_url);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('repository_import' => array());
			
			$data_array['repository_import']['uri'] = $import_url;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "repository_imports." . $this->format, "POST", $data);
	}


	//
	// User Permissions
	//

	/**
	 * Find permissions for a user
	 *
	 * @link http://api.beanstalkapp.com/permissions.html
	 * @param integer $user_id
	 * @return SimpleXMLElement|array
	 */
	public function find_user_permissions($user_id) {
		if(empty($user_id))
			throw new InvalidArgumentException("User ID required");
		
		return $this->_execute_curl("permissions", $user_id . "." . $this->format);
	}

	/**
	 * Create permissions for a user for a repository - overwrites existing
	 *
	 * @link http://api.beanstalkapp.com/permissions.html
	 * @param integer $user_id
	 * @param integer $repo_id
	 * @param bool $read [optional]
	 * @param bool $write [optional]
	 * @param bool $full_deployments_access [optional] Gives full deployment access to a repository
	 * @param integer $server_environment_id [optional] Give deployment access only to a specific server environment
	 * @return SimpleXMLElement|array
	 */
	public function create_user_permissions($user_id, $repo_id, $read = false, $write = false, $full_deployments_access = false, $server_environment_id = NULL) {
		if(empty($user_id) || empty($repo_id))
			throw new InvalidArgumentException("Some required fields missing");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<permission></permission>');
			
			$user_xml = $xml->addChild('user_id', $user_id);
			$user_xml->addAttribute('type', 'integer');
			
			$repo_xml = $xml->addChild('repository_id', $repo_id);
			$repo_xml->addAttribute('type', 'integer');
			
			if($read === true)
				$read_xml = $xml->addChild('read', 'true');
			else
				$read_xml = $xml->addChild('read', 'false');
			
			$read_xml->addAttribute('type', 'boolean');
			
			if($write === true)
				$write_xml = $xml->addChild('write', 'true');
			else
				$write_xml = $xml->addChild('write', 'false');
			
			$write_xml->addAttribute('type', 'boolean');
			
			if($full_deployments_access === true)
				$full_deploy_xml = $xml->addChild('full_deployments_access', 'true');
			else
				$full_deploy_xml = $xml->addChild('full_deployments_access', 'false');
			
			$full_deploy_xml->addAttribute('type', 'boolean');
			
			if(!is_null($server_environment_id)) {
				$environment_xml = $xml->addChild('server_environment_id', $server_environment_id);
				$environment_xml->addAttribute('type', 'integer');
			}
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('permission' => array());
			
			$data_array['permission']['user_id'] = $user_id;
			$data_array['permission']['repository_id'] = $repo_id;
			
			if($read === true)
				$data_array['permission']['read'] = true;
			else
				$data_array['permission']['read'] = false;
			
			if($write === true)
				$data_array['permission']['write'] = true;
			else
				$data_array['permission']['write'] = false;
			
			if($full_deployments_access === true)
				$data_array['permission']['full_deployments_access'] = true;
			else
				$data_array['permission']['full_deployments_access'] = false;
			
			if(!is_null($server_environment_id))
				$data_array['permission']['server_environment_id'] = $server_environment_id;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl("permissions." . $this->format, NULL, "POST", $data);
	}

	/**
	 * Strip a user of a set of permissions for a repository
	 *
	 * @link http://api.beanstalkapp.com/permissions.html
	 * @param integer $permission_id
	 * @return SimpleXMLElement|array
	 */
	public function delete_user_permissions($permission_id) {
		if(empty($permission_id))
			throw new InvalidArgumentException("Permission ID required");
		
		return $this->_execute_curl("permissions", $permission_id . "." . $this->format, "DELETE");
	}


	//
	// Integrations
	//

	/**
	 * Find all integrations for a repository
	 *
	 * @link http://api.beanstalkapp.com/integration.html
	 * @param integer $repo_id
	 * @return SimpleXMLElement|array
	 */
	public function find_all_integrations($repo_id) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");

		return $this->_execute_curl("repositories", $repo_id . "/integrations." . $this->format);
	}

	/**
	 * Find a single integration from a repository
	 *
	 * @link http://api.beanstalkapp.com/integration.html
	 * @param integer $repo_id
	 * @param integer $integration_id
	 * @return SimpleXMLElement|array
	 */
	public function find_single_integration($repo_id, $integration_id) {
		if(empty($repo_id) || empty($integration_id))
			throw new InvalidArgumentException("Repository ID and Integration ID required");

		return $this->_execute_curl("repositories", $repo_id . "/integrations/" . $integration_id . "." . $this->format);
	}


	//
	// Changesets
	//

	/**
	 * Returns Beanstalk account changeset list
	 *
	 * @link http://api.beanstalkapp.com/changeset.html
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 15, max 30
	 * @param string $order_field [optioanl] Order results by a field - default 'time'
	 * @param string $order [optional] Order direction - can be ASC or DESC - default 'DESC'
	 * @return SimpleXMLElement|array
	 */
	public function find_all_changesets($page = 1, $per_page = 15, $order_field = 'time', $order = 'DESC') {
		$per_page = intval($per_page) > 30 ? 30 : intval($per_page);
		$order = strtoupper($order) == 'ASC' ? 'ASC' : 'DESC';
		
		return $this->_execute_curl("changesets." . $this->format . "?page=" . $page . "&per_page=" . $per_page . "&order_field" . $order_field . "&order=" . $order);
	}

	/**
	 * Returns a Beanstalk repository changesets based on a specific repository ID
	 *
	 * @link http://api.beanstalkapp.com/changeset.html
	 * @param integer $repo_id		required
	 * @param integer $page [optional]
	 * @param integer $per_page [optional] Set results per page - default 15
	 * @param string $order_field [optioanl] Order results by a field - default 'time'
	 * @param string $order [optional] Order direction - can be ASC or DESC - default 'DESC'
	 * @return SimpleXMLElement|array
	 */
	public function find_single_repository_changesets($repo_id, $page = 1, $per_page = 15, $order_field = 'time', $order = 'DESC') {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		
		$per_page = intval($per_page) > 30 ? 30 : intval($per_page);
		$order = strtoupper($order) == 'ASC' ? 'ASC' : 'DESC';
		
		return $this->_execute_curl("changesets", "repository." . $this->format . "?repository_id=" . $repo_id . "&page=" . $page . "&per_page=" . $per_page . "&order_field" . $order_field . "&order=" . $order);
	}

	/**
	 * Returns a Beanstalk repository's specific changeset based on a specific repository ID and changeset ID
	 *
	 * @link http://api.beanstalkapp.com/changeset.html
	 * @param integer $repo_id		required
	 * @param integer $revision		required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_changeset($repo_id, $revision) {
		if(empty($repo_id) || empty($revision))
			throw new InvalidArgumentException("Changeset ID and repository ID required");
		else
			return $this->_execute_curl("changesets", $revision . "." . $this->format . "?repository_id=" . $repo_id);
	}

	/**
	 * Return the diff for a specified repository ID and changeset ID
	 * 
	 * @link http://api.beanstalkapp.com/changeset.html
	 * @param integer $repo_id		required
	 * @param integer $revision		required
	 * @return SimpleXMLElement|array
	 */
	public function find_changeset_diffs($repo_id, $revision) {
		if(empty($repo_id) || empty($revision))
			throw new InvalidArgumentException("Changeset ID and repository ID required");
		else
			return $this->_execute_curl("changesets", $revision . "/differences." . $this->format . "?repository_id=" . $repo_id);
	}


	//
	// Comments
	//

	/**
	 * Returns a Beanstalk repository's comment listing
	 *
	 * @link http://api.beanstalkapp.com/comment.html
	 * @param integer $repo_id		required
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 15, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_all_comments($repo_id, $page = 1, $per_page = 15) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		return $this->_execute_curl($repo_id, "comments." . $this->format . "?page=" . $page . "&per_page=" . $per_page);
	}

	/**
	 * Returns a Beanstalk repository's comment listing for a specific changeset
	 *
	 * @link http://api.beanstalkapp.com/comment.html
	 * @param integer $repo_id		required
	 * @param integer $revision		required
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 15, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_all_changeset_comments($repo_id, $revision, $page = 1, $per_page = 15) {
		if(empty($repo_id) || empty($revision))
			throw new InvalidArgumentException("Repository ID and revision ID required");
		
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		return $this->_execute_curl($repo_id, "comments." . $this->format . "?revision=" . $revision . "&page=" . $page . "&per_page=" . $per_page);
	}

	/**
	 * Return comments from a specific user
	 *
	 * @link http://api.beanstalkapp.com/comment.html
	 * @param integer $user_id
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 15, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_single_user_comments($user_id, $page = 1, $per_page = 15) {
		if(empty($user_id))
			throw new InvalidArgumentException("User ID required");
		
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		return $this->_execute_curl("comments", "user." . $this->format . "?user_id=" . $user_id . "&page=" . $page . "&per_page=" . $per_page);
	}

	/**
	 * Returns a Beanstalk repository's comment based on a specific comment ID
	 *
	 * @link http://api.beanstalkapp.com/comment.html
	 * @param integer $repo_id		required
	 * @param integer $revision		required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_comment($repo_id, $comment_id) {
		if(empty($repo_id) || empty($comment_id))
			throw new InvalidArgumentException("Repository ID and comment ID required");
		else
			return $this->_execute_curl($repo_id, "comments/" . $comment_id . "." . $this->format);
	}

	/**
	 * Create new comment - unclear from docs which parameters are required
	 *
	 * @link http://api.beanstalkapp.com/comment.html
	 * @param integer $repo_id
	 * @param integer $revision_id
	 * @param string $body
	 * @param string $file_path
	 * @param integer $line_number
	 * @return SimpleXMLElement|array
	 */
	public function create_comment($repo_id, $revision_id, $body, $file_path, $line_number) {
		if(empty($repo_id) || empty($revision_id) || empty($body) || empty($file_path) || empty($line_number))
			throw new InvalidArgumentException("Some required fields missing");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<comment></comment>');
			
			$revision_xml = $xml->addChild('revision', $revision_id);
			$revision_xml->addAttribute('type', 'integer');
			
			$xml->addChild('body', $body);
			$xml->addChild('file_path', $file_path);
			$xml->addChild('line_number', $line_number); // Should this have type attribute set as well?
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('comment' => array());
			
			$data_array['comment']['revision'] = $revision_id;
			$data_array['comment']['body'] = $body;
			$data_array['comment']['file_path'] = $file_path;
			$data_array['comment']['line_number'] = $line_number;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "comments." . $this->format, "POST", $data);
	}


	//
	// Server Environments
	//

	/**
	 * Returns a Beanstalk repository's server environment listing
	 *
	 * @link http://api.beanstalkapp.com/server_environment.html
	 * @param integer $repo_id		required
	 * @return SimpleXMLElement|array
	 */
	public function find_all_server_environments($repo_id) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		else
			return $this->_execute_curl($repo_id, "server_environments." . $this->format);
	}

	/**
	 * Returns a Beanstalk repository's server environment listing based on a specific environment ID
	 *
	 * @link http://api.beanstalkapp.com/server_environment.html
	 * @param integer $repo_id		required
	 * @param integer $environment_id	required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_server_environment($repo_id, $environment_id) {
		if(empty($repo_id) || empty($environment_id))
			throw new InvalidArgumentException("Repository ID required");
		else
			return $this->_execute_curl($repo_id, "server_environments/" . $environment_id . "." . $this->format);
	}

	/**
	 * Create a new server environment
	 *
	 * @link http://api.beanstalkapp.com/server_environment.html
	 * @param integer $repo_id
	 * @param string $name
	 * @param bool $automatic [optional]
	 * @param string $branch_name [optional] Git only
	 * @param string $color_label [optional] Accepts - red, orange, yellow, green, blue, pink, grey
	 * @return SimpleXMLElement|array
	 */
	public function create_server_environment($repo_id, $name, $automatic = false, $branch_name = NULL, $color_label = NULL) {
		if(empty($repo_id) || empty($name) || ($automatic !== false && $automatic !== true))
			throw new InvalidArgumentException("Repository ID, name and deploy automatically required");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<server_environment></server_environment>');
			
			$xml->addChild('name', $name);
			$xml->addChild('automatic', $automatic);
			
			if(!is_null($branch_name))
				$xml->addChild('branch_name', $branch_name);
			
			if(!is_null($color_label))
				$xml->addChild('color_label', 'color-' . $color_label);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('server_environment' => array());
			
			$data_array['server_environment']['name'] = $name;
			$data_array['server_environment']['automatic'] = $automatic;
			
			if(!is_null($branch_name))
				$data_array['server_environment']['branch_name'] = $branch_name;
			
			if(!is_null($color_label))
				$data_array['server_environment']['color_label'] = 'color-' . $color_label;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "server_environments." . $this->format, "POST", $data);
	}

	/**
	 * Update a server environment
	 *
	 * @link http://api.beanstalkapp.com/server_environment.html
	 * @param integer $repo_id
	 * @param integer $environment_id
	 * @param array $params Accepts - name, automatic, branch_name
	 * @return SimpleXMLElement|array
	 */
	public function update_server_environment($repo_id, $environment_id, $params = array()) {
		if(empty($repo_id) || empty($environment_id))
			throw new InvalidArgumentException("Repository ID and server environment ID requried");
		
		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<server_environment></server_environment>');
			
			if(isset($params['name']))
				$xml->addChild('name', $params['name']);
			
			if(isset($params['automatic']))
				$xml->addChild('automatic', $params['automatic']);
			
			if(isset($params['branch_name']))
				$xml->addChild('branch_name', $params['branch_name']);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('server_environment' => array());
			
			if(isset($params['name']))
				$data_array['server_environment']['name'] = $params['name'];
			
			if(isset($params['automatic']))
				$data_array['server_environment']['automatic'] = $params['automatic'];
			
			if(isset($params['branch_name']))
				$data_array['server_environment']['branch_name'] = $params['branch_name'];
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "server_environments/" . $environment_id . "." . $this->format, "PUT", $data);
	}


	//
	// Release Servers
	//

	/**
	 * Returns a Beanstalk repository's release server listing
	 *
	 * @link http://api.beanstalkapp.com/release_server.html
	 * @param integer $repo_id		required
	 * @param integer $environment_id	required
	 * @return SimpleXMLElement|array
	 */
	function find_all_release_servers($repo_id, $environment_id) {
		if(empty($repo_id) || empty($environment_id))
			throw new InvalidArgumentException("Repository ID and environment ID required");
		else
			return $this->_execute_curl($repo_id, "release_servers." . $this->format . "?environment_id=" . $environment_id);
	}

	/**
	 * Returns a Beanstalk repository's release server listing based on a specific server ID
	 *
	 * @link http://api.beanstalkapp.com/release_server.html
	 * @param integer $repo_id		required
	 * @param integer $server_id		required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_release_server($repo_id, $server_id) {
		if(empty($repo_id) || empty($server_id))
			throw new InvalidArgumentException("Repository ID and server ID required");
		else
			return $this->_execute_curl($repo_id, "release_servers/" . $server_id . "." . $this->format);
	}

	/**
	 * Create a release server
	 *
	 * @link http://api.beanstalkapp.com/release_server.html
	 * @param integer $repo_id
	 * @param integer $environment_id
	 * @param string $name
	 * @param string $local_path
	 * @param string $remote_path
	 * @param string $remote_addr
	 * @param string $protocol [optional] Accepts - ftp, sftp
	 * @param integer $port [optional]
	 * @param string $login
	 * @param string $password
	 * @param bool $use_active_mode [optional]
	 * @param bool $authenticate_by_key [optional]
	 * @param bool $use_feat [optional] Defaults to true
	 * @param string $pre_release_hook [optional]
	 * @param string $post_release_hook [optional]
	 * @return SimpleXMLElement|array
	 */
	public function create_release_server($repo_id, $environment_id, $name, $local_path, $remote_path, $remote_addr, $protocol = 'ftp', $port = 21, $login, $password, $use_active_mode = NULL, $authenticate_by_key = NULL, $use_feat = true, $pre_release_hook = NULL, $post_release_hook = NULL) {
		if(empty($repo_id) || empty($environment_id) || empty($name) || empty($local_path) || empty($remote_path) || empty($remote_addr) || empty($protocol) || empty($port) || empty($login))
			throw new InvalidArgumentException("Some required fields missing");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<release_server></release_server>');
			
			$xml->addChild('name', $name);
			$xml->addChild('local_path', $local_path);
			$xml->addChild('remote_path', $remote_path);
			$xml->addChild('remote_addr', $remote_addr);
			
			$xml->addChild('login', $login);
			
			if($protocol == 'sftp') {
				$xml->addChild('protocol', 'sftp');
				
				if($authenticate_by_key == true) {
					$xml->addChild('authenticate_by_key', true);
				}
				else {
					$xml->addChild('password', $password);
				}
			}
			else {
				$xml->addChild('protocol', 'ftp');
				$xml->addChild('password', $password);
			}
			
			$xml->addChild('port', $port);
			
			if(!is_null($use_active_mode))
				$xml->addChild('use_active_mode', $use_active_mode);
			
			if(!is_null($use_feat))
				$xml->addChild('use_feat', $use_feat); // True by default
			
			if(!is_null($pre_release_hook))
				$xml->addChild('pre_release_hook', $pre_release_hook);
			
			if(!is_null($post_release_hook))
				$xml->addChild('post_release_hook', $post_release_hook);
			
			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('release_server' => array());
			
			$data_array['release_server']['name'] = $name;
			$data_array['release_server']['local_path'] = $local_path;
			$data_array['release_server']['remote_path'] = $remote_path;
			$data_array['release_server']['remote_addr'] = $remote_addr;
			
			$data_array['release_server']['login'] = $login;
			
			if($protocol == 'sftp') {
				$data_array['release_server']['protocol'] = 'sftp';
				
				if($authenticate_by_key == true) {
					$data_array['release_server']['authenticate_by_key'] = true;
				}
				else {
					$data_array['release_server']['password'] = $password;
				}
			}
			else {
				$data_array['release_server']['protocol'] = 'ftp';
				$data_array['release_server']['password'] = $password;
			}
			
			$data_array['release_server']['port'] = $port;
			
			if(!is_null($use_active_mode))
				$data_array['release_server']['use_active_mode'] = $use_active_mode;
			
			if(!is_null($use_feat))
				$data_array['release_server']['use_feat'] = $use_feat; // True by default
			
			if(!is_null($pre_release_hook))
				$data_array['release_server']['pre_release_hook'] = $pre_release_hook;
			
			if(!is_null($post_release_hook))
				$data_array['release_server']['post_release_hook'] = $post_release_hook;
			
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "release_servers." . $this->format . "?environment_id=" . $environment_id, "POST", $data);
	}

	/**
	 * Update a release server
	 *
	 * @link http://api.beanstalkapp.com/release_server.html
	 * @param integer $repo_id
	 * @param integer $server_id
	 * @param array $params Accepts - name, local_path, remote_path, remote_addr, protocol, port, login, password, use_active_mode, authenticate_by_key, use_feat, pre_release_hook, post_release_hook
	 * @return SimpleXMLElement|array
	 */
	public function update_release_server($repo_id, $server_id, $params = array()) {
		if(empty($repo_id) || empty($server_id))
			throw new InvalidArgumentException("Repository ID and release server ID required");
		
		if(count($params) == 0)
			throw new InvalidArgumentException("Nothing to update");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<release_server></release_server>');
	
			if(!is_null($params['name']))
				$xml->addChild('name', $params['name']);
	
			if(!is_null($params['local_path']))
				$xml->addChild('local_path', $params['local_path']);
	
			if(!is_null($params['remote_path']))
				$xml->addChild('remote_path', $params['remote_path']);
	
			if(!is_null($params['remote_addr']))
				$xml->addChild('remote_addr', $params['remote_addr']);
	
			if(!is_null($params['protocol']))
				$xml->addChild('protocol', $params['protocol']);
	
			if(!is_null($params['port']))
				$xml->addChild('port', $params['port']);
	
			if(!is_null($params['login']))
				$xml->addChild('login', $params['login']);

			if(!is_null($params['password']))
				$xml->addChild('password', $params['password']);

			if(!is_null($params['use_active_mode']))
				$xml->addChild('use_active_mode', $params['use_active_mode']);

			if(!is_null($params['authenticate_by_key']))
				$xml->addChild('authenticate_by_key', $params['authenticate_by_key']);

			if(!is_null($params['use_feat']))
				$xml->addChild('use_feat', $params['use_feat']);

			if(!is_null($params['pre_release_hook']))
				$xml->addChild('pre_release_hook', $params['pre_release_hook']);

			if(!is_null($params['post_release_hook']))
				$xml->addChild('post_release_hook', $params['post_release_hook']);

			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('release_server' => array());
			
			if(!is_null($params['name']))
				$data_array['release_server']['name'] = $params['name'];
			
			if(!is_null($params['local_path']))
				$data_array['release_server']['local_path'] = $params['local_path'];
			
			if(!is_null($params['remote_path']))
				$data_array['release_server']['remote_path'] = $params['remote_path'];
			
			if(!is_null($params['remote_addr']))
				$data_array['release_server']['remote_addr'] = $params['remote_addr'];
			
			if(!is_null($params['protocol']))
				$data_array['release_server']['protocol'] = $params['protocol'];
			
			if(!is_null($params['port']))
				$data_array['release_server']['port'] = $params['port'];
			
			if(!is_null($params['login']))
				$data_array['release_server']['login'] = $params['login'];
			
			if(!is_null($params['password']))
				$data_array['release_server']['password'] = $params['password'];
			
			if(!is_null($params['use_active_mode']))
				$data_array['release_server']['use_active_mode'] = $params['use_active_mode'];
			
			if(!is_null($params['authenticate_by_key']))
				$data_array['release_server']['authenticate_by_key'] = $params['authenticate_by_key'];
			
			if(!is_null($params['use_feat']))
				$data_array['release_server']['use_feat'] = $params['use_feat'];
			
			if(!is_null($params['pre_release_hook']))
				$data_array['release_server']['pre_release_hook'] = $params['pre_release_hook'];
			
			if(!is_null($params['post_release_hook']))
				$data_array['release_server']['post_release_hook'] = $params['post_release_hook'];
	
			$data = json_encode($data_array);
		}
		
		return $this->_execute($repo_id, "release_servers/" . $server_id . "." . $this->format, "PUT", $data);
	}

	/**
	 * Delete a release server
	 *
	 * @link http://api.beanstalkapp.com/release_server.html
	 * @param integer $repo_id
	 * @param integer $server_id
	 * @return SimpleXMLElement|array
	 */
	public function delete_release_server($repo_id, $server_id) {
		if(empty($repo_id) || empty($server_id))
			throw new InvalidArgumentException("Repository ID and release server ID required");
		
		return $this->_execute_curl($repo_id, "release_servers/" . $server_id . "." . $this->format, "DELETE");
	}


	//
	// Releases
	//

	/**
	 * Returns a listing of releases for an account, or for a Beanstalk repository if specified
	 *
	 * @link http://api.beanstalkapp.com/release.html
	 * @param integer $repo_id [optional] Releases from specified repository
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 10, max 50
	 * @return SimpleXMLElement|array
	 */
	public function find_all_releases($repo_id = NULL, $page = 1, $per_page = 10) {
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		if(empty($repo_id))
		{
			return $this->_execute_curl("releases." . $this->format . "?page=" . $page . "&per_page=" . $per_page, NULL);
		}
		else
		{
			return $this->_execute_curl($repo_id, "releases." . $this->format . "?page=" . $page . "&per_page=" . $per_page);
		}
	}

	/**
	 * Returns a listing of releases for a specific repos, and optionally environment
	 * @param integer $repo_id
	 * @param integer $environment_id [optional] Optional server environment filtering
	 * @param integer $page [optional] Current page of results
	 * @param integer $per_page [optional] Results per page - default 10, max 50
	 * @return SimpleXmlElement|array
	 */
	public function find_all_repository_releases($repo_id, $environment_id = NULL, $page = 1, $per_page = 10) {
		if(empty($repo_id))
			throw new InvalidArgumentException("Repository ID required");
		
		$per_page = intval($per_page) > 50 ? 50 : intval($per_page);
		
		// Should this be changed to array of query string params and use http_build_query() ?
		if(is_null($environment_id))
		{
			return $this->_execute_curl($repo_id, "releases." . $this->format . "?page=" . $page . "&per_page=" . $per_page);
		}
		else
		{
			return $this->_execute_curl($repo_id, "releases." . $this->format . "?environment_id=" . $environment_id . "&page=" . $page . "&per_page=" . $per_page);
		}
	}

	/**
	 * Returns a Beanstalk repository's release based on a specific release id
	 *
	 * @link http://api.beanstalkapp.com/release.html
	 * @param integer $repo_id		required
	 * @param integer $release_id	required
	 * @return SimpleXMLElement|array
	 */
	public function find_single_release($repo_id, $release_id) {
		if(empty($repo_id) || empty($release_id))
			throw new InvalidArgumentException("Repository ID and release ID required");
		
		return $this->_execute_curl($repo_id, "releases/" . $release_id . "." . $this->format);
	}

	/**
	 * Create a new release - ie. deploy to a server environment
	 *
	 * @link http://api.beanstalkapp.com/release.html
	 * @param integer $repo_id
	 * @param integer $environment_id
	 * @param integer $revision_id
	 * @param string $comment [optional]
	 * @param bool $deploy_from_scratch [optional]
	 * @return SimpleXMLElement|array
	 */
	public function create_release($repo_id, $environment_id, $revision_id, $comment = '', $deploy_from_scratch = false) {
		if(empty($repo_id) || empty($environment_id) || empty($revision_id))
			throw new InvalidArgumentException("Repository ID, server environment ID and revision required");
		
		if($this->format == 'xml')
		{
			$xml = new SimpleXMLElement('<release></release>');
	
			$revision_xml = $xml->addChild('revision', $revision_id);
			$revision_xml->addAttribute('type', 'integer');
	
			$xml->addChild('comment', $comment);
			$xml->addChild('deploy_from_scratch', $deploy_from_scratch);

			$data = $xml->asXml();
		}
		else
		{
			$data_array = array('release' => array());
			
			$data_array['release']['revision'] = $revision_id;
			$data_array['release']['comment'] = $comment;
			$data_array['release']['deploy_from_scratch'] = $deploy_from_scratch;
	
			$data = json_encode($data_array);
		}
		
		return $this->_execute_curl($repo_id, "releases." . $this->format . "?environment_id=" . $environment_id, "POST", $data);
	}

	/**
	 * Retry a failed release
	 *
	 * @link http://api.beanstalkapp.com/release.html
	 * @param integer $repo_id
	 * @param integer $release_id
	 * @return SimpleXMLElement|array
	 */
	public function retry_release($repo_id, $release_id) {
		if(empty($repo_id) || empty($release_id))
			throw new InvalidArgumentException("Repository ID and release ID required");
		
		return $this->_execute_curl($repo_id, "releases/" . $release_id . "/retry." . $this->format, "PUT");
	}


	//
	// Utility functions
	//

	/**
	 * Sets up and executes the cURL requests and returns the response
	 *
	 * @param string $api_name
	 * @param string $api_params [optional]
	 * @param string $curl_verb [optional]
	 * @param string $write_data [optional]
	 * @return SimpleXMLElement Returns false on error
	 */
	private function _execute_curl($api_name, $api_params = NULL, $curl_verb = "GET", $write_data = NULL) {
		if( ! isset($api_params))
			$ch = curl_init("https://" . $this->account_name . ".beanstalkapp.com/api/" . $api_name);
		else
			$ch = curl_init("https://" . $this->account_name . ".beanstalkapp.com/api/" . $api_name . "/" . $api_params);

		$headers = array('Content-type: application/' . $this->format);
		curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
		curl_setopt($ch, CURLOPT_USERPWD, $this->username . ':' . $this->password);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION,1);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		
		curl_setopt($ch, CURLOPT_SSL_VERIFYPEER, false);
		
		if(!is_null($write_data))
			curl_setopt($ch, CURLOPT_POSTFIELDS, $write_data);
		
		// Special processing for DELETE requests
		if($curl_verb == 'DELETE') {
			$curl_verb = 'POST';
			curl_setopt($ch, CURLOPT_HTTPHEADER, array('X-HTTP-Method-Override: DELETE'));
		}
		
		curl_setopt($ch, CURLOPT_CUSTOMREQUEST, $curl_verb);

		$data = curl_exec($ch);

		$this->curl_info = curl_getinfo($ch);
		
		// Check return code is in 2xx range
		if(floor($this->curl_info['http_code'] / 100) != 2) {
			$this->error_code = $this->curl_info['http_code'];
			$this->error_string = "Curl request failed";
			throw new APIException($this->error_code . ": ".$this->error_string, $this->error_code);
		}

		// Request failed
		if ($data === FALSE) {
			$this->error_code = curl_errno($ch);
			$this->error_string = curl_error($ch);
			curl_close($ch);
			throw new APIException($this->error_code . ": " . $this->error_string, $this->error_code);
		}
		
		curl_close($ch);
		
		// API can return empty responses, just return true
		if(empty($data)) {
			return true;
		}
		
		if($this->format == 'xml')
		{
			// Process XML into SimpleXMLElement
			return simplexml_load_string($data);	
		}
		else
		{
			// Process JSON
			return json_decode($data);
		}
	}
}

// Exception thrown if there's a problem with the API
class APIException extends Exception {}
