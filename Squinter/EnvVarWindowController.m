
//  Created by Tony Smith on 14/08/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.
//  ADDED 2.3.131


#import "EnvVarWindowController.h"

@interface EnvVarWindowController ()

@end

@implementation EnvVarWindowController

@synthesize devicegroup, envVars;



#pragma mark - ViewController Lifecycle and Initialisation Methods


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    envVars = [[NSDictionary alloc] init];
    
    // Watch for table text field changes
    
    [NSNotificationCenter.defaultCenter addObserver:self
                                           selector:@selector(textDidEndEditing:)
                                               name:NSControlTextDidEndEditingNotification
                                             object:nil];
    
    // Set uo the various managers and fonts we will require later
    NSFontManager *nsfm = [NSFontManager sharedFontManager];
    italicFont = [nsfm convertFont:[NSFont systemFontOfSize:[NSFont systemFontSize]]
                       toHaveTrait:NSFontItalicTrait];
    
    nsnf = [[NSNumberFormatter alloc] init];
    nsnf.maximumFractionDigits = 8;
    nsnf.minimumFractionDigits = 1;
}



- (void)prepSheet
{
    // Ready the window for viewing before its appearance
    
    json = @"";
    
    // Set the header text
    
    headerTextField.stringValue = [NSString stringWithFormat:@"Device Group “%@” environment variables:", devicegroup];
    
    // Prepare the table-friendly data storage arrays
    
    if (envValues == nil) envValues = [[NSMutableArray alloc] init];
    if (envValues.count > 0) [envValues removeAllObjects];
    
    if (envKeys == nil) envKeys = [[NSMutableArray alloc] init];
    if (envKeys.count > 0) [envKeys removeAllObjects];
    
    // Do we have any KV pairs already?
    
    if (envVars.count > 0)
    {
        // Transfer the incoming dictonary of KV pairs into separate, editable arrays
        // NOTE We do this through iteration (rather than use '[envVars allValues]')
        //      in order to be sure we have the order of the items on both arrays correct
        
        [envKeys addObjectsFromArray:[envVars allKeys]];
        for (NSString *key in envKeys) [envValues addObject:[envVars valueForKey:key]];
    }
    
    // Update the size status readout
    
    [self convertToJSON];

    // Update the table view
    
    [variablesTableView reloadData];
}



- (void)prepareToCloseSheet
{
    // Make sure all the 'editing' fields are committed before closing the sheet

    if (variablesTableView.selectedRow != -1)
    {
        NSTableRowView *row = [variablesTableView rowViewAtRow:variablesTableView.selectedRow makeIfNecessary:NO];

        for (NSUInteger i = 0 ; i < 2 ; i++)
        {
            NSTableCellView *cell = [row viewAtColumn:i];
            [cell.textField resignFirstResponder];
        }
    }
}


#pragma mark - Data-sizing Methods


- (void)updateData
{
    // Rebuild the environment variables dictionary from the table source arrays

    envVars = [NSDictionary dictionaryWithObjects:envValues forKeys:envKeys];

    // Build a JSON string equivalent for data length checking and display

    [self convertToJSON];
}



- (void)convertToJSON
{
    // Convert the environment variables dictionary to a JSON string to determine the data length
    
    if ([NSJSONSerialization isValidJSONObject:envVars])
    {
        NSError *error = nil;
        NSData *data = [NSJSONSerialization dataWithJSONObject:envVars options:0 error:&error];
        
        if (error == nil) json = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
#if DEBUG
        NSLog(@"%@", json);
#endif
    }
    
    // Update the size status readout
    
    dataSizeTextField.stringValue = [NSString stringWithFormat:@"Variable storage size: %li bytes out of 16000", (long)json.length];
}



- (BOOL)checkDataSize
{
    // Return YES if the JSON representation of the environment variables dictionary is too long, otherwise NO
    
    return (json.length > 16000);
}



#pragma mark - Action Methods


- (IBAction)doAddItem:(id)sender
{
    // Add an item to the table with a dummy KV pair
    
    [envKeys addObject:[NSString stringWithFormat:@"Key_%li", (long)(envKeys.count + 1)]];
    [envValues addObject:[NSString stringWithFormat:@"Value_%li", (long)(envKeys.count + 1)]];
    [variablesTableView reloadData];

    // Select the new (last) item in the table
    
    NSIndexSet *rows = [[NSIndexSet alloc] initWithIndex:envKeys.count - 1];
    [variablesTableView selectRowIndexes:rows byExtendingSelection:NO];
    
    // Build a JSON string equivalent for data length checking and display
    
    [self updateData];
}



