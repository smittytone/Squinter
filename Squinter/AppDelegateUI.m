
//  Created by Tony Smith on 2 May 2019.
//  Copyright © 2019 Tony Smith. All rights reserved.


#import "AppDelegateUI.h"


@implementation AppDelegate(AppDelegateUI)


#pragma mark - Projects Menu


- (void)refreshProjectsMenu
{
    // Manages the Projects menu's state,
    // except for the Open Projects submenu (see 'refreshOpenProjectsMenu')
    // and the Current Products submenu (see 'refreshProductsmenu')

    if (currentProject != nil)
    {
        // A project is selected...

        showProjectInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", currentProject.name];
        showProjectFinderMenuItem.title = [NSString stringWithFormat:@"Show “%@” in Finder", currentProject.name];
        renameProjectMenuItem.title = [NSString stringWithFormat:@"Edit “%@”...", currentProject.name];
        syncProjectMenuItem.title = [NSString stringWithFormat:@"Sync “%@”...", currentProject.name];

        if (selectedProduct != nil)
        {
            // ...and a product is selected

            NSString *pName = [self getValueFrom:selectedProduct withKey:@"name"];
            linkProductMenuItem.title = [NSString stringWithFormat:@"Link Product “%@” to Project “%@”", pName, currentProject.name];
        }
        else
        {
            // ...but a product is not

            linkProductMenuItem.title = [NSString stringWithFormat:@"Link Product to Project “%@”", currentProject.name];
        }
    }
    else
    {
        // No project selected...

        showProjectInfoMenuItem.title = @"Show Project Info";
        showProjectFinderMenuItem.title = @"Show Project in Finder";
        renameProjectMenuItem.title = @"Edit Project...";
        syncProjectMenuItem.title = @"Sync Project...";

        if (selectedProduct != nil)
        {
            // ...but a product is selected

            NSString *pName = [self getValueFrom:selectedProduct withKey:@"name"];
            linkProductMenuItem.title = [NSString stringWithFormat:@"Link Product “%@” to Project", pName];
        }
        else
        {
            // ...and neither is a product

            linkProductMenuItem.title = @"Link Product to Project";
        }
    }

    // We only need to update the Projects menu's product-specific entries when a product is chosen

    if (selectedProduct != nil)
    {
        NSString *pName = [self getValueFrom:selectedProduct withKey:@"name"];

        downloadProductMenuItem.title = [NSString stringWithFormat:@"Download “%@”", pName];
        deleteProductMenuItem.title = [NSString stringWithFormat:@"Delete “%@”", pName];
        renameProductMenuItem.title = [NSString stringWithFormat:@"Edit “%@”...", pName];
    }
    else
    {
        downloadProductMenuItem.title = @"Download Product";
        deleteProductMenuItem.title = @"Delete Product";
        renameProductMenuItem.title = @"Edit Product...";
    }

    showProjectInfoMenuItem.enabled = currentProject != nil ? YES : NO;
    showProjectFinderMenuItem.enabled = currentProject != nil ? YES : NO;
    renameProjectMenuItem.enabled = currentProject != nil ? YES : NO;
    downloadProductMenuItem.enabled = selectedProduct != nil ? YES : NO;
    linkProductMenuItem.enabled = currentProject != nil && selectedProduct != nil ? YES : NO;
    deleteProductMenuItem.enabled = selectedProduct != nil ? YES : NO;
    renameProductMenuItem.enabled = selectedProduct != nil ? YES : NO;
    syncProjectMenuItem.enabled = currentProject != nil ? YES : NO;

    // Update the File menu's one changeable item

    fileAddFilesMenuItem.enabled = currentProject != nil ? YES : NO;
}



- (void)refreshOpenProjectsSubmenu
{
    // This method manages the Open projects submenu of the Projects menu
    // It also handles the Projects Popup, which is dynamically titled so we need to
    // rebuild the lot each time

    [openProjectsMenu removeAllItems];
    [projectsPopUp removeAllItems];

    NSMenuItem *item;

    if (projectArray.count > 0)
    {
        // There are projects to list, so add them all to the menu and the pop-up

        for (Project *project in projectArray)
        {
            NSString *name = project.name;
            item = [[NSMenuItem alloc] initWithTitle:name action:@selector(chooseProject:) keyEquivalent:@""];
            item.representedObject = project;
            [openProjectsMenu addItem:item];

            [projectsPopUp addItemWithTitle:name];
            NSMenuItem *subitem = [projectsPopUp itemWithTitle:project.name];
            subitem.representedObject = project;
        }

        if (currentProject != nil)
        {
            // We have a project selected, so mark it as such in the menu and pop-up

            NSMenuItem *selected = [openProjectsMenu itemWithTitle:currentProject.name];

            for (NSMenuItem *anItem in openProjectsMenu.itemArray)
            {
                if (anItem == selected)
                {
                    anItem.state = NSOnState;
                    [projectsPopUp selectItemWithTitle:selected.title];
                    projectsPopUp.selectedItem.title = [NSString stringWithFormat:@"%@/%@", currentProject.name, (currentDevicegroup != nil ? currentDevicegroup.name : @"None")];
                }
                else
                {
                    anItem.state = NSOffState;
                }
            }
        }

        projectsPopUp.enabled = YES;
    }
    else
    {
        // No projects open, so just add 'None' items to the the pop-up

        item = [[NSMenuItem alloc] initWithTitle:@"Create New Project"
                                          action:@selector(newProject:)
                                   keyEquivalent:@""];
        item.enabled = YES;
        item.state = NSOffState;
        [openProjectsMenu addItem:item];

        [projectsPopUp addItemWithTitle:@"None"];
        projectsPopUp.enabled = NO;
    }
}



