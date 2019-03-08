

//  Created by Tony Smith on 15/05/2018.
//  Copyright (c) 2017-19 Tony Smith. All rights reserved.


#import "SelectWindowViewController.h"

@interface SelectWindowViewController ()
@end


@implementation SelectWindowViewController
@synthesize project, theNewDevicegroup, theTargets, theTarget, makeNewFiles, targetType;



- (void)setProject:(Project *)aProject
{
	project = aProject;
    
    if (theTargets == nil) theTargets = [[NSMutableArray alloc] init];

    NSString *groupType = [theNewDevicegroup.type hasPrefix:@"pre_"] ? @"Test" : @"";
    
    // Get the target group type’s Squinter name from its API type
    NSString *target;
    NSString *targetName = @"ERROR";
    
    if (targetType == kTargetDeviceGroupTypeProd)
    {
        targetName = @"Production";
        target = groupType.length > 0 ? @"pre_production_devicegroup" : @"production_devicegroup" ;
    }
    
    if (targetType == kTargetDeviceGroupTypeDUT)
    {
        targetName = @"DUT";
        target = groupType.length > 0 ? @"pre_dut_devicegroup" : @"dut_devicegroup" ;
    }
    
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
			for (Devicegroup *dg in project.devicegroups)
			{
				if ([dg.type compare:target] == NSOrderedSame) [groups addObject:dg];
			}
		}
	}

	selectLabel.stringValue = [NSString stringWithFormat:@"Select the %@ Fixture Device Group’s %@ %@ Device Group target:", groupType, groupType, targetName];

	[selectTable reloadData];

	selectTable.needsDisplay = YES;
    theTarget = nil;
}



- (IBAction)check:(id)sender
{
	NSLog(@"Checked");
}



- (IBAction)checkGroup:(id)sender
{
	NSButton *aSender = (NSButton *)sender;

	// Turn off all the other checkboxes by iterating through the list of table rows
	// and seeing which rows don't match the sender
    
    NSUInteger count = 0;
    
	for (NSUInteger i = 0 ; i < selectTable.numberOfRows ; ++i)
	{
		CommitTableCellView *cellView = [selectTable viewAtColumn:0 row:i makeIfNecessary:NO];

		if (aSender != cellView.minimumCheckbox)
		{
			cellView.minimumCheckbox.state = NSOffState;
            count++;
		}
		else
		{
			theTarget = [groups objectAtIndex:i];
		}
	}
    
    // Nothing selected at all? Zap the stored target
    
    if (count == selectTable.numberOfRows) theTarget = nil;
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
		cell.minimumCheckbox.state = NSOffState;
		cell.minimumCheckbox.action = @selector(checkGroup:);
	}

	return cell;
}


@end
