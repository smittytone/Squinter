

//  Created by Tony Smith on 6 May 2019.
//  Copyright (c) 2015-19 Tony Smith. All rights reserved.


#import "AppDelegateFileHandlers.h"


@implementation AppDelegate(AppDelegateFileHandlers)


#pragma mark - File Opening Methods


- (void)presentOpenFilePanel:(NSInteger)openActionType
{
    // Complete the open file dialog settings with generic preferences
    
    openDialog.canChooseFiles = YES;
    openDialog.canChooseDirectories = NO;
    openDialog.delegate = self;
    
    // Start off at the working directory
    
    openDialog.directoryURL = [NSURL fileURLWithPath:workingDirectory isDirectory:YES];
    
    // Run the NSOpenPanel
    
    [openDialog beginSheetModalForWindow:mainWindow
                       completionHandler:^(NSInteger result)
     {
         // Close sheet first to stop it hogging the event queue
         
         [NSApp stopModal];
         [NSApp endSheet:openDialog];
         [openDialog orderOut:self];
         
         if (result == NSFileHandlingPanelOKButton) [self openFileHandler:[openDialog URLs] :openActionType];
     }
     ];
    
    [NSApp runModalForWindow:openDialog];
    [openDialog makeKeyWindow];
}



- (void)openFileHandler:(NSArray *)urls :(NSInteger)openActionType
{
    // This is where we open/add all files selected by the open file dialog
    // Multiple files may be passed in, as an array of URLs, and they will contain either
    // project files OR source code files (as specified by 'openActionType'
    
    if (openActionType == kActionOpenSquirrelProject)
    {
        // We're openning a Squirrel project, so pass on the array of URLs, converted to a mutable array
        
        [self openSquirrelProjects:[NSMutableArray arrayWithArray:urls]];
    }
    else
    {
        // We are opening one or more source code files to add to a device group, which may be new
        // Check the number of files selected. If we are using source files to create a project,
        // it should never be more than two
        
        if (urls.count > 2)
        {
            // The user has selected too many source files - they can't all be used - so present
            // a warning and then bail back to the file selection start ('selectFile:');
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"You have selected too many source files";
            alert.informativeText = [NSString stringWithFormat:@"Device Groups can contain only two source code files: one *.agent.nut and one *.device.nut, but you selected %lu files. Please select two source code files.", (long)urls.count];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:mainWindow
                          completionHandler:nil];
            
            return;
        }
        
        if (accessoryViewNewProjectCheckbox.state == NSOnState)
        {
            // This will be set if we have one or two source code files from which the user wants to make a device group.
            // NOTE this should only be possible if we have a current project, ie. we can assume 'currentProject' != nil
            
            // Make a new device group, and set it to current
            // TODO should we set it to a neutral variable in case it fails?
            
            currentDevicegroup = [[Devicegroup alloc] init];
            currentDevicegroup.models = [[NSMutableArray alloc] init];
            if (currentProject.devicegroups == nil) currentProject.devicegroups = [[NSMutableArray alloc] init];
            [currentProject.devicegroups addObject:currentDevicegroup];
            currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
            
            // This flag tracks the establishment of a newDeviceGroup, but it needs to be NO for now
            
            newDevicegroupFlag = NO;
        }
        
        // Process the added file(s)
        
        [self processAddedFiles:[NSMutableArray arrayWithArray:urls]];
    }
}



#pragma mark - Open Squirrel Projects Methods