- (void)refreshProductsMenu
{
    // This method manages the Current Products submenu of the Projects menu
    // It should ONLY be called as a consequence of getting a list of products
    // from the server

    NSMenuItem *item;

    [productsMenu removeAllItems];

    if (productsArray == nil)
    {
        // No product list to display, so add an appropriate action to the menu

        item = [[NSMenuItem alloc] initWithTitle:@"Get Products List"
                                          action:@selector(getProductsFromServer:)
                                   keyEquivalent:@""];
        item.enabled = YES;
        item.state = NSOffState;
        [productsMenu addItem:item];
        return;
    }

    if (productsArray.count == 0)
    {
        // No products in the list, so just add 'None' to the menu

        item = [[NSMenuItem alloc] initWithTitle:@"None"
                                          action:nil
                                   keyEquivalent:@""];
        item.enabled = NO;
        item.state = NSOffState;
        [productsMenu addItem:item];
        return;
    }

    NSMutableArray *sharers = nil;

    for (NSMutableDictionary *aProduct in productsArray)
    {
        // Run through the list of products to see if any contain a 'shared' object

        if (!aProduct[@"shared"])
        {
            // The product doesn't have a 'shared' object, so it belongs to the account holder -
            // just add it to the menu

            NSString *name = [self getValueFrom:aProduct withKey:@"name"];
            item = [[NSMenuItem alloc] initWithTitle:name
                                              action:@selector(chooseProduct:)
                                       keyEquivalent:@""];
            item.representedObject = aProduct;
            item.state = NSOffState;
            [productsMenu addItem:item];
        }
        else
        {
            // The product does have a 'shared' object, so it belongs to another account

            if (sharers == nil) sharers = [[NSMutableArray alloc] init];

            NSMutableDictionary *sharer = [aProduct objectForKey:@"shared"];
            BOOL got = NO;

            if (sharers.count > 0)
            {
                // If we already know about at least one shared account (each one is referenced
                // in 'sharers'), we get its ID and compare it to the creator ID of the current product

                for (NSUInteger i = 0 ; i < sharers.count ; i++)
                {
                    NSMutableDictionary *product = [sharers objectAtIndex:i];
                    NSString *aid = [product objectForKey:@"id"];
                    NSString *mid = [sharer objectForKey:@"id"];
                    if ([aid compare:mid] == NSOrderedSame) got = YES;
                }
            }

            // If we've not seen this product's creator before, add it to 'sharers'

            if (!got) [sharers addObject:sharer];
        }
    }

    if (sharers != nil)
    {
        // Some of the user's products are shared, so set up a sub-menu for these

        [productsMenu addItem:[NSMenuItem separatorItem]];

        item = [[NSMenuItem alloc] initWithTitle:@"Products Shared With You"
                                          action:nil
                                   keyEquivalent:@""];
        NSMenu *sharedMenu = [[NSMenu alloc] initWithTitle:@"Products Shared With You"];
        item.submenu = sharedMenu;

        // Now add the shared products to the sub-menu

        for (NSUInteger i = 0 ; i < sharers.count ; i++)
        {
            NSMutableDictionary *sharer = [sharers objectAtIndex:i];

            // If we have a stored name for the creator account, use it; otherwise use
            // the account ID (which may asynchronously be replaced - see 'gotAnAccount:'

            NSString *name = [sharer objectForKey:@"name"];
            if (name == nil || name.length == 0) name = [sharer objectForKey:@"id"];

            // Add the account name (or ID) to the sub-menu...
            NSMenuItem *aitem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"Account: %@", name]
                                                           action:nil
                                                    keyEquivalent:@""];
            aitem.state = NSOffState;
            aitem.enabled = NO;
            [sharedMenu addItem:aitem];

            // ...now add all of its products

            for (NSMutableDictionary *aProduct in productsArray)
            {
                NSString *sid = [sharer objectForKey:@"id"];

                if (aProduct[@"shared"])
                {
                    NSString *aid = [aProduct valueForKeyPath:@"shared.id"];

                    if ([sid compare:aid] == NSOrderedSame)
                    {
                        NSString *name = [self getValueFrom:aProduct withKey:@"name"];
                        aitem = [[NSMenuItem alloc] initWithTitle:name
                                                           action:@selector(chooseProduct:)
                                                    keyEquivalent:@""];
                        aitem.representedObject = aProduct;
                        aitem.state = NSOffState;
                        [sharedMenu addItem:aitem];
                    }
                }
            }

            // Only add a separator between creators if we haven't just added the last
            // creator on the list

            if (i < sharers.count - 1) [sharedMenu addItem:[NSMenuItem separatorItem]];
        }

        // Add the 'shared with you' menu item with its sub-menu of shared products

        [productsMenu addItem:item];
    }

    // Add the 'update list' command

    [productsMenu addItem:[NSMenuItem separatorItem]];

    item = [[NSMenuItem alloc] initWithTitle:@"Update Products List"
                                      action:@selector(getProductsFromServer:)
                               keyEquivalent:@""];
    item.enabled = YES;
    item.state = NSOffState;
    item.representedObject = nil;
    [productsMenu addItem:item];

    [self setProductsMenuTick];
}



- (void)setProductsMenuTick
{
    // Re-select the existing item or select the first on the list
    // NOTE we do this by comparing IDs because the selected product's
    // reference will have changed if the list was updated

    NSMenuItem *item;

    if (selectedProduct != nil)
    {
        for (item in productsMenu.itemArray)
        {
            if (item.submenu != nil)
            {
                bool shouldClear = YES;

                for (NSMenuItem *sitem in item.submenu.itemArray)
                {
                    if (sitem.representedObject == selectedProduct)
                    {
                        sitem.state = NSOnState;

                        // Highlight the submenu title so the user knows a subsdiiary Product has been selected

                        item.state = NSMixedState;
                        shouldClear = NO;
                    }
                    else
                    {
                        sitem.state = NSOffState;
                    }
                }

                if (shouldClear) item.state = NSOffState;
            }
            else
            {
                item.state = item.representedObject == selectedProduct ? NSOnState : NSOffState;
            }
        }
    }
    else
    {
        // Select the first item on the list unless the currentProject has an associated product

        if (currentProject.pid != nil && currentProject.pid.length > 0)
        {
            BOOL done = NO;

            for (NSMutableDictionary *product in productsArray)
            {
                NSString *apid = [self getValueFrom:product withKey:@"id"];

                if ([apid compare:currentProject.pid] == NSOrderedSame)
                {
                    for (NSMenuItem *item in productsMenu.itemArray)
                    {
                        // Compare the product objects' 'id' keys

                        if (item.representedObject == product)
                        {
                            item.state = NSOnState;
                            done = YES;
                            break;
                        }

                        if (item.submenu != nil)
                        {
                            for (NSMenuItem *sitem in item.submenu.itemArray)
                            {
                                if (sitem.representedObject == product)
                                {
                                    sitem.state = NSOnState;
                                    done = YES;
                                    break;
                                }
                            }
                        }

                        if (done) break;
                    }
                }

                if (done) break;
            }
        }
        else if (productsArray.count > 0)
        {
            // Choose first item on the list - if there is something to choose

            NSMenuItem *item = [productsMenu.itemArray objectAtIndex:0];
            item.state = NSOnState;
            selectedProduct = item.representedObject;
        }
    }
}



