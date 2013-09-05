// $Id: SkypeAPI.h,v 1.5 2005/11/28 19:00:28 teelem Exp $
//
//  SkypeAPI.h
//  SkypeMac
//
//  Created by Janno Teelem on 12/04/2005.
//  Copyright (c) 2005 Skype Technologies S.A. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol SkypeAPIDelegate;

@interface SkypeAPI : NSObject 
{

}

+ (BOOL)isSkypeRunning;				
+ (BOOL)isSkypeAvailable;		// You can only connect and send commands when this method returns YES.
								// For example, when Skype is running, but user is logged out, then it returns NO.
								
+ (void)setSkypeDelegate:(NSObject<SkypeAPIDelegate>*)aDelegate;
+ (NSObject<SkypeAPIDelegate>*)skypeDelegate;
+ (void)removeSkypeDelegate;

+ (void)connect;
+ (void)disconnect;

+ (NSString*)sendSkypeCommand:(NSString*)aCommandString;
@end


// delegate protocol
@protocol SkypeAPIDelegate
- (NSString*)clientApplicationName;
@end

// delegate informal protocol
@interface NSObject (SkypeAPIDelegateInformalProtocol)
- (void)skypeNotificationReceived:(NSString*)aNotificationString;
- (void)skypeAttachResponse:(unsigned)aAttachResponseCode;				// 0 - failed, 1 - success
- (void)skypeBecameAvailable:(NSNotification*)aNotification;
- (void)skypeBecameUnavailable:(NSNotification*)aNotification;
@end

