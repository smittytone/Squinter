

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2018 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface LoginToolbarItem : NSToolbarItem <NSCopying>

{
    BOOL isForeground;
}


@property (nonatomic, strong) NSString *activeLogoutImageName;
@property (nonatomic, strong) NSString *activeLoginImageName;
@property (nonatomic, strong) NSString *inactiveLogoutImageName;
@property (nonatomic, strong) NSString *inactiveLoginImageName;
@property (nonatomic, assign) BOOL isLoggedIn;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end