- (BOOL)addOpenProjectsMenuItem:(NSString *)title :(Project *)aProject
{
    // Create a new menu entry to the 'Projects' menu’s 'Open Projects' submenu and to the Current Project popup
    // For the Open Projects submenu, each menu item's representedObject points to the named project
    // For the Current Project popup, each menu item's tag is set to the index of the project in the submenu
    // This allows us to choose projects irrespective of the name used in the menu, for example letting us
    // distinguish between 'explorer' and 'explorer 2'
    // NOTE This is why we have a 'title' parameter and don't just user 'aProject.name'

    // Run through the existing menu items, to check that we're not adding one already there
    // If there are no menu items, we can proceed safely

    if (projectArray == nil || projectArray.count == 0)
    {
        // There are no open projects yet (the one we're adding is the first
        // so clear the 'None' entries from the menu pop-up

        [openProjectsMenu removeAllItems];
        [projectsPopUp removeAllItems];
    }
    else
    {
        // There are projects, so check that the passed in title is not on the menu already
        // TODO should have checked this already, so we can dispose of this section eventually

        for (NSMenuItem *item in openProjectsMenu.itemArray)
        {
            if ([item.title compare:title] == NSOrderedSame)
            {
                // The title is there already - but does the menu item reference the same project?
                // If so, bail and signal failure to add

                if (aProject == item.representedObject) return NO;
            }
        }
    }

    // Switch off all the menu items

    if (openProjectsMenu.itemArray.count > 0)
    {
        for (NSMenuItem *item in openProjectsMenu.itemArray)
        {
            if (item.state == NSOnState) item.state = NSOffState;
        }
    }

    // Add the menu to the list of open projects and select it...

    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(chooseProject:) keyEquivalent:@""];
    item.representedObject = aProject;
    item.state = NSOnState;
    [openProjectsMenu addItem:item];

    // ...and add it to the popup and select it

    [projectsPopUp addItemWithTitle:title];
    NSMenuItem *pitem = [projectsPopUp itemWithTitle:title];
    pitem.representedObject = aProject;
    projectsPopUp.enabled = YES;
    [projectsPopUp selectItem:pitem];

    // Return success

    return YES;
}



#pragma mark Device Groups Menu


- (void)refreshDeviceGroupsSubmenu
{
    // Rebuild the 'Project's Device Groups' submenu, under the 'Device Groups' menu
    // This menu controls the View menu

    NSMenuItem *item;

    // First, clear the current menu, if it has any items

    if (deviceGroupsMenu.itemArray.count > 0) [deviceGroupsMenu removeAllItems];

    // No device groups in the project? Just put 'None' in the menu

    if (currentProject == nil)
    {
        item = [[NSMenuItem alloc] initWithTitle:@"None"
                                          action:nil
                                   keyEquivalent:@""];
        item.enabled = NO;
        [deviceGroupsMenu addItem:item];
    }
    else if (currentProject.devicegroups.count == 0)
    {
        item = [[NSMenuItem alloc] initWithTitle:@"Create New Device Group"
                                          action:@selector(newDevicegroup:)
                                   keyEquivalent:@""];
        item.enabled = YES;
        item.state = NSOffState;
        [deviceGroupsMenu addItem:item];
    }
    else
    {
        [self refreshDevicegroupByType:@"development_devicegroup"];
        [self refreshDevicegroupByType:@"pre_factoryfixture_devicegroup"];
        [self refreshDevicegroupByType:@"pre_dut_devicegroup"];
        [self refreshDevicegroupByType:@"pre_production_devicegroup"];
        [self refreshDevicegroupByType:@"factoryfixture_devicegroup"];
        [self refreshDevicegroupByType:@"dut_devicegroup"];
        [self refreshDevicegroupByType:@"production_devicegroup"];

        // Add the 'fixed' menu entries

        item = [[NSMenuItem alloc] initWithTitle:@"Create New Device Group"
                                          action:@selector(newDevicegroup:)
                                   keyEquivalent:@""];
        item.enabled = YES;
        item.state = NSOffState;
        [deviceGroupsMenu addItem:item];

        // If we won't have a device group selected, so pick the first one on the list

        if (currentDevicegroup == nil)
        {
            item = [deviceGroupsMenu.itemArray objectAtIndex:0];
            item.state = NSOnState;
            currentDevicegroup = item.representedObject;
            currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
        }

        item = [projectsPopUp selectedItem];
        Project *pr = item.representedObject;
        item.title = [NSString stringWithFormat:@"%@/%@", pr.name, currentDevicegroup.name];
    }

    // Now go and build the assigned devices submenus
    // This SHOULD be only place we call this but may not be
    // (other than updateDevice:)

    [self refreshDeviceGroupSubmenuDevices];

    iwvc.project = currentProject;
}



- (void)refreshDevicegroupByType:(NSString *)type
{
    // Update 'Device Groups > Current Project' with a list of device groups of the specified type

    BOOL first = NO;
    NSMenuItem *item = nil;

    for (Devicegroup *dg in currentProject.devicegroups)
    {
        if ([dg.type compare:type] == NSOrderedSame)
        {
            if (!first)
            {
                first = YES;
                item = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ Device Groups", [self convertDevicegroupType:type :NO]]
                                                  action:@selector(chooseDevicegroup:)
                                           keyEquivalent:@""];
                item.representedObject = nil;
                item.state = NSOffState;
                item.enabled = NO;

                [deviceGroupsMenu addItem:item];
            }

            item = [[NSMenuItem alloc] initWithTitle:dg.name
                                              action:@selector(chooseDevicegroup:)
                                       keyEquivalent:@""];
            item.representedObject = dg;
            item.state = (dg == currentDevicegroup) ? NSOnState : NSOffState;
            [deviceGroupsMenu addItem:item];
        }
    }

    if (first)
    {
        item = [NSMenuItem separatorItem];
        [deviceGroupsMenu addItem:item];
    }
}



