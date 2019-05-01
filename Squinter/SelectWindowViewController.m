

//  Created by Tony Smith on 15/05/2018.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import "SelectWindowViewController.h"

@interface SelectWindowViewController ()
@end


@implementation SelectWindowViewController
@synthesize project, theNewDevicegroup, theSelectedTarget, targetType, makeNewFiles;



- (void)prepSheet
{
    // Prepare the sheet UI ahead of being presented by the host app
    // NOTE This should only be called ONCE per request for two targets
    //      as it clears the list of stored targets
    
    NSString *groupType = [theNewDevicegroup.type hasPrefix:@"pre_"] ? @"Test" : @"";
    
    // Get the target group type’s Squinter name from its API type
    
    NSString *targetAPIType;
    NSString *targetAPIName = @"ERROR";
    
    // FROM 2.3.128
    // Add 'targetType' property and code to update the UI depending on its value,
    // which is the type of target device group being selected
    
    if (targetType == kTargetDeviceGroupTypeNone)
    {
        // This should never come up, but just in case...
        
        selectLabel.stringValue = @"ERROR - Please contact the developer";
        return;
    }
    
    if (targetType == kTargetDeviceGroupTypeProd)
    {
        targetAPIName = @"Production";
        targetAPIType = groupType.length > 0 ? @"pre_production_devicegroup" : @"production_devicegroup" ;
    }
    
    if (targetType == kTargetDeviceGroupTypeDUT)
    {
        targetAPIName = @"DUT";
        targetAPIType = groupType.length > 0 ? @"pre_dut_devicegroup" : @"dut_devicegroup" ;
    }
    
    NSString *currentTargetName = @"";
    currentTargetID = @"";
    
    if (project != nil)
	{
        if (groups == nil)
        {
            groups = [[NSMutableArray alloc] init];
        }
        else
        {
            [groups removeAllObjects];
        }

		if (project.devicegroups != nil && project.devicegroups.count > 0)
		{
            // Save the current target device group's ID so it can be auto-selected
            
            NSString *source = targetType == kTargetDeviceGroupTypeProd ? @"production" : @"dut";
            source = [NSString stringWithFormat:@"relationships.%@_target.id", source];
            currentTargetID = [theNewDevicegroup.data valueForKeyPath:source];
            if ((NSNull *)currentTargetID == [NSNull null]) currentTargetID = @"";
            
            for (Devicegroup *dg in project.devicegroups)
			{
				if ([dg.type compare:targetAPIType] == NSOrderedSame) [groups addObject:dg];
                if (currentTargetID.length > 0 && [currentTargetID compare:dg.did] == NSOrderedSame) currentTargetName = dg.name;
			}
		}
	}
    else
    {
        // This should never come up, but just in case...
        
        selectLabel.stringValue = @"ERROR - Please contact the developer";
        return;
    }
    
    // Update the UI
    
    NSString *labelString = [NSString stringWithFormat:@"Select the %@ Fixture Device Group’s new %@ %@ Device Group target.\n", groupType, groupType, targetAPIName];
    
    if (currentTargetName.length > 0)
    {
        selectLabel.stringValue = [labelString stringByAppendingFormat:@"The current target is “%@”:", currentTargetName];
    }
    else
    {
        selectLabel.stringValue = [labelString stringByAppendingString:@"No target has yet been set:"];
    }
    
    [selectTable reloadData];

	selectTable.needsDisplay = YES;
    theSelectedTarget = nil;
}



- (IBAction)checkGroup:(id)sender
{
	// Called when the user clicks on a checkbox in the table view
    
    NSButton *theSender = (NSButton *)sender;

	// Turn off all the other checkboxes by iterating through the list of table rows
	// and seeing which rows don't match the sender
    
    NSUInteger count = 0;
    
	for (NSUInteger i = 0 ; i < selectTable.numberOfRows ; ++i)
	{
		CommitTableCellView *cellView = [selectTable viewAtColumn:0 row:i makeIfNecessary:NO];

		if (theSender != cellView.minimumCheckbox)
		{
			cellView.minimumCheckbox.state = NSOffState;
            count++;
		}
		else
		{
            theSelectedTarget = cellView.minimumCheckbox.state == NSOnState ? [groups objectAtIndex:i] : nil;
		}
	}
}



- (IBAction)showWebHelp:(id)sender
{
    [NSWorkspace.sharedWorkspace openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html#targets"]];
}



#pragma mark - NSTableView Delegate and DataSource Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
	return (groups != nil && groups.count > 0 ? groups.count : 0);
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return NO;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	CommitTableCellView *cell = [tableView makeViewWithIdentifier:@"selectcell" owner:nil];

	if (cell != nil)
	{
		Devicegroup *dg = [groups objectAtIndex:row];
		cell.minimumCheckbox.title = dg.name;
        cell.minimumCheckbox.action = @selector(checkGroup:);
        
        if (currentTargetID != nil && [currentTargetID compare:dg.did] == NSOrderedSame)
        {
            cell.minimumCheckbox.state = NSOnState;
            theSelectedTarget = dg;
        }
        else
        {
            cell.minimumCheckbox.state = NSOffState;
        }
	}

	return cell;
}


@end
