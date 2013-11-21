<?php

/*!
	@header     Alfred Script Filters
	@abstract   Provides filters that take input directly from Alfred for 
	            the purpose of filtering lists or selecting options.
	@discussion In order to use a handler within Alfred, simply call the
	            script with two arguments: the name of the filter to call
	            and the user's query.

	            See the following example for using a bash script to run a 
	            filter. Note that backquotes, double quotes, backslashes,
	            and dollar signs should be escaped when providing input
	            this way. Excess escaping can cause problems handling simple 
	            characters such as spaces.
				<pre><code>    /usr/bin/env php "`pwd`/filters.php" filterListsToAddTask "{query}"</code></pre>

				Why PHP? This is a [likely temporary] solution to slow 
				feedback from applescript for list filtering. It was found
				that a simple Hello World script took 90ms to run with
				osascript, making AppleScript unsuitable for live filtering.
				Simple script language alternatives such as Python and PHP
				were put through similar tests. By far Perl was the fastest.
				However, in order to be useful the language must have an 
				Alfred workflow library and load it efficiently. Perl did not
				and Python's two options were both shockingly slow. This left
				PHP which was capable of 60ms response times once the logic
				was fully implemented. 

				Unfortunately, PHP and AppleScript do not play well together
				when it comes to platform specifics such as localization. 
				This script will likely be replaced with a compiled Cocoa 
				utility that combines speed and platform suitability.
	@version    0.2
*/

require_once 'workflows.php';
require_once 'CFPropertyList/CFPropertyList.php';

$workflow = new Workflows();

/*!
	@abstract Loads the workflow's <code>settings.plist</code> into an 
	associative array.
	@return An associative array containing each of the keys from the
	property list in native PHP data structures.
*/
function getWorkflowSettings()
{
	global $workflow;

	try
	{
		# workflows.php does not handle property lists with anything other than 
		# single-line string data. Therefore it is necessary to use CFPropertyList
		# which will retrieve values from the settings list in the proper data
		# type.
		$plist = new \CFPropertyList\CFPropertyList($workflow->data() . '/settings.plist', \CFPropertyList\CFPropertyList::FORMAT_XML);
		return $plist->toArray();
	}
	catch (Exception $e)
	{
		return array();
	}
}

/*!
	@abstract   Loads list info from the cache or reloads it from Wunderlist
	@discussion 

	@param $attempts Guards against infinite recursion, for internal use only
	@return an array of associative arrays in the <code>ListInfo</code> format
	@see //apple_ref/applescript/func/getListInfo getListInfo in AppleScript
*/
function getListInfo($attempts = 0)
{
	global $workflow;

	$settings = getWorkflowSettings();
	$lists = $settings['lists'];
	$listsUpdatedTimestamp = $settings['listsUpdatedDate'];

	if ($attempts < 2 && (empty($lists) || time() - $listsUpdatedTimestamp > 30))
	{
		$status = 0;

		if (empty($lists))
		{
			# Use AppleScript to fetch the list info from the Wunderlist UI, 
			# forcing it to do whatever necessary to load the info
			$status = rtrim(`/usr/bin/env osascript wunderlist.scpt forceUpdateListInfo`);
		}
		else
		{
			# Use AppleScript to fetch the list info from the Wunderlist UI
			$status = rtrim(`/usr/bin/env osascript wunderlist.scpt updateListInfo`);
		}

		# The list info was refreshed and should be reloaded from settings.
		# Otherwise, the list info could not be reloaded so return whatever 
		# was cached
		if ($status == '1')
		{
			return getListInfo($attempts + 1);
		}
	}

	return $lists;
}

