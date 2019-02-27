

//  Created by Tony Smith on 27/02/2019.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import "DeviceLookupWindowViewController.h"

// ADDED IN 2.2.127
@interface DeviceLookupWindowViewController ()

@end

@implementation DeviceLookupWindowViewController
@synthesize deviceArray, selectedDeviceID;

- (IBAction)checkDevice:(id)sender
{
    NSButton *aSender = (NSButton *)sender;

    // Turn off all the other checkboxes by iterating through the list of table rows
    // and seeing which rows don't match the sender

    for (NSUInteger i = 0 ; i < deviceTable.numberOfRows ; ++i)
    {
        CommitTableCellView *cellView = [deviceTable viewAtColumn:0 row:i makeIfNecessary:NO];
        
        if (aSender != cellView.minimumCheckbox)
        {
            // Not the selected item, so make sure its checkbox is off
            
            cellView.minimumCheckbox.state = NSOffState;
        }
        else
        {
            // Record the selected device's ID for later

            NSDictionary *device = [listedDevices objectAtIndex:i];
            selectedDeviceID = [device objectForKey:@"id"];
        }
    }
}


- (void)prepSheet
{
    // Ready the sheet just before it's displayed:
    // - Clear the selected device (if any)
    // - Assume we're searching device IDs
    // - Make sure 'listedDevices' is not nil
    // - Update the device table
    // - Clear

    entryField.stringValue = @"";
    selectedDeviceID = nil;
    useId = YES;
    if (listedDevices == nil) listedDevices = [[NSMutableArray alloc] init];
    if (listedDevices.count > 0) [listedDevices removeAllObjects];
    [deviceTable reloadData];
}



#pragma mark - NSTextFieldDelegate Methods

- (void)controlTextDidChange:(NSNotification *)obj
{
    id sender = obj.object;

    if (sender == entryField)
    {
        // Match up what's being keyed in letter-by-letter to the list of devices
        // If the user starts with a 0, we assume they're looking up a MAC address,
        // otherwise we assume they're entering a device ID. 'useID' is true in
        // the latter case, and we use this to set the auxilliary info column
        // head title etc.

        [entryField refusesFirstResponder];
        [listedDevices removeAllObjects];

        NSString *keyed = entryField.stringValue;

        if (keyed.length > 0)
        {
            NSString *prefix = [keyed substringToIndex:1];
            useId = [prefix compare:@"0"] == NSOrderedSame ? NO : YES;
        }

        //NSTableColumn *column = deviceTable.tableColumns.lastObject;
        //[column.headerCell setStringValue:(useId ? @"Device MAC" : @"Device ID")];
        //[deviceTable.headerView setNeedsLayout:YES];

        for (NSDictionary *device in deviceArray) {

            NSString *did = [device objectForKey:@"id"];
            NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
            if ((NSNull *)mac == [NSNull null]) mac = @"Unknown";
            mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];

            NSString *sdid = useId
                ? [did substringToIndex:(keyed.length <= did.length ? keyed.length : did.length)]
            : [mac substringToIndex:(keyed.length <= mac.length ? keyed.length : mac.length)];

            if ([sdid compare:keyed] == NSOrderedSame)
            {
                // Devices that match are added to 'listedDevices' which
                // is then read by the table as a data source
                
                NSString *name = [device valueForKeyPath:@"attributes.name"];
                if ((NSNull *)name == [NSNull null]) name = did;

                NSDictionary *d = @{ @"name" : name,
                                     @"id"   : did,
                                     @"mac"  : mac };
                [listedDevices addObject:d];
            }
        }

        [deviceTable reloadData];
        [entryField acceptsFirstResponder];
    }
}



#pragma mark - NSTableView Delegate and DataSource Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (listedDevices != nil ? listedDevices.count : 0);
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    // Makes sure all other rows are not selected

    for (NSUInteger i = 0 ; i < deviceTable.numberOfRows ; ++i)
    {
        if (i != rowIndex) [deviceTable deselectRow:i];
    }

    // Record the selected device's ID for later

    NSDictionary *device = [listedDevices objectAtIndex:rowIndex];
    selectedDeviceID = [device objectForKey:@"id"];
    return YES;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier compare:@"devicelookup_column_name"] == NSOrderedSame)
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"devicelookup_cell_name" owner:nil];

        if (cell != nil)
        {
            NSDictionary *device = [listedDevices objectAtIndex:row];
            cell.textField.stringValue = [device objectForKey:@"name"];
            cell.textField.enabled = NO;
            return cell;
        }
    }
    else if ([tableColumn.identifier compare:@"devicelookup_column_id"] == NSOrderedSame)
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"devicelookup_cell_id" owner:nil];

        if (cell != nil)
        {
            NSDictionary *device = [listedDevices objectAtIndex:row];
            cell.textField.stringValue = [device objectForKey:@"id"];
            cell.textField.enabled = NO;
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"devicelookup_cell_mac" owner:nil];

        if (cell != nil)
        {
            NSDictionary *device = [listedDevices objectAtIndex:row];
            cell.textField.stringValue = [device objectForKey:@"mac"];
            cell.textField.enabled = NO;
            return cell;
        }
    }

    return nil;
}


@end