- (void)refreshDeviceGroupsMenu
{
    // This method updates the main Device Groups menu, ie. all but the list of
    // the current Project's Device Groups, which is handled by 'refreshDevicegroupMenu:'
    // This menu controls the View menu

    NSMenuItem *item;
    BOOL compiled = YES;
    BOOL gotFiles = YES;

    // Set the names of the menu items according to whether there is a selected
    // device group or not

    if (currentDevicegroup != nil)
    {
        NSString *name = currentDevicegroup.name;

        showDeviceGroupInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", name];
        showModelFilesFinderMenuItem.title = [NSString stringWithFormat:@"Show “%@” Source Files in Finder", name];
        restartDeviceGroupMenuItem.title = [NSString stringWithFormat:@"Restart “%@” Devices", name];
        listCommitsMenuItem.title = [NSString stringWithFormat:@"List Commits to “%@”", name];
        deleteDeviceGroupMenuItem.title = [NSString stringWithFormat:@"Delete “%@”", name];
        renameDeviceGroupMenuItem.title = [NSString stringWithFormat:@"Edit “%@”...", name];
        compileMenuItem.title = [NSString stringWithFormat:@"Compile “%@” Code", name];
        uploadMenuItem.title = [NSString stringWithFormat:@"Upload “%@” Code", name];

        externalSourceMenu.title = [NSString stringWithFormat:@"View “%@” Source in Editor", name];
        externalLibsMenu.title = [NSString stringWithFormat:@"View “%@” Local Libraries in Editor", name];
        externalFilesMenu.title = [NSString stringWithFormat:@"View “%@” Local Files in Editor", name];

        if (currentDevicegroup.models.count > 0)
        {
            // Got models - see if the code is compiled

            compiled = ((currentDevicegroup.squinted & kDeviceCodeSquinted) != 0 && (currentDevicegroup.squinted & kAgentCodeSquinted) != 0);
        }
        else
        {
            // No models, ergo no compiled code

            compiled = NO;
            gotFiles = NO;
        }
    }
    else
    {
        showDeviceGroupInfoMenuItem.title = @"Show Device Group Info";
        showModelFilesFinderMenuItem.title = @"Show Device Group Source Files in Finder";
        restartDeviceGroupMenuItem.title = @"Restart Device Group Devices";
        listCommitsMenuItem.title = @"List Commits to Device Group";
        deleteDeviceGroupMenuItem.title = @"Delete Device Group";
        renameDeviceGroupMenuItem.title = @"Edit Device Group";
        compileMenuItem.title = @"Compile Device Group Code";
        uploadMenuItem.title = @"Upload Device Group Code";

        externalSourceMenu.title = @"View Device Group Source in Editor";
        externalLibsMenu.title = @"View Device Group Local Libraries in Editor";
        externalFilesMenu.title = @"View Device Group Local Files in Editor";

        [self defaultExternalMenus];
    }

    // Enable or disable items as appropriate

    showDeviceGroupInfoMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    showModelFilesFinderMenuItem.enabled = currentDevicegroup != nil && gotFiles == YES ? YES : NO;
    restartDeviceGroupMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    conRestartDeviceGroupMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    setMinimumMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    setProductionTargetMenuItem.enabled = (currentDevicegroup != nil && [currentDevicegroup.type containsString:@"fixture"]) ? YES : NO;
    setDUTTargetMenuItem.enabled = (currentDevicegroup != nil && [currentDevicegroup.type containsString:@"fixture"]) ? YES : NO;
    listCommitsMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    deleteDeviceGroupMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    renameDeviceGroupMenuItem.enabled = currentDevicegroup != nil ? YES : NO;
    compileMenuItem.enabled = currentDevicegroup != nil && gotFiles == YES ? YES : NO;
    uploadMenuItem.enabled = currentDevicegroup != nil && compiled == YES ? YES : NO;
    uploadExtraMenuItem.enabled = currentDevicegroup != nil && compiled == YES ? YES : NO;
    checkImpLibrariesMenuItem.enabled = currentDevicegroup != nil && gotFiles == YES ? YES : NO;
    removeFilesMenuItem.enabled = currentDevicegroup != nil && gotFiles == YES ? YES : NO;
    listTestBlessedDevicesMenuItem.enabled = (currentDevicegroup != nil && [currentDevicegroup.type containsString:@"pre_production"]) ? YES : NO;
    // FROM 2.3.130
    logAllDevicegroupDevices.enabled = currentDevicegroup != nil ? YES : NO;
    nextDevicegroupMenuItem.enabled = (currentProject != nil && currentProject.devicegroups.count > 1) ? YES : NO;
    previousDevicegroupMenuItem.enabled = (currentProject != nil && currentProject.devicegroups.count > 1) ? YES : NO;
    
    // FROM 2.3.128
    // Set the Set Target menu titles appropriate to test/production

    if ([currentDevicegroup.type hasPrefix:@"pre_"])
    {
        setProductionTargetMenuItem.title = @"Set Target Test Production Device Group...";
        setDUTTargetMenuItem.title = @"Set Target Test DUT Device Group...";
    }
    else
    {
        setProductionTargetMenuItem.title = @"Set Target Production Device Group...";
        setDUTTargetMenuItem.title = @"Set Target DUT Device Group...";
    }

    // Enable or Disable the source code submenu based on whether's there's a selected device group
    // and whether that deviece group has agent and/or device code or not

    compiled = NO;
    gotFiles = NO;

    if (currentDevicegroup != nil)
    {
        if (currentDevicegroup.models.count > 0)
        {
            for (Model *md in currentDevicegroup.models)
            {
                if ([md.type compare:@"agent"] == NSOrderedSame && md.filename.length > 0) compiled = YES;
                if ([md.type compare:@"device"] == NSOrderedSame && md.filename.length > 0) gotFiles = YES;
            }
        }
    }

    for (NSUInteger i = 0 ; i < externalSourceMenu.itemArray.count ; ++i)
    {
        item = [externalSourceMenu.itemArray objectAtIndex:i];

        if (i == 0) item.enabled = (compiled == YES) ? YES : NO;
        if (i == 1) item.enabled = (gotFiles == YES) ? YES : NO;
        if (i == 2) item.enabled = (gotFiles == YES && compiled == YES) ? YES : NO;
    }

    // Upddate the library, imp library and files submenus

    [self refreshLibraryMenus];
    [self refreshFilesMenu];

    // Update the View Menu
    // This SHOULD be the only place we do this, ie. we should always come here first
    // because this only changes when the device group state changes

    [self refreshViewMenu];
}



