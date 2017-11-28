

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>

@interface InspectorButtonTableCellView : NSTableCellView

@property (nonatomic, strong) IBOutlet NSButton *link;
@property (nonatomic, readwrite) NSInteger index;

@end
