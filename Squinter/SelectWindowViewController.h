

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


- (IBAction)check:(id)sender;
- (IBAction)checkGroup:(id)sender;
- (void)setProject:(Project *)aProject;


@property (nonatomic, strong, setter=setProject:) Project *project;
@property (nonatomic, strong) Devicegroup *theNewDevicegroup;
@property (nonatomic, strong) Devicegroup *theTarget;
@property (nonatomic, strong) NSMutableArray *theTargets;
@property (nonatomic, readwrite) BOOL makeNewFiles;
@property (nonatomic, readwrite) NSInteger targetType;


@end