- (void)defaultExternalMenus
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
    item.enabled = NO;
    [externalLibsMenu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
    item.enabled = NO;
    [externalFilesMenu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
    item.enabled = NO;
    [impLibrariesMenu addItem:item];
}



- (void)refreshDeviceGroupSubmenuDevices
{
    // Rebuild the various sub-menus listing devices assigned to
    // listed device groups, ie. those belonging to the current project

    if (currentProject == nil || currentProject.devicegroups.count == 0)
    {
        // There is no project selected, or the project has no device groups,
        // so this menu will be empty. Proceed no further

        return;
    }

    NSMenuItem *menuItem = nil;

    if (deviceGroupsMenu.numberOfItems > 2)
    {
        // Remove existing the devices sub-submenus
        // NOTE The 'deviceGroupsMenu' submenu has at least two non-device group items:
        //      'Create New Device Group' and a separator item

        for (menuItem in deviceGroupsMenu.itemArray)
        {
            if (menuItem.submenu != nil)
            {
                [menuItem.submenu removeAllItems];
                menuItem.submenu = nil;
            }
        }
    }

    // Rebuild the devices sub-sub menus

    if (devicesArray.count > 0)
    {
        // Set through all the known devices and add them to the appropriate sub-submenu

        for (NSMutableDictionary *device in devicesArray)
        {
            NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
            NSString *dgid = [self getValueFrom:dg withKey:@"id"];

            if (dgid != nil)
            {
                // If the device's device group ID is not nil, it's assigned
                // and we should check for its inclusion here

                for (NSMenuItem *item in deviceGroupsMenu.itemArray)
                {
                    Devicegroup *adg = item.representedObject;

                    if (adg != nil)
                    {
                        if ([adg.did compare:dgid] == NSOrderedSame)
                        {
                            NSMenu *submenu = item.submenu;

                            if (submenu == nil)
                            {
                                // There's no devices submenu, so add one

                                submenu = [[NSMenu alloc] initWithTitle:adg.name];
                                item.submenu = submenu;
                                submenu.autoenablesItems = YES;
                            }

                            // Add the device's menu entry and enable it

                            NSString *dstring = [self getValueFrom:device withKey:@"name"];
                            NSMenuItem *ditem = [[NSMenuItem alloc] initWithTitle:dstring action:@selector(chooseDevice:) keyEquivalent:@""];

                            [submenu addItem:ditem];
                            ditem.enabled = YES;
                            ditem.state = NSOffState;
                            ditem.representedObject = device;
                            ditem.image = [self menuImage:device];

                            break;

                            // TODO We don't check for multiple devices with the same name but different (of course)
                            //      device IDs — we should sort that out here or (better) when we load the device list
                        }
                    }
                }
            }
        }
    }

    // Sort the device groups menus submenus

    for (NSMenuItem *item in deviceGroupsMenu.itemArray)
    {
        if (item.submenu != nil)
        {
            NSArray *items = item.submenu.itemArray;
            [item.submenu removeAllItems];

            NSSortDescriptor *alpha = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES selector:@selector(caseInsensitiveCompare:)];
            items = [items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:alpha, nil]];

            for (NSMenuItem *ditem in items)
            {
                [item.submenu addItem:ditem];
                if (ditem.isHidden) ditem.hidden = NO; // What's this for?
            }
        }
    }

    // Re-select the selected device, if there is one

    [self setDevicesMenusTicks];
}



- (void)setDevicesMenusTicks
{
    // Run through all of the 'Project's Device Groups' submenu items to find those with
    // devices sub-submenus. Of those that do, if a listed device matches the currently
    // selected device, tick it; otherwise untick it (just in case)

    if (selectedDevice != nil)
    {
        BOOL flag = NO;

        // For 'deviceGroupsMenu' we have to iterate through any submenus
        // and compare the IDs of the represented device and the selectedDevice
        // as the objects may be identical by value but not by reference

        for (NSMenuItem *menuItem in deviceGroupsMenu.itemArray)
        {
            if (menuItem.submenu != nil)
            {
                for (NSMenuItem *subMenuItem in menuItem.submenu.itemArray)
                {
                    if (subMenuItem.representedObject == selectedDevice)
                    {
                        subMenuItem.state = NSOnState;
                        flag = YES;
                        break;
                    }
                    else
                    {
                        subMenuItem.state = NSOffState;
                    }
                }
            }

            if (flag) break;
        }
    }
}



- (void)refreshLibraryMenus
{
    // This method updates the lists of local and ei libraries

    // Update the external library menu. First clear the current menu

    if (externalLibsMenu.numberOfItems > 0) [externalLibsMenu removeAllItems];
    if (impLibrariesMenu.numberOfItems > 0) [impLibrariesMenu removeAllItems];

    NSInteger aLibCount = 0;
    NSInteger dLibCount = 0;
    NSInteger iaLibCount = 0;
    NSInteger idLibCount = 0;
    NSString *m;
    NSMenuItem *item;

    for (Model *model in currentDevicegroup.models)
    {
        if ([model.type compare:@"agent"] == NSOrderedSame)
        {
            aLibCount = aLibCount + model.libraries.count;
            iaLibCount = iaLibCount + model.impLibraries.count;
        }
        else
        {
            dLibCount = dLibCount + model.libraries.count;
            idLibCount = idLibCount + model.impLibraries.count;
        }
    }

    // Add agent libraries, if any

    if (aLibCount > 0)
    {
        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Compiled Agent Code";
        item = [[NSMenuItem alloc] initWithTitle:m action:nil keyEquivalent:@""];
        item.enabled = NO;
        [externalLibsMenu addItem:item];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"agent"] == NSOrderedSame)
            {
                [self libAdder:model.libraries :NO];
            }
        }
    }

    // Add device libraries, if any

    if (dLibCount > 0)
    {
        // Drop in a spacer if we have any files above

        if (aLibCount > 0) [externalLibsMenu addItem:[NSMenuItem separatorItem]];

        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Compiled Device Code";
        item = [[NSMenuItem alloc] initWithTitle:m action:nil keyEquivalent:@""];
        item.enabled = NO;
        [externalLibsMenu addItem:item];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"device"] == NSOrderedSame)
            {
                [self libAdder:model.libraries :NO];
            }
        }
    }

    if (dLibCount == 0 && aLibCount == 0)
    {
        item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
        item.enabled = NO;
        [externalLibsMenu addItem:item];
    }

    // Add EI Libraries, if any... agent...

    if (iaLibCount > 0)
    {
        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Agent Code";
        item = [[NSMenuItem alloc] initWithTitle:m action:nil keyEquivalent:@""];
        item.enabled = NO;
        [impLibrariesMenu addItem:item];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"agent"] == NSOrderedSame) [self libAdder:model.impLibraries :YES];
        }
    }

    // ...and device

    if (idLibCount > 0)
    {
        // Drop in a spacer if we have any files above

        if (iaLibCount > 0) [impLibrariesMenu addItem:[NSMenuItem separatorItem]];

        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Device Code";
        item = [[NSMenuItem alloc] initWithTitle:m action:nil keyEquivalent:@""];
        item.enabled = NO;
        [impLibrariesMenu addItem:item];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"device"] == NSOrderedSame) [self libAdder:model.impLibraries :YES];
        }
    }

    if (idLibCount == 0 && iaLibCount == 0)
    {
        NSString *title = @"None";

        if (currentDevicegroup != nil && currentDevicegroup.squinted == 0) title = @"Unknown - Code Uncompiled";

        item = [[NSMenuItem alloc] initWithTitle:title action:nil keyEquivalent:@""];
        item.enabled = NO;
        [impLibrariesMenu addItem:item];
    }
}



- (void)libAdder:(NSMutableArray *)libs :(BOOL)isEILib
{
    for (File *lib in libs) [self addLibraryToMenu:lib :isEILib :YES];
}



