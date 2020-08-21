

//  Created by Tony Smith on 01/08/2018.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>


@interface InspectorLinkButton : NSButton


// FROM 2.3.131
- (void)appWillBecomeActive;
- (void)appWillResignActive;
- (void)appWillQuit;


@end
