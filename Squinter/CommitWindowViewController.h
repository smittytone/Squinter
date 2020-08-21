
//  Created by Tony Smith on 11/20/17.
//  Copyright (c) 2020 Tony Smith. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "CommitTableCellView.h"
#import "Devicegroup.h"
#import "ConstantsPrivate.h"


// This view controller manages the panel we present to present a downloaded
// list of commits made to a devicegroup (specified by property)

@interface CommitWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView *commitTable;
    IBOutlet NSTextField *commitLabel;
    IBOutlet NSProgressIndicator *commitIndicator;

    NSDateFormatter *commitDef, *def;

	NSInteger minIndex;
}


- (void)prepSheet;
- (void)setCommits:(NSArray *)input;
- (IBAction)checkMinimum:(id)sender;
- (IBAction)showWebHelp:(id)sender;


@property (nonatomic, weak, setter=setCommits:) NSArray *commits;
@property (nonatomic, strong) NSDictionary *minimumDeployment;
@property (nonatomic, strong) Devicegroup *devicegroup;


@end
