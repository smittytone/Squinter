
//  Created by Tony Smith on 02/05/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.


#import "AppDelegateAPIHandlers.h"


@implementation AppDelegate(AppDelegateAPIHandlers)


#pragma mark - Notification Configuration

- (void)configureNotifications
{
    [nsncdc addObserver:self
               selector:@selector(displayError:)
                   name:@"BuildAPIError"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(loggedIn:)
                   name:@"BuildAPILoggedIn"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(listProducts:)
                   name:@"BuildAPIGotProductsList"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(createProductStageTwo:)
                   name:@"BuildAPIProductCreated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(deleteProductStageThree:)
                   name:@"BuildAPIProductDeleted"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(updateProductStageTwo:)
                   name:@"BuildAPIProductUpdated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(createDevicegroupStageTwo:)
                   name:@"BuildAPIDeviceGroupCreated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(updateDevicegroupStageTwo:)
                   name:@"BuildAPIDeviceGroupUpdated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(deleteDevicegroupStageTwo:)
                   name:@"BuildAPIDeviceGroupDeleted"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(restarted:)
                   name:@"BuildAPIDeviceGroupRestarted"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(listDevices:)
                   name:@"BuildAPIGotDevicesList"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(reassigned:)
                   name:@"BuildAPIDeviceUnassigned"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(reassigned:)
                   name:@"BuildAPIDeviceAssigned"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(renameDeviceStageTwo:)
                   name:@"BuildAPIDeviceUpdated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(restarted:)
                   name:@"BuildAPIDeviceRestarted"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(deleteDeviceStageTwo:)
                   name:@"BuildAPIDeviceDeleted"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(uploadCodeStageTwo:)
                   name:@"BuildAPIDeploymentCreated"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(showCodeErrors:)
                   name:@"BuildAPICodeErrors"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(productToProjectStageTwo:)
                   name:@"BuildAPIGotDeviceGroupsList"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(productToProjectStageThree:)
                   name:@"BuildAPIGotDeployment"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(loggingStarted:)
                   name:@"BuildAPIDeviceAddedToStream"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(loggingStopped:)
                   name:@"BuildAPIDeviceRemovedFromStream"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(presentLogEntry:)
                   name:@"BuildAPILogEntryReceived"
                 object:nil];
    
    [nsncdc addObserver:self
               selector:@selector(listLogs:)
                   name:@"BuildAPIGotLogs"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(listLogs:)
                   name:@"BuildAPIGotHistory"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(listCommits:)
                   name:@"BuildAPIGotDeploymentsList"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(updateCodeStageTwo:)
                   name:@"BuildAPIGotDevicegroup"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(setMinimumDeploymentStageTwo:)
                   name:@"BuildAPISetMinDeployment"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(updateDevice:)
                   name:@"BuildAPIGotDevice"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(gotMyAccount:)
                   name:@"BuildAPIGotMyAccount"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(gotAnAccount:)
                   name:@"BuildAPIGotAnAccount"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(loginRejected:)
                   name:@"BuildAPILoginRejected"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(loggedOut:)
                   name:@"BuildAPILoggedOut"
                 object:ide];
    
    [nsncdc addObserver:self
               selector:@selector(endLogging:)
                   name:@"BuildAPILogStreamEnd"
                 object:ide];
}


#pragma mark - API Response Handler Methods

#pragma mark API Called Account Methods

