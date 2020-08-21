

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "InspectorLinkButton.h"


@interface InspectorDataCellView : NSTableCellView


@property (nonatomic) IBOutlet InspectorLinkButton *openFileButton;
@property (nonatomic) IBOutlet NSTextField *title;
@property (nonatomic) IBOutlet NSTextField *data;
@property (nonatomic, readwrite) NSInteger row;
@property (nonatomic) NSString *path;

// FROM 2.3.130
@property (nonatomic) IBOutlet InspectorLinkButton *goFolderButton;


@end
