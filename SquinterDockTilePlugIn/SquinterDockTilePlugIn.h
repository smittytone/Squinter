
//  Created by Tony Smith on 17/05/2017.
//  Copyright © 2017 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "ConstantsPrivate.h"


@interface SquinterDockTilePlugIn : NSObject <NSDockTilePlugIn>
{
	NSMenu *dockMenu;
	NSString *wd;
	BOOL stale;
}


- (void)dockMenuOpenRecent:(id)sender;
- (void)dockMenuAction:(id)sender;
- (NSURL *)urlForBookmark:(NSData *)bookmark;


@end
