//
//  CommitWindowViewController.m
//  Squinter
//
//  Created by Tony Smith on 11/20/17.
//  Copyright © 2017 Tony Smith. All rights reserved.
//

#import "CommitWindowViewController.h"

@interface CommitWindowViewController ()

@end

@implementation CommitWindowViewController

@synthesize commits, minimumDeployment, devicegroup;


- (void)prepSheet
{
    if (commits != nil) commits = nil;

    [commitIndicator startAnimation:nil];
    [commitTable reloadData];

    commitIndicator.hidden = NO;
    commitLabel.stringValue = @"Downloading commits...";
    commitTable.needsDisplay = YES;

    if (commitDef == nil)
    {
        commitDef = [[NSDateFormatter alloc] init];
        commitDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ"; // @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
        //commitDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }
}



- (void)setCommits:(NSArray *)input
{
    commits = input;
	minIndex = -1;

	for (NSUInteger i = 0 ; i < commits.count ; ++i)
	{
		NSDictionary *deployment = [commits objectAtIndex:i];
		NSString *depid = [deployment objectForKey:@"id"];

		if (devicegroup.mdid != nil && [devicegroup.mdid compare:depid] == NSOrderedSame) minIndex = commits.count - 1 - i;
	}

    [commitIndicator stopAnimation:nil];
    [commitTable reloadData];

    commitIndicator.hidden = YES;
    commitLabel.stringValue = @"Choose the device group’s minimum deployment (most recent last):";
    commitTable.needsDisplay = YES;
}



- (IBAction)checkMinimum:(id)sender
{
    NSButton *aSender = (NSButton *)sender;

    // Turn off all the other checkboxes by iterating through the list of table rows
    // and seeing which rows don't match the sender

    for (NSUInteger i = 0 ; i < commitTable.numberOfRows ; ++i)
    {
        CommitTableCellView *cellView = [commitTable viewAtColumn:0 row:i makeIfNecessary:NO];

        if (aSender != cellView.minimumCheckbox)
        {
            cellView.minimumCheckbox.state = NSOffState;
        }
        else
        {
            minimumDeployment = [commits objectAtIndex:(commits.count - 1 - i)];
        }
    }
}



#pragma mark - NSTableView Delegate and DataSource Methods

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return (commits != nil ? commits.count : 0);
}



- (BOOL)tableView:(NSTableView *)aTableView shouldSelectRow:(NSInteger)rowIndex
{
	return NO;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
	if ([tableColumn.identifier compare:@"commitcolumncheck"] == NSOrderedSame)
	{
		CommitTableCellView *cell = [tableView makeViewWithIdentifier:@"commitcellcheck" owner:nil];

		if (cell != nil)
		{
			cell.minimumCheckbox.title = @"";
			cell.minimumCheckbox.state = row == minIndex ? NSOnState : NSOffState;
			cell.minimumCheckbox.action = @selector(checkMinimum:);
			if (row < minIndex) cell.minimumCheckbox.enabled = NO;

			return cell;
		}
	}
	else if ([tableColumn.identifier compare:@"commitcolumnnum"] == NSOrderedSame)
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:@"commitcellnum" owner:nil];

		if (cell != nil)
		{
			if (commits.count < 100)
			{
				cell.textField.stringValue = [NSString stringWithFormat:@"%02li", (long)(row + 1)];
			}
			else if (commits.count < 1000)
			{
				cell.textField.stringValue = [NSString stringWithFormat:@"%03li", (long)(row + 1)];
			}
			else
			{
				cell.textField.stringValue = [NSString stringWithFormat:@"%05li", (long)(row + 1)];
			}

			cell.textField.enabled = NO;
			cell.textField.textColor = row < minIndex ? NSColor.grayColor : NSColor.blackColor;
		}

		return cell;
	}
	else
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:@"commitcelltext" owner:nil];

		if (cell != nil)
		{
			NSDictionary *deployment = [commits objectAtIndex:(commits.count - 1 - row)];
			NSString *sha = [deployment valueForKeyPath:@"attributes.updated_at"];
			if (sha == nil) sha = [deployment valueForKeyPath:@"attributes.created_at"];
			sha = [commitDef stringFromDate:[commitDef dateFromString:sha]];
			sha = [sha stringByReplacingOccurrencesOfString:@"GMT" withString:@"+00:00"];
			sha = [sha stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
			sha = [sha stringByReplacingOccurrencesOfString:@"T" withString:@" "];

			cell.textField.stringValue = [NSString stringWithFormat:@"Committed at %@", sha];
			cell.textField.enabled = NO;
			cell.textField.textColor = row < minIndex ? NSColor.grayColor : NSColor.blackColor;
		}

		return cell;
	}

	return nil;
}


@end
