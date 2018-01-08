

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"


@interface StreamToolbarItem : NSToolbarItem <NSCopying>

{
    BOOL isForeground;
    CGRect storedFrame;
}


@property (nonatomic, strong) NSString *onImageName;
@property (nonatomic, strong) NSString *onImageNameGrey;
@property (nonatomic, strong) NSString *offImageName;
@property (nonatomic, strong) NSString *offImageNameGrey;
@property (nonatomic, strong) NSString *midImageName;
@property (nonatomic, strong) NSString *midImageNameGrey;
@property (nonatomic, assign) NSInteger state;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;



@end
