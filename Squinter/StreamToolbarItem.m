

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "StreamToolbarItem.h"


@implementation StreamToolbarItem
@synthesize onImageName, offImageName, offImageNameGrey, onImageNameGrey;
@synthesize state, midImageName, midImageNameGrey;



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
        onImageName = @"log_flagged";
        offImageName = @"streamon";
        midImageName = @"log_flagging";
        midImageNameGrey = @"log_flagging_grey";
        onImageNameGrey = @"log_flagged_grey";
        offImageNameGrey = @"streamon_grey";
        
        // NOTE Some of the above images are misnamed due to changes in the app's evolution.
        //      Despite its name, 'streamon' really means 'logging_off'
    }

    return self;
}



- (void)validate
{
    // Set the toolbar item image name according to whether the app is foregrounded or not,
    // and whether the current device is logging ('on'), not logging ('off') or
    // changing logging state ('mid')
    
    switch (state)
    {
        case kStreamToolbarItemStateOff:
            [self setImage:[NSImage imageNamed:(isForeground ? offImageName : offImageNameGrey)]];
            break;
            
        case kStreamToolbarItemStateMid:
            [self setImage:[NSImage imageNamed:(isForeground ? midImageName : midImageNameGrey)]];
            break;
            
        default:
            [self setImage:[NSImage imageNamed:(isForeground ? onImageName : onImageNameGrey)]];
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
    StreamToolbarItem *copiedItem = [super copyWithZone:zone];
    copiedItem->onImageName = [self.onImageName copyWithZone:zone];
    copiedItem->onImageNameGrey = [self.onImageNameGrey copyWithZone:zone];
	copiedItem->offImageName = [self.offImageName copyWithZone:zone];
	copiedItem->offImageNameGrey = [self.offImageNameGrey copyWithZone:zone];
    copiedItem->midImageName = [self.midImageName copyWithZone:zone];
    copiedItem->midImageNameGrey = [self.midImageNameGrey copyWithZone:zone];
    return copiedItem;
}



@end
