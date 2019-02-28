

//  Created by Tony Smith on 27/02/2019.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import "DeviceLookupWindowViewController.h"

// ADDED IN 2.2.127
@interface DeviceLookupWindowViewController ()

@end

@implementation DeviceLookupWindowViewController
@synthesize deviceArray, selectedDeviceID;



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
    searchOnDeviceId = YES;
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
        // otherwise we assume they're entering a device ID. 'searchOnDeviceId' is true in
        // the latter case, and we use this to set the auxilliary info column
        // head title etc.
        
        // Stop the text field from working during processing?
        
        [entryField refusesFirstResponder];
        
        // Clear any devices we have found - we rebuild the list each time
        
        [listedDevices removeAllObjects];

        // Get the entered text, and it it's not an emtpy string, check its first
        // character. If this is a '0', then the user is entering a MAC address;
        // otherwise it will be an device ID
        // TODO - How do we spot an agent ID?
        
        NSString *keyed = entryField.stringValue;

        if (keyed.length > 0)
        {
            NSString *prefix = [keyed substringToIndex:1];
            searchOnDeviceId = [prefix compare:@"0"] == NSOrderedSame ? NO : YES;
        }

        // Run through the device list to look for a match against each
        // device's MAC or ID
        
        for (NSDictionary *device in deviceArray) {

            // NOTE Check for NULL entries
            
            NSString *did = [device objectForKey:@"id"];
            NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
            if ((NSNull *)mac == [NSNull null]) mac = @"Unknown";
            mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];

            NSString *sdid = searchOnDeviceId
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
        
        // Update the displayed table with the new list of found devices
        
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
    // The user has clicked a table row to select it
    
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
        // Display the device's name in the name column
        
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
        // Display the device's ID in the ID column
        
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
        // Display the device's MAC in the MAC column
        
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