- (void)addLibraryToMenu:(File *)lib :(BOOL)isEILib :(BOOL)isActive
{
    // Create a new menu entry for the libraries menus

    NSMenuItem *item;

    if (isEILib)
    {
        item = [[NSMenuItem alloc] initWithTitle:[lib.filename stringByAppendingFormat:@" (%@)", lib.version] action:@selector(showEILibsPage) keyEquivalent:@""];
        item.representedObject = lib;
        [impLibrariesMenu addItem:item];
    }
    else
    {
        if (isActive)
        {
            item = [[NSMenuItem alloc] initWithTitle:[lib.filename stringByAppendingFormat:@" (%@)", ((lib.version.length == 0) ? @"unknown" : lib.version)]
                                              action:@selector(externalLibOpen:)
                                       keyEquivalent:@""];
            item.representedObject = lib;
        }
        else
        {
            item = [[NSMenuItem alloc] initWithTitle:lib.filename action:nil keyEquivalent:@""];
        }

        item.enabled = isActive;
        [externalLibsMenu addItem:item];
    }
}



- (void)refreshFilesMenu
{
    // Update the external files menu. First clear the current menu

    if (externalFilesMenu.numberOfItems > 0) [externalFilesMenu removeAllItems];

    NSInteger aFileCount = 0;
    NSInteger dFileCount = 0;
    NSString *m;

    for (Model *model in currentDevicegroup.models)
    {
        if ([model.type compare:@"agent"] == NSOrderedSame)
        {
            aFileCount += model.files.count;
        }
        else
        {
            dFileCount += model.files.count;
        }
    }

    // Add agent files, if any

    if (aFileCount > 0)
    {
        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Compiled Agent Code";

        [self addItemToFileMenu:m :NO];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"agent"] == NSOrderedSame) [self fileAdder:model.files];
        }
    }

    // Add device files, if any

    if (dFileCount > 0)
    {
        // Drop in a spacer if we have any files above

        if (aFileCount > 0) [externalFilesMenu addItem:[NSMenuItem separatorItem]];

        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Compiled Device Code";

        [self addItemToFileMenu:m :NO];

        for (Model *model in currentDevicegroup.models)
        {
            if ([model.type compare:@"device"] == NSOrderedSame) [self fileAdder:model.files];
        }
    }

    if (dFileCount == 0 && aFileCount == 0)
    {
        [self addItemToFileMenu:@"None" :NO];
    }
    else
    {
        // Check for duplications, ie. if agent and device both use the same lib
        // TODO someone may have the same library name in separate files, so we need to
        // check for this too.

        for (NSUInteger i = 0 ; i < externalFilesMenu.numberOfItems ; ++i)
        {
            NSMenuItem *fileItem = [externalFilesMenu itemAtIndex:i];

            if (fileItem.enabled == YES)
            {
                for (NSUInteger j = 0 ; j < externalFilesMenu.numberOfItems ; ++j)
                {
                    if (j != i)
                    {
                        NSMenuItem *aFileItem = [externalFilesMenu itemAtIndex:j];

                        if (aFileItem.enabled == YES)
                        {
                            if ([fileItem.title compare:aFileItem.title] == NSOrderedSame)
                            {
                                // The names match, so remove the current one

                                [externalFilesMenu removeItemAtIndex:j];
                            }
                        }
                    }
                }
            }
        }
    }
}



- (void)fileAdder:(NSMutableArray *)models
{
    for (File *file in models) [self addFileToMenu:file :YES];
}



- (void)addFileToMenu:(File *)file :(BOOL)isActive
{
    // Adds a model's imported file to the menu list

    NSMenuItem *item;

    if (isActive)
    {
        NSString *version = @"";
        if (file.version.length > 0) version = [NSString stringWithFormat:@" (%@)", file.version];
        item = [[NSMenuItem alloc] initWithTitle:[file.filename stringByAppendingFormat:@"%@", version]
                                          action:@selector(externalFileOpen:)
                                   keyEquivalent:@""];
        item.representedObject = file;
    }
    else
    {
        item = [[NSMenuItem alloc] initWithTitle:file.filename action:nil keyEquivalent:@""];
        item.representedObject = file;
    }

    item.enabled = isActive;
    [externalFilesMenu addItem:item];
}



- (void)addItemToFileMenu:(NSString *)text :(BOOL)isActive
{
    // Adds a model's imported file to the menu list

    NSMenuItem *item;

    if (isActive)
    {
        item = [[NSMenuItem alloc] initWithTitle:text action:@selector(externalFileOpen:) keyEquivalent:@""];
    }
    else
    {
        item = [[NSMenuItem alloc] initWithTitle:text action:nil keyEquivalent:@""];

    }

    item.enabled = isActive;
    [externalFilesMenu addItem:item];
}



#pragma mark Device Menu


- (void)refreshDeviceMenu
{
    // Called to set the state of the 'Device' Menu
    // The 'Unassigned Devices' submenu is set by 'refreshDevicesPopup:'

    // Title menus according to whether there is a currently selected device or not

    if (selectedDevice != nil)
    {
        NSString *dName = [self getValueFrom:selectedDevice withKey:@"name"];

        showDeviceInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", dName];
        restartDeviceMenuItem.title = [NSString stringWithFormat:@"Restart “%@”", dName];
        copyAgentURLMenuItem.title = [NSString stringWithFormat:@"Copy “%@” Agent URL", dName];
        openAgentURLMenuItem.title = [NSString stringWithFormat:@"Open “%@” Agent URL", dName];
        unassignDeviceMenuItem.title = [NSString stringWithFormat:@"Unassign “%@”", dName];
        getLogsMenuItem.title = [NSString stringWithFormat:@"Get Past Logs from “%@”", dName];
        getHistoryMenuItem.title = [NSString stringWithFormat:@"Get History of “%@”", dName];
        deleteDeviceMenuItem.title = [NSString stringWithFormat:@"Delete “%@”", dName];

        BOOL flag = [ide isDeviceLogging:[selectedDevice objectForKey:@"id"]];
        streamLogsMenuItem.title = flag ? [NSString stringWithFormat:@"Close Log Stream for “%@”", dName] : [NSString stringWithFormat:@"Open Log Stream for “%@”", dName];
    }
    else
    {
        showDeviceInfoMenuItem.title = @"Show Device Info";
        restartDeviceMenuItem.title = @"Restart Device";
        copyAgentURLMenuItem.title = @"Copy Device’s Agent URL";
        openAgentURLMenuItem.title = @"Open Device’s Agent URL";
        unassignDeviceMenuItem.title = @"Unassign Device";
        getLogsMenuItem.title = @"Get Past Logs from Device";
        getHistoryMenuItem.title = @"Get History of Device";
        deleteDeviceMenuItem.title = @"Delete Device";
        streamLogsMenuItem.title = @"Start Log Streaming";
    }

    // Title menus according to whether there is a currently selected device or not

    showDeviceInfoMenuItem.enabled = selectedDevice != nil ? YES : NO;
    restartDeviceMenuItem.enabled = selectedDevice != nil ? YES : NO;
    copyAgentURLMenuItem.enabled = selectedDevice != nil ? YES : NO;
    openAgentURLMenuItem.enabled = selectedDevice != nil ? YES : NO;
    unassignDeviceMenuItem.enabled = selectedDevice != nil ? YES : NO;
    getLogsMenuItem.enabled = selectedDevice != nil ? YES : NO;
    getHistoryMenuItem.enabled = selectedDevice != nil ? YES : NO;
    streamLogsMenuItem.enabled = selectedDevice != nil ? YES : NO;
    deleteDeviceMenuItem.enabled = selectedDevice != nil ? YES : NO;

    // Title menus according to whether there is a loaded list of devices or not

    unassignDeviceMenuItem.enabled = devicesArray.count > 0 ? YES : NO;
    renameDeviceMenuItem.enabled = devicesArray.count > 0 ? YES : NO;
    assignDeviceMenuItem.enabled = devicesArray.count > 0 && projectArray.count > 0 ? YES : NO;
    findDeviceMenuItem.enabled = devicesArray.count > 0 ? YES : NO;
}



