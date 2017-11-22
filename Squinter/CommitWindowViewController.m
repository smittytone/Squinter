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

    [commitIndicator stopAnimation:nil];
    [commitTable reloadData];

    commitIndicator.hidden = YES;
    commitLabel.stringValue = @"Choose the device group’s minimum deployment (most recent first):";
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



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CommitTableCellView *cell = [tableView makeViewWithIdentifier:@"commitcell" owner:nil];

    if (cell != nil)
    {
        NSDictionary *deployment = [commits objectAtIndex:(commits.count - 1 - row)];
        NSString *sha = [deployment valueForKeyPath:@"attributes.updated_at"];
        if (sha == nil) sha = [deployment valueForKeyPath:@"attributes.created_at"];
        sha = [commitDef stringFromDate:[commitDef dateFromString:sha]];
        sha = [sha stringByReplacingOccurrencesOfString:@"GMT" withString:@"+00:00"];
        sha = [sha stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
        sha = [sha stringByReplacingOccurrencesOfString:@"T" withString:@" "];

        if (commits.count < 100)
        {
            cell.minimumCheckbox.title = [NSString stringWithFormat:@"%02li Committed at %@", (long)(row + 1), sha];
        }
        else if (commits.count < 1000)
        {
            cell.minimumCheckbox.title = [NSString stringWithFormat:@"%03li Committed at %@", (long)(row + 1), sha];
        }
        else
        {
            cell.minimumCheckbox.title = [NSString stringWithFormat:@"%05li Committed at %@", (long)(row + 1), sha];
        }

        NSString *depid = [deployment objectForKey:@"id"];
        cell.minimumCheckbox.state = (devicegroup.mdid != nil && [devicegroup.mdid compare:depid] == NSOrderedSame) ? NSOnState : NSOffState;
        cell.minimumCheckbox.action = @selector(checkMinimum:);
    }

    return cell;
}


@end
