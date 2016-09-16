

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015 Tony Smith. All rights reserved.


#import "SquinterToolbarItem.h"


@implementation SquinterToolbarItem
@synthesize onImageName, offImageName;



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
		onImageName= @"compile";
		offImageName = @"compile";
	}

	return self;
}



-(void)validate
{
	if (isForeground)
	{
		[self setImage:[NSImage imageNamed:onImageName]];
	}
	else
	{
		[self setImage:[NSImage imageNamed:offImageName]];
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
	SquinterToolbarItem *copiedItem = [super copyWithZone:zone];
	copiedItem->onImageName = [self.onImageName copyWithZone:zone];
	copiedItem->offImageName = [self.onImageName copyWithZone:zone];
	return copiedItem;
}



@end