

//  Created by Tony Smith on 15/05/2018.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "LoginToolbarItem.h"


@implementation LoginToolbarItem
@synthesize activeLoginImageName, activeLogoutImageName, inactiveLoginImageName, inactiveLogoutImageName, isLoggedIn;



- (instancetype)initWithItemIdentifier:(NSString *)itemIdentifier
{
    if (self = [super initWithItemIdentifier:itemIdentifier])
    {
		// Set up notification watchers for key app events: going active and becoming active
		// so that the button can switch its displayed image accordingly

		[[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillResignActive)
                                                     name:NSApplicationWillResignActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillBecomeActive)
                                                     name:NSApplicationWillBecomeActiveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(appWillQuit)
                                                     name:NSApplicationWillTerminateNotification
                                                   object:nil];

        isForeground = YES;
        isLoggedIn = NO;
        activeLogoutImageName = @"logout";
        activeLoginImageName = @"login";
        inactiveLogoutImageName = @"logout_grey";
        inactiveLoginImageName = @"login_grey";
        
        // NOTE These images display the action that takes place when clicked, ie. the reverse
        //      of the current stage. For example, when a user is logged in, the icon will show
        //      an open lock to indicate that a click will cause the user to be logged out. A closed
        //      lock icon indicates the user needs to unlock the lock, ie. log in.
        // TODO Perhaps change these icons to be more representative of logging in/out
    }

    return self;
}



- (void)validate
{
    // Set the toolbar item image name according to whether the app is foregrounded or not,
    // and whether the user is currently logged in ('Login') or not ('Logout') and update
    // the item's label while we're at it
    
    if (!isLoggedIn)
    {
        [self setImage:[NSImage imageNamed:(isForeground ? activeLoginImageName : inactiveLoginImageName)]];
        self.label = @"In";
    }
    else
    {
        [self setImage:[NSImage imageNamed:(isForeground ? activeLogoutImageName : inactiveLogoutImageName)]];
        self.label = @"Out";
    }
    
    [super validate];
}



- (void)appWillBecomeActive
{
    // App is entering the background to set the toolbar item image to green
    
    isForeground = YES;
    [self validate];
}



- (void)appWillResignActive
{
    // App is entering the background to set the toolbar item image to grey
    
    isForeground = NO;
    [self validate];
}



- (void)appWillQuit
{
    // App is about to bail, so tidy up: stop watching for notifications

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (id)copyWithZone:(NSZone *)zone
{
    LoginToolbarItem *copiedItem = [super copyWithZone:zone];
    copiedItem->activeLogoutImageName = [self.activeLogoutImageName copyWithZone:zone];
    copiedItem->activeLoginImageName = [self.activeLoginImageName copyWithZone:zone];
    copiedItem->inactiveLogoutImageName = [self.inactiveLogoutImageName copyWithZone:zone];
    copiedItem->inactiveLoginImageName = [self.inactiveLoginImageName copyWithZone:zone];
    return copiedItem;
}



@end