- (void)gotMyAccount:(NSNotification *)note
{
    // Called by BuildAPIAccess instance AFTER loading the account info
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (source != nil)
    {
        // Because the BuildAPIAccess instance's own attempt to get the account info will come here, we
        // (uniquely) need to make sure that we have a passed object ('source') to work with before processing
        
        accountType = kElectricImpAccountTypeFree;
        NSString *accType = [data valueForKeyPath:@"account.attributes.tier"];
        if ([accType hasPrefix:@"ent"]) accountType = kElectricImpAccountTypePaid;
        
        if (action != nil)
        {
            if ([action compare:@"getproducts"] == NSOrderedSame)
            {
                // Just re-call 'getProductsFromServer:' as the check on the BuildAPIAccess instance's
                // 'currentAccount' property will pass, and the products list will be requested from the server
                
                [self getProductsFromServer:nil];
            }
            
            if ([action compare:@"loggedin"] == NSOrderedSame)
            {
                // Just re-call 'getProductsFromServer:' as the check on the BuildAPIAccess instance's
                // 'currentAccount' property will pass, and the products list will be requested from the server
                
                if ([defaults boolForKey:@"com.bps.squinter.autoloadlists"]) [self getProductsFromServer:nil];
            }
        }
        else
        {
            [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (gotMyAccount:)"] :YES];
        }
    }
}



- (void)gotAnAccount:(NSNotification *)note
{
    // Called by BuildAPIAccess instance AFTER loading the account info
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *account = [data objectForKey:@"account"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSMutableDictionary *product = [source objectForKey:@"product"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"getaccountid"] == NSOrderedSame)
        {
            if (product[@"shared"])
            {
                NSString *userName = [account valueForKeyPath:@"attributes.username"];
                [product setValue:userName forKeyPath:@"shared.name"];
                [self refreshProductsMenu];
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (gotAccount:)"] :YES];
    }
}



- (void)loggedIn:(NSNotification *)note
{
    // BuildAPIAccess has signalled login success
    
    // First, get the user's account ID
    
    NSDictionary *dict = @{ @"action" : @"loggedin" };
    
    [ide getMyAccount:dict];
    
    // Action continues asynchronously at 'gotMyAccount:'
    // Meatime, save credentials if they have changed required
    
    BOOL flag = NO;
    
    if (saveDetailsCheckbox.state == NSOnState)
    {
        // User has indicated they want the credentials saved for next time
        // NOTE this should not happen if we auto-log in
        
        PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
        NSString *untf = usernameTextField.stringValue;
        NSString *pwtf = passwordTextField.stringValue;
        
        // Compare the entered value with the existing value - only overwrite if they are different
        
        NSString *cs = [pc stringForKey:@"com.bps.Squinter.ak.notional.tully"];
        
        cs = (cs == nil) ? @"" : [ide decodeBase64String:cs];
        
        if ([cs compare:untf] != NSOrderedSame)
        {
            [pc setString:[ide encodeBase64String:untf] forKey:@"com.bps.Squinter.ak.notional.tully"];
            flag = YES;
        }
        
        cs = [pc stringForKey:@"com.bps.Squinter.ak.notional.tilly"];
        
        cs = (cs == nil) ? @"" : [ide decodeBase64String:cs];
        
        if ([cs compare:pwtf] != NSOrderedSame)
        {
            [pc setString:[ide encodeBase64String:pwtf] forKey:@"com.bps.Squinter.ak.notional.tilly"];
            flag = YES;
        }
        
        if (flag) [self writeStringToLog:@"impCloud credentials saved in your keychain." :YES];
    }
    
    // Set the 'Accounts' menu
    
    NSString *cloudName = [self getCloudName:ide.impCloudCode];
    accountMenuItem.title = [NSString stringWithFormat:@"Signed in to “%@”", usernameTextField.stringValue];
    if (cloudName.length > 0) accountMenuItem.title = [accountMenuItem.title stringByAppendingFormat:@" (%@ impCloud)", [cloudName substringToIndex:cloudName.length - 1]];
    
    loginMenuItem.title = @"Log out of this Account";
    // switchAccountMenuItem.enabled = YES;
    
    if (switchingAccount)
    {
        // We are switching to a secondary account, so we should change the login option
        
        switchAccountMenuItem.title = @"Log in to Your Main Account";
        loginMode = kLoginModeAlt;
    }
    else
    {
        // We have logged into the primary account
        
        switchAccountMenuItem.title = @"Log in to a Different Account...";
        loginMode = kLoginModeMain;
    }
    
    [self setToolbar];
    
    // Register we are no longer trying to log in
    
    isLoggingIn = NO;
    credsFlag = YES;
    switchingAccount = NO;
    otpLoginToken = nil;
    
    // Inform the user he or she is logged in - and to which cloud
    
    [self writeStringToLog:[NSString stringWithFormat:@"You now are logged in to the %@impCloud.", cloudName] :YES];
    
    // Check for any post-login actions that need to be performed
    
    // User may want the Product lists loaded on login
    
    // FROM 2.0.125, this check takes place in 'inloggedInStageTwo:' which indirectly requires a correct account ID
    
    // User wants to update devices' status periodically, or the Device lists loaded on login
    
    if ([defaults boolForKey:@"com.bps.squinter.updatedevs"])
    {
        // Set Squinter to begin the periodic device update timer
        
        [self keepDevicesStatusUpdated:nil];
    }
    else if ([defaults boolForKey:@"com.bps.squinter.autoloaddevlists"])
    {
        // Go and get a list of the account's devices
        
        [self updateDevicesStatus:nil];
    }
}



- (void)loggedInStageTwo
{
    // User wants the Product lists loaded on login
    // TODO Remove this
    
    if ([defaults boolForKey:@"com.bps.squinter.autoloadlists"]) [self getProductsFromServer:nil];
}



- (void)loginRejected:(NSNotification *)note
{
    // Called if BuildAPIAccess has notified the host that a login attempt has been rejected
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Sorry, your impCentral credentials have been rejected";
    alert.informativeText = @"Please check your account details and then try to log in again.";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:mainWindow completionHandler:nil];
    
    // Register we are no longer trying to log in
    
    isLoggingIn = NO;
    credsFlag = YES;
    switchingAccount = NO;
    otpLoginToken = nil;
    loginMode = kLoginModeNone;
}



- (void)loggedOut:(NSNotification *)note
{
    // Called if BuildAPIAccess has notified the host that we have been logged out
    
    loginKey = nil;
    otpLoginToken = nil;
    
    // Stop auto-updating account devices' status
    
    [self keepDevicesStatusUpdated:nil];
    
    // Update the UI elements relating to these items
    
    [self refreshProductsMenu];
    [self refreshProjectsMenu];
    [self refreshDevicesMenus];
    [self refreshDeviceMenu];
    [self refreshDevicesPopup];
    [self setToolbar];
    
    // Set the account menu UI
    
    accountMenuItem.title = @"Not Signed in to any Account";
    loginMenuItem.title = @"Log in to your Main Account";
    switchAccountMenuItem.title = @"Log in to a Different Account...";
    loginMode = kLoginModeNone;
    accountType = kElectricImpAccountTypeNone;
}



#pragma mark API Called Project Methods

- (void)uploadProjectStageThree:(Project *)project
{
    // NOTE We can't get here without one or more device groups
    // and there will be one deployment per devicegroup
    
    [self writeStringToLog:[NSString stringWithFormat:@"Uploading project \"%@\" code...", project.name] :YES];
    
    // Record the total number of device group code uploads
    
    project.count = project.devicegroups.count;
    
    for (Devicegroup *devicegroup in project.devicegroups)
    {
        [self uploadDevicegroupCode:devicegroup :project];
    }
}



#pragma mark API Called Products Methods

- (void)listProducts:(NSNotification *)note
{
    // Called by the BuildAPIAccess instance AFTER loading a list of products
    // At this point we typically need to select or re-select a product
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSArray *products = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];
    NSString *sid = nil;
    NSInteger index = 0;
    
    if (action != nil)
    {
        // 'selectedProduct' may point to an entry in the existing 'productsArray', but this is
        // about to be zapped, so preserved the ID of the product it points to so that we can
        // reselect it after updating 'productsArray'
        
        if (selectedProduct != nil)
        {
            sid = [self getValueFrom:selectedProduct withKey:@"id"];
            selectedProduct = nil;
        }
        
        // Clear out or create the products list. If there are no products returned, we don't
        // want to continue listing products that may have been deleted elsewhere
        
        if (productsArray == nil)
        {
            productsArray = [[NSMutableArray alloc] init];
        }
        else
        {
            [productsArray removeAllObjects];
        }
        
        NSString *noneString = @"There are no products listed on the server for this account.";
        
        if (products != nil)
        {
            if (products.count > 0)
            {
                // Process the product dictionaries retrieved from the server
                
                for (NSDictionary *product in products)
                {
                    // Convert incoming dictionary into a mutable one and copy the data
                    
                    NSMutableDictionary *aProduct = [[NSMutableDictionary alloc] init];
                    
                    [aProduct setObject:[product objectForKey:@"id"] forKey:@"id"];
                    [aProduct setObject:[product objectForKey:@"type"] forKey:@"type"];
                    [aProduct setObject:[product objectForKey:@"relationships"] forKey:@"relationships"];
                    [aProduct setObject:[NSMutableDictionary dictionaryWithDictionary:[product objectForKey:@"attributes"]] forKey:@"attributes"];
                    
                    // Set owner information
                    
                    NSString *creatorID = [aProduct valueForKeyPath:@"relationships.creator.id"];
                    NSString *myID = ide.currentAccount;
                    
                    if ([creatorID compare:myID] != NSOrderedSame)
                    {
                        // The Product is being shared with a collaborator (user ID != creator ID)
                        // so add a 'shared' dictionary to the product dictionary, so we know later,
                        // eg. when presenting the Projects > Products in the impCloud sub-menu
                        
                        NSMutableDictionary *shared = [[NSMutableDictionary alloc] init];
                        [shared setObject:@"" forKey:@"name"];
                        [shared setObject:creatorID forKey:@"id"];
                        [aProduct setObject:shared forKey:@"shared"];
                        
                        // Get the creator account name
                        
                        NSDictionary *dict = @{ @"action" : @"getaccountid",
                                                @"product" : aProduct };
                        
                        [ide getAccount:creatorID :dict];
                        
                        // Pick up the asynchronous action at 'gotAnAccount:'
                        
                        // Add shared products to the end of the list
                        
                        [productsArray addObject:aProduct];
                        
                        // Get the index of the first shared product
                        // 'index' will be zero until then
                        
                        if (index == 0) index = [productsArray indexOfObject:aProduct];
                    }
                    else
                    {
                        if (index == 0)
                        {
                            // No shared Products yet, so just add the owned Product to the end of the list
                            
                            [productsArray addObject:aProduct];
                        }
                        else
                        {
                            // There are shared Products so, insert the owned product just before the start
                            // of the shared Products, and increment the index to grow as the array grows
                            
                            [productsArray insertObject:aProduct atIndex:(index - 1)];
                            index++;
                        }
                    }
                    
                    // If we need to match against a previous 'selectedProduct' ID, do it now
                    
                    if (sid != nil && [sid compare:[product objectForKey:@"id"]] == NSOrderedSame) selectedProduct = aProduct;
                    
                    // If we are here after creating a product, make sure it's the selected one
                    
                    if (selectedProduct == nil && ([action compare:@"newproduct"] == NSOrderedSame || [action compare:@"uploadproject"] == NSOrderedSame))
                    {
                        NSString *pid = [so objectForKey:@"productid"];
                        NSString *apid = [product objectForKey:@"id"];
                        
                        if ([pid compare:apid] == NSOrderedSame) selectedProduct = aProduct;
                    }
                }
                
                // Inform the user
                
                [self writeStringToLog:@"List of products loaded: see 'Projects' > 'Products in the impCloud'." :YES];
                
                // Choose the first product on the list
                
                if (selectedProduct == nil) selectedProduct = [productsArray objectAtIndex:0];
            }
            else
            {
                [self writeStringToLog:noneString :YES];
            }
        }
        else
        {
            // TODO Indicate an issue???
            
            [self writeStringToLog:noneString :YES];
        }
        
        // Update the UI
        
        [self refreshProductsMenu];
        [self refreshProjectsMenu];
        [self setToolbar];
        
        // Point the Inspector at the current products list
        
        iwvc.products = productsArray;
        
        if ([action compare:@"uploadproject"] == NSOrderedSame)
        {
            // We are coming here because we want to upload a new project, so go back
            // and re-check the product information now we have retrieved it
            
            [self uploadProject:[so objectForKey:@"project"]];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (listProducts:)"] :YES];
    }
}



- (void)productToProjectStageTwo:(NSNotification *)note
{
    // This method is called by BuildAPIAccess ONLY with a list of a product's device groups
    // It may be in response to calling 'downloadProduct:', to 'deleteProduct:' or 'syncProject:, with the
    // actions "downloadproduct", "deleteproduct" and "syncproject", respectively
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSMutableArray *devicegroups = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"syncproject"] == NSOrderedSame)
        {
            // FROM 2.3.128
            // Compare download list of device groups to saved list of groups
            
            Project *project = [so objectForKey:@"project"];
            NSMutableArray *locals;
            NSMutableArray *remotes;
            
            if (project.devicegroups.count > 0)
            {
                // Determine which, if any, remote device groups are not listed
                // in the local project. Record them in 'remotes'
                
                for (NSDictionary *adg in devicegroups)
                {
                    BOOL listedLocally = NO;
                    NSString *dgid = [adg objectForKey:@"id"];
                    
                    for (Devicegroup *dg in project.devicegroups)
                    {
                        if (dg.did != nil && [dgid compare:dg.did] == NSOrderedSame)
                        {
                            listedLocally = YES;
                            break;
                        }
                    }
                    
                    if (!listedLocally)
                    {
                        if (remotes == nil) remotes = [[NSMutableArray alloc] init];
                        [remotes addObject: adg];
                    }
                }
            }
            else
            {
                // If there are no local device groups, then all of the retrieved ones are out of sync
                
                if (devicegroups.count > 0) remotes = devicegroups;
            }
            
            if (remotes != nil && remotes.count > 0)
            {
                // We have some device groups on the server that are not recorded locally, so present
                // the sync choice sheet so the user can select which ones they want to download
                
                sywvc.syncGroups = remotes;
                sywvc.project = project;
                sywvc.presentingRemotes = YES;
                
                [sywvc prepSheet];
                [mainWindow beginSheet:syncChoiceSheet completionHandler:nil];
                
                // Pick up the action at 'cancelSyncChoiceSheet:' or 'closeSyncChoiceSheet:'
                // depending on the user's choice
                // NOTE We will return to 'productToProjectStageTwo:' if we go to 'closeSyncChoiceSheet:'
                //      in order to check for any devicegroups not yet uploaded
            }
            else
            {
                // There are no devicegroups on the server that are not present locally,
                // so determine which, if any, local devicegroups are not
                // present on the server. Record them in 'locals'
                
                for (Devicegroup *dg in project.devicegroups)
                {
                    BOOL onServer = NO;
                    
                    if (dg.did != nil && dg.did.length > 0)
                    {
                        // The local devicegroup has an ID - see if it matches a
                        // devicegroup on the server
                        
                        for (NSDictionary *adg in devicegroups)
                        {
                            NSString *dgid = [adg objectForKey:@"id"];
                            
                            if ([dgid compare:dg.did] == NSOrderedSame)
                            {
                                onServer = YES;
                                break;
                            }
                        }
                    }
                    
                    if (!onServer)
                    {
                        if (locals == nil) locals = [[NSMutableArray alloc] init];
                        [locals addObject: dg];
                    }
                }
                
                if (locals != nil && locals.count > 0)
                {
                    // We have some device groups locally that are not present on the server, so present
                    // the sync choice sheet so the user can select which ones they want to upload
                    
                    // First, check uploadable names while we still have access to a list
                    // of server devicegroups (we have previously matched against unique IDs)
                    
                    for (Devicegroup *dg in locals)
                    {
                        BOOL nameMatch = NO;
                        NSUInteger index = 0;
                        NSUInteger count = 0;
                        NSString *name = dg.name;
                        
                        do {
                            NSDictionary *adg = [devicegroups objectAtIndex:index];
                            NSString *aname = [self getValueFrom:adg withKey:@"name"];
                            
                            if ([dg.name compare:aname] == NSOrderedSame)
                            {
                                nameMatch = YES;
                                index = 0;
                                ++count;
                                name = [dg.name stringByAppendingFormat:@"%li", index];
                            }
                            else
                            {
                                ++index;
                            }
                        } while (index < devicegroups.count);
                        
                        if ([name compare:dg.name] != NSOrderedSame)
                        {
                            // Record the updated name for later
                            
                            if (dg.data == nil) dg.data = [[NSMutableDictionary alloc] init];
                            [dg.data setObject:name forKey:@"dgname"];
                        }
                    }
                    
                    sywvc.syncGroups = locals;
                    sywvc.project = project;
                    sywvc.presentingRemotes = NO;
                    
                    [sywvc prepSheet];
                    [mainWindow beginSheet:syncChoiceSheet completionHandler:nil];
                    
                    // Pick up the action at 'cancelSyncChoiceSheet:' or 'closeSyncChoiceSheet:'
                    // depending on the user's choice
                    // NOTE We will return to 'productToProjectStageTwo:' if we go to 'closeSyncChoiceSheet:'
                    //      in order to check for any devicegroups not yet uploaded
                }
                else
                {
                    // The local project matches the remote product, so let the user know
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = [NSString stringWithFormat:@"Project “%@” in sync", project.name];
                    alert.informativeText = @"All of the Device Groups listed on the server are accessible via the Project.";
                    [alert beginSheetModalForWindow:mainWindow completionHandler:nil];
                }
            }
        }
        else if ([action compare:@"downloadproduct"] == NSOrderedSame)
        {
            // Perform the flow for downloading a product: Iterate over the list of device groups
            // and in each case go and get its current deployment
            
            Project *newProject = [so objectForKey:@"project"];
            
            // Record the total number of device groups to the product has, ie. the number of
            // device group deployments we will need to retrieve
            
            if (devicegroups.count > 0)
            {
                // The product has at least one device group, so add the device group records to the new project
                
                newProject.devicegroups = [[NSMutableArray alloc] init];
                newProject.count = devicegroups.count;
                
                for (NSDictionary *devicegroup in devicegroups)
                {
                    Devicegroup *newDevicegroup = [[Devicegroup alloc] init];
                    newDevicegroup.name = [self getValueFrom:devicegroup withKey:@"name"];
                    newDevicegroup.did = [self getValueFrom:devicegroup withKey:@"id"];
                    newDevicegroup.description = [self getValueFrom:devicegroup withKey:@"description"];
                    newDevicegroup.type = [self getValueFrom:devicegroup withKey:@"type"];
                    newDevicegroup.models = [[NSMutableArray alloc] init];
                    newDevicegroup.devices = [[NSMutableArray alloc] init];
                    newDevicegroup.data = [NSMutableDictionary dictionaryWithDictionary:devicegroup];
                    [newProject.devicegroups addObject:newDevicegroup];
                    
                    // Get the ID of the group's current deployemnt
                    
                    NSDictionary *cd = [self getValueFrom:devicegroup withKey:@"current_deployment"];
                    
                    if (cd != nil)
                    {
                        // Get the current deployment's deployment ID
                        
                        NSString *dpid = [cd objectForKey:@"id"];
                        
                        if (dpid != nil)
                        {
                            // Now retrieve the code using the deployment ID
                            
                            NSDictionary *dict = @{ @"action" : action,
                                                    @"devicegroup" : newDevicegroup,
                                                    @"project" : newProject };
                            
                            [ide getDeployment:dpid :dict];
                            
                            // At this point we have to wait for multiple async calls to 'productToProjectStageThree:'
                        }
                        else
                        {
                            // Can't proceed so decrement the tally of downloadable device groups and move on
                            
                            --newProject.count;
                        }
                    }
                    else
                    {
                        // Can't proceed so decrement the tally of downloadable device groups and move on
                        
                        --newProject.count;
                        
                        // FROM 2.3.182
                        // Get all the deployments for the device group so we can grab the latest one
                        
                        NSDictionary *dict = @{ @"action" : action,
                                                @"devicegroup" : newDevicegroup,
                                                @"project" : newProject };
                        
                        [ide getDeploymentsWithFilter:@"devicegroup.id" :newDevicegroup.did :dict];
                        
                        // Get deployments for this device group. Pick up at 'listCommits:'
                    }
                    
                    // NOTE if 'cd' or 'dpid' is nil, the device group has no current deployment
                    // TODO do we get a historical, or create an empty file?
                }
                
                if (newProject.count == 0) [self productToProjectStageFour:newProject];
            }
            else
            {
                // Product has no device groups, so just save the new project as is
                // NOTE Methods called by 'productToProjectStageFour:' will handle adding
                // the project to the project array, updating the UI, etc.
                
                [self productToProjectStageFour:newProject];
            }
        }
        else
        {
            // Perform the flow for deleting a product
            
            NSMutableDictionary *productToDelete = [so objectForKey:@"product"];
            NSDictionary *product = [productToDelete objectForKey:@"product"];
            [productToDelete setObject:[NSNumber numberWithInteger:devicegroups.count] forKey:@"count"];
            [productToDelete setObject:devicegroups forKey:@"devicegroups"];
            
            if (devicegroups.count > 0)
            {
                [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - checking device groups for assigned devices...", [self getValueFrom:product withKey:@"name"]] :YES];
                
                // Run through all of the product's device groups to acquire a list off their devices
                
                for (NSDictionary *devicegroup in devicegroups)
                {
                    NSDictionary *dict = @{ @"action" : action,
                                            @"devicegroup" : devicegroup,
                                            @"product" : productToDelete };
                    
                    // Get the list of devices assigned to this device group
                    
                    [ide getDevicesWithFilter:@"devicegroup.id" :[devicegroup objectForKey:@"id"] :dict];
                    
                    // Pick up the action in 'listDevices:'
                }
            }
            else
            {
                // The product has no devicegroups - ergo no devices — so go direct to the next stage,
                // ie. don't bother to check device groups for devices
                
                [self deleteProductStageTwo:productToDelete];
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (productToProjectStageTwo:)"] :YES];
    }
}



- (void)productToProjectStageThree:(NSNotification *)note
{
    // Called by the BuildAPIAccess instance in response to
    // multiple requests to retrieve the current deployment for a given device group
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *deployment = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];
    Project *newProject = [so objectForKey:@"project"];
    Devicegroup *newDevicegroup = [so objectForKey:@"devicegroup"];
    
    // NOTE No check for no action value here as it will have been checked by
    //      all calling methods
    
    if (deployment != nil)
    {
        if ([action compare:@"updatecode"] == NSOrderedSame)
        {
            if (newDevicegroup.models.count == 0) return;
            
            // Compare the deployment we have with the one just downloaded
            
            NSString *sha = [self getValueFrom:deployment withKey:@"sha"];
            NSString *updated = [self getValueFrom:deployment withKey:@"updated_at"];
            if (updated == nil) updated = [self getValueFrom:deployment withKey:@"created_at"];
            NSDate *deployDate = [inLogDef dateFromString:updated];
            
            for (Model *model in newDevicegroup.models)
            {
                // Check dates
                
                NSDate *modelDate = [inLogDef dateFromString:model.updated];
                
                if ([modelDate earlierDate:deployDate] == modelDate)
                {
                    // The model is older than the current deployment, so update the model
                    
                    NSString *code = [model.type compare:@"agent"] == NSOrderedSame
                    ? [self getValueFrom:deployment withKey:@"agent_code"]
                    : [self getValueFrom:deployment withKey:@"device_code"];
                    
                    model.code = code;
                    model.sha = sha;
                    model.updated = updated;
                    model.squinted = NO;
                    newDevicegroup.squinted = 0;
                    
                    Project *project = [self getParentProject:newDevicegroup];
                    project.haschanged = YES;
                    
                    if (project == currentProject)
                    {
                        iwvc.project = currentProject;
                        [saveLight needSave:YES];
                    }
                }
            }
        }
        else
        {
            // We presume the 'action' is 'downloadproduct' or (from 2.3.128) 'syncmodelcode'
            // Either way, create two models - one device, one agent - based on the deployment
            // and add it to the target device group object
            
            if (newDevicegroup.models == nil) newDevicegroup.models = [[NSMutableArray alloc] init];
            
            Model *model;
            NSString *code = [self getValueFrom:deployment withKey:@"device_code"];
            
            if (code != nil)
            {
                model = [[Model alloc] init];
                model.type = @"device";
                model.squinted = NO;
                model.code = code;
                model.path = newProject.path;
                model.filename = @"UNSAVED";
                model.sha = [self getValueFrom:deployment withKey:@"sha"];
                model.updated = [self getValueFrom:deployment withKey:@"updated_at"];
                if (model.updated == nil) model.updated = [self getValueFrom:deployment withKey:@"created_at"];
                [newDevicegroup.models addObject:model];
            }
            
            code = [self getValueFrom:deployment withKey:@"agent_code"];
            
            if (code != nil)
            {
                model = [[Model alloc] init];
                model.type = @"agent";
                model.squinted = NO;
                model.code = code;
                model.path = newProject.path;
                model.filename = @"UNSAVED";
                model.sha = [self getValueFrom:deployment withKey:@"sha"];
                model.updated = [self getValueFrom:deployment withKey:@"updated_at"];
                if (model.updated == nil) model.updated = [self getValueFrom:deployment withKey:@"created_at"];
                [newDevicegroup.models addObject:model];
            }
            
            // NOTE The code files have not been saved yet. This should take place when the user
            //      closes the project, quits the app or asks to save the project
        }
    }
    
    // Decrement the tally of downloadable device groups or deployments to see if we've got them all yet
    
    --newProject.count;
    
    if (newProject.count <= 0)
    {
        // We have now acquired all the device groups models, so we can set the
        
        // ALREADY SET???? newProject.aid = ide.isLoggedIn ? ide.currentAccount : @"";
        
        // Select the devices, if any, belonging to the project's device groups
        
        if (newProject.devicegroups.count > 0)
        {
            if (devicesArray.count > 0)
            {
                // If we have a device list, run through it and see which devices, if any,
                // have been assigned to the new project's device group(s)
                
                for (NSDictionary *device in devicesArray)
                {
                    NSDictionary *relationships = [device objectForKey:@"relationships"];
                    NSDictionary *deviceDevGrp = [relationships objectForKey:@"devicegroup"];
                    NSString *dgid = [deviceDevGrp objectForKey:@"id"];
                    NSString *deviceid = [device objectForKey:@"id"];
                    
                    // Just check for a nil device group ID - to avoid unassigned devices - and
                    // then record the device ID in the device group record if it belongs there
                    
                    for (Devicegroup *dg in newProject.devicegroups)
                    {
                        if ([dg.did compare:dgid] == NSOrderedSame)
                        {
                            // This device 'belongs' to this devicegroup
                            
                            if (dg.devices == nil) dg.devices = [[NSMutableArray alloc] init];
                            [dg.devices addObject:deviceid];
                        }
                    }
                }
                
                // See if the current device group has any devices, and select one
                // NOTE But only if the project is owned by the user
                
                if ([newProject.cid compare:newProject.aid] == NSOrderedSame) [self selectFirstDevice];
            }
        }
        
        // FROM 2.3.128
        // If action is 'syncmodelcode', work out which files need to be saved
        
        if ([action compare:@"syncmodelcode"] == NSOrderedSame)
        {
            // Update the UI for the downloaded project
            
            [self postSync:newProject];
            
            /*
             NSMutableArray *filesToSave = [[NSMutableArray alloc] init];
             
             if (newProject.devicegroups.count > 0)
             {
             for (Devicegroup *dg in newProject.devicegroups)
             {
             if (dg.models.count > 0)
             {
             for (Model *model in dg.models)
             {
             // NOTE we save a model file even if it contains no code - the user may add code later
             
             if (model.filename == nil || model.filename.length == 0)
             {
             model.path = newProject.path;
             model.filename = [dg.name stringByAppendingFormat:@".%@.nut", model.type];
             
             [filesToSave addObject:model];
             }
             }
             }
             }
             }
             
             // If we have files that need saving, save them
             
             if (filesToSave.count > 0) [self saveFiles:filesToSave :newProject];
             */
        }
        else
        {
            // Save the project
            
            [self productToProjectStageFour:newProject];
        }
    }
}



