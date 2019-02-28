

//  Created by Tony Smith on 01/08/2018.
//  Copyright (c) 2018-19 Tony Smith. All rights reserved.


#import "LogView.h"

@implementation LogView



- (void)awakeFromNib
{
    // Set up a custom cursor
    // EXPERIMENTAL - DOESN't APPEAR TO WORK VERY WELL
    
    NSCursor *cursor = [NSCursor currentCursor];
    NSImage *cursorImage = [NSImage imageNamed:@"darkcursor"];
    [cursorImage setSize:cursor.image.size];
    if (darkibeam == nil) darkibeam = [[NSCursor alloc] initWithImage:cursorImage hotSpot:cursor.hotSpot];
}



- (void)resetCursorRects
{
    [super resetCursorRects];
    // [self addCursorRect:self.visibleRect cursor:darkibeam];
}



@end
