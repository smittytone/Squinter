

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import "SelectWindowViewController.h"

@interface SelectWindowViewController ()

@end

@implementation SelectWindowViewController
@synthesize project, theNewDevicegroup, theTarget, makeNewFiles;


- (void)setProject:(Project *)aProject
{
	project = aProject;

	if (project != nil)
	{
		if (groups == nil) groups = [[NSMutableArray alloc] init];

		[groups removeAllObjects];

		NSString *target = [theNewDevicegroup.type compare:@"pre_factoryfixture_devicegroup"] == NSOrderedSame ? @"pre_production_devicegroup" : @"production_devicegroup";

		if (project.devicegroups != nil && project.devicegroups.count > 0)
		{
			for (Devicegroup *dg in project.devicegroups)
			{
				if ([dg.type compare:target] == NSOrderedSame) [groups addObject:dg];
			}
		}
	}

	NSString *addition = [theNewDevicegroup.type compare:@"pre_factoryfixture_devicegroup"] == NSOrderedSame ? @"test" : @"";
	selectLabel.stringValue = [NSString stringWithFormat:@"Select the %@ factory device group’s target:", addition];

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

	for (NSUInteger i = 0 ; i < selectTable.numberOfRows ; ++i)
	{
		CommitTableCellView *cellView = [selectTable viewAtColumn:0 row:i makeIfNecessary:NO];

		if (aSender != cellView.minimumCheckbox)
		{
			cellView.minimumCheckbox.state = NSOffState;
		}
		else
		{
			theTarget = [groups objectAtIndex:i];
		}
	}
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
