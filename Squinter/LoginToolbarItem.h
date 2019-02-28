

//  Created by Tony Smith on 15/05/2018.
//  Copyright (c) 2018-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface LoginToolbarItem : NSToolbarItem <NSCopying>
{
    BOOL isForeground;
}


// Properties are used to set the names of the image files used to represent
// the toolbar item's user-logged-in state ('login' or 'logout'), and for the
// toolbar item state itself: 'isLoggedIn'. There's a set of each of these
// for when the app is active (ie. foregrounded) or inactive
@property (nonatomic, strong) NSString *activeLogoutImageName;
@property (nonatomic, strong) NSString *activeLoginImageName;
@property (nonatomic, strong) NSString *inactiveLogoutImageName;
@property (nonatomic, strong) NSString *inactiveLoginImageName;
@property (nonatomic, assign) BOOL isLoggedIn;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end
