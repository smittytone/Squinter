

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-15 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"


@interface StatusLight : NSView

{
    BOOL fullFlag, isLightOn, isForeground;
}


@property (nonatomic, strong) NSImage *theCurrentImage;


- (void)setLight:(BOOL)onOrOff;
- (void)setFull:(BOOL)fullOrOutline;

- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end