

//  Created by Tony Smith on 15/05/2018.
//  Copyright (c) 2018-19 Tony Smith. All rights reserved.


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
    }

    return self;
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



- (void)validate
{
    // Set the toolbar item image name according to whether the app is foregrounded or not,
    // and whether the user is currently logged in ('Login') or not ('Logout') and update
    // the item's label while we're at it
    
    if (isForeground)
    {
        // App in foreground, so draw in green

        if (!isLoggedIn)
        {
            [self setImage:[NSImage imageNamed:activeLoginImageName]];
            self.label = @"In";
        }
        else
        {
            [self setImage:[NSImage imageNamed:activeLogoutImageName]];
            self.label = @"Out";
        }
    }
    else
    {
        // App in background, draw in grey

        if (!isLoggedIn)
        {
            [self setImage:[NSImage imageNamed:inactiveLoginImageName]];
            self.label = @"In";
        }
        else
        {
            [self setImage:[NSImage imageNamed:inactiveLogoutImageName]];
            self.label = @"Out";
        }
    }
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
