

//  Created by Tony Smith on 15/05/2017.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "CommitTableCellView.h"
#import "Devicegroup.h"
#import "Project.h"


@interface SelectWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
	IBOutlet NSTableView *selectTable;
	IBOutlet NSTextField *selectLabel;
    
	NSMutableArray *groups;
}


- (IBAction)checkGroup:(id)sender;
- (void)prepSheet;


@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) Devicegroup *theNewDevicegroup;
@property (nonatomic, strong) Devicegroup *theSelectedTarget;
@property (nonatomic, readwrite) BOOL makeNewFiles;
@property (nonatomic, readwrite) NSInteger targetType;


@end
