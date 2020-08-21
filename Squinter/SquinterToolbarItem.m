

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "SquinterToolbarItem.h"


@implementation SquinterToolbarItem
@synthesize activeImageName, inactiveImageName;



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
        activeImageName= @"compile";
        inactiveImageName = @"compile";
    }

    return self;
}



-(void)validate
{
    // Set the toolbar item image name according to whether the app is foregrounded or not
    
    [self setImage:[NSImage imageNamed:(isForeground ? activeImageName : inactiveImageName)]];
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
    SquinterToolbarItem *copiedItem = [super copyWithZone:zone];
    copiedItem->activeImageName = [self.activeImageName copyWithZone:zone];
    copiedItem->inactiveImageName = [self.inactiveImageName copyWithZone:zone];
    return copiedItem;
}



@end