- (void)productToProjectStageFour:(Project *)project
{
    // Called by 'productToProjectStageThree:' in order to
    // clean up after downloading the product
    
    project.count = 999;
    project.haschanged = YES;
    project.filename = [project.name stringByAppendingString:@".squirrelproj"];
    
    // Set the downloaded project as current
    
    [projectArray addObject:project];
    
    currentProject = project;
    iwvc.project = project;
    
    // Set the current device group to the first on the list of the project's
    // device groups (or zero if the project has no device groups)
    
    if (project.devicegroups != nil && project.devicegroups.count > 0)
    {
        currentDevicegroup = [project.devicegroups firstObject];
        project.devicegroupIndex = 0;
    }
    else
    {
        currentDevicegroup = nil;
        project.devicegroupIndex = -1;
    }
    
    // Update the UI
    
    [saveLight show];
    [saveLight needSave:project.haschanged];
    
    [self refreshOpenProjectsMenu];
    [self refreshProjectsMenu];
    [self refreshDevicegroupMenu];
    [self refreshMainDevicegroupsMenu];
    [self setToolbar];
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"Product “%@” downloaded", project.name];
    alert.informativeText = @"Please save the Project to write any downloaded code files to disk.";
    
    [alert beginSheetModalForWindow:mainWindow completionHandler:nil];
    
    // FROM 2.3.128 Don't immediately save any more
    
    /*
     if (savingProject != nil)
     {
     // We already have a project being saved...
     // TODO
     
     return;
     }
     
     // Save the project
     
     savingProject = project;
     savingProject.filename = [savingProject.name stringByAppendingString:@".squirrelproj"];
     [self saveProjectAs:nil];
     */
}



