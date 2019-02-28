

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"


@interface StreamToolbarItem : NSToolbarItem <NSCopying>
{
    BOOL isForeground;
    CGRect storedFrame;
}


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


// Properties are used to set the names of the image files used to represent
// the toolbar item's logging state (on, off or changing, aka 'mid'), and for the
// toolbar item state itself. There's a set of each of these for when the app is
// active (ie. foregrounded) or inactive ('grey')
@property (nonatomic, strong) NSString *onImageName;
@property (nonatomic, strong) NSString *onImageNameGrey;
@property (nonatomic, strong) NSString *offImageName;
@property (nonatomic, strong) NSString *offImageNameGrey;
@property (nonatomic, strong) NSString *midImageName;
@property (nonatomic, strong) NSString *midImageNameGrey;
@property (nonatomic, assign) NSInteger state;


@end