- (IBAction)doRemoveItem:(id)sender
{
    // Delete the selcted rows from the data store, provided there is at least one selected row
    // and, if so, the user confirms the deletion
    
    NSIndexSet *selectedRows = [variablesTableView selectedRowIndexes];
    
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
                              [variablesTableView reloadData];
                              [self updateData];
                          }
                      }
         ];
    }
    
    // Build a JSON string equivalent for data length checking and display
    
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
        EnvVarValueCell *cell = (EnvVarValueCell *)[tableView makeViewWithIdentifier:@"env-var-val-cell" owner:nil];
        
        if (cell != nil)
        {
            EnvVarTextField *cellTextField = (EnvVarTextField *)cell.textField;
            
            // Get the value - it may be an NSString or an NSNumber (int or float)
            
            id value = [envValues objectAtIndex:row];
            
            if ([value isKindOfClass:[NSNumber class]])
            {
                // If 'value' is an NSNUmber, is it an int or a float?
                // SEE https://stackoverflow.com/questions/2518761/get-type-of-nsnumber
                
                NSNumber *number = (NSNumber *)value;
                NSString *numberString = (strcmp([number objCType], @encode(double)) == 0) ? [nsnf stringFromNumber:number] : number.stringValue;
                cell.isString = NO;
                
                // Set up the italic string
                /*
                NSArray *values = [NSArray arrayWithObjects:italicFont, nil];
                NSArray *keys = [NSArray arrayWithObjects:NSFontAttributeName, nil];
                NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values
                                                                       forKeys:keys];
                NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:numberString
                                                                                 attributes:attributes];
                cellTextField.attributedStringValue = attrString;
                 */
                cellTextField.stringValue = numberString;
            }
            else
            {
                // Display the value as a string
                
                cellTextField.stringValue = (NSString *)value;
                cell.isString = YES;
            }

            cellTextField.delegate = self;
            cellTextField.tableRow = row;
            cellTextField.type = kEnvVarTypeValue;
            return cell;
        }
    }
    else
    {
        NSTableCellView *cell = [tableView makeViewWithIdentifier:@"env-var-key-cell" owner:nil];
        
        if (cell != nil)
        {
            EnvVarTextField *cellTextField = (EnvVarTextField *)cell.textField;
            cellTextField.stringValue = [envKeys objectAtIndex:row];
            cellTextField.delegate = self;
            cellTextField.tableRow = row;
            cellTextField.type = kEnvVarTypeKey;
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
        NSString *editedValue = cellTextField.stringValue;
        BOOL isNumber = NO;
        
        if (cellTextField.type == kEnvVarTypeValue)
        {
            // Check whether the entered value is a numeric value, either a float or an int

            // First, check for an integer - ie. 'xxxx' only (no periods
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kEnvVarIntRegex
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSRange rofm = [regex rangeOfFirstMatchInString:editedValue
                                                    options:0
                                                      range:NSMakeRange(0, editedValue.length)];

            if (rofm.location != NSNotFound)
            {
                // Found an int, so save it as such

                isNumber = YES;
                [envValues insertObject:[NSNumber numberWithInteger:editedValue.integerValue] atIndex:cellTextField.tableRow];
                [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
            }
            else
            {
                // Didn't find an int, so try for a float (double), ie. 'xxx.yyy' ONLY

                regex = [NSRegularExpression regularExpressionWithPattern:kEnvVarFloatRegex
                                                                  options:NSRegularExpressionCaseInsensitive
                                                                    error:&error];
                rofm = [regex rangeOfFirstMatchInString:editedValue
                                                options:0
                                                  range:NSMakeRange(0, editedValue.length)];

                if (rofm.location != NSNotFound)
                {
                    // Found a float, so save it as such

                    isNumber = YES;
                    double value = editedValue.doubleValue;
                    [envValues insertObject:[NSNumber numberWithDouble:value] atIndex:cellTextField.tableRow];
                    [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
                }
            }
            
            if (!isNumber)
            {
                // Store the value as a string
                
                [envValues insertObject:editedValue atIndex:cellTextField.tableRow];
                [envValues removeObjectAtIndex:(cellTextField.tableRow + 1)];
            }
        }
        else
        {
            // Check for key clash - is the new name already in use?
            
            NSString *editedkey = cellTextField.stringValue;
            BOOL got = NO;
            
            for (NSUInteger i = 0 ; i < envKeys.count ; i++)
            {
                NSString *key = [envKeys objectAtIndex:i];

                if ([key compare:editedkey] == NSOrderedSame && i != cellTextField.tableRow)
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
            
            // Check for API key limitations:
            // 1. 100 chars max
            
            if (editedkey.length > kEnvVarMaxKeySize)
            {
                [self showWarning:@"Key too long"
                                 :@"Keys must contain no more than 100 alphanumeric characters."];
                cellTextField.stringValue = [envKeys objectAtIndex:cellTextField.tableRow];
                return;
            }
            
            // 2. Alphanumeric only
            
            NSError *error = nil;
            NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:kEnvVarKeyRegex
                                                                                   options:NSRegularExpressionCaseInsensitive
                                                                                     error:&error];
            NSRange rofm = [regex rangeOfFirstMatchInString:editedValue
                                                    options:0
                                                      range:NSMakeRange(0, editedValue.length)];

            if (rofm.length == 0)
            {
                [self showWarning:@"Key contains illegal characters"
                                 :@"Keys must contain only alphanumeric characters and must not start with numeric characters."];
                cellTextField.stringValue = [envKeys objectAtIndex:cellTextField.tableRow];
                return;
            }
            
            // All good so make the change
            
            [envKeys insertObject:cellTextField.stringValue atIndex:cellTextField.tableRow];
            [envKeys removeObjectAtIndex:(cellTextField.tableRow + 1)];
        }
        
        // Update the JSON string
        
        [self updateData];
        [variablesTableView reloadData];

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
