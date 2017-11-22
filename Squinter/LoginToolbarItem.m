

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import "LoginToolbarItem.h"


@implementation LoginToolbarItem
@synthesize openImageName, lockedImageName, openImageNameGrey, lockedImageNameGrey, isLocked;



- (instancetype)initWithItemIdentifier:(NSString *)itemIdentifier
{
    self = [super initWithItemIdentifier:itemIdentifier];

    if (self)
    {
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
        isLocked = YES;
        openImageName = @"logout";
        lockedImageName = @"login";
        openImageNameGrey = @"logout_grey";
        lockedImageNameGrey = @"login_grey";
    }

    return self;
}



- (void)validate
{
    if (isForeground)
    {
        // App in foreground, so draw in green

        if (isLocked)
        {
            [self setImage:[NSImage imageNamed:lockedImageName]];
            self.label = @"In";
        }
        else
        {
            [self setImage:[NSImage imageNamed:openImageName]];
            self.label = @"Out";
        }
    }
    else
    {
        // App in background, draw in grey

        if (isLocked)
        {
            [self setImage:[NSImage imageNamed:lockedImageNameGrey]];
            self.label = @"In";
        }
        else
        {
            [self setImage:[NSImage imageNamed:openImageNameGrey]];
            self.label = @"Out";
        }
    }
}



- (void)appWillBecomeActive
{
    isForeground = YES;
    [self validate];
}



- (void)appWillResignActive
{
    isForeground = NO;
    [self validate];
}



- (void)appWillQuit
{
    // Stop watching for notifications

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



- (id)copyWithZone:(NSZone *)zone
{
    LoginToolbarItem *copiedItem = [super copyWithZone:zone];
    copiedItem->openImageName = [self.openImageName copyWithZone:zone];
    copiedItem->lockedImageName = [self.lockedImageName copyWithZone:zone];
    copiedItem->openImageNameGrey = [self.openImageNameGrey copyWithZone:zone];
    copiedItem->lockedImageNameGrey = [self.lockedImageNameGrey copyWithZone:zone];
    return copiedItem;
}



@end
