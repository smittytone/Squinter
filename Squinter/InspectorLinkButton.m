

//  Created by Tony Smith on 01/08/2018.
//  Copyright (c) 2018 Tony Smith. All rights reserved.


#import "InspectorLinkButton.h"

@implementation InspectorLinkButton


- (void)resetCursorRects
{
    // Reset the cursor when it hovers over the button
    
    [super resetCursorRects];
    [self addCursorRect:self.bounds cursor:[NSCursor pointingHandCursor]];
}


@end