- (void)getCurrentDeployment:(NSDictionary *)data
{
    // Called by BuildAPIAccess ONLY with a list of a device group's deployments,
    // from which we extract the most recent. This is only used in rare instances where
    // a device group has no 'current_deployment' field
    
    NSDictionary *source = [data objectForKey:@"object"];
    Project *project = [source objectForKey:@"project"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    NSMutableArray *deployments = [data objectForKey:@"data"];
    
    if (deployments != nil && deployments.count > 0)
    {
        NSString *newest = @"";
        NSDictionary *currentDeployment = nil;
        
        for (NSDictionary *deployment in deployments)
        {
            NSString *date = [self getValueFrom:deployment withKey:@"updated_at"];
            if (date == nil) date = [self getValueFrom:deployment withKey:@"created_at"];
            
            if ([date compare:newest] == NSOrderedDescending)
            {
                newest = date;
                currentDeployment = deployment;
            }
        }
        
        if (currentDeployment != nil)
        {
            // Process deployment
            
            if (devicegroup.models == nil) devicegroup.models = [[NSMutableArray alloc] init];
            
            Model *model;
            NSString *code = [self getValueFrom:currentDeployment withKey:@"device_code"];
            
            if (code != nil)
            {
                model = [[Model alloc] init];
                model.type = @"device";
                model.squinted = NO;
                model.code = code;
                model.path = project.path;
                model.filename = @"UNSAVED";
                model.sha = [self getValueFrom:currentDeployment withKey:@"sha"];
                model.updated = [self getValueFrom:currentDeployment withKey:@"updated_at"];
                if (model.updated == nil) model.updated = [self getValueFrom:currentDeployment withKey:@"created_at"];
                [devicegroup.models addObject:model];
            }
            
            code = [self getValueFrom:currentDeployment withKey:@"agent_code"];
            
            if (code != nil)
            {
                model = [[Model alloc] init];
                model.type = @"agent";
                model.squinted = NO;
                model.code = code;
                model.path = project.path;
                model.filename = @"UNSAVED";
                model.sha = [self getValueFrom:currentDeployment withKey:@"sha"];
                model.updated = [self getValueFrom:currentDeployment withKey:@"updated_at"];
                if (model.updated == nil) model.updated = [self getValueFrom:currentDeployment withKey:@"created_at"];
                [devicegroup.models addObject:model];
            }
        }
    }
    
    --project.count;
    
    if (project.count == 0) [self productToProjectStageFour:project];
}



- (void)createProductStageTwo:(NSNotification *)note
{
    // Called by the BuildAPIAccess instance in response to a new product being created
    // This is a result of the user creating a new project and asking for a product to be made too.
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    Project *project = [source objectForKey:@"project"];
    data = [data objectForKey:@"data"];
    
    // Perform appropriate action flows
    
    if (action != nil)
    {
        // Link the project to the new product
        
        project.pid = [data objectForKey:@"id"];
        project.cid = [data valueForKeyPath:@"relationships.creator.id"];
        
        [self writeStringToLog:[NSString stringWithFormat:@"Created product for project \"%@\".", project.name] :YES];
        [self writeStringToLog:@"Refreshing your list of products..." :YES];
        
        selectedProduct = nil;
        
        NSDictionary *dict = @{ @"action" : @"newproduct",
                                @"productid" : project.pid };
        
        [ide getProducts:dict];
        
        // -> Pick up the async outcomce in 'listProducts:'
        
        if ([action compare:@"newproject"] == NSOrderedSame)
        {
            // This is the action flow for a new project, new product
            
            // Enable project-related UI items
            
            [self refreshOpenProjectsMenu];
            [self refreshProjectsMenu];
            [self refreshMainDevicegroupsMenu];
            [self refreshDevicegroupMenu];
            [self refreshDeviceMenu];
            [self setToolbar];
            
            // Mark the status light as empty, ie. in need of saving
            
            [saveLight show];
            [saveLight needSave:YES];
            
            // Save the new project - this gives the user the chance to re-locate it
            
            iwvc.project = currentProject;
            savingProject = currentProject;
            
            [self saveProjectAs:nil];
        }
        else if ([action compare:@"uploadproject"] == NSOrderedSame)
        {
            // This is the action flow for a project being uploaded
            // We now have to upload the device groups
            
            [self writeStringToLog:@"Uploading the project's device groups..." :YES];
            
            if (project.devicegroups.count > 0)
            {
                // Record the number of device groups to be uploaded
                
                project.count = project.devicegroups.count;
                
                // Begin uploading device groups one after the other
                
                for (Devicegroup *devicegroup in project.devicegroups)
                {
                    [self writeStringToLog:[NSString stringWithFormat:@"Uploading device group \"%@\"...", devicegroup.name] :YES];
                    
                    NSDictionary *dict = @{ @"action" : action,
                                            @"project" : project,
                                            @"devicegroup" : devicegroup };
                    
                    NSDictionary *details = @{ @"name" : devicegroup.name,
                                               @"description" : devicegroup.description,
                                               @"productid" : project.pid,
                                               @"type" : devicegroup.type };
                    
                    [ide createDevicegroup:details :dict];
                    
                    // Pick up the action at 'createDevicegroupStageTwo:'
                }
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createProductStageTwo:)"] :YES];
    }
}



- (void)deleteProductStageTwo:(NSMutableDictionary *)productToDelete
{
    // We come here directly after checking all of a product's device groups to see if they can be deleted
    // It's here that we action the deletion of each device group
    
    NSArray *devicegroups = [productToDelete objectForKey:@"devicegroups"];
    NSDictionary *product = [productToDelete objectForKey:@"product"];
    
    // At this point we can be pretty sure we can delete the product and any device groups it has,
    // so we can break its link with any current projects. Run through the open projects and clear
    // their PID.
    
    // TODO should we also clear the account ID, since the link to the account is the product, and
    //      that has now gone? With no account ID, the project is free to be uploaded to a new acct
    
    NSString *pid = [product objectForKey:@"id"];
    
    // Find the project, if any, linked to the deleted product
    
    Project *project = nil;
    
    if (projectArray.count > 0)
    {
        for (Project *aproject in projectArray)
        {
            if ([aproject.pid compare:pid] == NSOrderedSame)
            {
                project = aproject;
                break;
            }
        }
    }
    
    // Run through the device groups in the list and delete them
    
    if (devicegroups.count > 0)
    {
        // Reset the value of the 'count' key
        
        [productToDelete setObject:[NSNumber numberWithInteger:devicegroups.count] forKey:@"count"];
        
        [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - deleting device groups...", [self getValueFrom:product withKey:@"name"]] :YES];
        
        // Run through the device group list and delete each entry
        
        for (NSDictionary *devicegroup in devicegroups)
        {
            NSDictionary *source = project != nil ?
            @{ @"action" : @"deleteproduct",
               @"devicegroup" : devicegroup,
               @"project": project,
               @"product" : productToDelete } :
            @{ @"action" : @"deleteproduct",
               @"devicegroup" : devicegroup,
               @"product" : productToDelete };
            
            [ide deleteDevicegroup:[devicegroup objectForKey:@"id"] :source];
        }
        
        // Pick up the action in 'deleteDevicegroupStageTwo:'
    }
    else
    {
        // There are no device groups to delete so just delete the product itself
        
        [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\"...", [self getValueFrom:product withKey:@"name"]] :YES];
        
        NSDictionary *source = project != nil ?
        @{ @"action" : @"deleteproduct",
           @"project": project,
           @"product" : productToDelete } :
        @{ @"action" : @"deleteproduct",
           @"product" : productToDelete };
        
        [ide deleteProduct:pid :source];
        
        // Pick this up at 'deleteProductStageThree:'
    }
}



- (void)deleteProductStageThree:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess instance AFTER deleting a product
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSDictionary *productToDelete = [source objectForKey:@"product"];
    NSDictionary *product = [productToDelete objectForKey:@"product"];
    Project *project = [source objectForKey:@"project"];
    
    // Clear the current product if it's still the one we're deleting
    
    if (selectedProduct == product) selectedProduct = nil;
    
    // Inform the user
    
    [self writeStringToLog:[NSString stringWithFormat:@"Deleted product \"%@\".", [self getValueFrom:product withKey:@"name"]] :YES];
    [self writeStringToLog:@"Refreshing your list of products..." :YES];
    
    // Go and get an updated list of products
    
    NSDictionary *dict = @{ @"action" : @"getproducts" };
    
    [ide getProducts:dict];
    
    // Pick up the action at 'listProducts:'
    
    // Meantime, update the project, if one has been recorded
    
    if (project != nil)
    {
        project.pid = @"";
        project.haschanged = YES;
        
        if (project == currentProject)
        {
            iwvc.project = currentProject;
            [saveLight needSave:YES];
        }
    }
}



- (void)updateProductStageTwo:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER updating a product
    // Becuase of this, we only update the local project at this point
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *response = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    Project *project = [source objectForKey:@"project"];
    
    if (action != nil)
    {
        if ([action compare:@"projectchanged"] == NSOrderedSame)
        {
            if (project != nil)
            {
                project.name = [self getValueFrom:response withKey:@"name"];
                project.description = [self getValueFrom:response withKey:@"description"];
                
                [self writeStringToLog:[NSString stringWithFormat:@"Project and product \"%@\" updated.", project.name] :YES];
            }
            else
            {
                // Separate response text for when we're updating a product
                
                [self writeStringToLog:[NSString stringWithFormat:@"Product \"%@\" updated.", [self getValueFrom:response withKey:@"name"]] :YES];
            }
            
            if (productsArray.count > 0)
            {
                // Update the local products list, if we have one (we may not)
                
                [self writeStringToLog:@"Refreshing your list of products..." :YES];
                [self getProductsFromServer:nil];
                
                // NOTE 'getProductsFromServer:' will go to 'listProducts:' which will update Inspector's 'products' property
            }
        }
        else if ([action compare:@"syncproduct"] == NSOrderedSame)
        {
            // Update the local products list, if we have one (we may not)
            
            [self writeStringToLog:@"Refreshing your list of products..." :YES];
            [self getProductsFromServer:nil];
            
            project.count = project.devicegroups.count;
            
            if (project.devicegroups.count > 0)
            {
                for (Devicegroup *dg in project.devicegroups)
                {
                    NSDictionary *dict = @{ @"action" : @"updatedevicegroup",
                                            @"devicegroup" : dg };
                    
                    [ide getDevicegroup:dg.did :dict];
                    
                    // Action continues in parallel at 'updateCodeStageTwo:'
                }
            }
        }
        else if ([action compare:@"none"] == NSOrderedSame)
        {
            return;
        }
        
        // Mark the device group's parent project as changed
        // NOTE we check for nil, but this is very unlikely (project closed before server responded)
        
        if (project != nil)
        {
            project.haschanged = YES;
            
            if (project == currentProject)
            {
                iwvc.project = currentProject;
                [saveLight needSave:YES];
            }
            
            // Update the UI
            
            [self refreshOpenProjectsMenu];
            [self refreshDevicegroupMenu];
            [self refreshMainDevicegroupsMenu];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateProductStageTwo:)"] :YES];
    }
}



#pragma mark API Called Device Group Methods

- (void)updateDevicegroupStageTwo:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER updating a device group
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *rawGroupData = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    
    // Change the local device group data
    
    BOOL updated = NO;
    
    if (action != nil)
    {
        // FROM 2.3.128
        // Perform operations common to both actions
        
        devicegroup.data = [NSMutableDictionary dictionaryWithDictionary:rawGroupData];
        NSDictionary *dict = [self getValueFrom:rawGroupData withKey:@"min_supported_deployment"];
        devicegroup.mdid = [dict objectForKey:@"id"];
        dict = [self getValueFrom:rawGroupData withKey:@"current_deployment"];
        devicegroup.cdid = [dict objectForKey:@"id"];
        
        // Process the actions
        
        if ([action compare:@"devicegroupchanged"] == NSOrderedSame)
        {
            NSString *newName = [self getValueFrom:rawGroupData withKey:@"name"];
            NSString *newDesc = [self getValueFrom:rawGroupData withKey:@"description"];
            
            // FROM 2.3.128
            // Store retrieved type (may have been changed BuildAPIAccess
            
            devicegroup.type = [self getValueFrom:rawGroupData withKey:@"type"];
            
            // Update name and description as required
            
            if (newName != nil && [newName compare:devicegroup.name] != NSOrderedSame)
            {
                // If the name has changed, report it
                
                [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" renamed \"%@\".", devicegroup.name, newName] :YES];
                devicegroup.name = newName;
                updated = YES;
            }
            else if (newDesc != nil && [newDesc compare:devicegroup.description] != NSOrderedSame)
            {
                // Only report a description update if the name hasn't changed too
                
                [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" description updated.", devicegroup.name] :YES];
                updated = YES;
            }
        }
        else if ([action compare:@"resetprodtarget"] == NSOrderedSame)
        {
            // FROM 2.3.128
            // Use the data we have already just retrieved (rather than get it again)
            // See AppDelegateUtilities - reloads the core device group data from the server
            // [self updateDevicegroup:devicegroup];
            
            // Target changed, so report it
            
            Devicegroup *targetDevicegroup = [source objectForKey:@"target"];
            NSString *type = [self convertDevicegroupType:targetDevicegroup.type :NO];
            
            [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" now has a new target %@ device group: \"%@\".", devicegroup.name, type, targetDevicegroup.name] :YES];
            
            updated = YES;
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateDevicegroupStageTwo:)"] :YES];
    }
    
    if (updated)
    {
        // Mark the device group's parent project as changed, but only if it has
        // NOTE we check for nil, but this is very unlikely (project closed before server responded)
        
        //[self updateDevicegroup:devicegroup];
        
        Project *project = [self getParentProject:devicegroup];
        
        if (project != nil)
        {
            project.haschanged = YES;
            
            if (project == currentProject)
            {
                iwvc.project = currentProject;
                [saveLight needSave:YES];
            }
            
            [self refreshMainDevicegroupsMenu];
            [self refreshDevicegroupMenu];
        }
        else
        {
            [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device group \"%@\" is an orphan.", devicegroup.name] :YES];
        }
    }
}



