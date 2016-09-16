

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015 Tony Smith. All rights reserved.


#import "StreamToolbarItem.h"


@implementation StreamToolbarItem
@synthesize onImageName, offImageName, offImageNameGrey, onImageNameGrey, isOn;



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
		onImageName = @"compile";
		offImageName = @"compile";
		onImageNameGrey = @"compile_grey";
		offImageNameGrey = @"compile_grey";
	}

	return self;
}



- (void)validate
{
	NSImage *itemIcon = [[NSImage alloc] initWithSize:NSMakeSize(self.image.size.height, self.image.size.width)];

	if (isForeground)
	{
		// App in foreground, so draw in green

		if (isOn)
		{
			NSImage *icon = [NSImage imageNamed:offImageName];
			NSImage *flag = [NSImage imageNamed:onImageName];
			NSRect iRect = NSMakeRect(0, 0, itemIcon.size.width, itemIcon.size.height);
			[itemIcon lockFocus];
			[icon drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[flag drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[itemIcon unlockFocus];
		}
		else
		{
			NSImage *icon = [NSImage imageNamed:offImageName];
			NSRect iRect = NSMakeRect(0, 0, itemIcon.size.width, itemIcon.size.height);
			[itemIcon lockFocus];
			[icon drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[itemIcon unlockFocus];
		}
	}
	else
	{
		// App in background, draw in grey

		if (isOn)
		{
			NSImage *icon = [NSImage imageNamed:offImageNameGrey];
			NSImage *flag = [NSImage imageNamed:onImageNameGrey];
			NSRect iRect = NSMakeRect(0, 0, itemIcon.size.width, itemIcon.size.height);
			[itemIcon lockFocus];
			[icon drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[flag drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[itemIcon unlockFocus];
		}
		else
		{
			NSImage *icon = [NSImage imageNamed:offImageNameGrey];
			NSRect iRect = NSMakeRect(0, 0, itemIcon.size.width, itemIcon.size.height);
			[itemIcon lockFocus];
			[icon drawInRect:iRect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
			[itemIcon unlockFocus];
		}
	}

	[self setImage:itemIcon];
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
	StreamToolbarItem *copiedItem = [super copyWithZone:zone];
	copiedItem->onImageName = [self.onImageName copyWithZone:zone];
	copiedItem->offImageName = [self.onImageName copyWithZone:zone];
	copiedItem->onImageNameGrey = [self.onImageNameGrey copyWithZone:zone];
	copiedItem->offImageNameGrey = [self.offImageNameGrey copyWithZone:zone];
	return copiedItem;
}



@end