- (void)openSquirrelProjects:(NSMutableArray *)urls
{
    // We are opening one Squirrel project files from an array ('urls')
    // When a file has been opened (or rejected for some reason) it is removed
    // from the array and 'openSquirrelProjects' is called recursively until there
    // are no more urls left in the array
    
    if (urls.count == 0) return;
    
    Project *aProject;
    NSString *fileName, *newName, *filePath, *oldPath;
    NSURL *url;
    
    BOOL nameMatch = NO;
    BOOL pathMatch = NO;
    BOOL gotFlag = NO;
    BOOL projectMoved = NO;
    
    url = [urls objectAtIndex:0];
    [urls removeObjectAtIndex:0];
    
    filePath = [url path];
    aProject = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
    
    if (aProject != nil)
    {
        // Project opened successfully
        
        // Check for an old project being opened - if it is convert it as best as we can
        
        if ([aProject.pid compare:@"old"] == NSOrderedSame)
        {
            // NOTE .pid = 'old' is set when we open an pre-3.0 project using code in Project.m
            // which uses 'devicegroups' to store old file location data and 'description' to
            // hold the number and type of files
            
            [self writeStringToLog:[NSString stringWithFormat:@"Converting an older project file (version %@) to a current one (version %@)", aProject.version, kSquinterCurrentVersion] :YES];
            
            NSString *agentPath, *devicePath;
            Model *model;
            
            NSInteger files = aProject.description.integerValue;
            
            NSArray *parts = [aProject.version componentsSeparatedByString:@"."];
            NSInteger major = [[parts objectAtIndex:0] integerValue];
            NSInteger minor = [[parts objectAtIndex:1] integerValue];
            BOOL absFlag = NO;
            
            if (major < 2 || (major == 2 && minor < 1))
            {
                // If the old project is less than 2.1 CHECK, the paths will be absolute
                
                absFlag = YES;
            }
            
            if (files > 0)
            {
                // The old Squinter project has associated model files, which we now need
                // to put into a device group. We mark this as 'old' to ensure it gets uploaded later
                
                Devicegroup *dg = [[Devicegroup alloc] init];
                dg.models = [[NSMutableArray alloc] init];
                dg.name = [aProject.name stringByAppendingString:@" Device Group"];
                dg.did = @"old";
                
                if (files > 1)
                {
                    // We have agent code
                    
                    agentPath = [aProject.devicegroups objectAtIndex:0];
                    
                    if (absFlag) agentPath = [self getRelativeFilePath:[filePath stringByDeletingLastPathComponent] :agentPath];
                }
                
                if (files & 0x01)
                {
                    // We have device code
                    
                    files = (files > 1) ? 1 : 0;
                    devicePath = [aProject.devicegroups objectAtIndex:files];
                    
                    if (absFlag) devicePath = [self getRelativeFilePath:[filePath stringByDeletingLastPathComponent] :devicePath];
                }
                
                // Clear out the saved file data
                
                [aProject.devicegroups removeAllObjects];
                
                if (agentPath.length > 0)
                {
                    model = [[Model alloc] init];
                    model.path = agentPath;
                    model.filename = [model.path lastPathComponent];
                    model.path = [model.path stringByDeletingLastPathComponent];
                    model.type = @"agent";
                    
                    [dg.models addObject:model];
                }
                
                if (devicePath.length > 0)
                {
                    model = [[Model alloc] init];
                    
                    model.path = devicePath;
                    model.filename = [model.path lastPathComponent];
                    model.path = [model.path stringByDeletingLastPathComponent];
                    model.type = @"device";
                    
                    [dg.models addObject:model];
                }
                
                [aProject.devicegroups addObject:dg];
            }
            
            // Clear project settings used in conversion process
            
            aProject.haschanged = YES;
            aProject.version = kSquinterCurrentVersion;
            aProject.description = @"";
            
            if (aProject.path == nil || aProject.path.length == 0) aProject.path = [filePath stringByDeletingLastPathComponent];
            
            [self writeStringToLog:@"Project converted." :YES];
        }
        
        // Check for a change of project name via project filename
        
        pathMatch = [self checkProjectPaths:nil :filePath];
        
        if (!pathMatch)
        {
            // Full path (path + name) of opened project doesn't match,
            // but we still need to check the name, in case we have to add '01' to the name
            
            newName = [[filePath lastPathComponent] stringByDeletingPathExtension];
            nameMatch = [self checkProjectNames:nil :aProject.name];
            
            if (nameMatch)
            {
                // Name matches an existing open project from a non-matching project file (path different)
                
                NSString *aName = aProject.name;
                
                if ([newName compare:aName] != NSOrderedSame)
                {
                    // The project's name and its filename don't match, so we may be able to list it by filename
                    // provided that's not already on the list too
                    
                    if (![self checkProjectNames:nil :newName])
                    {
                        // Filename-derived project name doesn't match an existing name, so use that
                        
                        [self writeStringToLog:[NSString stringWithFormat:@"A project called \"%@\" is already loaded so the new project's filename, \"%@.squirrelproj\", will be used", aName, newName] :YES];
                    }
                    else
                    {
                        // The project's name and its filename match, so we have to use the name
                        // but modify it with a numeric value (which may also be on the the list)
                        
                        NSInteger projectCount = 0;
                        
                        for (NSUInteger j = 0 ; j < openProjectsMenu.numberOfItems ; ++j)
                        {
                            NSString *mName = [[openProjectsMenu itemAtIndex:j] title];
                            
                            if ([mName containsString:aName])
                            {
                                // The project menu contains a title which includes the new project's name
                                
                                if (mName.length == aName.length)
                                {
                                    // If they are the same length, we can just add a value to the new project's name
                                    
                                    ++projectCount;
                                }
                                else
                                {
                                    // If they are a different length, we have to check that the difference is
                                    // ONLY the addition of a number (watch for the space between name and number)
                                    
                                    NSString *sub = [mName substringFromIndex:aName.length + 1];
                                    if (sub.integerValue > 0) ++projectCount;
                                }
                            }
                        }
                        
                        if (projectCount > 0) newName = [aName stringByAppendingFormat:@" %li", (long)(projectCount + 1)];
                    }
                }
                else
                {
                    // The project's name and its filename do match, so we have to use the name
                    // but modify it with a numeric value (which may also be on the the list)
                    
                    NSInteger projectCount = 0;
                    
                    for (NSUInteger j = 0 ; j < openProjectsMenu.numberOfItems ; ++j)
                    {
                        NSString *mName = [[openProjectsMenu itemAtIndex:j] title];
                        
                        if ([mName containsString:aName])
                        {
                            // The project menu contains a title which includes the new project's name
                            
                            if (mName.length == aName.length)
                            {
                                // If they are the same length, we can just add a value to the new project's name
                                
                                ++projectCount;
                            }
                            else
                            {
                                // If they are a different length, we have to check that the difference is
                                // ONLY the addition of a number (watch for the space between name and number)
                                
                                NSString *sub = [mName substringFromIndex:aName.length + 1];
                                if (sub.integerValue > 0) ++projectCount;
                            }
                        }
                    }
                    
                    if (projectCount > 0) newName = [aName stringByAppendingFormat:@" %li", (long)(projectCount + 1)];
                }
            }
            else
            {
                // Name doesn't match an existing open project
                
                newName = nil;
            }
        }
        else
        {
            // Full path (path + name) matches so user is trying to open an already open project
            
            [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" is already open.", aProject.name] :YES];
            aProject = nil;
            gotFlag = YES;
        }
        
#pragma mark Opened a new project
        
        if (!gotFlag)
        {
            // Set the newly opened project to be the current one
            
            currentProject = aProject;
            currentDevicegroup = nil;
            currentProject.devicegroupIndex = -1;
            
            // Update the 'path' and 'filename' according to where we have just loaded the file from
            // NOTE 'oldPath' points to where it was when previously opened, which may not be the same
            
            oldPath = currentProject.path;
            currentProject.path = [filePath stringByDeletingLastPathComponent];
            currentProject.filename = [filePath lastPathComponent];
            
            [self writeStringToLog:[NSString stringWithFormat:@"Loading project \"%@\" from file \"%@\".", currentProject.name, filePath] :YES];
            
            // Are the loaded and stored paths different?
            
            if ([oldPath compare:currentProject.path] != NSOrderedSame)
            {
                [self writeStringToLog:[NSString stringWithFormat:@"Project file has moved from %@ to %@ since it was last opened.", oldPath, currentProject.path] :YES];
                projectMoved = YES;
            }
            
            // Add the opened project to the array of open projects
            
            [projectArray addObject:currentProject];
            
            // Is the project associated with a product? If so, select it
            
            if (currentProject.pid.length > 0)
            {
                
#pragma mark Opened project is tied to a product
                
                // Project is associated with a product, or is being updated - ie. pid = "old"
                
                if ([currentProject.pid compare:@"old"] == NSOrderedSame)
                {
                    // We have a converted project we probably need to upload becuase it won't
                    // be associated with a product yet, and its device group (see above) won't
                    // have an ID yet either
                    
                    if (ide.isLoggedIn)
                    {
                        // TODO - Ask if the user wants to do this as it may already belong to a product
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        alert.messageText = @"This project has been updated from an earlier version.";
                        alert.informativeText = [NSString stringWithFormat:@"You can upload project “%@’ as a new product, or you may prefer to associate it with an existing product or upload it later. If you see processing errors in the log, you should not upload this project.", currentProject.name];
                        [alert addButtonWithTitle:@"Upload Now"];
                        [alert addButtonWithTitle:@"Later"];
                        [alert setAlertStyle:NSAlertStyleWarning];
                        [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) {
                            if (returnCode == NSAlertFirstButtonReturn) {
                                [self writeStringToLog:[NSString stringWithFormat:@"Uploading project \"%@\" to the impCloud as a product...", currentProject.name] :YES];
                                
                                // Run the transfer as a standard upload, though we bypass uploadProject: at first
                                
                                NSDictionary *dict = @{ @"action" : @"uploadproject",
                                                        @"project" : currentProject };
                                
                                [ide createProduct:currentProject.name :currentProject.description :dict];
                                
                                // Asynchronous pick up in 'createProductStageTwo:' but we continue here
                            }
                        }];
                    }
                    else
                    {
                        // We're not logged in so warn the user
                        // This is important so pop up an alert this time
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        alert.messageText = @"You are not logged in to your account.";
                        alert.informativeText = [NSString stringWithFormat:@"You will need to upload project “%@” manually later, after you have logged in.", currentProject.name];
                        [alert addButtonWithTitle:@"OK"];
                        [alert setAlertStyle:NSAlertStyleWarning];
                        [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) { }];
                    }
                }
                else
                {
                    
#pragma mark Opened project is up to date
                    
                    if (productsArray != nil && productsArray.count > 0)
                    {
                        // We have a list of products so we should check the project against them
                        
                        BOOL match = NO;
                        
                        for (NSMutableDictionary *product in productsArray)
                        {
                            NSString *pid = [self getValueFrom:product withKey:@"id"];
                            
                            if ([pid compare:currentProject.pid] == NSOrderedSame)
                            {
                                // The opened project has a PID and it matches one of the account's known products
                                
                                match = YES;
                                
                                if ((currentProject.aid == nil || currentProject.aid.length == 0))
                                {
                                    // The current project does not have an associated accoint, but since we have a
                                    // match on the ID of a product in the current account, so we can perform the
                                    // association anyway
                                    
                                    if (ide.isLoggedIn)
                                    {
                                        // We can only associate the project with the account if we're logged in
                                        
                                        currentProject.aid = ide.currentAccount;
                                        currentProject.haschanged = YES;
                                        
                                        [saveLight needSave:YES];
                                        [self writeStringToLog:[NSString stringWithFormat:@"Associating project \"%@\" with account ID %@", currentProject.name, currentProject.aid] :YES];
                                    }
                                    
                                    // NOTE If we're not logged in there's not much else we can do
                                    //      to associate the project with an account
                                }
                                else
                                {
                                    // The opened project has an account ID - is it the same as the current account's ID?
                                    
                                    if (ide.isLoggedIn && [currentProject.aid compare:ide.currentAccount] != NSOrderedSame)
                                    {
                                        // Whoops - they don't match so warn the use that they can't work with this project
                                        
                                        [self projectAccountAlert:currentProject :@"**apply changes to this project" :mainWindow];
                                        
                                        // DON'T go on to select the product or set the creator ID as it will be wrong
                                        // Same product ID but wrong account ID
                                        
                                        break;
                                    }
                                }
                                
                                if (currentProject.cid != nil && currentProject.cid.length == 0)
                                {
                                    // We don't have a creator ID stored for the project, so set it to the account ID
                                    // (we can do this because we know what the linked product is)
                                    
                                    currentProject.cid = [product valueForKeyPath:@"relationships.creator.id"];
                                    currentProject.haschanged = YES;
                                    [self writeStringToLog:[NSString stringWithFormat:@"Setting project \"%@\" creator ID to %@", currentProject.name, currentProject.cid] :YES];
                                }
                                
                                // Select the product the project is linked to
                                
                                BOOL done = NO;
                                
                                for (NSMenuItem *item in productsMenu.itemArray)
                                {
                                    if (item.representedObject != nil)
                                    {
                                        if (product == (NSMutableDictionary *)item.representedObject)
                                        {
                                            [self chooseProduct:item];
                                            
                                            break;
                                        }
                                    }
                                    
                                    // Look for a submenu - only the 'Products Shared With You' item should have one,
                                    // which lists the shared products separately
                                    
                                    if (item.submenu != nil)
                                    {
                                        for (NSMenuItem *sitem in item.submenu.itemArray)
                                        {
                                            if (sitem.representedObject != nil)
                                            {
                                                if (product == (NSMutableDictionary *)sitem.representedObject)
                                                {
                                                    [self chooseProduct:sitem];
                                                    
                                                    done = YES;
                                                    break;
                                                }
                                            }
                                        }
                                    }
                                    
                                    if (done) break;
                                }
                                
                                break;
                            }
                        }
                        
#pragma mark Opened project's product is not listed
                        
                        // At this point 'match' will be YES if the project matches a product in the loaded list, or NO if there is no match
                        
                        if (!match)
                        {
                            // The project doesn't match any known product. Perhaps it's on the wrong account, so check
                            
                            if (currentProject.aid != nil &&
                                currentProject.aid.length > 0 &&
                                ide.isLoggedIn)
                            {
                                if ([currentProject.aid compare:ide.currentAccount] != NSOrderedSame)
                                {
                                    // Whoops - they don't match so warn the use that they can't work with this project
                                    
                                    [self projectAccountAlert:currentProject :@"*apply changes to this project" :mainWindow];
                                }
                                
                                // NOTE If account IDs match, we could suggest the user logs in at this point...
                            }
                            
                            // NOTE If we're not logged in, or the project account ID is nil or empty, we can't compare account IDs,
                            //      so there's not much else we can do at this point
                        }
                    }
                    else
                    {
                        // We have no loaded list of products, so we can't see if the project's PID refers to a product
                        // in the current account, but we can check, if we're logged in, that the project account ID and the
                        // current account ID match — if not, we need to warn the user
                        
                        if (ide.isLoggedIn &&
                            currentProject.aid != nil &&
                            currentProject.aid.length > 0 &&
                            [ide.currentAccount compare:currentProject.aid] != NSOrderedSame)
                        {
                            // If the account IDs don't match, then the product ID won't no matter what
                            
                            [self projectAccountAlert:currentProject :@"***apply changes to this project" :mainWindow];
                        }
                    }
                }
            }
            else
            {
                
#pragma mark Opened project is not tied to a product
                
                // The opened project is not assigned to a product
                // If it also has no account affiliation we can ignore it
                
                if (currentProject.aid != nil && currentProject.aid.length > 0)
                {
                    // The opened project has an accout ID we can attempt to match against the logged in account
                    
                    if (ide.isLoggedIn && [currentProject.aid compare:ide.currentAccount] != NSOrderedSame)
                    {
                        // Whoops - they don't match so warn the use that they can't work with this project
                        
                        [self projectAccountAlert:currentProject :@"*apply changes to this project" :mainWindow];
                    }
                }
                else
                {
                    if (ide.isLoggedIn)
                    {
                        // This project doesn't have an account ID, so warn the user
                        
                        NSAlert *alert = [[NSAlert alloc] init];
                        alert.messageText = [NSString stringWithFormat:@"Project “%@” is yet not associated with an Electric Imp Account.", currentProject.name];
                        alert.informativeText = @"Do you wish to associate it with the account you are currently logged in to? If you are not certain that this project relates to this account, you should select ‘No’.";
                        [alert addButtonWithTitle:@"No"];
                        [alert addButtonWithTitle:@"Yes"];
                        
                        Project *aProject = currentProject;
                        
                        [alert beginSheetModalForWindow:mainWindow completionHandler:^(NSModalResponse returnCode) {
                            if (returnCode == NSAlertSecondButtonReturn)
                            {
                                aProject.aid = ide.currentAccount;
                                aProject.haschanged = YES;
                                if (aProject == currentProject) [saveLight needSave:YES];
                                [self writeStringToLog:[NSString stringWithFormat:@"Associating project \"%@\" with account ID %@", aProject.name, aProject.aid] :YES];
                            }
                            
                            // Continue opening the other filesr
                            
                            [self openSquirrelProjects:urls];
                        }];
                        
                        return;
                    }
                }
            }
            