/*!
	@abstract   A Script Filter input that shows the user's lists in Alfred, allowing
	a task to be added to a specific list.
	@discussion Queries the Wunderlist UI to provide all of the lists into which
	new tasks can be added. The response is formatted for Alfred to display in
	a way that allows the user to type their task, then action a specific list to
	insert the task there.

	After selecting one of these options, the final query will be a concatenation 
	of the list index and the user's task in a format suitable for 
	@link addTaskToList @/link:
	<pre><code>    5::2% milk</code></pre>

	The user may also select a list by autocompletion or substring matching. If the
	query text is a substring of any of the list names, the lists will be filtered
	to show only those that match. The user can action a list item to autocomplete 
	the list name in the following format:
	<pre><code>    Groceries:2% milk</code></pre>

	Alternatively, the user can type a colon character indicating that the task is
	to be entered in the first task matching that substring. The match is case 
	insensitive but is sensitive to accents and other diacritical marks.
	<pre><code>    gro:2% milk</code></pre>
	@param task The text of the task, optionally specified with a substring of a 
	list name followed by a colon to designate the list into which the task should
	be added.
*/
function filterListsToAddTask($query)
{
	global $workflow;

	$responseItems = array();
	$listFilter = '';
	$task = '';
	$queryComponents = explode(':', $query, 2);
	$hasTask = false;

	# Parse the query
	if (count($queryComponents) == 2)
	{
		$listFilter = $queryComponents[0];
		$task = $queryComponents[1];
		$hasTask = true;
	}
	else if (count($queryComponents) == 1)
	{
		$listFilter = $queryComponents[0];
	}

	$listFilter = strtolower($listFilter);

	$allLists = getListInfo();
	$writableLists = array();
	$matchingLists = array();
	$canAutocomplete = !$hasTask;

	# Get list names from Wunderlist in the current locale
	$list_all = 'All';
	$list_assignedToMe = 'Assigned to Me';
	$list_completed = 'Completed';
	$list_week = 'Week';
	$list_inbox = 'Inbox';
	$list_today = 'Today';;
	$list_starred = 'Starred';

	# These lists do not allow addition of new tasks
	$readonlyLists = array(strtolower($list_all), strtolower($list_assignedToMe), strtolower($list_completed), strtolower($list_week));

	foreach ($allLists as $listInfo)
	{
		$listName = strtolower($listInfo['listName']);
		if (!in_array($listName, $readonlyLists))
		{
			# If nothing matches the filter we need to have a 
			# record of all the lists that accept tasks
			array_push($writableLists, $listInfo);

			if ($listFilter !== '' && strpos($listName, $listFilter) !== false)
			{
				# The list is an exact match and the user has typed
				# (or autocompleted) the : following the list name, 
				# look no further
				if ($hasTask && $listName == $listFilter)
				{
					# Show only the matching list and add the task 
					# on return
					$matchingLists = array($listInfo);
					$canAutocomplete = false;
					break;
				}
				# The list filter is a substring of this list name
				else
				{
					array_push($matchingLists, $listInfo);
				}
			}
		}
	}

	# There are no matching lists, so just let the user type a
	# task and select a list later using the arrow keys
	if (count($matchingLists) == 0)
	{
		$matchingLists = $writableLists;

		# If no text has been entered, allow autocompleting,
		# otherwise the user has begun to type a task. In
		# that case, actioning a list in Alfred should insert
		# the task into the list, not perform autocompletion.
		if ($listFilter !== '')
		{
			$canAutocomplete = false;

			# The task contained a colon which should not be
			# misinterpreted as filtering the list because
			# we know that no lists matched.
			if ($task !== '')
			{
				$task = $query;
			}
		}

		# Since autocomplete is disabled, set the first item to
		# the active list.
		$uid = null;
		$arg = $listIndex . '::' . $task;
		$title = 'Most recently used';
		$subtitle = 'Add a task to the most recently used list';
		$icon = 'icon.png';
		$valid = true;
		$autocompletion = null;

		$workflow->result($uid, $arg, $title, $subtitle, $icon, $valid, $autocompletion);

		# If the user did not type a colon the listFilter will
		# contain the text of the task. We know it doesn't match
		# any of the lists so now we can just reassign this.
		if ($task === '')
		{
			$task = $queryComponents[0];
		}
	}

	# Display all matching lists
	foreach ($matchingLists as $listInfo)
	{
		$listName = $listInfo['listName'];
		$taskCount = $listInfo['taskCount'];
		$listIndex = $listInfo['listIndex'];

		# Populate data for the result
		# Show 'a task' as a placeholder in 'Add [a task] to this list'
		$uid = null;
		$arg = $listIndex . '::' . $task;
		$title = $listName;
		$subtitle = 'Add ' . ($task ? $task : 'a task') . ' to this list';
		$icon = '/generic.png';
		$valid = true;
		$autocompletion = null;

		# If autocompletion is possible, set isValid to false
		# to enable autocomplete on tab
		if ($canAutocomplete)
		{
			$valid = true;
			$autocompletion = $listName . ':';
		}

		# Choose the proper icon for each list
		if ($listName == $list_inbox)
		{
			$icon = '/inbox.png';
		}
		else if ($listName == $list_today)
		{
			$icon = '/today.png';
		}
		else if ($listName == $list_starred)
		{
			$icon = '/starred.png';
		}

		# Load the icon based on the configured theme 
		$icon = 'lists/light/' . $icon;
		
		$workflow->result($uid, $arg, $title, $subtitle, $icon, $valid, $autocompletion);
	}

	return $workflow->toxml();
}

# Handle command input
if (count($argv) == 3)
{
	$command = $argv[1];
	$query = $argv[2];

	if ($command == 'filterListsToAddTask')
	{
		echo filterListsToAddTask($query);
	}
}
else if (count($argv) == 2)
{
	$command = $argv[1];
}