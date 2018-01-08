

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface SquinterToolbarItem : NSToolbarItem <NSCopying>

{
    BOOL isForeground;
}


@property (nonatomic, strong) NSString *activeImageName;
@property (nonatomic, strong) NSString *inactiveImageName;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end