- (void)deleteDevicegroupStageTwo:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER deleting a device group
    // This may be because the user chose a device group to be deleted, or deleted a product which contains
    // device groups that must also be deleted
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        // FROM 2.3.128
        // Perform operations common to all actions
        
        
        if ([action compare:@"deletedevicegroup"] == NSOrderedSame)
        {
            Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
            Project *project = [self getParentProject:devicegroup];
            
            if (project != nil)
            {
                // FROM 2.3.128 - Unwatch the device group's files
                
                [self closeDevicegroupFiles:devicegroup :project];
                
                [project.devicegroups removeObject:devicegroup];
                
                if (devicegroup == currentDevicegroup)
                {
                    if (project.devicegroups.count > 0)
                    {
                        currentDevicegroup = [project.devicegroups objectAtIndex:0];
                        project.devicegroupIndex = 0;
                    }
                    else
                    {
                        currentDevicegroup = nil;
                        project.devicegroupIndex = -1;
                    }
                }
                
                [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" deleted.", devicegroup.name] :YES];
                
                project.haschanged = YES;
                
                if (project == currentProject)
                {
                    iwvc.project = currentProject;
                    [saveLight needSave:YES];
                }
                
                [self refreshDevicegroupMenu];
                [self refreshMainDevicegroupsMenu];
            }
            else
            {
                [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device group \"%@\" is an orphan.", devicegroup.name] :YES];
            }
        }
        else
        {
            // Run the delete product flow
            
            NSDictionary *devicegroup = [source objectForKey:@"devicegroup"];
            Project *project = [source objectForKey:@"project"];
            NSMutableDictionary *productToDelete = [source objectForKey:@"product"];
            NSNumber *number = [productToDelete objectForKey:@"count"];
            NSArray *devicegroups = [productToDelete objectForKey:@"devicegroups"];
            NSDictionary *product = [productToDelete objectForKey:@"product"];
            NSInteger count = number.integerValue - 1;
            
            [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - device group \"%@\" deleted (%li of %li).", [self getValueFrom:product withKey:@"name"], [self getValueFrom:devicegroup withKey:@"name"], (long)(devicegroups.count - count), (long)devicegroups.count] :YES];
            
            // FROM 2.3.128 If we have a project recorded, run through and find which of its
            // device groups matches the device group that thas just been deleted on the server
            // and clear its ID value
            
            if (project != nil)
            {
                NSString *did = [devicegroup objectForKey:@"id"];
                
                for (Devicegroup *adg in project.devicegroups)
                {
                    if ([adg.did compare:did] == NSOrderedSame)
                    {
                        adg.did = @"";
                        if (project == currentProject) iwvc.project = currentProject;
                        break;
                    }
                }
            }
            
            [productToDelete setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
            
            if (count <= 0)
            {
                // All the device groups are gone, now for the product itself... phew
                
                [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\"...", [self getValueFrom:product withKey:@"name"]] :YES];
                
                [ide deleteProduct:[product objectForKey:@"id"] :source];
                
                // Pick this up at 'deleteProductStageThree:'
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (deleteDevicegroupStageTwo:)"] :YES];
    }
}



- (void)createDevicegroupStageTwo:(NSNotification *)note
{
    // We're back after creating the Device Group on the server
    // so extract the persisted data to get the new device group,
    // its project and the flag indicating whether the user wants
    // source files creating
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *rawGroupData = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSNumber *makeNewFiles = [source objectForKey:@"files"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    Project *project = [source objectForKey:@"project"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        // Record the new device group's ID and its API record
        
        devicegroup.did = [rawGroupData objectForKey:@"id"];
        devicegroup.data = [NSMutableDictionary dictionaryWithDictionary:rawGroupData];
        
        if ([action compare:@"newdevicegroup"] == NSOrderedSame)
        {
            if (newDevicegroupFlag)
            {
                // We are adding a device group for newly added files, so go and process those files
                // and proceed no further here
                
                [self processAddedFiles:saveUrls];
                return;
            }
            
            // Add the device group to the project
            
            if (project.devicegroups == nil) project.devicegroups = [[NSMutableArray alloc] init];
            
            [project.devicegroups addObject:devicegroup];
            
            // Mark the project as changed
            
            project.haschanged = YES;
            
            if (project == currentProject)
            {
                // Set the status light if the project is the current one
                
                [saveLight needSave:YES];
                
                // And select the device group
                
                currentDevicegroup = devicegroup;
                currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
                
                // Update the UI
                
                [self refreshDevicegroupMenu];
                [self refreshMainDevicegroupsMenu];
                [self setToolbar];
                
                // Update the inspector, if required
                
                iwvc.project = currentProject;
            }
            
            // Now we can produce the source code file, as the user requested
            
            if (makeNewFiles != nil && makeNewFiles.boolValue) [self createFilesForDevicegroup:devicegroup.name :@"agent"];
        }
        else if ([action compare:@"uploadproject"] == NSOrderedSame || [action compare:@"syncdevicegroup"] == NSOrderedSame)
        {
            // We're here after creating a device group as part of a project upload
            // Once all the parts have been uploaded, we move on to upload the code
            // via 'uploadProjectStageThree:'
            
            // FROM 2.3.128
            // We also come here after a project sync devicegroup upload
            
            if ([action compare:@"syncdevicegroup"] == NSOrderedSame) [self syncLocalDevicegroupsStageTwo:devicegroup];
            
            // Decrement the device group processing count
            
            --project.count;
            
            if (project.count == 0)
            {
                // FROM 2.3.128
                // If the action is 'syncdevicegroup', attempt to sync again, so that
                // we trigger the correct UI update
                
                if ([action compare:@"syncdevicegroup"] == NSOrderedSame)
                {
                    [self syncProject:project];
                    return;
                }
                
                // We have created all the device groups we need to, so it's now time to upload code
                
                [self uploadProjectStageThree:project];
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createDevicegroupStageTwo:)"] :YES];
    }
}



- (void)syncLocalDevicegroupsStageTwo:(Devicegroup *)devicegroup
{
    // FROM 2.3.128
    // Upload the code for a single devicegroup
    // We come here from 'createDevicegroupStageTwo:'
    
    Project *parent = [self getParentProject:devicegroup];
    
    [self uploadDevicegroupCode:devicegroup :parent];
}



- (void)uploadDevicegroupCode:(Devicegroup *)devicegroup :(Project *)project
{
    // FROM 2.3.128
    // Upload the code for a single devicegroup that has just been created on the server.
    // We come here from 'syncLocalDevicegroupsStageTwo:'
    
    if (devicegroup.squinted == kBothCodeSquinted)
    {
        // Code's agent and device code is compiled
        
        if (devicegroup.models > 0)
        {
            [self writeStringToLog:[NSString stringWithFormat:@"Uploading code from device group \"%@\"...", devicegroup.name] :YES];
            
            NSString *agentCode = @"";
            NSString *deviceCode = @"";
            
            for (Model *model in devicegroup.models)
            {
                if ([model.type compare:@"agent"] == NSOrderedSame)
                {
                    agentCode = model.code;
                }
                else
                {
                    deviceCode = model.code;
                }
            }
            
            // Set the upload time and date
            
            NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
            dateFormatter.dateStyle = NSDateFormatterMediumStyle;
            dateFormatter.timeStyle = NSDateFormatterNoStyle;
            
            NSString *desc = [dateFormatter stringFromDate:[NSDate date]];
            
            // Assemble the deployment record for uploading the code
            
            NSDictionary *adg = @{ @"type" : devicegroup.type,
                                   @"id" : devicegroup.did };
            
            NSDictionary *relationships = @{ @"devicegroup" : adg };
            
            NSDictionary *attributes = @{ @"flagged" : @NO,
                                          @"agent_code" : agentCode,
                                          @"device_code" : deviceCode,
                                          @"description" : [NSString stringWithFormat:@"Uploaded from Squinter %@ at %@", desc, kSquinterAppVersion] };
            
            NSDictionary *deployment = @{ @"type" : @"deployment",
                                          @"attributes" : attributes,
                                          @"relationships" : relationships };
            
            NSDictionary *data = @{ @"data" : deployment };
            
            NSDictionary *dict = @{ @"action" : @"uploadproject",
                                    @"devicegroup" : devicegroup,
                                    @"project" : project };
            
            [ide createDeployment:data :dict];
            
            // Pick up the action at 'uploadCodeStageTwo:'
        }
        else
        {
            [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" has no code to upload.", devicegroup.name] :YES];
        }
    }
    else
    {
        // Device group's model code is not squinted, so don't upload at this time
        
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\"'s code is not compiled so cannot be uploaded. Please compiile the code then upload later.", devicegroup.name] :YES];
    }
}



#pragma mark API Called Code Methods

- (void)updateCodeStageTwo:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER uploading code
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *rawDevicegroup = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"updatedevicegroup"] == NSOrderedSame)
        {
            // We're updating the devicegroup with info from the server
            
            Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
            devicegroup.data = [NSMutableDictionary dictionaryWithDictionary:rawDevicegroup];
            
            NSDictionary *dict = [self getValueFrom:rawDevicegroup withKey:@"min_supported_deployment"];
            devicegroup.mdid = [dict objectForKey:@"id"];
            dict = [self getValueFrom:rawDevicegroup withKey:@"current_deployment"];
            devicegroup.cdid = [dict objectForKey:@"id"];
            
            // FROM 2.3.128
            // Auto-update the Inspector with retrieved data
            
            Project *parent = [source objectForKey:@"project"];
            if (parent == currentProject) iwvc.project = currentProject;
        }
        else if ([action compare:@"updatecode"] == NSOrderedSame)
        {
            // We're updating the devicegroup's code
            
            NSDictionary *currentDeployment = [self getValueFrom:rawDevicegroup withKey:@"current_deployment"];
            
            if (currentDeployment != nil)
            {
                // Get the deployment
                
                [ide getDeployment:[self getValueFrom:currentDeployment withKey:@"id"] :source];
                
                // Pick up the action at 'productToProjectStageThree:'
            }
            else
            {
                // Device group has no current deployment so just run an upload
                
                [self uploadCode:nil];
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateCodeStageTwo:)"] :YES];
    }
}



- (void)uploadCodeStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a deployment has been created
    // It updates the local records with post-upload data, eg. SHA
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *response = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    NSString *action = [source objectForKey:@"action"];
    
    // Get the code SHA and updated date and add to the updated device groups's two models
    
    NSString *sha = [self getValueFrom:response withKey:@"sha"];
    NSString *updated = [self getValueFrom:response withKey:@"updated_at"];
    if (updated == nil) updated = [self getValueFrom:response withKey:@"created_at"];
    
    for (Model *model in devicegroup.models)
    {
        model.sha = sha;
        model.updated = updated;
    }
    
    // Mark the updated device group's parent product as changed
    
    Project *project = [self getParentProject:devicegroup];
    project.haschanged = YES;
    
    if (project == currentProject)
    {
        iwvc.project = currentProject;
        [saveLight needSave:YES];
    }
    
    // Mark the devicegroup as uploaded
    
    devicegroup.squinted = devicegroup.squinted | 0x08;
    
    if (action != nil)
    {
        if ([action compare:@"uploadproject"] == NSOrderedSame)
        {
            // Decrement the count of uploaded deployments
            
            --project.count;
            
            if (project.count == 0)
            {
                // All done! Refresh the products list
                
                // REMOVED IN 2.3.128 (already handled in 'createProductStageTwo:')
                // NSDictionary *dict = @{ @"action" : @"getproducts" };
                // [ide getProducts:dict];
                // [self writeStringToLog:@"Refreshing product list." :YES];
                // Pick up the action at 'listProducts:'
                
                [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" uploaded to impCloud. Please save your project file.", project.name] :YES];
            }
        }
        else
        {
            [self writeStringToLog:[NSString stringWithFormat:@"Code uploaded to device group \"%@\". Restart its assigned device(s) to run the new code.", devicegroup.name] :YES];
            [self updateDevicegroup:devicegroup];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (uploadCodeStageTwo:)"] :YES];
    }
}



- (void)showCodeErrors:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess signalling
    // that there are errors in uploaded code - which this method displays
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSMutableArray *errors = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    
    if (errors.count > 0)
    {
        [self writeErrorToLog:@"The impCloud reported the following syntax errors in your code:" :YES];
        [self writeErrorToLog:@" " :NO];
        
        // Run through each of the errors
        
        for (NSArray *error in errors)
        {
            // Extract the reported line and column number
            // NOTE 'err' is a dictionary defined by BuildAPIAccess
            
            NSDictionary *err = [error objectAtIndex:0];
            NSUInteger row = [[err objectForKey:@"row"] integerValue];
            NSUInteger col = [[err objectForKey:@"column"] integerValue];
            NSString *filename = [err objectForKey:@"file"];
            NSArray *parts = [filename componentsSeparatedByString:@"_"];
            filename = [parts objectAtIndex:0];
            
            [self writeErrorToLog:[NSString stringWithFormat:@"Error in %@ code: %@ (line %lu, column %lu)", filename, [err objectForKey:@"text"], (unsigned long)row, (unsigned long)col] :NO];
            
            // Get the line of code from the relevant model and display it
            
            for (Model *model in devicegroup.models)
            {
                if ([model.type compare:filename] == NSOrderedSame) [self listCode:model.code :row - 5 :row + 5 :row :col];
            }
        }
    }
}