#pragma mark Update the UI with the opened project
            
            // Update the Project menu’s 'openProjectsMenu' sub-menu by adding the project's name
            // (or 'newName' if we are using a temporary name because of a match with a project on the list)
            
            [self addOpenProjectsMenuItem:(newName != nil ? newName : currentProject.name) :currentProject];
            
            // Do we have any device groups in the project?
            
            if (currentProject.devicegroups.count > 0)
            {
                // Choose the first device group in the list
                
                currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
                currentProject.devicegroupIndex = 0;
                
                // Get the device group data, provided we're logged in to the correct account
                
                if (ide.isLoggedIn && [self isCorrectAccount:currentProject])
                {
                    for (Devicegroup *devicegroup in currentProject.devicegroups)
                    {
                        // Update the device group data in case it has changed since the user last logged in
                        
                        NSDictionary *dict = @{ @"action" : @"updatedevicegroup",
                                                @"devicegroup" : devicegroup,
                                                @"project": currentProject };
                        
                        [ide getDevicegroup:devicegroup.did :dict];
                        
                        // Action continues asynchronously at 'updateCodeStageTwo:'
                        
                        // Set the devicegroup's device list
                        
                        [self setDevicegroupDevices:devicegroup];
                    }
                }
                
                // Auto-compile all of the project's device groups, if required by the user
                
                if ([defaults boolForKey:@"com.bps.squinter.autocompile"])
                {
                    [self writeStringToLog:@"Auto-compiling the project's device groups. This can be disabled in Preferences." :YES];
                    
                    for (Devicegroup *devicegroup in currentProject.devicegroups)
                    {
                        if (devicegroup.models.count > 0) [self compile:devicegroup :NO];
                    }
                    
                    // Add the mail project files to the watch list
                    // NOTE compile: adds (via methods) library and other files to the watch queue
                    
                    [self watchfiles:currentProject];
                }
                else
                {
                    // We're not autocompiling the the project, so we just add the known files and libraries to the file-watch queue
                    
                    NSString *modelAbsPath, *modelRelPath;
                    BOOL result;
                    
                    for (Devicegroup *devicegroup in currentProject.devicegroups)
                    {
                        if (devicegroup.models.count > 0)
                        {
                            // Run through the device group's models, if it has any
                            
                            for (Model *model in devicegroup.models)
                            {
                                // Get the model's expected location (this is relative to 'oldPath')
                                
                                modelRelPath = [NSString stringWithFormat:@"%@/%@", model.path, model.filename];
                                
                                NSRange range = [model.path rangeOfString:@"../"];
                                
                                // Is the model file above or below the project file in the hiererchy (expected)
                                
                                if (range.location != NSNotFound)
                                {
                                    // Model file should be above the old project file, get it via old path,
                                    // which will match the new path if the project hasn't moved
                                    
                                    modelAbsPath = [self getAbsolutePath:oldPath :modelRelPath];
                                }
                                else
                                {
                                    // Model file should be below the old project file, so is *probably* below the new one too,
                                    // whether the project has moved or not
                                    
                                    modelAbsPath = [self getAbsolutePath:currentProject.path :modelRelPath];
                                }
                                
#ifdef DEBUG
                                NSLog(@"Model Abs: %@", modelAbsPath);
#endif
                                // Check that the file is where we think it is
                                
                                result = [self checkAndWatchFile:modelAbsPath];
                                modelAbsPath = [modelAbsPath stringByDeletingLastPathComponent];
                                
                                if (!result)
                                {
                                    // We can't locate the model file at the expected location, whether the project has moved or not
                                    
                                    [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Could not find source file \"%@\" at expected location %@.", model.filename, [self getPrintPath:currentProject.path :model.path]] :YES];
                                    
                                    [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" cannot be compiled until this is resolved.", devicegroup.name] :YES];
                                    
                                    model.hasMoved = YES;
                                }
                                else
                                {
                                    // Update the model file location if the project has moved and we found the file using the old project path
                                    
                                    if (projectMoved)
                                    {
                                        if (range.location != NSNotFound)
                                        {
                                            // Model file is still above the project - ie. we found it at oldPath - so recalculate relative path
                                            
                                            model.path = [self getRelativeFilePath:currentProject.path :modelAbsPath];
                                            
                                            [self writeStringToLog:[NSString stringWithFormat:@"Updating saved source file \"%@\" path to %@ - source or project file has moved.", model.filename, [self getPrintPath:currentProject.path :model.path]] :YES];
                                            
                                            currentProject.haschanged = YES;
                                        }
                                    }
                                    
                                    // Now check the subsidiary files
                                    // NOTE These are just the known locations - they may not reflect what is actually
                                    // in the file, which is which is why we compile on load as the default
                                    
                                    if (model.libraries.count > 0)
                                    {
                                        for (File *file in model.libraries)
                                        {
                                            [self checkFiles:file :oldPath :@"library" :devicegroup :projectMoved];
                                        }
                                    }
                                    
                                    if (model.files.count > 0)
                                    {
                                        for (File *file in model.files)
                                        {
                                            [self checkFiles:file :oldPath :@"file" :devicegroup :projectMoved];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            else
            {
                currentDevicegroup = nil;
                currentProject.devicegroupIndex = -1;
            }
            
            // Select the first device assigned to this project's first device group
            // NOTE This will update the UI ticks
            
            [self selectFirstDevice];
            
            // Update the UI:
            // The 'Projects' menu and its 'Open Projects' submenu
            // The 'Device Groups' menu and its 'Project's Device Groups' submenu
            // The 'Device' menu (because the Device Group will have changed)
            // The Toolbar
            
            [self refreshProjectsMenu];
            [self refreshOpenProjectsSubmenu];    // Need this or we crash in refreshDeviceGroupsSubmenu: TODO - check why
            [self refreshDeviceGroupsMenu];
            [self refreshDeviceGroupsSubmenu];
            [self refreshDeviceMenu];
            [self setToolbar];
            
            // Set the status light - light is YES to be not greyed out; full is YES (solid) or NO (empty)
            
            [saveLight show];
            [saveLight needSave:currentProject.haschanged];
            
            // Add the newly opened project to the recent files list
            
            [self addToRecentMenu:currentProject.filename :currentProject.path];
            
            // Update the Inspector
            
            iwvc.project = currentProject;
        }
    }
    else
    {
        // Project didn't load for some reason so warn the user
        
        [self writeErrorToLog:[NSString stringWithFormat:@"Could not load project file \"%@\".", fileName] :YES];
    }
    
    // Call the method again in case there are any URLs left to deal with
    // NOTE The 'urls' list is tested at the start of the method
    
    [self openSquirrelProjects:urls];
}



- (void)checkFiles:(File *)file :(NSString *)oldPath :(NSString *)type :(Devicegroup *)devicegroup :(BOOL)projectMoved
{
    // Get the path of the file, which is relative to 'oldPath'
    
    NSString *fileAbsPath = nil;
    NSString *fileRelPath = [NSString stringWithFormat:@"%@/%@", file.path, file.filename];
    
    NSRange range = [file.path rangeOfString:@"../"];
    
    if (range.location != NSNotFound)
    {
        // File is above the project file in the hierarchy
        
        fileAbsPath = [self getAbsolutePath:oldPath :fileRelPath];
    }
    else
    {
        // File is below the project file in the hierarchy
        
        fileAbsPath = [self getAbsolutePath:currentProject.path :fileRelPath];
    }
    
#ifdef DEBUG
    NSLog(@"%@ Rel: %@-%@", type, file.path, file.filename);
    NSLog(@"%@ Abs: %@", type, fileAbsPath);
#endif
    
    BOOL result = [self checkAndWatchFile:fileAbsPath];
    fileAbsPath = [fileAbsPath stringByDeletingLastPathComponent];
    
    if (!result)
    {
        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Could not find %@ \"%@\" at expected location %@ - source or project file has moved.", type, file.filename, [self getPrintPath:currentProject.path :file.path]] :YES];
        
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" cannot be compiled until this is resolved.", devicegroup.name] :YES];
        
        file.hasMoved = YES;
    }
    else
    {
        if (projectMoved)
        {
            if (range.location != NSNotFound)
            {
                // File is still above the project - ie. we found it at oldPath - so recalculate relative path
                
                file.path = [self getRelativeFilePath:currentProject.path :fileAbsPath];
                
                [self writeStringToLog:[NSString stringWithFormat:@"Updating stored %@ \"%@/%@\" - source or project file has moved.", type, [self getPrintPath:currentProject.path :file.path], file.filename] :YES];
                
                currentProject.haschanged = YES;
                iwvc.project = currentProject;
                
#ifdef DEBUG
                NSLog(@"N: %@", file.path);
#endif
                
            }
        }
    }
}



