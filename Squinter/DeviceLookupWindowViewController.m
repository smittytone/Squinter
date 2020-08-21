

//  Created by Tony Smith on 27/02/2019.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


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

    selectButton.enabled = NO;
    entryField.stringValue = @"";
    selectedDeviceID = @"";
    searchOnDeviceId = YES;
    if (listedDevices == nil) listedDevices = [[NSMutableArray alloc] init];
    if (listedDevices.count > 0) [listedDevices removeAllObjects];
    [deviceTable reloadData];
}



- (IBAction)showWebHelp:(id)sender
{
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:[kSquinterHelpURL stringByAppendingString:@"#lookup"]]];
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
        
        // FROM 2.3.128
        // Match on agent ID as well as MAC and Device ID, and make sure device ID and
        // MAC searches are NOT case-sensitive        
        
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
            // Run through the device list to look for a match against each
            // device's MAC or ID
            
            for (NSDictionary *device in deviceArray) {

                // NOTE Check for NULL entries
                
                NSString *did = [device objectForKey:@"id"];
                NSString *sdid = [device objectForKey:@"id"];
                did = [did substringToIndex:(keyed.length <= did.length ? keyed.length : did.length)];
                
                NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
                NSString *smac = @"";
                if ((NSNull *)mac == [NSNull null])
                {
                    mac = nil;
                }
                else
                {
                    mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
                    smac = [mac copy];
                    mac = [mac substringToIndex:(keyed.length <= mac.length ? keyed.length : mac.length)];
                }
                
                NSString *aid = [device valueForKeyPath:@"attributes.agent_id"];
                NSString *said = @"No Agent";
                if ((NSNull *)aid == [NSNull null])
                {
                    aid = nil;
                }
                else
                {
                    said = [aid copy];
                    aid = [aid substringToIndex:(keyed.length <= aid.length ? keyed.length : aid.length)];
                }
                
                /*
                NSString *sdid = searchOnDeviceId
                    ? [did substringToIndex:(keyed.length <= did.length ? keyed.length : did.length)]
                : [mac substringToIndex:(keyed.length <= mac.length ? keyed.length : mac.length)];
                */
                
                bool matched = NO;
                
                if ([keyed.lowercaseString compare:did] == NSOrderedSame) matched = YES;
                if (mac != nil && [keyed.lowercaseString compare:mac] == NSOrderedSame) matched = YES;
                if (aid != nil && [keyed compare:aid] == NSOrderedSame) matched = YES;
                
                if (matched)
                {
                    // Devices that match are added to 'listedDevices' which
                    // is then read by the table as a data source
                    
                    NSString *name = [device valueForKeyPath:@"attributes.name"];
                    if ((NSNull *)name == [NSNull null]) name = sdid;

                    NSDictionary *d = @{ @"name" : name,
                                         @"id"   : sdid,
                                         @"mac"  : smac,
                                         @"aid"  : said };
                    [listedDevices addObject:d];
                }
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



- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    // ADDED 2.3.129
    // If no row is selected ('selectedRow' = -1) then clear 'selectedDeviceID'
    // to make sure the device doesn't change when the dialog closes after 'Select Device'
    // was clicked

    // FROM 2.3.133
    // Enable or disable the selection button too
    
    NSTableView *tableView = (NSTableView *)notification.object;

    if (tableView.selectedRow == -1)
    {
        selectedDeviceID = @"";
        selectButton.enabled = NO;
    }
    else
    {
        selectButton.enabled = YES;
    }
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
    else if ([tableColumn.identifier compare:@"devicelookup_column_mac"] == NSOrderedSame)
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
    else
    {
        // Display the device's Agent ID in the aid column
        
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"devicelookup_cell_aid" owner:nil];
        
        if (cell != nil)
        {
            NSDictionary *device = [listedDevices objectAtIndex:row];
            cell.textField.stringValue = [device objectForKey:@"aid"];
            cell.textField.enabled = NO;
            return cell;
        }
    }

    return nil;
}



@end
