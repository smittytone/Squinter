
//  Created by Tony Smith on 29/11/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//

#import "InspectorToolbarItem.h"

@implementation InspectorToolbarItem
@synthesize activeShowImageName, activeHideImageName, inactiveShowImageName, inactiveHideImageName, isShown;



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
        isShown = YES;
        activeShowImageName = @"inspector_show";
        activeHideImageName = @"inspector_hide";
        inactiveShowImageName = @"inspector_show_grey";
        inactiveHideImageName = @"inspector_hide_grey";
        
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
    
    if (isShown)
    {
        [self setImage:[NSImage imageNamed:(isForeground ? activeHideImageName : inactiveHideImageName)]];
    }
    else
    {
        [self setImage:[NSImage imageNamed:(isForeground ? activeShowImageName : inactiveShowImageName)]];
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
    InspectorToolbarItem *copiedItem = [super copyWithZone:zone];
    copiedItem->activeHideImageName = [self.activeHideImageName copyWithZone:zone];
    copiedItem->activeShowImageName = [self.activeShowImageName copyWithZone:zone];
    copiedItem->inactiveHideImageName = [self.inactiveHideImageName copyWithZone:zone];
    copiedItem->inactiveShowImageName = [self.inactiveShowImageName copyWithZone:zone];
    return copiedItem;
}



@end