#pragma mark API Called Device Methods

- (void)listDevices:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER loading a list of devices
    // This list may have been request by many methods — check the source object's 'action' key to find out
    // which flow we need to run here
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSArray *devices = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"deleteproduct"] == NSOrderedSame)
        {
            // Perform the delete product flow. All we are doing here is checking the
            // number devices being provided for one of a product's device groups so we
            // can decide whether we need to halt the deletion process, ie. the presence
            // of assigned devices means the devicegroup deletion will fail
            
            NSMutableDictionary *productToDelete = [source objectForKey:@"product"];
            NSDictionary *product = [productToDelete objectForKey:@"product"];
            NSNumber *number = [productToDelete objectForKey:@"count"];
            NSInteger count = number.integerValue;
            
            // First check if we've already discovered the presence of devices
            // If we have, there's no need to proceed — just bail out
            
            if (count == kDoneChecking) return;
            
            // Does the device group have any devices? If so we can't proceed
            
            if (devices != nil && devices.count > 0)
            {
                // The device group has devices, so the API won't let us delete the devcie group and thus the product
                
                // Set the count to doneChecking so that other calls to this method (which are async) will bail
                
                [productToDelete setObject:[NSNumber numberWithInteger:kDoneChecking] forKey:@"count"];
                
                NSDictionary *devicegroup = [source objectForKey:@"devicegroup"];
                
                [self writeWarningToLog:[NSString stringWithFormat:@"Product \"%@\" can't be deleted because device group \"%@\" has devices assigned. Aborting delete.", [self getValueFrom:product withKey:@"name"], [self getValueFrom:devicegroup withKey:@"name"]] :YES];
            }
            else
            {
                // This device group has no devices. Have we checked all the other device groups?
                // The key 'count' decrements as each device group is checked
                // NOTE 'count' will already be zero if there were no device groups to begin with
                
                --count;
                
                if (count <= 0)
                {
                    // We've checked all the device groups and we're good to delete them
                    
                    [self deleteProductStageTwo:productToDelete];
                }
                else
                {
                    // Decrement the device group count and continue until we get to the last one
                    
                    [productToDelete setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
                }
            }
            
            return;
        }
        
        if ([action compare:@"showdevicegroupinfo"] == NSOrderedSame)
        {
            // This is the async handler for 'showDevicegroupInfo:'
            
            if (devices.count > 0)
            {
                NSString *line = @"";
                
                if (devices.count == 1)
                {
                    line = [NSString stringWithFormat:@"1 device assigned to this Device Group: %@", [self getValueFrom:[devices objectAtIndex:0] withKey:@"name"]];
                }
                else
                {
                    line = [NSString stringWithFormat:@"%li devices assigned to this Device Group: ", devices.count];
                    NSString *devs = @"";
                    
                    for (NSUInteger i = 0 ; i < devices.count ; ++i)
                    {
                        NSDictionary *dict = [devices objectAtIndex:i];
                        devs = [devs stringByAppendingFormat:@"%@, ", [self getValueFrom:dict withKey:@"name"]];
                    }
                    
                    // Remove final ", "
                    
                    devs = [devs substringFromIndex:devs.length - 2];
                    line = [line stringByAppendingString:devs];
                }
                
                [self writeStringToLog:line :YES];
            }
            else
            {
                [self writeStringToLog:@"This Device Group has no devices assigned to it." :YES];
            }
            
            return;
        }
        
        if ([action compare:@"gettestblesseddevices"] == NSOrderedSame)
        {
            [self listBlessedDevices:devices :[source objectForKey:@"devicegroup"]];
            return;
        }
        
        if ([action compare:@"getdevices"] == NSOrderedSame)
        {
            // Initialise or clear the current list of devices then prep to add the incoming list
            
            if (devicesArray == nil)
            {
                devicesArray = [[NSMutableArray alloc] init];
            }
            else
            {
                [devicesArray removeAllObjects];
            }
            
            action = @"adddevices";
        }
        
        if ([action compare:@"adddevices"] == NSOrderedSame)
        {
            // Add all the incoming devices to the list
            // Creata a mutable version of the 'device' NSDictionary so we can amend the name
            // in the local record. We do this here because all further menus derive from this
            
            for (NSDictionary *device in devices)
            {
                // Only list development devices
                
                NSString *dtype = [device valueForKeyPath:@"relationships.devicegroup.type"];
                if ((NSNull *)dtype == [NSNull null]) dtype = nil;
                
                if (dtype == nil || (![dtype hasPrefix:@"pro"] && ![dtype hasPrefix:@"pre-p"] && ![dtype hasPrefix:@"pre-du"] && ![dtype hasPrefix:@"dut"]))
                {
                    // Construct a dictionary for each device derived from the fixed data returned by the server.
                    // The inner dictionary, 'attributes' is converted to a mutable dictionary
                    
                    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[device objectForKey:@"attributes"]];
                    NSString *name = [self getValueFrom:device withKey:@"name"];
                    
                    if (name == nil || ((NSNull *)name == [NSNull null]))
                    {
                        // Name is nil or missing, so use its ID instead, replacing the empty
                        // value (locally) with the new, ID-based name
                        
                        name = [self getValueFrom:device withKey:@"id"];
                        [attributes setObject:name forKey:@"name"];
                    }
                    
                    NSMutableDictionary *newDevice = [[NSMutableDictionary alloc] init];
                    [newDevice setObject:[device objectForKey:@"id"] forKey:@"id"];
                    [newDevice setObject:[device objectForKey:@"type"] forKey:@"type"];
                    [newDevice setObject:attributes forKey:@"attributes"];
                    [newDevice setObject:[device objectForKey:@"relationships"] forKey:@"relationships"];
                    
                    // Finally, add modified (or not) device to current list of devices
                    
                    [devicesArray addObject:newDevice];
                    
                    NSDictionary *dict = @{ @"action" : @"getdevice",
                                            @"device" : newDevice };
                    
                    [ide getDevice:[newDevice objectForKey:@"id"] :dict];
                    
                    // Pick up the action at 'updateDevice:'
                }
                else
                {
                    NSLog(@"Non-development device type: %@", dtype);
                }
            }
            
            // Sort the devices list by device name (inside the 'attributes' dictionary)
            
            NSComparator compareNames = ^(id dev1, id dev2)
            {
                NSString *n1 = [self getValueFrom:dev1 withKey:@"name"];
                NSString *n2 = [self getValueFrom:dev2 withKey:@"name"];
                return [n1 caseInsensitiveCompare:n2];
            };
            
            [devicesArray sortUsingComparator:compareNames];
        }
        
        // Add device IDs to open projects' device groups 'devices' property
        
        if (projectArray.count > 0)
        {
            for (Project *project in projectArray)
            {
                if (project.devicegroups.count > 0)
                {
                    for (Devicegroup *devicegroup in project.devicegroups)
                    {
                        if (devicegroup.devices == nil)
                        {
                            devicegroup.devices = [[NSMutableArray alloc] init];
                        }
                        else
                        {
                            [devicegroup.devices removeAllObjects];
                        }
                        
                        for (NSDictionary *device in devicesArray)
                        {
                            // Get the ID of the device's host device group
                            
                            NSDictionary *relationships = [device objectForKey:@"relationships"];
                            NSDictionary *devgrp = [relationships objectForKey:@"devicegroup"];
                            NSString *devgrpid = [devgrp objectForKey:@"id"];
                            
                            // Just check for a nil device group ID - to avoid unassigned devices
                            
                            if (devgrpid != nil)
                            {
                                // If the ID of the device's host device group matches that of the iterated device group ('devicegroup')
                                // then add the device's own ID to 'devicegroup's list of devices
                                
                                if ([devgrpid compare:devicegroup.did] == NSOrderedSame) [devicegroup.devices addObject:[device objectForKey:@"id"]];
                            }
                        }
                    }
                }
            }
        }
        
        [self writeStringToLog:@"List of devices loaded: see 'Current Device' and 'Devices' > 'Unassigned Devices'." :YES];
        
        // Update the UI
        // NOTE Because we have just updated the device list, we need to refresh it with refreshDevicesPopup and refreshDeviceMenu
        //      rather than just change the popup's selection
        
        [self refreshDevicesPopup];
        [self refreshDeviceMenu];
        [self refreshDevicegroupMenu];
        [self setToolbar];
        
        // Update the Inspector
        
        if (loggedDevices == nil) loggedDevices = [[NSMutableArray alloc] init];
        iwvc.loggingDevices = loggedDevices;
        iwvc.device = selectedDevice;
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (listDevices:)"] :YES];
    }
}



- (void)listBlessedDevices:(NSArray *)devices :(Devicegroup *)devicegroup
{
    // This method presents a tabulated list of the devices in a pre-production device group
    
    if (devices.count == 0)
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" contains no test production devices.", devicegroup.name] :YES];
        return;
    }
    
    __block NSString *titleString = [NSString stringWithFormat:@"Device group \"%@\" test production devices:", devicegroup.name];
    __block NSString *lineString = @"+-----------------------------------------------------------------------+";
    __block NSString *headString = @"| Device ID         |  MAC Address        |  Enrolled                   |";
    __block NSString *midString =  @"+-------------------+---------------------+-----------------------------+";
    
    [extraOpQueue addOperationWithBlock:^(void){
        
        [self performSelectorOnMainThread:@selector(logLogs:)
                               withObject:[NSString stringWithFormat:@"\n%@\n%@\n%@\n%@", titleString, lineString, headString, midString]
                            waitUntilDone:NO];
        
        for (NSDictionary *device in devices)
        {
            NSString *enrolled = @"Unknown                   ";
            NSDate *enrolDate = [self getValueFrom:device withKey:@"last_enrolled_at"];
            
            if (enrolDate != nil)
            {
                enrolled = [self convertDate:enrolDate];
                enrolled = [enrolled stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
                enrolled = [enrolled stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
            }
            
            NSString *line = [NSString stringWithFormat:@"| %@  |  %@  |  %@ |", [self getValueFrom:device withKey:@"id"],
                              [self getValueFrom:device withKey:@"mac_address"], enrolled];
            
            [self performSelectorOnMainThread:@selector(logLogs:)
                                   withObject:line
                                waitUntilDone:NO];
        }
        
        [self performSelectorOnMainThread:@selector(logLogs:)
                               withObject:lineString
                            waitUntilDone:NO];
    }];
}



- (void)updateDevice:(NSNotification *)note
{
    // We're back after getting a list of devices from the server,
    // and then, for each one, getting the single-device record,
    // which contains extra fields that we add to the main 'deviceArray'
    // record here
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *device = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSMutableDictionary *aDevice = [source objectForKey:@"device"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        NSMutableDictionary *attributes = [aDevice objectForKey:@"attributes"];
        
        if ([action compare:@"refreshdevice"] == NSOrderedSame)
        {
            // Update the existing record's status with the new info
            
            NSNumber *boolean = [self getValueFrom:device withKey:@"device_online"];
            [attributes setObject:boolean forKey:@"device_online"];
            
            if (aDevice == selectedDevice) iwvc.device = aDevice;
            
            ++deviceCheckCount;
            
            // NSLog(@"Device %li of %li", (long)deviceCheckCount, (long)devicesArray.count);
            
            if (deviceCheckCount == devicesArray.count)
            {
                // All done so update the UI and set the not-checking marker
                
                deviceCheckCount = -1;
                
                [self refreshDevicesMenus];
                [self refreshDevicesPopup];
                //if (projectArray.count > 0) [self refreshDevicesMenus];
                
                if (ide.numberOfConnections < 1)
                {
                    // Only hide the connection indicator if 'ide' has no live connections
                    
                    [connectionIndicator stopAnimation:self];
                    connectionIndicator.hidden = YES;
                }
            }
            
            return;
        }
        
        // The following is only executed on action 'getdevice'
        
        NSString *version = [self getValueFrom:device withKey:@"swversion"];
        if (version != nil) [attributes setObject:version forKey:@"swversion"];
        
        version = [self getValueFrom:device withKey:@"plan_id"];
        if (version != nil) [attributes setObject:version forKey:@"plan_id"];
        
        NSNumber *free = [self getValueFrom:device withKey:@"free_memory"];
        if (free != nil) [attributes setObject:free forKey:@"free_memory"];
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateDevice:)"] :YES];
    }
}