- (void)refreshDevicesPopup
{
    // Make up the device pop up from scratch. It should list all the device we have,
    // Not just the ones in selected project device groups

    // Clear the devices list pop up

    devicesPopUp.enabled = NO;
    [devicesPopUp removeAllItems];

    if (devicesArray.count > 0)
    {
        for (NSUInteger i = 0 ; i < devicesArray.count ; ++i)
        {
            // For each device in the list, set the popup with its name and appropriate graphics
            // for its connectivity state and its logging state (via menuImage:)

            NSMutableDictionary *device = [devicesArray objectAtIndex:i];
            NSString *dvName = [self getValueFrom:device withKey:@"name"];
            [devicesPopUp addItemWithTitle:dvName];

            NSMenuItem *item = [devicesPopUp itemWithTitle:dvName];
            item.representedObject = device;
            item.image = [self menuImage:device];
        }

        devicesPopUp.enabled = YES;
    }
    else
    {
        // No devices, so add a 'None' item and select it

        [devicesPopUp addItemWithTitle:@"None"];
        [devicesPopUp selectItemWithTitle:@"None"];
        NSMenuItem *item = [devicesPopUp itemWithTitle:@"None"];
        item.enabled = NO;
    }

    // Show the device selection in the UI

    [self setDevicesPopupTick];

    // Update the list of unassigned devices - this only happens here

    [self refreshUnassignedDevicesMenu];
}



- (void)setDevicesPopupTick
{
    // Mark the device on the popup which has been selected
    // Or the select the first on the list if there is not selected device yet

    if (selectedDevice != nil)
    {
        // Select the correct pop-up item

        NSString *dvName = [self getValueFrom:selectedDevice withKey:@"name"];
        [devicesPopUp selectItemWithTitle:dvName];
    }
    else
    {
        // Select the first device on the list - but only if there is a list

        if (devicesArray.count > 0)
        {
            [devicesPopUp selectItemAtIndex:0];
            selectedDevice = [devicesArray objectAtIndex:0];

            // Also show the device in the Inspector

            iwvc.device = selectedDevice;
        }
    }
}



- (void)refreshUnassignedDevicesMenu
{
    // Rebuild the Devices menu's sub-menu listing unassigned devices

    // NOTE This should ALWAYS be called after 'refreshDevicesPopup:'
    //      Indeed, it is ONLY called by 'refreshDevicesPopup:'

    [unassignedDevicesMenu removeAllItems];

    NSMutableArray *unnassignedDevices = nil;
    NSMutableArray *representedObjects = nil;

    // Determine which devices we know about (ie. we have a downloaded list) are unassigned

    if (devicesArray.count > 0)
    {
        for (NSMutableDictionary *device in devicesArray)
        {
            // Run through the list of devices and find those what are unassigned, ie. have no device group ID

            NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
            NSString *dvName = [self getValueFrom:device withKey:@"name"];
            NSString *dgid = [dg objectForKey:@"id"];
            dgid = [self checkForNull:dgid];

            if (dgid == nil)
            {
                // If there is no device group ID, the device must be unassigned

                if (unnassignedDevices == nil) unnassignedDevices = [[NSMutableArray alloc] init];
                if (representedObjects == nil) representedObjects = [[NSMutableArray alloc] init];

                [unnassignedDevices addObject:dvName];
                [representedObjects addObject:device];
            }
        }
    }

    if (unnassignedDevices != nil && unnassignedDevices.count > 0)
    {
        // Populate the submenu

        for (NSUInteger i = 0 ; i < unnassignedDevices.count ; ++i)
        {
            // For each unassigned device, add its name to the menu and add an approrpriate
            // graphic indicating its connection state and its logging state (via 'menuImage:)
            // We also bind the submenu item to the device in the devices array it represents

            NSString *device = [unnassignedDevices objectAtIndex:i];
            NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:device action:@selector(chooseDevice:) keyEquivalent:@""];
            NSMutableDictionary *representedObject = [representedObjects objectAtIndex:i];
            item.representedObject = representedObject;
            item.state = selectedDevice == representedObject ? NSOnState : NSOffState;
            item.image = [self menuImage:representedObject];
            [unassignedDevicesMenu addItem:item];
        }
    }
    else
    {
        // There are no unassigned devices, so add 'None'

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
        item.enabled = NO;
        [unassignedDevicesMenu addItem:item];
    }

    [self setUnassignedDevicesMenuTick];
}



- (void)setUnassignedDevicesMenuTick
{
    // Run through the 'Unassigned Devices' submenu and switch all the entries off
    // EXCEPT the one matching 'selectedDevice'

    for (NSMenuItem *unassignedDeviceitem in unassignedDevicesMenu.itemArray)
    {
        unassignedDeviceitem.state = (selectedDevice != nil && unassignedDeviceitem.representedObject == selectedDevice) ? NSOnState : NSOffState;
    }
}



- (NSImage *)menuImage:(NSMutableDictionary *)device
{
    // Sets a device's menu and/or popup icon according to the device's connection status

    NSString *imageNameString = @"";
    NSString *dvid = [self getValueFrom:device withKey:@"id"];
    NSNumber *boolean = [self getValueFrom:device withKey:@"device_online"];

    // FROM 2.3.128
    // Check 'boolean' isn't null, which it can be at certain times
    // In this case, assume offline

    if ((NSNull *)boolean == [NSNull null])
    {
        boolean = [NSNumber numberWithBool:NO];
#ifdef DEBUG
        NSLog(@"Device %@ has no 'device_online' value", dvid);
#endif
    }

    imageNameString = boolean.boolValue ? @"online" : @"offline";
    if ([ide isDeviceLogging:dvid]) imageNameString = [imageNameString stringByAppendingString:@"_logging"];
    return [NSImage imageNamed:imageNameString];
}



