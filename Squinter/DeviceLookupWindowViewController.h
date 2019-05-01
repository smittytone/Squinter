

//  Created by Tony Smith on 27/02/2019.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "CommitTableCellView.h"

NS_ASSUME_NONNULL_BEGIN


// ADDED IN 2.2.127
// This view controller manages the panel we show to allow users to look up
// devices by their MAC address or ID.

@interface DeviceLookupWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
{
    IBOutlet NSTableView *deviceTable;
    IBOutlet NSTextField *entryField;

    NSMutableArray *listedDevices;

    bool searchOnDeviceId;
}


- (void)prepSheet;
- (IBAction)showWebHelp:(id)sender;


@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) NSString *selectedDeviceID;

@end

NS_ASSUME_NONNULL_END
