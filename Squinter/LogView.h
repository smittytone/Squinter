
//  Created by Tony Smith on 12/05/2015.
//  Copyright (c) 2015 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>

@interface LogView : NSTextView

{
	NSSize originalSize;
	NSSize previousValueOfDocSizeInPage;
	BOOL previousValueOfWrappingToFit;
}


@property (assign) NSSize originalSize;


@end