- (BOOL)checkProjectPaths:(Project *)byProject :(NSString *)orProjectPath
{
    // Method runs through the list of open projects and returns YES if the
    // passed project's full path matches one of them, otherwise NO
    
    if (projectArray.count > 0)
    {
        for (Project *aProject in projectArray)
        {
            NSString *aPath = [NSString stringWithFormat:@"%@/%@", aProject.path, aProject.filename];
            
            if (orProjectPath != nil && [orProjectPath compare:aPath] == NSOrderedSame) return YES;
            
            if (byProject != nil)
            {
                NSString *bPath = [NSString stringWithFormat:@"%@/%@", byProject.path, byProject.filename];
                
                if ([bPath compare:aPath] == NSOrderedSame) return YES;
            }
        }
    }
    
    return NO;
}



- (BOOL)checkProjectNames:(Project *)byProject :(NSString *)orName
{
    // Method runs through the list of open projects and returns YES if the
    // passed project matches one of them, otherwise NO
    
    if (projectArray.count > 0)
    {
        for (Project *aProject in projectArray)
        {
            if (byProject != nil && orName == nil)
            {
                // Caller has passed just a project
                
                if ([byProject.name compare:aProject.name] == NSOrderedSame) return YES;
            }
            else if (byProject == nil && orName != nil)
            {
                // Caller has passed just a name string
                
                if ([orName compare:aProject.name] == NSOrderedSame) return YES;
            }
            else
            {
                // Caller has passed a project AND a name, that if the name matches
                // on projects that are NOT the passed one
                
                if ([orName compare:aProject.name] == NSOrderedSame && byProject != aProject) return YES;
            }
        }
    }
    
    return NO;
}