- (void)restarted:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device or devices have restarted
    // It is called in response to 'restartDevice:' and 'restartDevices:'
    // The former passes in 'selectedDevice'; the latter 'currentDevicegroup'
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"restartdevice"] == NSOrderedSame)
        {
            // The returned entity is a device - we originally called 'restartDevice:'
            
            NSDictionary *device = [source objectForKey:@"device"];
            [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" has restarted.", [self getValueFrom:device withKey:@"name"]] :YES];
        }
        else
        {
            // The returned entity is a device group - we originally called 'restartDevices:'
            
            Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
            
            NSString *fString = ([action compare:@"conrestartdevice"] == NSOrderedSame)
            ? @"The devices assigned to device group \"%@\" have conditionally restarted."
            : @"The devices assigned to device group \"%@\" have restarted.";
            
            [self writeStringToLog:[NSString stringWithFormat:fString, devicegroup.name] :YES];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (restarted:)"] :YES];
    }
}



- (void)reassigned:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device has been reassigned to a different device group
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    NSDictionary *device = [source objectForKey:@"device"];
    
    if (action != nil)
    {
        if ([action compare:@"unassigndevice"] == NSOrderedSame)
        {
            // We're here after a device unassign operation
            // In this case ONLY, the returned data's 'data' key will be a string
            // indicating the performed action
            
            NSString *result = [data objectForKey:@"data"];
            
            [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" %@.", [self getValueFrom:device withKey:@"name"], result] :YES];
        }
        else
        {
            // We're here after a device assign/re-asssign operation
            // In this case ONLY, the returned data's 'data' key will be a dictionary
            
            Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
            
            [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" assigned to device group \"%@\".", [self getValueFrom:device withKey:@"name"], devicegroup.name] :YES];
        }
        
        // Update the device lists to reflect the change - this will update UI
        
        [self updateDevicesStatus:nil];
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (reassigned:)"] :YES];
    }
}



- (void)renameDeviceStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device has been renamed
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    
    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" renamed \"%@\".", [source objectForKey:@"old"], [source objectForKey:@"new"]] :YES];
    
    // Make sure the device is not being listed in the Inspector and elsewhere
    
    selectedDevice = nil;
    iwvc.device = nil;
    
    // Now refresh the devices list to get the new name
    // TODO Probably just need to get this one device's info
    
    [self updateDevicesStatus:nil];
}



- (void)deleteDeviceStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device has been deleted
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSDictionary *device = [source objectForKey:@"device"];
    
    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" removed from your account.", [self getValueFrom:device withKey:@"name"]] :YES];
    
    // If the selected device is the one we've just delete - likely it is
    
    if (selectedDevice == device)
    {
        selectedDevice = nil;
        iwvc.device = nil;
    }
    
    // Now refresh the devices list
    
    [self updateDevicesStatus:nil];
}



- (void)setMinimumDeploymentStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a minimum deployment has been set
    // 'note' contains a deployment record at the key 'data', but we don't use it here
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    if (action != nil)
    {
        if ([action compare:@"setmindeploy"] == NSOrderedSame)
        {
            Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
            Project *project = [self getParentProject:devicegroup];
            
            // Re-acquire the device group data from the server so we have up-to-date info locally
            
            [self updateDevicegroup:devicegroup];
            
            [self writeStringToLog:[NSString stringWithFormat:@"Minimum deployment set for project \"%@\"'s device group \"%@\".", project.name, devicegroup.name] :YES];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (setMinimumDeploymentStageTwo:)"] :YES];
    }
}



#pragma mark API Called Misc Methods

- (void)displayError:(NSNotification *)note;
{
    // Called in response to a notification from BuildAPIAccess that an error occurred
    
    NSDictionary *error = (NSDictionary *)note.object;
    NSString *errorMessage = [error objectForKey:@"message"];
    NSNumber *code = [error objectForKey:@"code"];
    NSInteger errorCode = [code integerValue];
    
    if (isLoggingIn)
    {
        // We are attempting to log in, so the error should relate to that action, ie.
        // most likely a failed connection, or missing or rejected credentials
        
        BOOL flag = NO;
        
        if (saveDetailsCheckbox.state == NSOnState && errorCode == kErrorNetworkError)
        {
            // User has indicated they want the credentials saved for next time
            // NOTE only save the credentials if we were unable to connect, ie. ignore rejected credentials
            
            PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
            NSString *untf = usernameTextField.stringValue;
            NSString *pwtf = passwordTextField.stringValue;
            
            // Compare the entered value with the existing value - only overwrite if they are different
            
            NSString *cs = [pc stringForKey:@"com.bps.Squinter.ak.notional.tully"];
            
            cs = (cs == nil) ? @"" : [ide decodeBase64String:cs];
            
            if ([cs compare:untf] != NSOrderedSame)
            {
                [pc setString:[ide encodeBase64String:untf] forKey:@"com.bps.Squinter.ak.notional.tully"];
                flag = YES;
            }
            
            cs = [pc stringForKey:@"com.bps.Squinter.ak.notional.tilly"];
            
            cs = (cs == nil) ? @"" : [ide decodeBase64String:cs];
            
            if ([cs compare:pwtf] != NSOrderedSame)
            {
                [pc setString:[ide encodeBase64String:pwtf] forKey:@"com.bps.Squinter.ak.notional.tilly"];
                flag = YES;
            }
            
            if (flag) [self writeStringToLog:@"impCloud credentials saved in your keychain." :YES];
        }
        
        // Notify the user
        
        if (errorCode == kErrorNetworkError)
        {
            [self writeErrorToLog:@"[LOGIN ERROR] Could not access the Electric Imp impCloud. Please check your network connection." :YES];
        }
        else if (errorCode == kErrorLoginRejectCredentials)
        {
            [self writeErrorToLog:@"[LOGIN ERROR] Your impCloud access credentials have been rejected. Please check your username and password." : YES];
        }
        else
        {
            [self writeErrorToLog:[NSString stringWithFormat:@"[LOGIN ERROR] %@", errorMessage] : YES];
        }
        
        // Register that we are no longer trying to log in
        
        isLoggingIn = NO;
    }
    else
    {
        // The error was not specifically related to log in
        
        [self writeErrorToLog:errorMessage :YES];
        
        // Just in case we are attemmpting to log stream from the current device
        
        streamLogsItem.state = 0;
        [squinterToolbar validateVisibleItems];
    }
}



- (void)listCommits:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess with a list of deployments made to a device group
    // The commits are in 'note.data' under the key 'data'
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];
    
    __block Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    __block NSMutableArray *deployments = [data objectForKey:@"data"];
    
    if (action != nil)
    {
        if ([action compare:@"getcommits"] == NSOrderedSame)
        {
            // This is the result of a request to get commits so they can be presented
            // in the Commit Panel (cwvc)
            
            cwvc.commits = deployments;
            return;
        }
        
        if ([action compare:@"downloadproduct"] == NSOrderedSame)
        {
            // This is the result of a request to get commits so that the most recent one
            // can be extracted to get the code for a newly downloaded device group that
            // has no 'current_deployment' key its record
            
            [self getCurrentDeployment:data];
            return;
        }
        
        // Assume from this point, action is "listcommits"
        
        devicegroup.history = deployments;
        
        if (deployments.count > 0)
        {
            [extraOpQueue addOperationWithBlock:^(void){
                
                /* NSString *lineString = [@"" stringByPaddingToLength:74 withString:@"-" startingAtIndex:0];
                 
                 [self performSelectorOnMainThread:@selector(logLogs:)
                 withObject:lineString
                 waitUntilDone:NO];
                 */
                
                NSString *headString = [NSString stringWithFormat:@"Most recent commits to Device Group \"%@\":", devicegroup.name];
                
                [self performSelectorOnMainThread:@selector(logLogs:)
                                       withObject:headString
                                    waitUntilDone:NO];
                
                NSDictionary *min = [self getValueFrom:devicegroup.data withKey:@"min_supported_deployment"];
                NSString *mid = min != nil ? [min objectForKey:@"id"] : @"";
                
                NSDictionary *cur = [self getValueFrom:devicegroup.data withKey:@"current_deployment"];
                NSString *cid = cur != nil ? [cur objectForKey:@"id"] : @"";
                
                for (NSUInteger i = deployments.count ; i > 0 ; --i)
                {
                    NSDictionary *deployment = [deployments objectAtIndex:(i - 1)];
                    NSString *sha = [self getValueFrom:deployment withKey:@"sha"];
                    NSString *message = [self getValueFrom:deployment withKey:@"description"];
                    NSString *timestamp = [self formatTimestamp:[self getValueFrom:deployment withKey:@"created_at"]];
                    NSString *origin = [self getValueFrom:deployment withKey:@"origin"];
                    NSArray *tags = [self getValueFrom:deployment withKey:@"tags"];
                    NSString *tagString = @"";
                    
                    if (tags != nil && tags.count > 0)
                    {
                        // List tags out separted by commas
                        
                        for (NSString *tag in tags) tagString = [tagString stringByAppendingFormat:@"%@, ", tag];
                        tagString = [tagString substringToIndex:tagString.length - 2];
                    }
                    
                    NSString *ns = [NSString stringWithFormat:@"%03lu. ", (deployments.count - i + 1)];
                    NSString *ss = [@"                               " substringToIndex:ns.length + 2];
                    NSString *cs;
                    
                    if (message != nil && message.length > 0)
                    {
                        cs = [NSString stringWithFormat:@"%@%@\n%@When: %@", ns, message, ss, timestamp];
                    }
                    else
                    {
                        cs = [NSString stringWithFormat:@"%@When: %@", ns, timestamp];
                    }
                    
                    if (sha != nil)  cs = [cs stringByAppendingFormat:@"\n%@SHA: %@", ss, sha];
                    if (origin != nil && origin.length > 0) cs = [cs stringByAppendingFormat:@"\n%@Origin: %@", ss, origin];
                    if (tagString.length > 0) cs = [cs stringByAppendingFormat:@"\n%@Tags: %@", ss, tagString];
                    
                    // Record whether the current entry is the min. supported deployment or the current
                    
                    bool flag = NO;
                    
                    if (mid.length > 0 || cid.length > 0)
                    {
                        NSString *did = [deployment objectForKey:@"id"];
                        if ([did compare:mid] == NSOrderedSame)
                        {
                            cs = [cs stringByAppendingFormat:@"\n%@MINIMUM SUPPORTED DEPLOYMENT", ss];
                            flag = YES;
                        }
                        
                        if ([did compare:cid] == NSOrderedSame)
                        {
                            cs = [cs stringByAppendingFormat:@"\n%@CURRENT DEPLOYMENT", ss];
                            flag = YES;
                        }
                    }
                    
                    cs = [cs stringByAppendingString:@"\n"];
                    
                    // Add a prefix to indicate min. supported deployment and/or current deployment
                    
                    cs = flag ? [@"* " stringByAppendingString:cs] : [@"  " stringByAppendingString:cs];
                    
                    [self performSelectorOnMainThread:@selector(logLogs:)
                                           withObject:cs
                                        waitUntilDone:NO];
                }
                
                /*
                 [self performSelectorOnMainThread:@selector(logLogs:)
                 withObject:lineString
                 waitUntilDone:NO];
                 */
            }];
        }
        else
        {
            [self writeWarningToLog:[NSString stringWithFormat:@"No commits have yet been made to device group \"%@\".", devicegroup.name] :YES];
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (listCommits:)"] :YES];
    }
}



