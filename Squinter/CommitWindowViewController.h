//
//  CommitWindowViewController.h
//  Squinter
//
//  Created by Tony Smith on 11/20/17.
//  Copyright © 2017 Tony Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommitTableCellView.h"
#import "Devicegroup.h"


@interface CommitWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

{
    IBOutlet NSTableView *commitTable;
    IBOutlet NSTextField *commitLabel;
    IBOutlet NSProgressIndicator *commitIndicator;

    NSDateFormatter *commitDef;

	NSInteger minIndex;
}


- (IBAction)checkMinimum:(id)sender;
- (void)setCommits:(NSArray *)input;
- (void)prepSheet;


@property (nonatomic, weak, setter=setCommits:) NSArray *commits;
@property (nonatomic, strong) NSDictionary *minimumDeployment;
@property (nonatomic, strong) Devicegroup *devicegroup;


@end