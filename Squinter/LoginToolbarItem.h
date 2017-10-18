

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface LoginToolbarItem : NSToolbarItem <NSCopying>

{
	BOOL isForeground;
}


@property (nonatomic, strong) NSString *openImageName;
@property (nonatomic, strong) NSString *lockedImageName;
@property (nonatomic, strong) NSString *openImageNameGrey;
@property (nonatomic, strong) NSString *lockedImageNameGrey;
@property (nonatomic, assign) BOOL isLocked;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end
