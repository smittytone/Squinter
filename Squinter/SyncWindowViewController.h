

//  Created by Tony Smith on 11/03/2019.
//  Copyright (c) 20119 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "CommitTableCellView.h"
#import "Devicegroup.h"
#import "Project.h"


NS_ASSUME_NONNULL_BEGIN


@interface SyncWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource>
{
    IBOutlet NSTableView *syncTable;
    IBOutlet NSTextField *syncLabel;
}


- (void)prepSheet;
- (IBAction)checkSyncTarget:(id)sender;
- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back;


@property (nonatomic, strong) Project *project;
@property (nonatomic, strong) NSMutableArray *syncGroups;
@property (nonatomic, strong) NSMutableArray *selectedGroups;
@property (nonatomic, readwrite) BOOL *presentingRemotes;

@end


NS_ASSUME_NONNULL_END
