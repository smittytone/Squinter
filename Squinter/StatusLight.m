

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


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
    // When the StatusLight redraws, draw it based on current image:
    // - green (app foregrounded) or grey
    // - hollow (project needs to be saved) or full
    // - full opacity (at least one project is open) or low opacity
    
    float alpha = isLightOn ? 1.0 : 0.2;

    theCurrentImage = isForeground
        ? [NSImage imageNamed:(isLightFull ? @"light_full" : @"light_outline")]
        : [NSImage imageNamed:(isLightFull ? @"light_full_grey" : @"light_outline_grey")];

    [theCurrentImage drawAtPoint: NSMakePoint(0.0, 0.0)
                        fromRect: NSMakeRect(0, 0, 0, 0)
                       operation: NSCompositingOperationSourceOver
                        fraction: alpha];
}



- (void)needSave:(BOOL)yesOrNo
{
	// Convenience method to set the StatusLight image correctly according
    // to whether a selected project needs to be saved or not. Internally,
    // the boolean determining which image to use is the OPPOSITE of the
    // do-we-need-to-save-the-project boolean
    
    [self setFull:!yesOrNo];
	[self.window setDocumentEdited:yesOrNo];
}



- (void)show
{
    // Show the StatusLight, ie. a project is loaded
    
    [self setLight:YES];
}



- (void)hide
{
    // Hide the StatusLight, ie. no projects are loaded
    
    [self setLight:NO];
}



- (void)setLight:(BOOL)onOrOff
{
    // Controls the StatusLight icon's opacity: full when there is at least one project open
    // or low when there are NO projects open

    isLightOn = onOrOff;
    [self setNeedsDisplay:YES];
}



- (void)setFull:(BOOL)fullOrOutline
{
    // Controls the save? icon's image: full for no changes; outline for changes
    // (ie. the open project needs to be saved)

    isLightFull = fullOrOutline;
    [self setNeedsDisplay:YES];
}



- (void)appWillBecomeActive
{
    // App is entering the foreground to set the StatusLight image to green
    
    isForeground = YES;
    [self setNeedsDisplay:YES];
}



- (void)appWillResignActive
{
    // App is entering the background to set the StatusLight image to grey
    
    isForeground = NO;
    [self setNeedsDisplay:YES];
}



- (void)appWillQuit
{
    // App is about to bail, so tidy up: stop watching for notifications
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