#pragma mark - Add Model Files To Device Groups Methods


- (IBAction)selectFile:(id)sender
{
    // Called by 'Add Files to Device Group...' File menu item
    // If no current project is selected, warn and bail - but we shouldn't
    // do this because the menu will be disabled on 'currentProject' = nil
    
    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }
    
    // FROM 2.3.128
    // Make sure we have a path for the current project. If not, ask the user to save the project first
    if (currentProject.path == nil || currentProject.path.length == 0)
    {
        [self unsavedAlert:currentProject.name :@"adding source code files to its device groups" :mainWindow];
        return;
    }
    
    // Set up an open panel
    
    openDialog = [NSOpenPanel openPanel];
    openDialog.message = @"Select Squirrel source code (*.agent.nut/*.device.nut) file(s)...";
    openDialog.allowedFileTypes = [NSArray arrayWithObjects:@"nut", nil];
    openDialog.allowsMultipleSelection = YES;
    
    // Set the panel's accessory view checkbox to OFF - ie. don't create a new device group
    // Unless we don't have a current device group - ie. the current project has no groups yet
    
    if (currentDevicegroup != nil)
    {
        accessoryViewNewProjectCheckbox.state = NSOffState;
        accessoryViewNewProjectCheckbox.title = [NSString stringWithFormat:@"Create a new device group with the file(s) – or uncheck to add the file(s) to group \"%@\"", currentDevicegroup.name];
    }
    else
    {
        accessoryViewNewProjectCheckbox.state = NSOnState;
        accessoryViewNewProjectCheckbox.title = @"Create a new device group with the file(s)";
    }
    
    // Add the accessory view to the panel
    
    openDialog.accessoryView = accessoryView;
    if (sysVer.majorVersion >= 10 && sysVer.minorVersion >= 11) openDialog.accessoryViewDisclosed = YES;
    
    // Show the panel
    
    [self presentOpenFilePanel:kActionOpenWithAddFiles];
}



- (IBAction)newDevicegroupCheckboxHander:(id)sender
{
    // This is called if the state of 'accessoryViewNewProjectCheckbox' changes
    
    if (accessoryViewNewProjectCheckbox.state == NSOffState && currentDevicegroup == nil)
    {
        // There's no point adding files to a non-existent and non-created device group
        
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"You have no device group selected. To add files, you must create a new device group for the added files";
        alert.informativeText = @"Alternatively, cancel the process and create a new device group separately.";
        [alert beginSheetModalForWindow:openDialog
                      completionHandler:^(NSModalResponse response)
         {
             accessoryViewNewProjectCheckbox.state = NSOnState;
         }
         ];
    }
}



- (IBAction)endSourceTypeSheet:(id)sender
{
    // Triggered by clicking 'Agent Code' or 'Device Code' in the 'sourceTypeSheet' dialog
    
    NSString *type = (sender == sourceTypeDeviceButton) ? @"device" : @"agent";
    
    [mainWindow endSheet:sourceTypeSheet];
    [self processAddedFilesStageTwo:saveUrls :type];
    
    saveUrls = nil;
}



- (IBAction)cancelSourceTypeSheet:(id)sender
{
    // User has cancelled
    // TODO - Just this file or all of them?
    
    [mainWindow endSheet:sourceTypeSheet];
    
    // Remove the current file and process the next
    
    [saveUrls removeObjectAtIndex:0];
    [self processAddedFiles:saveUrls];
    
    saveUrls = nil;
}



