

//  Created by Tony Smith on 01/08/2018.
//  Copyright (c) 2018 Tony Smith. All rights reserved.


#import "LogView.h"

@implementation LogView


- (void)awakeFromNib
{
    NSCursor *c = [NSCursor currentCursor];
    NSImage *cr = [NSImage imageNamed:@"darkcursor"];
    [cr setSize:c.image.size];
    if (darkibeam == nil) darkibeam = [[NSCursor alloc] initWithImage:cr hotSpot:c.hotSpot];
}



- (void)resetCursorRects
{
    [super resetCursorRects];
    // [self addCursorRect:self.visibleRect cursor:darkibeam];
}







@end
