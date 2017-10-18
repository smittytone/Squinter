

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2015-17 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface StreamToolbarItem : NSToolbarItem <NSCopying>

{
	BOOL isForeground;
	CGRect storedFrame;
}


@property (nonatomic, strong) NSString *onImageName;
@property (nonatomic, strong) NSString *onImageNameGrey;
@property (nonatomic, strong) NSString *offImageName;
@property (nonatomic, strong) NSString *offImageNameGrey;
@property (nonatomic, assign) BOOL isOn;


- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;



@end
