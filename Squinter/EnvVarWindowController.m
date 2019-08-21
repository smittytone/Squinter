
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import "EnvVarWindowController.h"

@interface EnvVarWindowController ()

@end

@implementation EnvVarWindowController

@synthesize jsonString, devicegroup;


- (void)viewDidLoad
{
    [super viewDidLoad];
}



- (void)prepSheet
{
    // Ready the window for viewing
    
    if (envValues == nil) envValues = [[NSMutableArray alloc] init];
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
            // Get all of the incoming data's keys

            [envKeys addObjectsFromArray:[dict allKeys]];

            // Iterate through the list of keys to get the relevant values.
            // We do this to ensure we have the correct order CHECK

            for (NSString *key in envKeys)
            {
                [envValues addObject:[dict valueForKey:key]];
            }
        }
    }

    // Update the table view
    
    [envVarTableView reloadData];

    // Set the header text

    headerTextField.stringValue = [NSString stringWithFormat:@"Environment variable set for “%@”", devicegroup];
}



- (void)updateData
{
    // Convert the current table data back to a JSON string

    NSDictionary *dict = [NSDictionary dictionaryWithObjects:envValues forKeys:envKeys];
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    if (error == nil)
    {
        jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
}



- (BOOL)checkDataSize
{
    
}


#pragma mark - Action Methods


- (IBAction)doAddItem:(id)sender
{
    NSString *keyName = [NSString stringWithFormat:@"Key %li", (long)(envKeys.count + 1)];
    [envKeys addObject:keyName];
    [envValues addObject:@""];
    [envVarTableView reloadData];

    // Select the new (last) item
    
    NSIndexSet *rows = [[NSIndexSet alloc] initWithIndex:envKeys.count - 1];
    [envVarTableView selectRowIndexes:rows byExtendingSelection:NO];
}



- (IBAction)doRemoveItem:(id)sender
{

}



#pragma mark - NSTableView Delegate and DataSource Methods


- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return envKeys.count;
}



- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    if ([tableColumn.identifier compare:@"env-var-val-col"] == NSOrderedSame)
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-val-cell" owner:nil];
        
        if (cell != nil)
        {
            cell.textField.stringValue =  [envValues objectAtIndex:row];
            cell.textField.delegate = self;
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-key-cell" owner:nil];
        
        if (cell != nil)
        {
            cell.textField.stringValue = [envKeys objectAtIndex:row];;
            return cell;
        }
    }
    
    return nil;
}



#pragma mark - NSTextFieldDelegate Methods

- (void)textDidEndEditing:(NSNotification *)notification
{
    NSTextField *tf = (NSTextField *)notification.object;
    NSUInteger row = [envVarTableView rowForView:tf.superview];
    [envValues addObject:tf.stringValue];
    [envValues exchangeObjectAtIndex:row withObjectAtIndex:(envValues.count - 1)];
    [envValues removeLastObject];
}

@end
