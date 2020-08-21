

//  Created by Tony Smith on 27/02/2019.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import <Cocoa/Cocoa.h>
#import "CommitTableCellView.h"
#import "ConstantsPrivate.h"


NS_ASSUME_NONNULL_BEGIN


// ADDED IN 2.2.127
// This view controller manages the panel we show to allow users to look up
// devices by their MAC address or ID.

@interface DeviceLookupWindowViewController : NSViewController <NSTableViewDelegate, NSTableViewDataSource, NSTextFieldDelegate>
{
    IBOutlet NSTableView *deviceTable;
    IBOutlet NSTextField *entryField;

    // FROM 2.3.133
    IBOutlet NSButton *selectButton;

    NSMutableArray *listedDevices;

    bool searchOnDeviceId;
}


- (void)prepSheet;
- (IBAction)showWebHelp:(id)sender;


@property (nonatomic, strong) NSMutableArray *deviceArray;
@property (nonatomic, strong) NSString *selectedDeviceID;

@end

NS_ASSUME_NONNULL_END