#pragma mark View Menu


- (void)refreshViewMenu
{
    // The View menu has two items. These are only actionable if there is a selected device group
    // and that device group's code has been compiled

    logDeviceCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kDeviceCodeSquinted) ? YES : NO;
    logAgentCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kAgentCodeSquinted) ? YES : NO;
}



#pragma mark Files Menu


- (IBAction)showHideToolbar:(id)sender
{
    // Flip the menu item in the View menu

    squinterToolbar.visible = !squinterToolbar.isVisible;
    showHideToolbarMenuItem.title = squinterToolbar.isVisible ? @"Hide Toolbar" : @"Show Toolbar";
    [defaults setValue:[NSNumber numberWithBool:squinterToolbar.isVisible] forKey:@"com.bps.squinter.toolbarstatus"];
}



- (void)refreshRecentFilesMenu
{
    NSMenuItem *item;

    [openRecentMenu removeAllItems];

    // 'recentFiles' is set by 'addRecentFileToMenu:' and initialised at startup by reading in from the defaults

    if (recentFiles == nil || recentFiles.count == 0)
    {
        // No recent files listed, so just put a disabled 'clear menu' option in place

        item = [[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(clearRecent:) keyEquivalent:@""];
        item.enabled = NO;
        [openRecentMenu addItem:item];
    }
    else
    {
        // Iterate through the recent files list and add each one to the menu

        for (NSDictionary *file in recentFiles)
        {
            item = [[NSMenuItem alloc] initWithTitle:[file objectForKey:@"name"] action:@selector(openRecent:) keyEquivalent:@""];
            item.enabled = YES;
            item.representedObject = file;
            [openRecentMenu addItem:item];
        }

        // Add a separator...

        [openRecentMenu addItem:[NSMenuItem separatorItem]];

        // ...then an 'Open All' option...

        item = [[NSMenuItem alloc] initWithTitle:@"Open All" action:@selector(openRecentAll) keyEquivalent:@""];
        item.enabled = YES;
        [openRecentMenu addItem:item];

        // ...then another separator...

        [openRecentMenu addItem:[NSMenuItem separatorItem]];

        // ...and lastly the 'Clear Menu' option

        item = [[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(clearRecent:) keyEquivalent:@""];
        item.enabled = YES;
        [openRecentMenu addItem:item];
    }
}



#pragma mark Toolbar Methods


- (void)setToolbar
{
    // Enable or disable project-specific toolbar items
    // New Project, Clear, Print are always available

    infoItem.enabled = (currentProject != nil) ? YES : NO;
    newDevicegroupItem.enabled = (currentProject != nil) ? YES : NO;
    devicegroupInfoItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    squintItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    restartDevicesItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    openAllItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    copyAgentItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    copyDeviceItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    openAgentCode.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    openDeviceCode.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    listCommitsItem.enabled = (currentProject != nil && currentDevicegroup != nil) ? YES : NO;
    uploadCodeItem.enabled = (currentProject != nil && currentDevicegroup != nil && currentDevicegroup.squinted > 0) ? YES : NO;
    uploadCodeExtraItem.enabled = (currentProject != nil && currentDevicegroup != nil && currentDevicegroup.squinted > 0) ? YES : NO;
    downloadProductItem.enabled = (selectedProduct != nil) ? YES : NO;
    syncItem.enabled = (currentProject != nil) ? YES : NO;

    // Enable or disable device-specific toolbar items

    BOOL flag = [ide isDeviceLogging:[selectedDevice objectForKey:@"id"]];
    streamLogsItem.enabled = (selectedDevice != nil) ? YES : NO;
    streamLogsItem.state = flag ? kStreamToolbarItemStateOn : kStreamToolbarItemStateOff;

    // Enabled or disable the login item

    loginAndOutItem.isLoggedIn = ide.isLoggedIn;

    // Validate items to set the colour of items that have different modes

    [squinterToolbar validateVisibleItems];
}



#pragma mark - Dock Menu Methods


- (NSMenu *)applicationDockMenu:(NSApplication *)sender
{
    NSMenuItem *item;

    if (dockMenu == nil)
    {
        dockMenu = [[NSMenu alloc] init];
        dockMenu.autoenablesItems = NO;
    }
    else
    {
        // Clear the dock menu's list items because we may have new items to add

        [dockMenu removeAllItems];
    }

    // Add the list of recently opened files, if any

    if (recentFiles.count > 0)
    {
        // Add the files themselves

        for (NSDictionary *file in recentFiles)
        {
            item = [[NSMenuItem alloc] initWithTitle:[file objectForKey:@"name"] action:@selector(openRecent:) keyEquivalent:@""];
            item.representedObject = file;
            item.target = self;
            item.tag = -1;
            [dockMenu addItem:item];
        }

        // Then add a separator

        [dockMenu addItem:[NSMenuItem separatorItem]];
    }

    // Finally, add the fixed items: directory, separator and web links

    item = [[NSMenuItem alloc] initWithTitle:@"Open Working Directory" action:@selector(dockMenuAction:) keyEquivalent:@""];
    [item setImage:[NSImage imageNamed:@"folder"]];
    item.target = self;
    item.tag = 99;
    [dockMenu addItem:item];

    [dockMenu addItem:[NSMenuItem separatorItem]];

    item = [[NSMenuItem alloc] initWithTitle:@"Squinter Information" action:@selector(dockMenuAction:) keyEquivalent:@""];
    item.tag = 1;
    [dockMenu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Electric Imp Dev Center" action:@selector(dockMenuAction:) keyEquivalent:@""];
    item.tag = 2;
    [dockMenu addItem:item];

    item = [[NSMenuItem alloc] initWithTitle:@"Electric Imp Forum" action:@selector(dockMenuAction:) keyEquivalent:@""];
    item.tag = 3;
    [dockMenu addItem:item];

    return dockMenu;
}



- (void)dockMenuAction:(id)sender
{
    NSMenuItem *item = (NSMenuItem *)sender;

    if (item.tag != -1)
    {
        switch(item.tag)
        {
            case 1:
                [self launchOwnSite:@""];
                break;

            case 2:
                [self launchWebSite:@"https://developer.electricimp.com/"];
                break;

            case 3:
                [self launchWebSite:@"https://forums.electricimp.com/"];
                break;

            default:
                [nswsw openFile:workingDirectory withApplication:nil andDeactivate:YES];
        }
    }
}



@end
