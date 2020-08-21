

//  Created by Tony Smith on 11/03/2019.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "Constants.h"
#import "CommitTableCellView.h"
#import "Devicegroup.h"
#import "Project.h"


NS_ASSUME_NONNULL_BEGIN


// This view controller manages the panel we present to present a list of device groups
// which have been identifide during a sync operation as missing from the server or
// missing locally.

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
@property (nonatomic, readwrite) BOOL presentingRemotes;

@end


NS_ASSUME_NONNULL_END
