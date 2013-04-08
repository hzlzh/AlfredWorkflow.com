# Introducing Mail Actions
Go crazy minimal with **Mail.app** and still stay functional thanks to the power of Alfred 2 Workflows.

## Features
Use Alfred to:
- Navigate Mailboxes from Alfred.  
	Drill down to the Mailbox you want and action the result.
- Move/Copy selected emails with Alfred.  
	Type a few keywords to choose the desired folder. ↩ to move, ⌥+↩ to copy.
	
###Optimizations
In order to limit the overhead of always having to query and generate a list of all Mailboxes, the workflow store the information in a plist file that is updated every 7 days. The file is located at:  

	~/Library/Application Support/Alfred 2/Workflow Data/com.palobo.mailactions/mbCache.plist

	
## Installation
[Download](http://bit.ly/10UFFP5) and import or alternatively use AlfPT.

## Usage
### Keywords

- **mm** - Move the selected messages to the chosen folder;
- **mm** - With ⌥ as modifier copies the messages rather than moving
- **mg** - Go To the chosen folder.
- **mgu** - Show list of mailboxes with unread messages
- **minfo** - Shows either **README** or **CHANGELOG**. Uses Marked by default or if not present will use your default markdown viewer/editor.

### Hotkeys
- **⇧⌘A** - Toggle script to Move/Copy messages
- **⇧⌘Z** - Toggle script to Go To Mailbox;
- **⇧⌘R** - Mark every unread message in current mailbox as read;
- **⇧⌘D** - Delete every message in current mailbox!! (USe with caution)
- **⌘U** - Show list of mailboxes with unread messages

## Todo
1. Implement an action to update the cache on demand;
2. Filter the list of mailboxes with unread email
3. Integrate other useful workflows such as send to evernote/taskpaper etc.;
