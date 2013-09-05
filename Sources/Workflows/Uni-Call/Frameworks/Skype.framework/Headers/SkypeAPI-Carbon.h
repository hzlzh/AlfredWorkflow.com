// $Id: SkypeAPI-Carbon.h,v 1.4 2005/11/28 19:00:28 teelem Exp $
/*
 *  SkypeAPI-Carbon.h
 *  SkypeMac
 *
 *  Created by Janno Teelem on 14/06/2005.
 *  Copyright 2005 Skype Technologies S.A.. All rights reserved.
 *
 */

#import <sys/cdefs.h>
#import <Carbon/Carbon.h>

__BEGIN_DECLS

// In order to use Skype API, you must create a single instance of SkypeDelegate.
// Set callback functions for the members of this struct and Skype will call these
// functions to notify your application when something happens.
struct SkypeDelegate
{
	// Required member
	CFStringRef clientApplicationName;
	
	// Optional members, can be NULL
	void (*SkypeNotificationReceived)(CFStringRef aNotificationString);
	void (*SkypeAttachResponse)(unsigned int aAttachResponseCode);			// 0 - failed, 1 - success
	void (*SkypeBecameAvailable)(CFPropertyListRef aNotification);
	void (*SkypeBecameUnavailable)(CFPropertyListRef aNotification);
};

Boolean IsSkypeRunning(void);
Boolean IsSkypeAvailable(void);

// You must call this function, before calling ConnectToSkype() and SendSkypeCommand()
void SetSkypeDelegate(struct SkypeDelegate* aDelegate);

struct SkypeDelegate* GetSkypeDelegate(void);
void RemoveSkypeDelegate(void);

void ConnectToSkype(void);
void DisconnectFromSkype(void);

CFStringRef SendSkypeCommand(CFStringRef aCommandString);

__END_DECLS