- (void)listLogs:(NSNotification *)note
{
    // We come here in response to a notification from BuildAPIAccess
    // The notification contains a list of log entries or a list of device history events -
    // we sort one from the other by looking at the 'action' value
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    
    __block NSDictionary *device = [source objectForKey:@"device"];
    __block NSString *action = [source objectForKey:@"action"];
    __block NSMutableArray *theLogs = [data objectForKey:@"data"];
    
    // Shouldn't need to trap for failure (device == nil) as we only get the selected device
    // to acquire its name; this method wouldn't have been called if there *hadn't* been
    // a device selected
    
    if (theLogs.count > 0)
    {
        [extraOpQueue addOperationWithBlock:^(void){
            
            NSMutableArray *lines = [[NSMutableArray alloc] init];
            
            if ([action compare:@"gethistory"] == NSOrderedSame)
            {
                // Iterate through the history entries, rendering them as lines of text
                
                [lines addObject:[NSString stringWithFormat:@"History of device \"%@\":", [self getValueFrom:device withKey:@"name"]]];
                
                for (NSUInteger i = theLogs.count ; i > 0  ; --i)
                {
                    NSDictionary *entry = [theLogs objectAtIndex:(i - 1)];
                    NSString *timestamp = [self formatTimestamp:[entry objectForKey:@"timestamp"]];
                    NSString *event = [entry objectForKey:@"event"];
                    NSString *owner = [entry objectForKey:@"owner_id"];
                    NSString *actor = [entry objectForKey:@"actor_id"];
                    NSString *doer = ([owner compare:actor] == NSOrderedSame) ? @"you." : @"someone else.";
                    NSString *lString = [NSString stringWithFormat:@"%@ Device %@ by %@", timestamp, event, doer];
                    
                    [lines addObject:lString];
                }
            }
            else
            {
                // Iterate through the log entries, rendering them as lines of text
                
                [lines addObject:[NSString stringWithFormat:@"Latest log entries for device \"%@\":",[self getValueFrom:device withKey:@"name"]]];
                
                // Calculate the width of the widest status message for spacing the output into columns
                
                NSUInteger width = 0;
                
                for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
                {
                    NSDictionary *aLog = [theLogs objectAtIndex:i];
                    NSString *type = [aLog objectForKey:@"type"];
                    type = [self recodeLogTags:[NSString stringWithFormat:@"[%@]", type]];
                    if (type.length > width) width = type.length;
                }
                
                for (NSUInteger i = theLogs.count ; i > 0  ; --i)
                {
                    NSDictionary *entry = [theLogs objectAtIndex:(i - 1)];
                    NSString *timestamp = [self formatTimestamp:[entry objectForKey:@"ts"]];
                    
                    NSString *type = [entry objectForKey:@"type"];
                    type = [self recodeLogTags:[NSString stringWithFormat:@"[%@]", type]];
                    NSString *msg = [entry objectForKey:@"msg"];
                    
                    NSString *spacer = [@"                              " substringToIndex:width + 1 - type.length];
                    NSString *lString = [NSString stringWithFormat:@"%@ %@%@%@", timestamp, type, spacer, msg];
                    
                    [lines addObject:lString];
                }
            }
            
            [self performSelectorOnMainThread:@selector(writeLinesToLog:) withObject:lines waitUntilDone:YES];
            
            // Look for URLs etc one all the items have gone in
            
            [self performSelectorOnMainThread:@selector(parseLog)
                                   withObject:nil
                                waitUntilDone:NO];
        }];
    }
    else
    {
        NSString *items = ([action compare:@"gethistory"] == NSOrderedSame) ? @"history" : @"logs";
        
        [self writeStringToLog:[NSString stringWithFormat:@"There are no %@ entries for device \"%@\"", items, [self getValueFrom:device withKey:@"name"]] :YES];
    }
}



- (void)gotLibraries:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER loading a list of devices
    // This list may have been request by many methods — check the source object's 'action' key to find out
    // which flow we need to run here
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSArray *libs = [data objectForKey:@"data"];
    
    NSString *eilibs = @"";
    NSInteger count = 0;
    
    for (NSDictionary *lib in libs)
    {
        NSString *name = [lib valueForKeyPath:@"attributes.name"];
        
        if ([name hasPrefix:@"private:"]) break;
        
        bool supported = [lib valueForKeyPath:@"attributes.supported"];
        NSString *latest;
        
        if (supported)
        {
            NSArray *versions = [lib valueForKeyPath:@"relationships.versions"];
            NSDictionary *version = [versions objectAtIndex:0];
            latest = [version objectForKey:@"id"];
            NSArray *parts = [latest componentsSeparatedByString:@":"];
            latest = [parts objectAtIndex:1];
        }
        else
        {
            latest = @"dep";
        }
        
        name = [name stringByAppendingFormat:@",%@\n", latest];
        eilibs = [eilibs stringByAppendingString:name];
        count++;
    }
    
    eiLibListData = [NSMutableData dataWithData:[eilibs dataUsingEncoding:NSUTF8StringEncoding]];
    
    // Check all of the cached devicegroups
    
    for (Devicegroup *devicegroup in eiDeviceGroupCache)
    {
        [self compareElectricImpLibs:devicegroup];
    }
}



#pragma mark API Called Logging Methods

- (void)loggingStarted:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device has been added to the log stream
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSString *deviceID = [data objectForKey:@"device"];
    NSDictionary *device;
    
    // The returned data includes the device's ID,
    // so use that to find the device in the device array
    
    for (NSDictionary *aDevice in devicesArray)
    {
        NSString *aDeviceID = [aDevice objectForKey:@"id"];
        
        if ([aDeviceID compare:deviceID] == NSOrderedSame)
        {
            device = aDevice;
            break;
        }
    }
    
    // Add the device to the list of logging devices
    
    if (loggedDevices == nil) loggedDevices = [[NSMutableArray alloc] init];
    
    if (loggedDevices.count < kMaxLogStreamDevices)
    {
        [loggedDevices addObject:deviceID];
    }
    else
    {
        NSInteger index = -1;
        
        for (NSInteger i = 0 ; i < loggedDevices.count ; ++i)
        {
            NSString *aDeviceID = [loggedDevices objectAtIndex:i];
            
            if ([aDeviceID compare:@"FREE"] == NSOrderedSame)
            {
                index = i;
                break;
            }
        }
        
        if (index != -1)
        {
            [loggedDevices replaceObjectAtIndex:index withObject:deviceID];
        }
        else
        {
            NSLog(@"loggedDevices index error in loggingStarted:");
        }
    }
    
    // Inform the user
    
    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" added to log stream", [self getValueFrom:device withKey:@"name"]] :YES];
    
    // Update the UI: add logging marks to menus, colour to the toolbar item,
    // and set the menu item's text and state; set the Inspector
    
    iwvc.loggingDevices = loggedDevices;
    
    if (device == selectedDevice)
    {
        streamLogsItem.state = kStreamToolbarItemStateOn;
        streamLogsMenuItem.title = @"Stop Log Streaming";
        iwvc.device = selectedDevice;
    }
    
    [streamLogsItem validate];
    [self refreshDevicesMenus];
    [self refreshDevicesPopup];
}



- (void)loggingStopped:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a device has been removed from the log stream
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSString *dvid = [data objectForKey:@"device"];
    NSDictionary *device;
    
    // The returned data includes the device's ID,
    // so use that to find the device in the device array
    
    for (NSDictionary *aDevice in devicesArray)
    {
        NSString *advid = [aDevice objectForKey:@"id"];
        
        if ([advid compare:dvid] == NSOrderedSame)
        {
            device = aDevice;
            break;
        }
    }
    
    // Remove the device from the list of logging devices WITHOUT eliminating its index
    
    if (loggedDevices.count == 1)
    {
        // Only one device on the list which will now be removed,
        // so we don't need to replace it, just empty the array
        
        [loggedDevices removeAllObjects];
    }
    else
    {
        NSInteger index = -1;
        
        for (NSInteger i = 0 ; i < loggedDevices.count ; i++)
        {
            NSString *advid = [loggedDevices objectAtIndex:i];
            
            if ([advid compare:dvid] == NSOrderedSame)
            {
                index = i;
                break;
            }
        }
        
        if (index != -1)
        {
            [loggedDevices replaceObjectAtIndex:index withObject:@"FREE"];
        }
        else
        {
            NSLog(@"loggedDevices index error in loggingStopped:");
        }
    }
    
    // Inform the user
    
    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" removed from log stream", [self getValueFrom:device withKey:@"name"]] :YES];
    
    // Update the UI: remove logging marks, re-colour to the toolbar item,
    // and set the menu item's text and state, including the inspector
    
    iwvc.loggingDevices = loggedDevices;
    
    if (device == selectedDevice)
    {
        streamLogsItem.state = kStreamToolbarItemStateOff;
        streamLogsMenuItem.title = @"Start Log Streaming";
        iwvc.device = selectedDevice;
    }
    
    [streamLogsItem validate];
    [self refreshDevicesMenus];
    [self refreshDevicesPopup];
}



- (void)presentLogEntry:(NSNotification *)note
{
    // Decode a streamed log entry relayed from BuildAPIAccess
    // Log entry formats:
    // @"232390b030728cee 2017-05-19T17:28:19.095Z development server.log Connected by WiFi on SSID \"darkmatter\" with IP address 192.168.0.2"
    // @"subscribed 232390b030728cee"
    
    NSDictionary *data = (NSDictionary *)note.object;
    NSString *logItem = [data objectForKey:@"message"];
    NSArray *parts = [logItem componentsSeparatedByString:@" "];
    
    if (parts.count > 2)
    {
        // Indicates the first of the message formats listed above, ie.
        // {device ID} {timestamp} {log type} {event type} {message}
        // NOTE {message} comprises the remaining parts of the string
        
        NSUInteger width = 11;
        NSColor *logColour;
        NSString *device;
        NSString *log;
        
        NSString *type = [parts objectAtIndex:3];
        NSString *stype = [NSString stringWithFormat:@"[%@]", type];
        stype = [self recodeLogTags:stype];
        
        NSString *timestamp = [parts objectAtIndex:1];
        timestamp = [outLogDef stringFromDate:[inLogDef dateFromString:timestamp]];
        timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
        timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
        
        if (stype.length > width) width = stype.length;
        
        NSString *spacer = [@"                                      " substringToIndex:width - stype.length];
        NSString *dvid = [parts objectAtIndex:0];
        
        for (NSDictionary *dev in devicesArray)
        {
            NSString *adid = [dev objectForKey:@"id"];
            
            if ([dvid compare:adid] == NSOrderedSame)
            {
                device = [self getValueFrom:dev withKey:@"name"];
                break;
            }
        }
        
        // Get the index of the entry's device in the loggedDevices array.
        // We will use this to get correct logging colour
        
        NSUInteger index = 0;
        
        for (NSInteger i = 0 ; i < loggedDevices.count ; i++)
        {
            NSString *advid = [loggedDevices objectAtIndex:i];
            
            if ([advid compare:dvid] == NSOrderedSame)
            {
                index = i;
                break;
            }
        }
        
        NSRange range = [logItem rangeOfString:type];
        NSString *message = [logItem substringFromIndex:(range.location + type.length + 1)];
        
        if (ide.numberOfLogStreams > 1)
        {
            NSString *subspacer = [@"                                      " substringToIndex:logPaddingLength - device.length];
            log = [NSString stringWithFormat:@"\"%@\"%@: %@ %@%@", device, subspacer, stype, spacer, message];
        }
        else
        {
            log = [NSString stringWithFormat:@"\"%@\": %@ %@%@", device, stype, spacer, message];
        }
        
        log = [timestamp stringByAppendingFormat:@" %@", log];
        logColour = [colors objectAtIndex:index];
        
        [self writeNoteToLog:log :logColour :NO];
    }
}



- (void)endLogging:(NSNotification *)note
{
    // Notification-triggered method called when logging ends because of a connection break
    
    NSString *devid = (NSString *)note.object;
    
    if (selectedDevice != nil)
    {
        NSString *seldevid = [self getValueFrom:selectedDevice withKey:@"id"];
        
        if ([devid compare:seldevid] == NSOrderedSame)
        {
            streamLogsItem.state = kStreamToolbarItemStateOff;
            streamLogsMenuItem.title = @"Start Log Streaming";
        }
        
        [streamLogsItem validate];
        [self refreshDevicesMenus];
        [self refreshDevicesPopup];
    }
}



@end
