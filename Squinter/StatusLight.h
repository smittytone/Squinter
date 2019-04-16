

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"


@interface StatusLight : NSView
{
    BOOL isLightFull, isLightOn, isForeground;
}


- (void)needSave:(BOOL)yesOrNo;
- (void)show;
- (void)hide;
- (void)setLight:(BOOL)onOrOff;
- (void)setFull:(BOOL)fullOrOutline;

- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@property (nonatomic, strong) NSImage *theCurrentImage;


@end