- (void)processAddedFiles:(NSMutableArray *)urls
{
    // Each pass through this method, we process reduce the number of urls in the array
    // NOTE we always come here to exit the file handling process via the following line
    
    if (urls.count == 0)
    {
        // All the selected files have been processed - what do we do now?
        
        if (accessoryViewNewProjectCheckbox.state == NSOnState && !newDevicegroupFlag)
        {
            // User asked to create a new device group for the added files so we handle that first
            // NOTE We only do this once, by checking 'newDevicegroupFlag' = NO
            // NOTE 'urls' is retained even though its .count is 0 so that what this method
            // is re-called, we come back here
            
            newDevicegroupFlag = YES;
            saveUrls = urls;
            
            // Name the new device group
            // NOTE it is already created and set to 'currentDevicegroup'
            
            [self newDevicegroup:self];
            
            // Pick up the action at 'newDevicegroup:' This will present the new device group dialog from which
            // the user either cancels - and no files are added - or a new device group is created and to which
            // the file URLs in 'saveUrls' are then added. Bail to prevent file URLs being processed in the meantime
            
            return;
        }
        
        // We've processed all the input files. If we created a new device group we have to
        // check that then end the process - or just end it
        
        if (newDevicegroupFlag)
        {
            // We created a new device group while adding files, so we need to update the UI
            // TODO probably don't need to do this as it's handled in the 'add devicegroup' phase
            
            newDevicegroupFlag = NO;
            saveUrls = nil;
            
            currentProject.haschanged = YES;
            iwvc.project = currentProject;
            
            [saveLight needSave:YES];
        }
        
        // Compile added files if required
        
        if ([defaults boolForKey:@"com.bps.squinter.autocompile"]) [self compile:currentDevicegroup :NO];
        
        // Update the UI
        
        [self refreshOpenProjectsSubmenu];
        [self refreshDeviceGroupsSubmenu];
        [self refreshDeviceGroupsMenu];
        [self setToolbar];
        
        return;
    }
    
    // Determine the type of file: device or agent
    
    NSString *fileType = @"";
    NSString *filePath = [[urls firstObject] path];
    NSString *fileName = [filePath lastPathComponent];
    
    [self writeStringToLog:[NSString stringWithFormat:@"Processing file: \"%@\".", filePath] :YES];
    
    // Try and identify the source type: is the file a *.device.nut file?
    
    NSRange range = [fileName rangeOfString:@"device.nut"];
    
    if (range.location != NSNotFound)
    {
        // Filename contains 'device.nut'
        
        fileType = @"device";
    }
    else
    {
        // Filename doesn't contain 'device.nut', so check for 'agent.nut'
        
        range = [fileName rangeOfString:@"agent.nut"];
        
        if (range.location != NSNotFound)
        {
            // Filename contains 'agent.nut'
            
            fileType = @"agent";
        }
        else
        {
            // Filename contains neither 'agent.nut' or 'device.nut' so is unknown
            // Just warn the user but take no other action - ie. end up with an empty file
            
            range = [fileName rangeOfString:@".class"];
            
            if (range.location != NSNotFound)
            {
                [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" seems to be a class or library. It should be imported into your device or agent code using \'#import <filename>\'.", fileName] :YES];
            }
            else
            {
                range = [fileName rangeOfString:@".lib"];
                
                if (range.location != NSNotFound)
                {
                    [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" seems to be a class or library. It should be imported into your device or agent code using \'#import <filename>\'.", fileName] :YES];
                }
            }
        }
    }
    
    if (fileType.length == 0)
    {
        // The file we processed couldn't be identified, so let's ask the user what it is
        // TODO convert to an app-specific dialog to avoid default button?
        
        saveUrls = urls;
        sourceTypeLabel.stringValue = [NSString stringWithFormat:@"Does the source file “%@” contain agent or device code?", fileName];
        
        [mainWindow beginSheet:sourceTypeSheet completionHandler:nil];
    }
    else
    {
        // Move on to the next stage of file processing
        
        [self processAddedFilesStageTwo:urls :fileType];
    }
}



- (void)processAddedFilesStageTwo:(NSMutableArray *)urls :(NSString *)fileType
{
    // This method takes the current list if URLs of files to be added, plus the type of the first
    // (set via 'processAddedFiles:') and adds it to the current device group according to type.
    // For each file, a model of the identified type is created (or updated, if a comparable model
    // already exists (we check with the user first that they want to update the model)
    
    NSString *filePath = [[urls firstObject] path];
    
    // If we identified agent or device code from the filename(s), save the path(s) to those file(s)
    
    if (currentDevicegroup.models == nil) currentDevicegroup.models = [[NSMutableArray alloc] init];
    
    NSMutableArray *models = currentDevicegroup.models;
    
    BOOL flag = NO;
    
    if (models.count > 0)
    {
        for (Model *model in models)
        {
            if ([model.type compare:fileType] == NSOrderedSame)
            {
                flag = YES;
                
                if (model.path != nil)
                {
                    // We already have a source code file reference, so ask if the user wants to use the new one
                    
                    NSAlert *alert = [[NSAlert alloc] init];
                    alert.messageText = [NSString stringWithFormat:@"Device group “%@” already has %@ code. Do you wish to replace it?", currentDevicegroup.name, fileType];
                    [alert addButtonWithTitle:@"Yes"];
                    [alert addButtonWithTitle:@"No"];
                    [alert beginSheetModalForWindow:mainWindow
                                  completionHandler:^(NSModalResponse response)
                     {
                         if (response == NSAlertFirstButtonReturn)
                         {
                             // User wants to replace the existing code file
                             // Remove the current file from the watch queue
                             
                             [fileWatchQueue removePath:[self getAbsolutePath:currentProject.path :[model.path stringByAppendingPathComponent:model.filename]]];
                             
                             // Add the new file to the model
                             
                             model.filename = [filePath lastPathComponent];
                             model.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];
                             
                             currentProject.haschanged = YES;
                             iwvc.project = currentProject;
                             
                             [saveLight needSave:YES];
                             [self checkAndWatchFile:filePath];
                         }
                         
                         // We may still have files to process, so go on to the next one
                         
                         [urls removeObjectAtIndex:0];
                         [self processAddedFiles:urls];
                     }
                     ];
                    
                    // Bail so that we stop processing the current and later file URLs while the NSAlert is up
                    
                    return;
                }
                else
                {
                    // We have a model in this device group of the required type, but it has no path, so just add the file to the model
                    
                    model.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];
                    model.filename = [filePath lastPathComponent];
                    
                    [self checkAndWatchFile:filePath];
                    
                    break;
                }
            }
        }
        
        if (!flag)
        {
            // We haven't got a model of the required type, so create a new one for that type
            
            Model *newModel = [[Model alloc] init];
            newModel.type = fileType;
            newModel.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];
            newModel.filename = [filePath lastPathComponent];
            [currentDevicegroup.models addObject:newModel];
            [self checkAndWatchFile:filePath];
        }
    }
    else
    {
        // The device group has no models at all, so we need to make one and set it to the required type
        
        Model *newModel = [[Model alloc] init];
        newModel.type = fileType;
        newModel.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];
        newModel.filename = [filePath lastPathComponent];
        [currentDevicegroup.models addObject:newModel];
        [self checkAndWatchFile:filePath];
    }
    
    // Having added the first file on the current list, we remove it from the list
    // then re-call the method to proces the next file on the list
    
    [urls removeObjectAtIndex:0];
    [self processAddedFiles:urls];
}




#pragma mark - Project Saving Methods


- (IBAction)saveProjectAs:(id)sender
{
    // This method can be called by menu, to save the current project,
    // or directly if 'savingProject' is pre-set
    
    if (sender == fileSaveAsMenuItem || sender == fileSaveMenuItem) savingProject = currentProject;
    
    if (savingProject == nil)
    {
        [self writeWarningToLog:@"[WARNING] You have not selected a project to save." :YES];
        return;
    }
    
    // Flag that we're willing to overwrite the current project
    // NOTE This is separate from the first line, above, as we may have entered from
    //      neither of the listed senders
    
    if (savingProject == currentProject) saveAsFlag = YES;
    
    // Configure the NSSavePanel to save the project
    
    saveProjectDialog = [NSSavePanel savePanel];
    saveProjectDialog.nameFieldStringValue = savingProject.filename;
    saveProjectDialog.canCreateDirectories = YES;
    saveProjectDialog.directoryURL = [NSURL fileURLWithPath:workingDirectory isDirectory:YES];
    
    [saveProjectDialog beginSheetModalForWindow:mainWindow
                              completionHandler:^(NSInteger result)
     {
         // Close sheet first to stop it hogging the event queue
         
         [NSApp stopModal];
         [NSApp endSheet:saveProjectDialog];
         [saveProjectDialog orderOut:self];
         
         // Check what button was clicked - was it 'Save'?
         
         if (result == NSFileHandlingPanelOKButton) [self savePrep:[saveProjectDialog directoryURL] :[saveProjectDialog nameFieldStringValue]];
         
         // NOTE A click on 'Cancel' just ends the dialog run loop
     }
     ];
    
    [NSApp runModalForWindow:saveProjectDialog];
    [saveProjectDialog makeKeyWindow];
}



