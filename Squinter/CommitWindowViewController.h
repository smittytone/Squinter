//
//  CommitWindowViewController.h
//  Squinter
//
//  Created by Tony Smith on 11/20/17.
//  Copyright © 2017 Tony Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommitTableCellView.h"


@interface CommitWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>

{
	IBOutlet NSTableView *commitTable;
	IBOutlet NSTextField *commitLabel;
	IBOutlet NSProgressIndicator *commitIndicator;

	NSDateFormatter *commitDef;
}


- (IBAction)checkMinimum:(id)sender;
- (void)setCommits:(NSArray *)input;
- (void)prepSheet;


@property (nonatomic, weak, setter=setCommits:) NSArray *commits;
@property (nonatomic, readwrite) NSInteger indexOfMinimum;


@end
