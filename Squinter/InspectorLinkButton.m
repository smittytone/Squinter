

//  Created by Tony Smith on 01/08/2018.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import "InspectorLinkButton.h"

@implementation InspectorLinkButton


- (void)awakeFromNib
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
}



- (void)resetCursorRects
{
    // Reset the cursor when it hovers over the button
    
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
}



- (void)appWillBecomeActive
{
    // ADDED 2.3.131
    // App is entering the foreground to set the StatusLight image to green
    
    self.alphaValue = 1.0;
}



- (void)appWillResignActive
{
    // ADDED 2.3.131
    // App is entering the background to set the Inspector's elements to half alpha
    
    self.alphaValue = 0.5;
}



- (void)appWillQuit
{
    // ADDED 2.3.131
    // App is about to bail, so tidy up: stop watching for notifications
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



@end