- (IBAction)saveProject:(id)sender
{
    // Call this method to save the current project by overwriting the previous version
    // This method should only be called by menu, to save the current project, which is added to the save list
    // NOTE 'savingProject' may already be set (eg. by 'saveChanges:') in which case caller should pass
    //      in nil as the sender
    
    if (sender == fileSaveMenuItem) savingProject = currentProject;
    
    if (savingProject == nil)
    {
        [self writeWarningToLog:@"[WARNING] You have not selected a project to save." :YES];
        return;
    }
    
    // Do we need to save the project file? If there have been no changes, then no
    
    if (!savingProject.haschanged) return;
    
    // Do we have a place to save the project file
    
    if (savingProject.path == nil || savingProject.path.length == 0)
    {
        // Current project has no saved path (ie. it hasn't yet been saved or opened)
        // so force a Save As...
        
        [self saveProjectAs:sender];
        return;
    }
    
    // Handle the save
    // NOTE 'path' does not include the filename (we add it in 'savePrep:')
    
    [self savePrep:[NSURL fileURLWithPath:savingProject.path] :nil];
}



- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName
{
    // Save the 'savingProject] project. This may be a newly created project and may not
    // necessarily be 'currentProject'
    
    BOOL success = NO;
    NSString *savePath = [saveDirectory path];
    
    if (newFileName == nil)
    {
        // No filename passed in, so we must have come from 'saveProject:'
        
        if (savingProject.filename != nil)
        {
            // We have an existing filename - use it
            
            newFileName = savingProject.filename;
        }
        else
        {
            // We have no saved filename and no passed in filename, so create one
            
            newFileName = [savingProject.name stringByAppendingString:@".squirrelproj"];
        }
    }
    else
    {
        // We have come from 'saveProjectAs:'
        
        // First add '.squirrelproj' to the specified file name if it has been removed
        
        NSRange r = [newFileName rangeOfString:@".squirrelproj"];
        
        if (r.location == NSNotFound) newFileName = [newFileName stringByAppendingString:@".squirrelproj"];
        
        if (savingProject.filename != nil)
        {
            // We have an existing filename - is the new one different?
            
            //if ([savingProject.filename compare:newFileName] != NSOrderedSame) nameChange = YES;
        }
    }
    
    savePath = [savePath stringByAppendingString:[NSString stringWithFormat:@"/%@", newFileName]];
    
    // Set the time of the update
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-DD'T'hh:mm:ss.sZ"];
    savingProject.updated = [dateFormatter stringFromDate:[NSDate date]];
    
    if ([nsfm fileExistsAtPath:savePath])
    {
        // The file already exists. We can safely overwrite it because that's what the user intended:
        // They asked for it implicitly with a Save command, or told the Save As... dialog to replace the file
        
        // Write the new version to a separate file
        
        NSString *altPath = [savePath stringByAppendingString:@".new"];
        success = [NSKeyedArchiver archiveRootObject:savingProject toFile:altPath];
        
        if (success)
        {
            // We have successfully written the new file, so we can replace the old one with the new one
            
            [fileWatchQueue removePath:savePath];
            
            NSError *error;
            NSURL *url;
            success = [nsfm replaceItemAtURL:[NSURL fileURLWithPath:savePath]
                               withItemAtURL:[NSURL fileURLWithPath:altPath]
                              backupItemName:nil
                                     options:NSFileManagerItemReplacementUsingNewMetadataOnly
                            resultingItemURL:&url
                                       error:&error];
            
            [fileWatchQueue addPath:savePath];
            
            // Log any error
            
            if (!success) [self writeErrorToLog:[NSString stringWithFormat:@"Could not replace file %@ with %@", savePath, altPath] :YES];
        }
        else
        {
            // Log failure to save as an error
            
            [self writeErrorToLog:[NSString stringWithFormat:@"Could not save file %@", altPath] :YES];
        }
    }
    else
    {
        // The file doesn't already exist at this location so just write it out
        
        success = [NSKeyedArchiver archiveRootObject:savingProject toFile:savePath];
        
        // Log any error
        
        if (!success) [self writeErrorToLog:[NSString stringWithFormat:@"Could not save file %@", savePath] :YES];
    }
    
    if (success == YES)
    {
        // The new file was successfully written
        
        savingProject.path = [savePath stringByDeletingLastPathComponent];
        savingProject.filename = newFileName;
        savingProject.haschanged = NO;
        
        if (savingProject == currentProject)
        {
            // The saved project is the one on view in the UI, so update the save indicator
            
            [saveLight needSave:NO];
            
            // Add the project to the list
            // Don't need to do this is just saving, only save as...
            
            if (saveAsFlag) [self addToRecentMenu:savingProject.filename :savingProject.path];
            
            saveAsFlag = NO;
        }
        
        // If we're immediately resaving a downloaded product after saving its files
        // (which updates the project files), then don't show the 'project saved' message,
        // otherwise do show it
        
        if (!doubleSaveFlag) [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" saved at %@.", savingProject.name, [savePath stringByDeletingLastPathComponent]] :YES];
    }
    else
    {
        [self writeErrorToLog:@"The project file could not be saved." :YES];
        
        // TODO Do we bail at this point, ie. return at this point, not try and save the model files?
        //      eg. savingProject = nil;
    }
    
    // Saved the project, but there may be models to save, eg. from a 'download product' or 'sync product' operation
    
    if (!doubleSaveFlag && savingProject.devicegroups.count > 0)
    {
        // The project to be saved has one or more device groups, so go and check for unsaved files
        
        [self saveModelFiles:savingProject];
        return;
    }
    
    doubleSaveFlag = NO;
    savingProject = nil;
    
    // Did we come here from a 'close project'? If so, re-run to actually close the project
    
    if (closeProjectFlag) [self closeProject:nil];
}



#pragma mark - Unsaved Changes Sheet Methods


- (IBAction)cancelChanges:(id)sender
{
    // The user doesn't care about the changes so close the sheet then tell the system to shut down the app
    // NOTE This is called via the 'you have unsaved changes' dialog
    
    [mainWindow endSheet:saveChangesSheet];
    
    if (!closeProjectFlag)
    {
        // If we haven't come here from the 'Close' menu option, we're here because
        // the app is quitting, so proceed with the quit
        
        [NSApp replyToApplicationShouldTerminate:NO];
    }
    else
    {
        // Cancel the 'close project' operation
        
        closeProjectFlag = NO;
    }
}



