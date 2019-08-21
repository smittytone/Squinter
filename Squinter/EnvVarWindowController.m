
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
    
    // Watch for text field changes
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textDidEndEditing:)
                                               name:NSControlTextDidEndEditingNotification
                                             object:nil];
}



- (void)prepSheet
{
    // Ready the window for viewing
    
    // Set the header text
    
    headerTextField.stringValue = [NSString stringWithFormat:@"Environment variable(s) set for “%@”:", devicegroup];
    
    // Prepare the table-friendly data storage arrays
    
    if (envValues == nil) envValues = [[NSMutableArray alloc] init];
    if (envValues.count > 0) [envValues removeAllObjects];
    
    if (envKeys == nil) envKeys = [[NSMutableArray alloc] init];
    if (envKeys.count > 0) [envKeys removeAllObjects];
    
    // Do we have any KV pairs already?
    
    if (jsonString.length > 0)
    {
        // Decode the JSON string passed to the iunstance into KV pairs
        
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

            for (NSString *key in envKeys) [envValues addObject:[dict valueForKey:key]];
        }
    }
    
    // Update the size status readout
    
    jsonSizeTextField.stringValue = [NSString stringWithFormat:@"Variable storage size: %li bytes", (long)jsonString.length];

    // Update the table view
    
    [envVarTableView reloadData];
}



- (void)updateData
{
    // Convert the current table data to a JSON string, typically when editing ends

    NSError *error = nil;
    NSDictionary *dict = [NSDictionary dictionaryWithObjects:envValues forKeys:envKeys];
    NSData *data = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    if (error == nil) jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    // Update the size status readout
    
    jsonSizeTextField.stringValue = [NSString stringWithFormat:@"Variable storage size: %li bytes", (long)jsonString.length];
}



- (BOOL)checkDataSize
{
    // Return YES if the string is too long, otherwise NO
    
    return (jsonString.length > 16000);
}



#pragma mark - Action Methods


- (IBAction)doAddItem:(id)sender
{
    // Add an item to the table with a dummy KV pair
    
    [envKeys addObject:[NSString stringWithFormat:@"Key %li", (long)(envKeys.count + 1)]];
    [envValues addObject:[NSString stringWithFormat:@"Value %li", (long)(envKeys.count + 1)]];
    [envVarTableView reloadData];

    // Select the new (last) item
    
    NSIndexSet *rows = [[NSIndexSet alloc] initWithIndex:envKeys.count - 1];
    [envVarTableView selectRowIndexes:rows byExtendingSelection:NO];
    
    // Update the JSON store
    
    [self updateData];
}



- (IBAction)doRemoveItem:(id)sender
{
    // Delete the selcted rows from the data store, provided there is at least one selected row
    // and, if so, the user confirms the deletion
    
    NSIndexSet *selectedRows = [envVarTableView selectedRowIndexes];
    
    if (selectedRows.count != 0)
    {
        // Remove all the KV pairs that have been selected - provided the user agrees
        
        NSAlert *alert = [[NSAlert alloc] init];
        NSString *tail = selectedRows.count == 1 ? @"" : @"s";
        alert.messageText = [NSString stringWithFormat:@"You are about to delete %li variable%@", (long)selectedRows.count, tail];
        alert.informativeText = @"Are you sure? This action cannot be undone.";
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];
        [alert beginSheetModalForWindow:self.view.window
                      completionHandler:^(NSModalResponse returnCode) {
                          if (returnCode == NSAlertFirstButtonReturn)
                          {
                              [envKeys removeObjectsAtIndexes:selectedRows];
                              [envValues removeObjectsAtIndexes:selectedRows];
                              [envVarTableView reloadData];
                              [self updateData];
                          }
                      }
         ];
    }
    
    // Update the JSON store
    
    [self updateData];
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
            EnvVarTextField *cellTextField = (EnvVarTextField *)cell.textField;
            cellTextField.stringValue =  [envValues objectAtIndex:row];
            cellTextField.delegate = self;
            cellTextField.tableRow = row;
            cellTextField.type = 1;
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-key-cell" owner:nil];
        
        if (cell != nil)
        {
            EnvVarTextField *cellTextField = (EnvVarTextField *)cell.textField;
            cellTextField.stringValue =  [envKeys objectAtIndex:row];
            cellTextField.delegate = self;
            cellTextField.tableRow = row;
            cellTextField.type = 2;
            return cell;
        }
    }
    
    return nil;
}



#pragma mark - NSTextField Delegatation Methods


- (void)textDidEndEditing:(NSNotification *)notification
{
    // Handle changes to keys and values made to the table
    // We need to check that the NSControl issuing the notitification is an instance of EnvVarTextField,
    // as other NSTextFields may trigger this (via delegation)
    
    if ([notification.object isKindOfClass:[EnvVarTextField class]])
    {
        EnvVarTextField *cellTextField = (EnvVarTextField *)notification.object;
        BOOL isNumber = NO;
        
        if (cellTextField.type == 1)
        {
            // Check whether the entered value is a numeric value, either a float or an int
            
            NSString *editedValue = cellTextField.stringValue;
            NSRange range = [editedValue rangeOfString:@"."];
            if (range.location != NSNotFound)
            {
                // String contains a decimal point - see if it is a float
                
                float floatValue = [editedValue floatValue];
                
                if (floatValue != HUGE_VAL && floatValue != -HUGE_VAL && floatValue != 0.0)
                {
                    [envValues insertObject:[NSNumber numberWithFloat:floatValue] atIndex:cellTextField.tableRow];
                    [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
                    isNumber = YES;
                }
            }
            else
            {
                // String may be an integer
                
                NSInteger intValue = [editedValue integerValue];
                
                if (intValue != 0)
                {
                    [envValues insertObject:[NSNumber numberWithInteger:intValue] atIndex:cellTextField.tableRow];
                    [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
                    isNumber = YES;
                }
            }
            
            if (!isNumber)
            {
                [envValues insertObject:cellTextField.stringValue atIndex:cellTextField.tableRow];
                [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
            }
        }
        else
        {
            // Check for key clash - is the new name already in use?
            
            NSString *editedkey = cellTextField.stringValue;
            BOOL got = NO;
            
            for (NSString *key in envKeys)
            {
                if ([key compare:editedkey] == NSOrderedSame)
                {
                    got = YES;
                    break;
                }
            }
            
            if (got)
            {
                // This key is already in use, so warn the user and put the old value back
                
                [self showWarning:@"That key already exits"
                                 :@"Keys must be unique. Either edit the value of the existing key, or change the key’s name before editing this one."];
                cellTextField.stringValue = [envKeys objectAtIndex:cellTextField.tableRow];
                return;
            }
            
            // All good so make the change
            
            [envKeys insertObject:cellTextField.stringValue atIndex:cellTextField.tableRow];
            [envKeys removeObjectAtIndex:(cellTextField.tableRow + 1)];
        }
        
        // Update the JSON string
        
        [self updateData];
        
        // Check the overall size of the data
        
        if ([self checkDataSize])
        {
            [self showWarning:@"Environment variables too big"
                             :@"Your environment variables (keys plus values) take up more than 16KB of space. This will be rejected by the impCloud. You should edit your variables to reduce their size, such as making keys shorter."];
        }
    }
}

                 

- (void)showWarning:(NSString *)header :(NSString *)body
{
    // Generic alert display method
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = header;
    alert.informativeText = body;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:self.view.window
                  completionHandler:nil];
}

@end
