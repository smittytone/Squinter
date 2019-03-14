

//  Created by Tony Smith on 11/03/2019.
//  Copyright (c) 2019 Tony Smith. All rights reserved.


#import "SyncWindowViewController.h"

@interface SyncWindowViewController ()

@end

@implementation SyncWindowViewController

@synthesize project, syncGroups, selectedGroups, presentingRemotes;



- (void)prepSheet
{
    // Set up the sheet ahead of its presentation in the window

    if (selectedGroups == nil)
    {
        selectedGroups = [[NSMutableArray alloc] init];
    }
    else
    {
        [selectedGroups removeAllObjects];
    }
    
    // Update the label
    
    syncLabel.stringValue = [@"The following Device Groups are listed " stringByAppendingString:(presentingRemotes ? @"on the server, but not locally:" : @"locally, but not on the server")];

    // NOTE 'syncTable' uses 'syncGroups' as its data source

    [syncTable reloadData];

    syncTable.needsDisplay = YES;
}



- (IBAction)checkSyncTarget:(id)sender
{
    // When a table entry's checkbox is clicked, we come here
    // to add (or remove) the indexed device group's indes to (or from)
    // the list of selected items ('selectedGroup')

    NSButton *aSender = (NSButton *)sender;

    for (NSUInteger i = 0 ; i < syncTable.numberOfRows ; ++i)
    {
        CommitTableCellView *cellView = [syncTable viewAtColumn:0 row:i makeIfNecessary:NO];

        if (aSender == cellView.minimumCheckbox)
        {
            if (cellView.minimumCheckbox.state == NSOnState)
            {
                // Item is checked so add its index to 'selectedGroup'

                [selectedGroups addObject:[NSNumber numberWithInteger:i]];
            }
            else
            {
                // Item is checked so remove its index from 'selectedGroup'

                if (selectedGroups.count > 0)
                {
                    // The saved index could be anywhere, so we need to iterate to find it

                    for (NSUInteger j = 0 ; j < selectedGroups.count ; j++)
                    {
                        NSNumber *num = [selectedGroups objectAtIndex:j];

                        if (num.integerValue == i)
                        {
                            [selectedGroups removeObjectAtIndex:j];
                            break;
                        }
                    }
                }
            }

            break;
        }
    }
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
    // Exchange device group names Squinter <-> API
    // if 'back' is YES, we return the API name, otherwise the Squinter name

    NSArray *dgtypes = @[ @"production_devicegroup", @"factoryfixture_devicegroup", @"dut_devicegroup", @"development_devicegroup",
                          @"pre_production_devicegroup", @"pre_factoryfixture_devicegroup", @"pre_dut_devicegroup"];
    NSArray *dgnames = @[ @"Production", @"Fixture", @"DUT", @"Development",
                          @"Test Production", @"Test Fixture", @"Test DUT"];

    for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
    {
        NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];

        if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
    }

    if (!back) return @"Unknown";
    return @"development_devicegroup";
}



#pragma mark - NSTableView Delegate and DataSource Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (syncGroups != nil && syncGroups.count > 0 ? syncGroups.count : 0);
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
    return NO;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    NSDictionary *dg = [syncGroups objectAtIndex:row];

    if ([tableColumn.identifier compare:@"sync_dg_check_col"] == NSOrderedSame)
    {
        CommitTableCellView *cell = [tableView makeViewWithIdentifier:@"sync_dg_check_cell" owner:nil];

        if (cell != nil)
        {
            cell.minimumCheckbox.title = @"";
            cell.minimumCheckbox.state = NSOffState;
            cell.minimumCheckbox.action = @selector(checkSyncTarget:);
            return cell;
        }
    }
    else if ([tableColumn.identifier compare:@"sync_dg_name_col"] == NSOrderedSame)
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"sync_dg_name_cell" owner:nil];

        if (cell != nil)
        {
            NSString *name = [dg valueForKeyPath:@"attributes.name"];
            if ((NSNull *)name == [NSNull null]) name = [dg objectForKey:@"id"];

            cell.textField.stringValue = name;
            cell.textField.enabled = NO;
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"sync_dg_type_cell" owner:nil];

        if (cell != nil)
        {
            NSString *type = [dg objectForKey:@"type"];
            cell.textField.stringValue = [self convertDevicegroupType:type :NO];
            cell.textField.enabled = NO;
            return cell;
        }
    }

    return nil;
}



@end
