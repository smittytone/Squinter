

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface SquinterToolbarItem : NSToolbarItem <NSCopying>
{
    BOOL isForeground;
}


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


// Properties are used to set the names of the image files used to represent
// the toolbar item's state: active (ie. foregrounded) or inactive
@property (nonatomic, strong) NSString *activeImageName;
@property (nonatomic, strong) NSString *inactiveImageName;


@end