- (IBAction)ignoreChanges:(id)sender
{
    // The user doesn't care about the changes so close the sheet then tell the system to shut down the app
    // NOTE This is called via the 'you have unsaved changes' dialog
    
    [mainWindow endSheet:saveChangesSheet];
    
    if (!closeProjectFlag)
    {
        // If we haven't come here from the 'Close' menu option, we're here because
        // the app is quitting, so proceed with the quit
        
        [NSApp replyToApplicationShouldTerminate:YES];
    }
    else
    {
        // Cancel the current 'close project' operation,
        // mark the project as not changed,
        // and re-attempt to close it (bypasses the project changed path)
        
        closeProjectFlag = NO;
        currentProject.haschanged = NO;
        [self closeProject:nil];
    }
}



- (IBAction)saveChanges:(id)sender
{
    // The user wants to save a project's changes when closing that project or quitting the app
    // NOTE This is called via the 'you have unsaved changes' dialog
    
    [mainWindow endSheet:saveChangesSheet];
    
    if (closeProjectFlag)
    {
        // 'closeProjectFlag' is YES if this method has been called when the user
        // wants to close a specific project or is closing them all
        
        savingProject = currentProject;
        
        [self saveProject:nil];
        
        closeProjectFlag = NO;
        return;
    }
    
    // From here on, we're planning to apply a single choice to all open projects
    // This is in the event of an app quit, rather than a close/close all
    
    for (Project *aProject in projectArray)
    {
        // The user wants to save unsaved changes, so run through the projects to see which have unsaved changes
        
        if (aProject.haschanged)
        {
            currentProject = aProject;
            
            // Save the project as if we had clicked the 'Save' menu item
            
            [self saveProject:fileSaveMenuItem];
        }
    }
    
    // Projects saved (or not), we can now tell the app to quit
    
    [NSApp replyToApplicationShouldTerminate:YES];
}



#pragma mark - Save Individual Model Files Methods


- (void)saveModelFiles:(Project *)project
{
    // Save all the model files from a downloaded product or a syncd project
    
    // Make a list of files that need to be saved
    
    NSMutableArray *filesToSave = [[NSMutableArray alloc] init];
    
    for (Devicegroup *dg in project.devicegroups)
    {
        if (dg.models.count > 0)
        {
            for (Model *model in dg.models)
            {
                // Is the model marked as unsaved?
                
                if ([model.filename compare:@"UNSAVED"] == NSOrderedSame)
                {
                    // NOTE we save a model file even if it contains no code - the user may add code later
                    
                    model.path = project.path;
                    model.filename = [dg.name stringByAppendingFormat:@".%@.nut", model.type];
                    
                    [filesToSave addObject:model];
                }
            }
        }
    }
    
    // If we have any files to save, save them now
    
    if (filesToSave.count > 0)
    {
        // Begin saving the files
        
        [self saveFiles:filesToSave :project];
    }
    else
    {
        // Jump straight to 'doneSaving:'
        
        [self doneSaving:project];
    }
}



- (void)saveFiles:(NSMutableArray *)files :(Project *)project
{
    // This method takes an array of .nut files that need to be saved,
    // typically because they have just been downloaded from a sync or
    // the creation of a new project.
    
    // Check at the outset whether there are any files left to save
    
    if (files.count == 0)
    {
        // We're done - all the files have been saved - so handle any exit operations
        // Currently these are only triggered by the provision of a project
        
        if (project != nil) [self doneSaving:project];
        return;
    }
    
    BOOL success = NO;
    Model *file = [files firstObject];
    NSData *data = [file.code dataUsingEncoding:NSUTF8StringEncoding];
    NSString *path = [file.path stringByAppendingFormat:@"/%@", file.filename];
    
    if (![nsfm fileExistsAtPath:path])
    {
        // The file doesn't exist already so try and write it out
        
        success = [nsfm createFileAtPath:path contents:data attributes:nil];
    }
    else
    {
        // The file does exist - this will be dealt with in the next section
        
        path = [path stringByAppendingString:@".new"];
        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" exists in chosen location - renaming file \"%@.new\".", file.filename, file.filename] :YES];
    }
    
    if (success)
    {
        // The file was saved successfully
        
        file.filename = [path lastPathComponent];
        file.path = [self getRelativeFilePath:file.path :[path stringByDeletingLastPathComponent]];
        
        // Removed the saved file from the list
        
        [files removeObjectAtIndex:0];
        [self saveFiles:files :project];
    }
    else
    {
        // Could not save the file, or it's already there, so pop up the Save Panel
        
        [self showFileSavePanel:path :files :project];
    }
}



- (void)showFileSavePanel:(NSString *)path :(NSMutableArray *)files :(Project *)project
{
    // Show the Save Panel when we're trying to save a model file and can't for some reason
    // Typically, this will be because the file already exists
    
    NSString *filename = [path lastPathComponent];
    
    // Configure the NSSavePanel to save the file at the specified path
    
    saveProjectDialog = [NSSavePanel savePanel];
    [saveProjectDialog setNameFieldStringValue:filename];
    [saveProjectDialog setCanCreateDirectories:YES];
    [saveProjectDialog setDirectoryURL:[NSURL fileURLWithPath:project.path isDirectory:YES]];
    [saveProjectDialog beginSheetModalForWindow:mainWindow
                              completionHandler:^(NSInteger result)
     {
         // Close sheet first to stop it hogging the event queue
         
         [NSApp stopModal];
         [NSApp endSheet:saveProjectDialog];
         [saveProjectDialog orderOut:self];
         
         if (result == NSFileHandlingPanelOKButton)
         {
             // Update the current file (ie. the first one in the list)
             // with its name name/location
             
             Model *file = [files firstObject];
             file.path = [[saveProjectDialog directoryURL] absoluteString];
             file.filename = [saveProjectDialog nameFieldStringValue];
         }
         else
         {
             // Handle cancel - do we cancel all saves, or just the current one?
             // Just the current one for now
             
             [files removeObjectAtIndex:0];
         }
         
         // Re-call 'saveFiles:' in order to actually save the file
         // at its new location (or the same one, if the user hit cancel)
         
         [self saveFiles:files :project];
     }
     ];
    
    [NSApp runModalForWindow:saveProjectDialog];
    [saveProjectDialog makeKeyWindow];
}



- (void)doneSaving:(Project *)project
{
    // Clean up after saving for downloaded products or sync'd projects
    // when there have been unsaved files
    
    /*
     if ([downloads indexOfObject:project] != NSNotFound)
     {
     // Project is in the download list, so remove it
     
     [downloads removeObject:project];
     }
     */
    
    // Update the UI
    
    [saveLight show];
    [saveLight needSave:NO];
    
    [self refreshOpenProjectsSubmenu];
    [self refreshProjectsMenu];
    [self refreshDeviceGroupsMenu];
    [self refreshDeviceGroupsSubmenu];
    
    if (project == currentProject) iwvc.project = project;
    
    // We now need to re-save the project file, which now contains the locations
    // of the various model files. We do this programmatically rather than indicate
    // to the user that they need to (re)save the project
    
    project.haschanged = YES;
    savingProject = project;
    doubleSaveFlag = YES;
    
    [self saveProject:nil];
}





@end
