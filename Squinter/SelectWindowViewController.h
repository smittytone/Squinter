

//  Created by Tony Smith on 15/05/2017.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "CommitTableCellView.h"
#import "Devicegroup.h"
#import "Project.h"


// This view controller manages the panel we present to select a device group,
// eg. the targets of a (Test) Fixture Device Group

@interface SelectWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
	IBOutlet NSTableView *selectTable;
	IBOutlet NSTextField *selectLabel;
    
	NSMutableArray *groups;
    
    NSString *currentTargetID;
}


- (void)prepSheet;
- (IBAction)checkGroup:(id)sender;
- (IBAction)showWebHelp:(id)sender;


@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) Devicegroup *theNewDevicegroup;
@property (nonatomic, strong) Devicegroup *theSelectedTarget;
@property (nonatomic, readwrite) BOOL makeNewFiles;
@property (nonatomic, readwrite) NSInteger targetType;


@end
