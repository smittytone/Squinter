

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-15 Tony Smith. All rights reserved.


#import "StatusLight.h"


@implementation StatusLight
@synthesize theCurrentImage;



- (instancetype)initWithFrame:(NSRect)frame
{
    if (self = [super initWithFrame:frame])
	{
        isLightFull = NO;
        isLightOn = NO;
        if (theCurrentImage == nil) theCurrentImage = [NSImage imageNamed:@"light_outline"];

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
    }
    
    return self;
}



- (void)drawRect:(NSRect)dirtyRect
{
	float alpha = 0.2;

	if (isLightOn == YES) alpha = 1.0;

    theCurrentImage = nil;

	if (isForeground)
	{
		if (isLightFull)
		{
			theCurrentImage = [NSImage imageNamed:@"light_full"];
		}
		else
		{
			theCurrentImage = [NSImage imageNamed:@"light_outline"];
		}
	}
	else
	{
		if (isLightFull)
		{
			theCurrentImage = [NSImage imageNamed:@"light_full_grey"];
		}
		else
		{
			theCurrentImage = [NSImage imageNamed:@"light_outline_grey"];
		}
	}

    [theCurrentImage drawAtPoint: NSMakePoint(0.0, 0.0)
                        fromRect: NSMakeRect(0, 0, 0, 0)
                       operation: NSCompositeSourceOver
                        fraction: alpha];
}



- (void)show
{
	[self setLight:YES];
}



- (void)hide
{
	[self setLight:NO];
}


- (void)setLight:(BOOL)onOrOff
{
	// Controls the save? icon's opacity: full when there is at least one project open
	// or low when there are NO projects open

	isLightOn = onOrOff;
	[self setNeedsDisplay:YES];
}



- (void)needSave:(BOOL)yesOrNo
{
	[self setFull:!yesOrNo];
}



- (void)setFull:(BOOL)fullOrOutline
{
	// Controls the save? icon's image: full for no changes; outline for changes

	isLightFull = fullOrOutline;
    [self setNeedsDisplay:YES];
}



- (void)appWillBecomeActive
{
	isForeground = YES;
	[self setNeedsDisplay:YES];
}



- (void)appWillResignActive
{
	isForeground = NO;
	[self setNeedsDisplay:YES];
}



- (void)appWillQuit
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
