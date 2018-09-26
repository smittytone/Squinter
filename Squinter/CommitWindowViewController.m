
//  Created by Tony Smith on 11/20/17.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.
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
        commitDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ";
		commitDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    }

	if (def == nil)
	{
		def = [[NSDateFormatter alloc] init];
		def.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZZ";
		def.timeZone = [NSTimeZone localTimeZone];
	}
}



- (void)setCommits:(NSArray *)input
{
    commits = input;
	minIndex = input.count;

	for (NSUInteger i = 0 ; i < commits.count ; ++i)
	{
		NSDictionary *deployment = [commits objectAtIndex:i];
		NSString *depid = [deployment objectForKey:@"id"];

		if (devicegroup.mdid != nil && [devicegroup.mdid compare:depid] == NSOrderedSame) minIndex = i;
	}

    [commitIndicator stopAnimation:nil];
    [commitTable reloadData];

    commitIndicator.hidden = YES;
    commitLabel.stringValue = @"Choose the device group’s minimum deployment:";
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
            minimumDeployment = [commits objectAtIndex:i];
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
			cell.minimumCheckbox.enabled = row > minIndex ? NO : YES;
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
				cell.textField.stringValue = [NSString stringWithFormat:@"%02li", (long)(commits.count - row)];
			}
			else if (commits.count < 1000)
			{
				cell.textField.stringValue = [NSString stringWithFormat:@"%03li", (long)(commits.count - row)];
			}
			else
			{
				cell.textField.stringValue = [NSString stringWithFormat:@"%05li", (long)(commits.count - row)];
			}

			cell.textField.enabled = NO;
			cell.textField.textColor = row > minIndex ? NSColor.grayColor : NSColor.labelColor;
		}

		return cell;
	}
	else
	{
		NSTableCellView *cell = [tableView makeViewWithIdentifier:@"commitcelltext" owner:nil];

		if (cell != nil)
		{
			NSDictionary *deployment = [commits objectAtIndex:row];
			NSString *sha = [deployment valueForKeyPath:@"attributes.updated_at"];
			if (sha == nil) sha = [deployment valueForKeyPath:@"attributes.created_at"];
			sha = [def stringFromDate:[commitDef dateFromString:sha]];
			sha = [sha stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
			sha = [sha stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
			sha = [sha stringByReplacingOccurrencesOfString:@"T" withString:@" "];

			cell.textField.stringValue = [NSString stringWithFormat:@"Committed at %@", sha];
			cell.textField.enabled = NO;
			cell.textField.textColor = row > minIndex ? NSColor.grayColor : NSColor.labelColor;
		}

		return cell;
	}

	return nil;
}


@end
