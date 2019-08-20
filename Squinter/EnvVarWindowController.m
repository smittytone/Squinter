
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import "EnvVarWindowController.h"

@interface EnvVarWindowController ()

@end

@implementation EnvVarWindowController

@synthesize jsonString;


- (void)viewDidLoad
{
    [super viewDidLoad];
}


- (void)prepSheet
{
    // Ready the window for viewing
    
    if (envData == nil) envData = [[NSMutableDictionary alloc] init];
    if (envKeys == nil) envKeys = [[NSMutableArray alloc] init];
    
    if (jsonString.length > 0)
    {
        // Decode the JSON into KV pairs to populate the table
        NSError *error = nil;
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data
                                                             options:0
                                                               error:&error];
        
        if (error == nil)
        {
            envData = [NSMutableDictionary dictionaryWithDictionary:dict];
            [envKeys addObjectsFromArray:[dict allKeys]];
        }
    }
    
    [envVarTableView reloadData];
}


#pragma mark - NSTableView Delegate and DataSource Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return envData.count;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier compare:@"env-var-val-col"] == NSOrderedSame)
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-val-cell" owner:nil];
        
        if (cell != nil)
        {
            NSString *key = [envKeys objectAtIndex:row];
            cell.textField.stringValue = [envData objectForKey:key];
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-key-cell" owner:nil];
        
        if (cell != nil)
        {
            NSString *key = [envKeys objectAtIndex:row];
            cell.textField.stringValue = key;
            return cell;
        }
    }
    
    return nil;
}



@end
