

#import "AppDelegate.h"


@implementation AppDelegate


#pragma mark - Initialization Methods


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	// Set up stock date formatter

    def = [[NSDateFormatter alloc] init];
    def.dateFormat = @"yyyy-MM-dd HH:mm:ss";

    // Initialize app properties

	ide = nil;
	reDeviceIndex = -1;
    reModelIndex = -1;
    currentDevice = -1;
    currentModel = -1;
	logPaddingLength = 0;
    sureSheetResult = NO;
    newModelFlag = NO;
    streamFlag = NO;
    autoRenameFlag = NO;
    showCodeFlag = NO;
    restartFlag = NO;
    fromDeviceSelectFlag = NO;
    projectArray = nil;
    currentProject = nil;
    noProjectsFlag = YES;
    noLibsFlag = YES;
	saveProjectSubFilesFlag = NO;
    selectDeviceFlag = NO;
	unassignDeviceFlag = NO;
	requiresAllowedAnywhereFlag = NO;
	checkModelsFlag = NO;
	eiLibListData = nil;
	eiLibListTask = nil;
	eiLibListTime = nil;

    // Initialize colours

    textColour = NSColor.blackColor;
    backColour = NSColor.whiteColor;

	colors = [[NSMutableArray alloc] init];
	logColors = [[NSMutableArray alloc] init];
	[self setColours];

    // Initialize the UI

    logDeviceCodeMenuItem.menu.autoenablesItems = NO;
    logAgentCodeMenuItem.menu.autoenablesItems = NO;
    externalOpenMenuItem.menu.autoenablesItems = NO;

	// Hide the Dictation and Emoji items in the Edit menu
	
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSDisabledDictationMenuItem"];
	[[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"NSDisabledCharacterPaletteMenuItem"];
	
	// Projects Menu

    projectMenu.autoenablesItems = NO;
    squintMenuItem.enabled = NO;
    uploadMenuItem.enabled = NO;
    cleanMenuItem.enabled = NO;
    projectLinkMenuItem.enabled = NO;
    externalCodeMenu.autoenablesItems = NO;
    externalOpenAgentItem.enabled = NO;
    externalOpenDeviceItem.enabled = NO;
    externalOpenBothItem.enabled = NO;
	copyAgentCodeItem.enabled = NO;
	copyDeviceCodeItem.enabled = NO;

    // Models Menu

    mainModelsMenu.autoenablesItems = NO;
    modelsMenu.autoenablesItems = NO;
    linkMenuItem.enabled = NO;
    saveModelProjectMenuItem.enabled = NO;
    showModelInfoMenuItem.enabled = NO;
    deleteModelMenuItem.enabled = NO;
    assignDeviceModelMenuItem.enabled = NO;
    renameModelMenuItem.enabled = NO;
    showModelCodeMenuItem.enabled = NO;
	restartDevicesModelMenuItem.enabled = NO;
    
    [modelsMenu removeAllItems];
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
    [modelsMenu addItem:item];
    item.enabled = NO;

    // Device Menu

    refreshMenuItem.enabled = YES;
	deviceMenu.autoenablesItems = NO;
    // streamLogsMenuItem.title = @"Start Log";

    for (item in deviceMenu.itemArray) item.enabled = NO;

    // View Menu

    showHideToolbarMenuItem.title = @"Hide Toolbar";
    logDeviceCodeMenuItem.enabled = NO;
    logAgentCodeMenuItem.enabled = NO;

    // Toolbar

    squintItem.onImageName = @"compile";
    squintItem.offImageName = @"compile_grey";
	squintItem.toolTip = @"Compile libraries and files into agent and device code for uploading.";
    newProjectItem.onImageName = @"new";
    newProjectItem.offImageName = @"new_grey";
	newProjectItem.toolTip = @"Create a new Squinter project.";
    infoItem.onImageName = @"info";
    infoItem.offImageName = @"info_grey";
	infoItem.toolTip = @"Display detailed project information.";
    openAllItem.onImageName = @"open";
    openAllItem.offImageName = @"open_grey";
	openAllItem.toolTip = @"Open the project's code and library files in your external editor.";
    viewDeviceCode.onImageName = @"open";
    viewDeviceCode.offImageName = @"open_grey";
	viewDeviceCode.toolTip = @"Display the compiled device code.";
    viewAgentCode.onImageName = @"open";
    viewAgentCode.offImageName = @"open_grey";
	viewAgentCode.toolTip = @"Display the compiled agent code.";
    uploadCodeItem.onImageName = @"upload";
    uploadCodeItem.offImageName = @"upload_grey";
	uploadCodeItem.toolTip = @"Upload the compiled project code to the Electric Imp Cloud.";
    restartDevicesItem.onImageName = @"restart";
    restartDevicesItem.offImageName = @"restart_grey";
	restartDevicesItem.toolTip = @"Force all devices running the project code to reboot.";
    clearItem.onImageName = @"clear";
    clearItem.offImageName = @"clear_grey";
	clearItem.toolTip = @"Clear the log window.";
    copyAgentItem.onImageName = @"copy";
    copyAgentItem.offImageName = @"copy_grey";
	copyAgentItem.toolTip = @"Copy the compiled agent code to the clipboard.";
    copyDeviceItem.onImageName = @"copy";
    copyDeviceItem.offImageName = @"copy_grey";
	copyDeviceItem.toolTip = @"Copy the compiled device code to the clipboard.";
    printItem.onImageName = @"print";
    printItem.offImageName = @"print_grey";
	printItem.toolTip = @"Print the contents of thelog window.";
	refreshModelsItem.onImageName = @"refresh";
	refreshModelsItem.offImageName = @"refresh_grey";
	refreshModelsItem.toolTip = @"Refresh the lists of models and devices from the server";

	streamLogsItem.onImageName = @"flag";
    streamLogsItem.offImageName = @"streamon";
	streamLogsItem.onImageNameGrey = @"flag_grey";
	streamLogsItem.offImageNameGrey = @"streamon_grey";
    streamLogsItem.toolTip = @"Enable or disable live log streaming for the current device.";
	streamLogsItem.isOn = NO;

	// Other UI Items
    
    connectionIndicator.hidden = YES;
	
	[projectsMenu removeAllItems];
    [externalLibsMenu removeAllItems];

    [projectsPopUp removeAllItems];
    [projectsPopUp addItemWithTitle:@"None"];
    projectsPopUp.enabled = NO;

    [devicesPopUp removeAllItems];
    [devicesPopUp addItemWithTitle:@"None"];
    devicesPopUp.enabled = NO;

    item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
    [externalLibsMenu addItem:item];
    [item setEnabled:NO];

    item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
    [projectsMenu addItem:item];
    [item setEnabled:NO];

    [saveLight setFull:YES];
    [saveLight setLight:NO];

    // Set initial working directory to user's Documents folder - this may be changed when we read in the defaults

    NSFileManager *fm = [NSFileManager defaultManager];
    NSURL *dirURL = [fm URLForDirectory:NSDocumentDirectory
                               inDomain:NSUserDomainMask
                      appropriateForURL:nil
                                 create:NO
                                  error:nil];

    workingDirectory = [dirURL path];

    // Set up Key and Value arrays as template for Defaults

    NSArray *keyArray = [NSArray arrayWithObjects:@"com.bps.squinter.workingdirectory", @"com.bps.squinter.windowsize", @"com.bps.squinter.preservews", @"com.bps.squinter.autocompile", @"com.bps.squinter.ak.count", @"com.bps.squinter.autoload", @"com.bps.squinter.toolbarstatus", @"com.bps.squinter.toolbarsize", @"com.bps.squinter.toolbarmode", @"com.bps.squinter.fontNameIndex", @"com.bps.squinter.fontSizeIndex", @"com.bps.squinter.text.red", @"com.bps.squinter.text.blue", @"com.bps.squinter.text.green", @"com.bps.squinter.back.red", @"com.bps.squinter.back.blue", @"com.bps.squinter.back.green", @"com.bps.squinter.autoselectdevice", @"com.bps.squinter.autocheckupdates", @"com.bps.squinter.showboldtext", nil];

    NSArray *objectArray = [NSArray arrayWithObjects:workingDirectory, [NSString stringWithString:NSStringFromRect(_window.frame)], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], @"xxxxxxxxxxxxx", [NSNumber numberWithBool:NO], [NSNumber numberWithBool:YES], [NSNumber numberWithInteger:NSToolbarSizeModeRegular], [NSNumber numberWithInteger:NSToolbarDisplayModeIconAndLabel], [NSNumber numberWithInteger:1], [NSNumber numberWithInteger:12], [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0], [NSNumber numberWithFloat:1.0], [NSNumber numberWithBool:YES], [NSNumber numberWithBool:NO], [NSNumber numberWithBool:NO], nil];

    // Drop the arrays into the Defauts

    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults registerDefaults:appDefaults];

    // Prepare the main window

    if ([defaults boolForKey:@"com.bps.squinter.preservews"])
    {
        NSString *frameString = [defaults stringForKey:@"com.bps.squinter.windowsize"];
        NSRect nuRect = NSRectFromString(frameString);
        [_window setFrame:nuRect display:NO];           // Note: display:YES prevents window from being displayed

        if ([defaults boolForKey:@"com.bps.squinter.toolbarstatus"])
        {
            squinterToolbar.visible = YES;
            showHideToolbarMenuItem.title = @"Hide Toolbar";
        }
        else
        {
            squinterToolbar.visible = NO;
            showHideToolbarMenuItem.title = @"Show Toolbar";
        }
    }
    else
    {
        [_window center];
    }
    
    // Set the Log TextView's font

    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.fontNameIndex"] integerValue];
    NSString *fontName = [self getFontName:index];
    NSInteger fontSize = [[defaults objectForKey:@"com.bps.squinter.fontSizeIndex"] integerValue];
	BOOL isBold = [[defaults objectForKey:@"com.bps.squinter.showboldtext"] boolValue];
	logTextView.font = [self setLogViewFont:fontName :fontSize :isBold];

    float r = [[defaults objectForKey:@"com.bps.squinter.text.red"] floatValue];
    float b = [[defaults objectForKey:@"com.bps.squinter.text.blue"] floatValue];
    float g = [[defaults objectForKey:@"com.bps.squinter.text.green"] floatValue];
    textColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    r = [[defaults objectForKey:@"com.bps.squinter.back.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.back.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.back.green"] floatValue];
    backColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    NSUInteger a = [self perceivedBrightness:backColour];

    if (a < 30)
    {
        [logScrollView setScrollerKnobStyle:NSScrollerKnobStyleLight];
    }
    else
    {
        [logScrollView setScrollerKnobStyle:NSScrollerKnobStyleDark];
    }

    [logTextView setTextColor:textColour];
    [logClipView setBackgroundColor:backColour];

	// Set up AppDelegate's observation of error, start and stop indication notifications

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc	addObserver:self
           selector:@selector(displayError)
               name:@"BuildAPIError"
             object:ide];

    [nc	addObserver:self
           selector:@selector(startProgress)
               name:@"BuildAPIProgressStart"
             object:ide];

    [nc	addObserver:self
           selector:@selector(stopProgress)
               name:@"BuildAPIProgressStop"
             object:ide];

	[nc	addObserver:self
		   selector:@selector(listLogs:)
			   name:@"BuildAPIGotLogs"
			 object:ide];
	
	[nc	addObserver:self
           selector:@selector(presentLogEntry:)
               name:@"BuildAPILogStream"
             object:ide];
	
	[nc	addObserver:self
		   selector:@selector(endLogging:)
			   name:@"BuildAPILogStreamEnd"
			 object:ide];

	[nc	addObserver:self
		   selector:@selector(listModels)
			   name:@"BuildAPIGotModelsList"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(listDevices)
			   name:@"BuildAPIGotDevicesList"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(uploadCodeStageTwo)
			   name:@"BuildAPIPostedCode"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(modelToProjectStageTwo)
			   name:@"BuildAPIGotCodeRev"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(createdModel)
			   name:@"BuildAPIModelCreated"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(renameModelStageTwo)
			   name:@"BuildAPIModelUpdated"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(deleteModelStageTwo)
			   name:@"BuildAPIModelDeleted"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(renameDeviceStageTwo)
			   name:@"BuildAPIDeviceUpdated"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(deleteDeviceStageTwo)
			   name:@"BuildAPIDeviceDeleted"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(restarted)
			   name:@"BuildAPIDeviceRestarted"
			 object:ide];
	
	[nc	addObserver:self
		   selector:@selector(reassigned)
			   name:@"BuildAPIDeviceAssigned"
			 object:ide];
}



- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // If the user launched Squinter by double-clicking a squirrelproj file, this method will be called
    // *before* applicationDidFinishLoading, so we need to instantiate the project array here. If it is
    // nil (ie. applicationDidFinishLoading hasn't yet been called) we know to create it.

    if (projectArray == nil) projectArray = [[NSMutableArray alloc] init];

    // Turn the opened file’s path into an NSURL an add to the array that openFileHandler: expects

    NSArray *array = [NSArray arrayWithObjects:[NSURL fileURLWithPath:filename], nil];
    BOOL success = [self openFileHandler:array :kOpenActionSquirrelProj];
    return success;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // We check for an uninstantiated projectArray because we don't want to zap one already
    // created by application:openFile if that was called before applicationDidFinishLoading,
    // as it would have been if the user launched Squinter with a .squirrelproj file double-click

    if (projectArray == nil) projectArray = [[NSMutableArray alloc] init];
    projectDefines = [[NSMutableDictionary alloc] init];

	// Instantiate an IDE-access object
	
	ide = [[BuildAPIAccess alloc] initForNSURLSession];
    //ide = [[BuildAPIAccess alloc] initForNSURLConnection];
	
	projectIncludes = [[NSMutableArray alloc] init];

	// Load in working directory, reading in the location from the defaults in case it has been changed by a previous launch

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    workingDirectory = [defaults stringForKey:@"com.bps.squinter.workingdirectory"];

	// Set up parallel operation queue and limit it to serial operation

	extraOpQueue = [[NSOperationQueue alloc] init];
	extraOpQueue.maxConcurrentOperationCount = 1;

	// Update UI

	[self updateMenus];
	[self setToolbar];

    [_window makeKeyAndOrderFront:nil];

    if ([defaults boolForKey:@"com.bps.squinter.autoload"]) [self getApps];
	
	// Check for updates if that is requested
	
	if ([defaults boolForKey:@"com.bps.squinter.autocheckupdates"]) [sparkler checkForUpdatesInBackground];
}



#pragma mark - Application Quit Methods


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApp
{
	// Return YES to quit app when user clicks on the close button
    
    return YES;
}



- (NSApplicationTerminateReply)applicationShouldTerminate:(NSNotification *)notification
{
    // Check for unsaved changes
    
    NSUInteger unsavedProjectCount = 0;
    
    for (Project *aProject in projectArray)
    {
        if (aProject.projectHasChanged == YES) ++unsavedProjectCount;
    }
    
    if (unsavedProjectCount == 0)
    {
        // There are no files to save, so shut down
        
        return NSTerminateNow;
    }
    else
    {
        // There are files to save, so we should warn the user

		if (unsavedProjectCount == 1)
        {
            [saveChangesSheetLabel setStringValue:@"1 project has unsaved changes."];
        }
        else
        {
            [saveChangesSheetLabel setStringValue:[NSString stringWithFormat:@"%li projects have unsaved changes.", (long)unsavedProjectCount]];
        }

		// Open the save sheet

        [_window beginSheet:saveChangesSheet completionHandler:nil];

		// Tell the system we'll shutdown shortly

        return NSTerminateLater;
    }
}



#pragma mark - Save Changes Sheet Methods


- (IBAction)cancelChanges:(id)sender
{
    // The user doesn't care about the changes so close the sheet then tell the system to shut down the app

    [_window endSheet:saveChangesSheet];

    if (closeProjectFlag == NO)
    {
        [NSApp replyToApplicationShouldTerminate:NO];
    }
    else
    {
        closeProjectFlag = NO;
    }
}



- (IBAction)ignoreChanges:(id)sender
{
    // The user doesn't care about the changes so close the sheet then tell the system to shut down the app
    
    [_window endSheet:saveChangesSheet];
	
	if (closeProjectFlag == NO)
	{
		[NSApp replyToApplicationShouldTerminate:YES];
	}
	else
	{
		currentProject.projectHasChanged = NO;
		closeProjectFlag = NO;
        [self closeProject:nil];
	}
}



- (IBAction)saveChanges:(id)sender
{
    [_window endSheet:saveChangesSheet];
	
	if (closeProjectFlag)
	{
		// 'closeProjectFlag' is YES if this method has been called when the user
		// wants to save a changed project before closing it or quitting the app

		[self saveProject:nil];
		closeProjectFlag = NO;
		return;
	}
    
    for (Project *aProject in projectArray)
    {
		// The user wants to save unsaved changes, so run through the projects to see which have unsaved changes

		if (aProject.projectHasChanged == YES)
        {
            currentProject = aProject;
            [self saveProject:nil];
        }
    }

	// Projects saved (or not), we can now tell the app to quit

    [NSApp replyToApplicationShouldTerminate:YES];
}



- (void)applicationWillTerminate:(NSNotification *)notification
{
	// Stop watching for file-changes

    [fileWatchQueue removeAllPaths];

	// Kill any connections

	[ide killAllConnections];

    // Record settings that are not set by the Prefs dialog

    NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
    [defaults setValue:workingDirectory forKey:@"com.bps.squinter.workingdirectory"];
    [defaults setValue:NSStringFromRect(_window.frame) forKey:@"com.bps.squinter.windowsize"];

    // Stop watching for notifications

    [[NSNotificationCenter defaultCenter] removeObserver:self];
}



#pragma mark - Full Screen Methods


- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    [_window setStyleMask:NSBorderlessWindowMask];
}



- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    [_window setStyleMask:(NSTitledWindowMask | NSMiniaturizableWindowMask | NSClosableWindowMask)];
    [_window setTitle:@"Squinter"];
}



#pragma mark - New Project Methods


- (IBAction)newProject:(id)sender
{
    newProjectDirLabel.stringValue = [@"Working directory: " stringByAppendingString:workingDirectory];
    newProjectAccessoryViewNewModel.enabled = YES;

	if (currentModel == -1)
	{
        // Can't associate the project with a model if one hasn't been selected so disable this checkbox

        newProjectAccessoryViewAssociateCheckbox.enabled = NO;
	}
	else
	{
        newProjectAccessoryViewAssociateCheckbox.enabled = YES;
	}

    [_window beginSheet:newProjectSheet completionHandler:nil];
}



- (IBAction)newProjectSheetCancel:(id)sender
{
    [_window endSheet:newProjectSheet];
}



- (IBAction)newProjectSheetCreate:(id)sender
{
    NSString *projectName = newProjectTextField.stringValue;
    BOOL rerunPanelFlag = NO;
    
    [_window endSheet:newProjectSheet];
    
    if (projectArray.count > 0)
    {
        // We only need to check the new name against open ones when there *are* open projects
        
        for (Project *aProject in projectArray)
        {
            if ([aProject.projectName compare:projectName] == NSOrderedSame)
            {
                // The name already exists, so re-run the New Project sheet with a suitable message
                
                rerunPanelFlag = YES;
                [newProjectLabel setStringValue:@"A project with that name is already open. Please choose another name, or cancel."];
            }
        }
    }

	if (newProjectAccessoryViewNewModel.state == YES && !rerunPanelFlag)
	{
		// We only need to check the new name against existing models if this box is checked
        // This can only be selected if we're logged in, ie. we have a list of models

        // TODO Really should view the server as the source of truth, but ide.models is close

		for (NSDictionary *model in ide.models)
		{
            NSString *modelName = [model objectForKey:@"name"];
            if ([modelName compare:projectName] == NSOrderedSame)
			{
				// The project has the same name as a known model

				rerunPanelFlag = YES;
				[newProjectLabel setStringValue:@"A model with that name already exists. Please choose another project name, or cancel."];
			}
		}
	}

    if (rerunPanelFlag)
    {
        // Rerun the New Project sheet to get a new name, or process Cancel

        [self newProject:nil];
    }
    else
    {
        // Make a new project

        itemToCreate = nil;
        currentProject = [[Project alloc] init];
        currentProject.projectName = projectName;
        currentDeviceLibCount = 0;
        currentAgentLibCount = 0;

        [projectArray addObject:currentProject];
		
		// Add the new project to the project menu. We've already checked for a name clash,
		// so we needn't care about the return value.
		
        [self addProjectMenuItem:projectName];

        // Enable project-related UI items
		
		[self updateMenus];
        [self setToolbar];
		
		// Clear the external libraries menu - the new project by defenition has none
		
        [externalLibsMenu removeAllItems];

		// Mark the status light as empty, ie. in need of saving

        [saveLight setLight:YES];
		[saveLight setFull:NO];

		// User wants to view the auto-generated agent and device code files, so make sure they're generated

		if (newProjectAccessoryViewFilesCheckbox.state == YES) saveProjectSubFilesFlag = YES;

		if (newProjectAccessoryViewAssociateCheckbox.state == YES)
		{
            // If the 'associate new project with current model' is checked

			if (currentModel != -1)
			{
				// Associate the project with the currently selected model

				NSDictionary *model = [ide.models objectAtIndex:currentModel];
				currentProject.projectModelID = [model objectForKey:@"id"];
			}
			else
			{
				// There is no selected model to associate project with
                // TODO check whether we can even get here (checkbox should be disabled)

				if (newProjectAccessoryViewNewModel.state == YES)
				{
					// So create a new model

					newModelFlag = YES;
					itemToCreate = currentProject.projectName;
					[ide createNewModel:currentProject.projectName];

					// This will pass control to ide, which will asynchronously call createdModel:
				}
			}
		}
        else if (newProjectAccessoryViewNewModel.state == YES)
        {
            // Create a new model (note this can't be selected unless we're logged in,
            // so we don't need to check that we *can* make a model at this point)

            newModelFlag = YES;
            itemToCreate = currentProject.projectName;
			[ide createNewModel:currentProject.projectName];
        }

		// Save project. We save it because we have created files. Or should we? TBD
        // No need to save projectPath here - it will be done by savePrep: (which bypasses dialog)
		
		savingProject = currentProject;
		[self saveProjectAs:nil];

		noProjectsFlag = NO;
    }
}



#pragma mark - Choose and Open Project Methods

- (void)chooseProject:(id)sender
{
    // Select one of the open projects from the Projects sub-menu or the Project menu
    
	NSMenuItem *item;
	NSUInteger itemNumber = 0;
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (sender == currentProject)
	{
		item = [projectsMenu itemWithTitle:currentProject.projectName];
	}
	else if (sender != nil)
	{
		item = (NSMenuItem *)sender;
	}
	else
	{
		item = [projectsMenu itemWithTitle:[projectsPopUp titleOfSelectedItem]];
	}
    
    for (NSUInteger i = 0 ; i < projectArray.count ; ++i)
    {
        Project *project = [projectArray objectAtIndex:i];
        
        if ([project.projectName compare:item.title] == NSOrderedSame)
        {
            // Compare the name of the menu item to the projects' names until we find
            // the one we want to make current
            
            itemNumber = i;
            currentProject = project;
            currentDeviceLibCount = 0;
            currentAgentLibCount = 0;

            // Enable or disable code view menu options whether we have code to view
            
            if (currentProject.projectDeviceCode != nil)
            {
                [logDeviceCodeMenuItem setEnabled:YES];
            }
            else
            {
                [logDeviceCodeMenuItem setEnabled:NO];
            }
            
            if (currentProject.projectAgentCode != nil)
            {
                [logAgentCodeMenuItem setEnabled:YES];
            }
            else
            {
                [logAgentCodeMenuItem setEnabled:NO];
            }
            
            // Update the external library and file menus
            
            [self updateLibraryMenu];
            [self updateFilesMenu];

			// Update the save? indicator

			[saveLight setFull:!currentProject.projectHasChanged];

			// Is the project associated with a model? If so, select it
			
			if (ide.models.count != 0)
			{
				for (NSInteger j = 0 ; j < ide.models.count ; ++j)
				{
					NSDictionary *model = [ide.models objectAtIndex:j];
					NSString *modelCode = [model objectForKey:@"id"];
					
                    if ([modelCode compare:currentProject.projectModelID] == NSOrderedSame)
					{
						NSMenuItem *mitem = [modelsMenu itemAtIndex:j];
                        selectDeviceFlag = YES;
						[self chooseModel:mitem];
                        selectDeviceFlag = NO;
					}
				}
			}
        }
    }
	
    // We've made the selected project the current one, so adjust the project menu's tick marks
    
    for (NSUInteger i = 0; i < projectsMenu.numberOfItems ; ++i)
    {
        // Turn off all the menu items except the current one
        
        item = [projectsMenu itemAtIndex:i];
        
        if (i == itemNumber)
        {
            [item setState:NSOnState];
        }
        else
        {
            [item setState:NSOffState];
        }
    }

	// Update the Project list popup

	NSUInteger index = [projectsPopUp indexOfItemWithTitle:currentProject.projectName];
	[projectsPopUp selectItemAtIndex:index];

	// Update the Menus and the Toolbar (left until now in case models etc are selected)

    [self updateMenus];
	[self setToolbar];

    // Check the preferences in case we need to compile the project we're switching to

	if ([defaults boolForKey:@"com.bps.squinter.autocompile"])
	{
        if (currentProject.projectSquinted == 0)
        {
            // Only compile if necessary

            [self writeToLog:@"Auto-compiling project. This can be disabled in Preferences." :YES];
            [self squint:nil];
        }
	}
}



- (IBAction)pickProject:(id)sender
{
	// Stub to handle UI interaction and call chooseProject: which actually
	// handles project selection

	[self chooseProject:nil];
}



- (IBAction)openProject:(id)sender
{
    // Set up an open panel to request a .squirrelproj file
    
    openDialog = [NSOpenPanel openPanel];
    openDialog.message = @"Select a Squirrel Project file...";
    openDialog.allowedFileTypes = [NSArray arrayWithObjects:@"squirrelproj", nil];
    openDialog.allowsMultipleSelection = YES;
    
    // Set the panel's accessory view checkbox to OFF
    
    [accessoryViewCheckbox setState:NSOffState];
    
    // Hide the accessory view - though it's not shown, openFileHandler: checks its state
    
    [openDialog setAccessoryView:nil];
    [self openFile:kOpenActionSquirrelProj];
}



- (IBAction)selectFile:(id)sender
{
    // Set up an open panel
    
    openDialog = [NSOpenPanel openPanel];
    openDialog.message = @"Select a Squirrel source code file...";
    openDialog.allowedFileTypes = [NSArray arrayWithObjects:@"nut", nil];
    openDialog.allowsMultipleSelection = YES;
    
    // Set the panel's accessory view checkbox to ON - ie. add file to a new project
    
    [accessoryViewCheckbox setState:NSOffState];
    
    // Add the accessory view to the panel
    
    [openDialog setAccessoryView:accessoryView];
    [self openFile:kOpenActionNutFile];
}



- (IBAction)selectFileForProject:(id)sender
{
    // Set up an open panel
    
    openDialog = [NSOpenPanel openPanel];
    openDialog.message = @"Select Agent and Device Squirrel source code files...";
    openDialog.allowedFileTypes = [NSArray arrayWithObjects:@"nut", nil];
    openDialog.allowsMultipleSelection = YES;
    
    // Set the panel's accessory view checkbox to OFF
    
    [accessoryViewCheckbox setState:NSOnState];
    
    // Hide the accessory view - though it's not shown, we still check its checkbox state
    
    [openDialog setAccessoryView:nil];
    [self openFile:kOpenActionNutFiles];
}



- (void)openFile:(NSInteger)openActionType
{
    // Complete the open file dialog settings with generic preferences
    
    openDialog.canChooseFiles = YES;
    openDialog.canChooseDirectories = NO;
	openDialog.delegate = self;
	openDialog.directoryURL = [NSURL fileURLWithPath:workingDirectory isDirectory:YES];
    
    // Run the NSOpenPanel
    
    [openDialog beginSheetModalForWindow:_window
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



- (BOOL)openFileHandler:(NSArray *)urls :(NSInteger)openActionType
{
	// This is where we open/add all files

	Project *newProject;
	NSString *projectName, *fileName, *filePath;
	NSUInteger count;
	BOOL gotFlag;

	if (openActionType == kOpenActionSquirrelProj)
	{
		// We are opening Squirrel project file(s)
		
		for (NSUInteger i = 0 ; i < urls.count ; ++i)
		{
			filePath = [[urls objectAtIndex:i] path];
			newProject = [NSKeyedUnarchiver unarchiveObjectWithFile:filePath];
			gotFlag = NO;
			
			if (newProject)
			{
				// Project loaded from file correctly, but is it already open?
				
				count = 0;

				if (projectArray.count > 0)
				{
					// We have open projects already so check we're not opening an already open one

					for (NSUInteger j = 0 ; j < projectArray.count ; ++j)
					{
						Project *project = [projectArray objectAtIndex:j];
						
						if ([project.projectName compare:newProject.projectName] == NSOrderedSame)
						{
							// The names match, so check the path too
							
							if ([project.projectPath compare:[filePath stringByDeletingLastPathComponent]] == NSOrderedSame)
							{
								// Projects' paths match too, so they are almost certainly the same
								// TODO check for bookmark match?
								
								[self writeToLog:[NSString stringWithFormat:@"[WARNING] The project \"%@\" is already open.", newProject.projectName] :YES];
								gotFlag = YES;
								break;
							}
							else
							{
								// The two projects' paths are different, so they may not be the same; rename the new one
								
								++count;
							}
						}
					}

					// TODO This approach to multiple projects of the same name is a bit crap - find a better one

					if (count > 0) newProject.projectName = [newProject.projectName stringByAppendingFormat:@" %lu", (unsigned long)count];
				}
				
				if (!gotFlag)
				{	
					// Set the newly opened project to be the current one as it's not loaded already
					
					currentProject = newProject;
					Float32 currentProjectVersion = currentProject.projectVersion.floatValue;
					
					// Update the project's path property which is not saved in case the user moves the file
					
					currentProject.projectPath = [filePath stringByDeletingLastPathComponent];

					if (currentProjectVersion > 2.0)
					{
						currentProject.projectBookmark = [self bookmarkForURL:[NSURL URLWithString:filePath]];
					}
					
					// Has the user changed the name of the file?
					
					NSString *aName = [[filePath lastPathComponent] stringByDeletingPathExtension];
					
					if ([aName compare:currentProject.projectName] != NSOrderedSame)
					{
						// The file name has changed so rename the project
						// TODO this is user-optional so should be deprecated
						
						[self writeToLog:[NSString stringWithFormat:@"Project \"%@\" has been renamed \"%@\" to match its filename.", currentProject.projectName, aName] :YES];
						currentProject.projectName = aName;
						currentProject.projectHasChanged = YES;
					}
					
					[self writeToLog:[NSString stringWithFormat:@"Loading project \"%@\" from file \"%@\".", currentProject.projectName, filePath] :YES];
					
					[projectArray addObject:currentProject];

                    // Set up kernel queue to watch for file changes
					
					if (fileWatchQueue == nil)
					{
						fileWatchQueue = [[VDKQueue alloc] init];
						[fileWatchQueue setDelegate:self];
					}
					
					NSFileManager *fm = [NSFileManager defaultManager];
					
					if (currentProjectVersion > 2.0)
					{
						if (currentProject.projectAgentCodeBookmark)
						{
							NSURL *agentCodeURL = [self urlForBookmark:currentProject.projectAgentCodeBookmark];
							currentProject.projectAgentCode = agentCodeURL.absoluteString;
						}

						if (currentProject.projectDeviceCodeBookmark)
						{
							NSURL *deviceCodeURL = [self urlForBookmark:currentProject.projectDeviceCodeBookmark];
							currentProject.projectDeviceCode = deviceCodeURL.absoluteString;
						}
					}

					if (currentProject.projectAgentCodePath != nil)
					{
						// Does the project's recorded agent code path point to a real file?

						if ([fm fileExistsAtPath:currentProject.projectAgentCodePath isDirectory:NO] == YES)
						{
							// It does and the pointer indicates an extant file

							[fileWatchQueue addPath:currentProject.projectAgentCodePath notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
							externalOpenMenuItem.enabled = YES;
							externalOpenAgentItem.enabled = YES;
							externalOpenBothItem.enabled = YES;
						}
						else
						{
							// There is no file where the pointer is indicating, so see if it's in the working directory

							NSString *path = [currentProject.projectAgentCodePath lastPathComponent];
							path = [workingDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", path]];
							
							if ([fm fileExistsAtPath:path isDirectory:NO] == YES)
							{
								// File is in the working directory, so update the saved path

								currentProject.projectAgentCodePath = path;
								[fileWatchQueue addPath:currentProject.projectAgentCodePath notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
								externalOpenMenuItem.enabled = YES;
								externalOpenAgentItem.enabled = YES;
								externalOpenBothItem.enabled = YES;
								[self writeToLog:[NSString stringWithFormat:@"[WARNING] The project’s agent code file has been moved to \"%@\".", path] :YES];
							}
							else
							{
								// Can't see the agent code file in the working directory so clear the pointer and warn the user

								currentProject.projectAgentCodePath = nil;
								[self writeToLog:@"[WARNING] The project’s agent code file has been moved to an unknown location. You will need to add it back to the project." :YES];
							}
							
							currentProject.projectHasChanged = YES;
						}
					}
				
					if (currentProject.projectDeviceCodePath != nil)
					{
						// As above per the agent code file, this time for the device code file

						if ([fm fileExistsAtPath:currentProject.projectDeviceCodePath isDirectory:NO] == YES)
						{
							[fileWatchQueue addPath:currentProject.projectDeviceCodePath notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
							externalOpenMenuItem.enabled = YES;
							externalOpenDeviceItem.enabled = YES;
							externalOpenBothItem.enabled = YES;
						}
						else
						{
							NSString *path = [currentProject.projectDeviceCodePath lastPathComponent];
							path = [workingDirectory stringByAppendingString:[NSString stringWithFormat:@"/%@", path]];
							
							if ([fm fileExistsAtPath:path isDirectory:NO] == YES)
							{
								currentProject.projectDeviceCodePath = path;
								[fileWatchQueue addPath:currentProject.projectDeviceCodePath notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
								externalOpenMenuItem.enabled = YES;
								externalOpenDeviceItem.enabled = YES;
								externalOpenBothItem.enabled = YES;
								[self writeToLog:[NSString stringWithFormat:@"[WARNING] The project’s device code file has been moved to \"%@\".", path] :YES];
							}
							else
							{
								currentProject.projectDeviceCodePath = nil;
								[self writeToLog:@"[WARNING] The project’s device code file has been moved to an unknown location. You will need to add it back to the project." :YES];
							}
							
							currentProject.projectHasChanged = YES;
						}
					}

					// Do we need to autocompile the project we have opened?
					
					if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.bps.squinter.autocompile"])
					{
						// NOTE squint: calls updateLibraryMenu: so we don't need to do it here
						
						[self writeToLog:@"Auto-compiling project. This can be disabled in Preferences." :YES];
						[self squint:nil];  // Currently jumps to squintr:
					}
					else
					{
						// Update the library menus with stored lists

						[self writeToLog:@"Please compile the project to update the library and linked file lists." :YES];
						[self updateLibraryMenu];
                        [self updateFilesMenu];
					}

					// Select the model associated with the project, if one has been

					count = 0;

					if (ide.models.count > 0)
					{
						// If we have loaded the models list, select the one which the project is linked to

						for (NSDictionary *model in ide.models)
						{
							NSString *mID = [model objectForKey:@"id"];
							if ([mID compare:currentProject.projectModelID] == NSOrderedSame)
							{
								// Select the linked model

                                selectDeviceFlag = YES;
								[self chooseModel:[modelsMenu itemAtIndex:count]];
                                selectDeviceFlag = NO;
							}
							else
							{
								++count;
							}
						}
					}

                    // Update the Project menu’s projects sub-menu

                    [self addProjectMenuItem:currentProject.projectName];
					
					// Update the Menus and the Toolbar
					
                    [self updateMenus];
                    [self setToolbar];

					// Finally, set the status light

					[saveLight setLight:YES];
					[saveLight setFull:!currentProject.projectHasChanged];

					// Mark that we have at least one open project

					noProjectsFlag = NO;
				}
			}
			else
			{
				// Project didn't load for some reason so warn the user
				
				[self writeToLog:[NSString stringWithFormat:@"[ERROR] Could not load project file \"%@\".", fileName] :YES];
			}
		}
	}
	else
	{
		// We are opening other, non-project types of file
		
		// Check the number of files selected. If we are using source files to create a project, it should never be more than two
		
		if (urls.count > 2)
		{
			[self writeToLog:@"[ERROR] Too many source files selected for project." :YES];
			[self writeToLog:[NSString stringWithFormat:@"Projects contain only two files: *.agent.nut and *.device.nut. You selected %lu files.", (long)urls.count] :YES];
			return NO;
		}
		
		if (accessoryViewCheckbox.state == NSOnState)
		{
			// This will be set if either we have two source code files from which the user wants to make a project,
			// or the user wants the one file opened to be used as the basis for a new project. So create a new project,
			// make it current and add it to the array of open projects
			
			currentProject = [[Project alloc] init];
			[projectArray addObject:currentProject];
		}
		
		// Clear 'foundLibs' and 'foundFiles' ahead of loading in new source code
		
		if (foundLibs != nil) foundLibs = nil;
		if (foundFiles != nil) foundFiles = nil;
		foundFiles = [[NSMutableArray alloc] init];
		foundLibs = [[NSMutableArray alloc] init];
		
		// Get the current project name; this will be nil for a new project
		
		projectName = currentProject.projectName;
		
		for (NSUInteger i = 0 ; i < urls.count ; ++i)
		{
			// Step through the files passed by the NSOpenPanel; may be only one
			
			BOOL isDeviceCodeFile = NO;
			BOOL isAgentCodeFile = NO;
			
			filePath = [[urls objectAtIndex:i] path];
			fileName = [filePath lastPathComponent];
			
			[self writeToLog:[NSString stringWithFormat:@"Processing file: \"%@\".", filePath] :YES];
			
			// Is the file a *.device.nut file?
			
			NSRange range = [fileName rangeOfString:@"device.nut"];
			
			if (range.location != NSNotFound)
			{
				// Filename contains 'device.nut'
				
				isDeviceCodeFile = YES;
				
				if (projectName == nil)
				{
					// The project name is nil, which means we created a new project earlier for this file and it has
					// yet to be populated with data. Get the name by stripping 'device.nut' from the filename
					
					if (currentProject == nil)
					{
						// User is opening the file into no project, so make one anyway - user doesn't have to save it
						
						[self writeToLog:[NSString stringWithFormat:@"Opening file \"%@\" from “%@”.", projectName, filePath] :YES];
						currentProject = [[Project alloc] init];
						[projectArray addObject:currentProject];
					}
					
					projectName = [fileName stringByReplacingOccurrencesOfString:@".device.nut" withString:@""];
					[self writeToLog:[NSString stringWithFormat:@"Creating project \"%@\" from \"%@\".", projectName, filePath] :YES];
					
					currentProject.projectName = projectName;
					currentProject.projectPath = [filePath stringByDeletingLastPathComponent];
					
					BOOL success = [self addProjectMenuItem:projectName];
					
					if (success == NO)
					{
						// The project's name is already on the Projects menu
						
						// Should allow user to rename [TODO]
						
						[self writeToLog:[NSString stringWithFormat:@"[ERROR] Project \"%@\" already loaded.", projectName] :YES];
						
						if (openActionType == kOpenActionNutFile)
						{
							// We're creating the project from this one file; we can't do so, so kill the new project object
							
							[projectArray removeObject:currentProject];
							currentProject = nil;
						}
						
						return NO;
					}
					else
					{
						[externalLibsMenu removeAllItems];
					}
				}
			}
			else
			{
				// Filename doesn't contain 'device.nut', so check for 'agent.nut'
				
				range = [fileName rangeOfString:@"agent.nut"];
				
				if (range.location != NSNotFound)
				{
					// Filename contains 'agent.nut'
					
					isAgentCodeFile = YES;
					
					if (projectName == nil)
					{
						// The project name is nil, which means we created a new project earlier for this file and it has
						// yet to be populated. Get the name by stripping 'agent.nut' from the filename
						
						if (currentProject == nil)
						{
							// User is opening the file into no project, so make one anyway - user doesn't have to save it
							
							[self writeToLog:[NSString stringWithFormat:@"Opening file \"%@\" from \"%@\".", projectName, filePath] :YES];
							currentProject = [[Project alloc] init];
							[projectArray addObject:currentProject];
						}
						
						projectName = [fileName stringByReplacingOccurrencesOfString:@".agent.nut" withString:@""];
						currentProject.projectName = projectName;
						
						[self writeToLog:[NSString stringWithFormat:@"Creating project \"%@\" from file \"%@\".", projectName, fileName] :YES];
						
						BOOL success = [self addProjectMenuItem:projectName];
						
						if (success == NO)
						{
							// The project's name is already on the Projects menu
							
							// Should allow user to rename [TODO]
							
							[self writeToLog:[NSString stringWithFormat:@"[ERROR] Project \"%@\" already loaded.", projectName] :YES];
							
							if (openActionType == kOpenActionNutFile)
							{
								// We're crearting the project from this one file; we can't do so, so kill the new project object
								
								[projectArray removeObject:currentProject];
								currentProject = nil;
							}
							
							return NO;
						}
						else
						{
							[externalLibsMenu removeAllItems];
						}
					}
				}
				else
				{
					// Filename contains neither 'agent.nut', 'device.nut' or '.squirrelproj' so is unknown - we'll have to ask
					
					range = [fileName rangeOfString:@".class"];
					
					if (range.location != NSNotFound)
					{
						[self writeToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" seems to be a class or library. It should be imported into your device or agent code using \'#import <filename>\'.", fileName] :YES];
						
						if (accessoryViewCheckbox.state == NSOnState)
						{
							// We created a project for this invalid file, so remove it
							
							[projectArray removeObject:currentProject];
							currentProject = nil;
						}
					}
					else
					{
						range = [fileName rangeOfString:@".lib"];
						
						if (range.location != NSNotFound)
						{
							[self writeToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" seems to be a class or library. It should be imported into your device or agent code using \'#import <filename>\'.", fileName] :YES];
							
							if (accessoryViewCheckbox.state == NSOnState)
							{
								// We created a project for this invalid file, so remove it
								
								[projectArray removeObject:currentProject];
								currentProject = nil;
							}
						}
						else
						{
							// Filename is not valid at all - but should never get here
							
							return NO;
						}
					}
				}
			}
			
			// If we identified agent or device code from the filename(s), save the path(s) to those file(s)
			
			if (isDeviceCodeFile == YES)
			{
				currentProject.projectDeviceCodePath = filePath;
				currentProject.projectHasChanged = YES;
				externalOpenMenuItem.enabled = YES;
                externalOpenDeviceItem.enabled = YES;
                externalOpenBothItem.enabled = YES;
				squintMenuItem.enabled = YES;
				[fileWatchQueue addPath:filePath];
				[self processSource:currentProject.projectDeviceCodePath :kCodeTypeDevice :NO];
			}
			else if (isAgentCodeFile == YES)
			{
				currentProject.projectAgentCodePath = filePath;
				currentProject.projectHasChanged = YES;
                externalOpenMenuItem.enabled = YES;
                externalOpenAgentItem.enabled = YES;
                externalOpenBothItem.enabled = YES;
                squintMenuItem.enabled = YES;
                [fileWatchQueue addPath:filePath];
				[self processSource:currentProject.projectAgentCodePath :kCodeTypeAgent :NO];
			}
		}
	
		// Update libraries menu with updated list of libraries
		
		[self processLibraries];
		[self updateLibraryMenu];
		[self updateFilesMenu];
		
		if (currentProject == nil) return NO;
		
		// Did we change the current project at all? Signal if we did
		
        [saveLight setFull:!currentProject.projectHasChanged];
        [saveLight setLight:YES];
		
		if (currentProject.projectAgentCodePath == nil && currentProject.projectDeviceCodePath == nil) [externalOpenMenuItem setEnabled:NO];
		
		// At this point, a new project should have a name and paths to device and/or agent code files.
		// If loaded from a squirrelproj file, it should also have a path.
	}
	
	return YES;
}



#pragma mark - Save Project Methods


- (IBAction)saveProjectAs:(id)sender
{
    // Call this method to save the project referenced by savingProject to disk a new name and/or location
	
	// If the method is called directly by a menu, set savingProject to currentProject
	
	if (sender == fileSaveAsMenuItem || sender == fileSaveMenuItem) savingProject = currentProject;
    if (savingProject == nil) return;
    
    // Configure the NSSavePanel.
    
    saveProjectDialog = [NSSavePanel savePanel];
    [saveProjectDialog setNameFieldStringValue:[savingProject.projectName stringByAppendingString:@".squirrelproj"]];
    [saveProjectDialog setCanCreateDirectories:YES];
    [saveProjectDialog setDirectoryURL:[NSURL fileURLWithPath:workingDirectory isDirectory:YES]];
    
    [saveProjectDialog beginSheetModalForWindow:_window
                              completionHandler:^(NSInteger result)
     {
         // Close sheet first to stop it hogging the event queue
         
         [NSApp stopModal];
         [NSApp endSheet:saveProjectDialog];
         [saveProjectDialog orderOut:self];
         
         if (result == NSFileHandlingPanelOKButton) [self savePrep:[saveProjectDialog directoryURL] :[saveProjectDialog nameFieldStringValue]];
     }
     ];
    
    [NSApp runModalForWindow:saveProjectDialog];
}



- (IBAction)saveProject:(id)sender
{
    // Call this method to save the current project by overwriting the previous version
    
	// If the method is called directly by a menu, set savingProject to currentProject
	
	if (sender == fileSaveAsMenuItem || sender == fileSaveMenuItem || closeProjectFlag) savingProject = currentProject;
	if (savingProject == nil) return;
	
	if (savingProject.projectPath == nil)
    {
        // Current project has no saved path (ie. it hasn't yet been saved or opened)
        // so force a Save As...
        
		[self saveProjectAs:nil];
        return;
    }
    
    // Do we need to save? If there have been no changes, then no
    
    if (savingProject.projectHasChanged == NO) return;
        
    // Handle the save. Note projectPath property does not include the filename (we add it in savePrep:)
    
    [self savePrep:[NSURL fileURLWithPath:savingProject.projectPath] :nil];
}



- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName
{
	// Save the savingProject project. This may be a newly created project and may not currentProject
	
	BOOL success = NO;
	
	NSFileManager *fm = [NSFileManager defaultManager];
    NSString *savePath = [saveDirectory path];
	NSString *oldName = savingProject.projectName;
	
	if (newFileName == nil) newFileName = savingProject.projectName;
	
	NSRange range = [newFileName rangeOfString:@".squirrelproj"];
	if (range.location == NSNotFound) newFileName = [newFileName stringByAppendingString:@".squirrelproj"];
	savePath = [savePath stringByAppendingString:[NSString stringWithFormat:@"/%@", newFileName]];
	
	// Update the project's name - we do this in case the passed newFileName has a file extension, which it might
	
	range = [newFileName rangeOfString:@".squirrelproj"];
	savingProject.projectName = [newFileName substringToIndex:range.location];
	
	// Set the agent and device code paths. We need to do this here because they are saved with the project file
	
	if (saveProjectSubFilesFlag == YES)
	{
        // 'saveProjectSubFilesFlag' is set by newProject: if the user has selected the option to create
        // agent and device code files automatically

        NSString *aFileName = [savingProject.projectName stringByAppendingString:@".agent.nut"];
		NSString *aPathName = [[savePath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@", aFileName];
		savingProject.projectAgentCodePath = aPathName;
		
		NSString *dFileName = [savingProject.projectName stringByAppendingString:@".device.nut"];
		NSString *dPathName = [[savePath stringByDeletingLastPathComponent] stringByAppendingFormat:@"/%@", dFileName];
		savingProject.projectDeviceCodePath = dPathName;

		if (savingProject.projectVersion.floatValue > 2.0)
		{
			NSData *acbm = [self bookmarkForURL:[NSURL URLWithString:savingProject.projectAgentCodePath]];
			if (acbm != nil) savingProject.projectAgentCodeBookmark = acbm;

			NSData *dcbm = [self bookmarkForURL:[NSURL URLWithString:savingProject.projectDeviceCodePath]];
			if (dcbm != nil) savingProject.projectDeviceCodeBookmark = dcbm;
		}
	}

    if ([fm fileExistsAtPath:savePath])
    {
        // The file already exists. We can safely overwrite it because that's what the user intended:
        // They asked for it implicitly with a Save command, or told the Save As... dialog to replace the file
        
        // Write the new version to a separate file
        
        NSString *altPath = [savePath stringByAppendingString:@".new"];
        success = [NSKeyedArchiver archiveRootObject:savingProject toFile:altPath];
        
        if (success)
        {
            // We have successfully written the new file, so we can replace the old one with the new one
            
            NSError *error;
            NSURL *url;
            success = [fm replaceItemAtURL:[NSURL fileURLWithPath:savePath]
                             withItemAtURL:[NSURL fileURLWithPath:altPath]
                            backupItemName:nil
                                   options:NSFileManagerItemReplacementUsingNewMetadataOnly
                          resultingItemURL:&url
                                     error:&error];
		}
    }
    else
    {
        // The file doesn't already exist at this location so just write it out
        
        success = [NSKeyedArchiver archiveRootObject:savingProject toFile:savePath];
    }
	
	if (success == YES)
	{
		// The new file was successfully written
		
		savingProject.projectPath = [savePath stringByDeletingLastPathComponent];

		if (savingProject.projectVersion.floatValue > 2.0)
		{
			NSData *pbm = [self bookmarkForURL:[NSURL URLWithString:savePath]];
			if (pbm != nil) savingProject.projectBookmark = pbm;
		}
		
		if (savingProject == currentProject) 
		{
			savingProject.projectHasChanged = NO;
			[saveLight setFull:!savingProject.projectHasChanged];
			
			// Now it's safe to switch the project’s listing in the project menu, but since we
			// may be coming here after saving a new project, compare the names first

			if ([oldName compare:savingProject.projectName] != NSOrderedSame)
			{
				NSMenuItem *item = [projectsMenu itemWithTitle:oldName];
				[projectsMenu removeItem:item];
				[self addProjectMenuItem:savingProject.projectName];
				
				NSInteger index = [projectsPopUp indexOfItemWithTitle:oldName];
				[projectsPopUp removeItemAtIndex:index];
				[projectsPopUp addItemWithTitle:savingProject.projectName];
			}
		}
		
		if (saveProjectSubFilesFlag == YES)
		{
			// We are saving a new project or one derived from a model, so we
			// need to write out the agent.nut and device.nut files too
			
			// NSString *aFileName = [savingProject.projectName stringByAppendingString:@".agent.nut"];
			// NSString *aPathName = [savingProject.projectPath stringByAppendingFormat:@"/%@", aFileName];
			// NSString *dFileName = [savingProject.projectName stringByAppendingString:@".device.nut"];
			// NSString *dPathName = [savingProject.projectPath stringByAppendingFormat:@"/%@", dFileName];
			
			NSString *dataString = nil;
			
			if (savingProject.projectAgentCode.length == 0)
			{
				dataString = @"// Agent Code\n\n";
			}
			else
			{
				dataString = savingProject.projectAgentCode;
			}
			
			NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
			BOOL aSuccess = [fm createFileAtPath:savingProject.projectAgentCodePath contents:data attributes:nil];
			
			if (savingProject.projectDeviceCode.length == 0)
			{
				dataString = @"// Device Code\n\n";
			}
			else
			{
				dataString = savingProject.projectDeviceCode;
			}
			
			data = [dataString dataUsingEncoding:NSUTF8StringEncoding];
			BOOL dSuccess = [fm createFileAtPath:savingProject.projectDeviceCodePath contents:data attributes:nil];
			
			if (aSuccess == NO)
			{
				// Warn user of 'file already exists' error
				
				[self writeToLog:[NSString stringWithFormat:@"[ERROR] File \"%@\" could not be created: file already exists.", savingProject.projectAgentCodePath] :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"File \"%@\" created and added to project \"%@\".", savingProject.projectAgentCodePath, savingProject.projectName] :YES];
				if (savingProject == currentProject)
                {
                    externalOpenBothItem.enabled = YES;
                    externalOpenAgentItem.enabled = YES;
                }
			}
			
			if (dSuccess == NO)
			{
				[self writeToLog:[NSString stringWithFormat:@"[ERROR] File \"%@\" could not be created - file already exists.", savingProject.projectDeviceCodePath] :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"File \"%@\" created and added to project \"%@\".", savingProject.projectDeviceCodePath, savingProject.projectName] :YES];
				if (savingProject == currentProject)
                {
                    externalOpenBothItem.enabled = YES;
                    externalOpenDeviceItem.enabled = YES;
                }
			}
			
			// If the 'open files' checkbox is ticked, open the files we've just created
			
			if (newProjectAccessoryViewOpenCheckbox.state == YES)
			{
				[self externalOpenAll:self];
				newProjectAccessoryViewOpenCheckbox.state = NO;
			}
		}
		
		[self writeToLog:[NSString stringWithFormat:@"Project \"%@\" saved at %@.", savingProject.projectName, savingProject.projectPath] :YES];
	}
	else
	{
		[self writeToLog:@"[ERROR] The project could not be saved." :YES];
	}
	
	// Whether we have saved the project or not, clear savingProject
	
	savingProject = nil;
	saveProjectSubFilesFlag = NO;

	// Did we come here from a 'close project'? If so, re-run to actually close the project

	if (closeProjectFlag) [self closeProject:nil];
}



#pragma mark - Close Project Methods


- (IBAction)closeProject:(id)sender
{
	// If no project currently selected so bail
	
	if (currentProject == nil) return;
	
	if (sender == closeAllMenuItem)
	{
        // We need to close multiple projects at once, so iterate through
        // all of them, recursively calling closeProject:, sending nil as
        // the sender so this block is not re-run. NOTE this should exit
        // with just one remaining project, which the rest of the method
        // will deal with

        if (projectArray.count > 1)
		{
			do
			{
                // Close the current project
                // NOTE closeProject: sets the current project

                [self closeProject:nil];
			}
			while (projectArray.count > 1);
		}
	}

	// Close the current project

	NSInteger index = [projectArray indexOfObject:currentProject];
	
	if (currentProject.projectHasChanged == YES)
	{
		// The project has unsaved changes, so warn the user before closing
		
		[saveChangesSheetLabel setStringValue:@"Project has unsaved changes."];
		[_window beginSheet:saveChangesSheet completionHandler:nil];
		closeProjectFlag = YES;
		return;
	}
	
	// Stop watching the current project's files
	
	if (currentProject.projectDeviceCodePath != nil) [fileWatchQueue removePath:currentProject.projectDeviceCodePath];
	if (currentProject.projectAgentCodePath != nil) [fileWatchQueue removePath:currentProject.projectAgentCodePath];

	NSArray *fileItems = [currentProject.projectAgentLibraries allValues];
	for (NSUInteger i = 0 ; i < fileItems.count ; ++i)
	{
		[fileWatchQueue removePath:[fileItems objectAtIndex:i]];
	}

	fileItems = [currentProject.projectAgentFiles allValues];
	for (NSUInteger i = 0 ; i < fileItems.count ; ++i)
	{
		[fileWatchQueue removePath:[fileItems objectAtIndex:i]];
	}

	fileItems = [currentProject.projectDeviceLibraries allValues];
	for (NSUInteger i = 0 ; i < fileItems.count ; ++i)
	{
		[fileWatchQueue removePath:[fileItems objectAtIndex:i]];
	}

	fileItems = [currentProject.projectDeviceFiles allValues];
	for (NSUInteger i = 0 ; i < fileItems.count ; ++i)
	{
		[fileWatchQueue removePath:[fileItems objectAtIndex:i]];
	}

    if (projectArray.count == 1)
	{
		// If there is only one open project, which we're about to close,
		// we can clear everything project-related in the UI
		
		[self writeToLog:[NSString stringWithFormat:@"Project \"%@\" closed. There are no other open projects.", currentProject.projectName] :YES];
        [projectArray removeAllObjects];
        [fileWatchQueue kill];
		fileWatchQueue = nil;
        currentProject = nil;
        noProjectsFlag = YES;
        noLibsFlag = YES;
		
		// Clear the projects submenu
		
		[projectsMenu removeAllItems];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
		[projectsMenu addItem:item];
		item.enabled = NO;

        // Clear the projects popup

        [projectsPopUp removeAllItems];
        [projectsPopUp addItemWithTitle:@"None"];
        projectsPopUp.enabled = NO;

		// Sort out the local library and files menus

		[self updateLibraryMenu];
		[self updateFilesMenu];

        // Fade the status light
		
		[saveLight setFull:YES];
        [saveLight setLight:NO];
	}
	else
	{
		// There's at least one other project open, so just remove the current one
		
		[projectArray removeObjectAtIndex:index];
		
		// Remove it from the Current Open Projects submenu
		
		NSMenuItem *item = [projectsMenu itemWithTitle:currentProject.projectName];
		[projectsMenu removeItem:item];
		
		// And from the Current Project popup
		
		NSInteger old = [projectsPopUp indexOfSelectedItem];
		[projectsPopUp selectItemWithTitle:currentProject.projectName];
		[projectsPopUp removeItemAtIndex:old];
		
		NSString *confirmMessage = [NSString stringWithFormat:@"Project \"%@\" closed.", currentProject.projectName];
		
		// Set the first project to the current one, and update the UI
		
		currentProject = [projectArray objectAtIndex:0];
        item = [projectsMenu itemWithTitle:currentProject.projectName];
		item.state = NSOnState;
		[self updateLibraryMenu];
		[self updateFilesMenu];
        [saveLight setFull:!currentProject.projectHasChanged];

        currentDeviceLibCount = 0;
		currentAgentLibCount = 0;

		if (sender != closeAllMenuItem)
		{
			confirmMessage = [confirmMessage stringByAppendingFormat:@" %@ is now the current project.", currentProject.projectName];
		
			if (projectArray.count == 1)
			{
				confirmMessage = [confirmMessage stringByAppendingString:@" There are no other open projects."];
			}
			else if (projectArray.count == 2)
			{
				confirmMessage = [confirmMessage stringByAppendingString:@" There is 1 other open project."];
			}
			else
			{
				confirmMessage = [confirmMessage stringByAppendingFormat:@" There are %li other open projects.", projectArray.count - 1];
			}
			
			[self writeToLog:confirmMessage :YES];
		}
	}
	
	// Update Menus and the Toolbar
	
	[self updateMenus];
	[self setToolbar];
}



#pragma mark - Squint Methods


- (IBAction)squint:(id)sender
{
    // This method is a hangover from a previous version. 
	// Now it simply calls the version which replaces it.
	
	[self squintr];
}



- (void)squintr
{
    // Squintr runs through the two prime source code files - agent and device - and (via subsidiary methods) 
    // looks for #require, #import and #include directives. For the last two of these, it updates the project's
    // lists of recorded libraries and files, and compiles the code into an upload-ready form (code stored in 
	// current project's 'projectAgentCode' and 'projectDeviceCode' properties

	
    // If we have no currently selected project, bail

    if (currentProject == nil)
    {
        [self writeToLog:@"[ERROR] There are no open projects to compile." :YES];
        return;
    }

    // Clear the lists of local libraries and files found in this compile
	// 'foundLibs' - all the libraries #imported or #included in the source files
	// 'foundFiles' - all the non-libraries #imported or #included in the source files

    if (foundLibs != nil) foundLibs = nil;
    if (foundFiles != nil) foundFiles = nil;
	foundFiles = [[NSMutableArray alloc] init];
    foundLibs = [[NSMutableArray alloc] init];
	
	// Clear the EI libraries listing - it will be repopulated via processSource: and processRequires:
	
	currentProject.projectImpLibs = nil;
	
	[projectIncludes removeAllObjects];

    BOOL doneFlag = NO;
	NSString *output;
	
    [self writeToLog:[NSString stringWithFormat:@"Processing project \"%@\"...", currentProject.projectName] :YES];

    // Process 'agent.nut' then 'device.nut' if either or both exist

	if (currentProject.projectVersion.floatValue > 2.0)
	{
		if (currentProject.projectAgentCodeBookmark != nil)
		{
			NSURL *agentCodeURL = [self urlForBookmark:currentProject.projectAgentCodeBookmark];

			[self writeToLog:[NSString stringWithFormat:@"Processing agent code file: \"%@\"...", agentCodeURL.absoluteString.lastPathComponent] :YES];
			output = [self processSource:agentCodeURL.absoluteString :kCodeTypeAgent :YES];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in agent code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}

			output = [self processDefines:output :kCodeTypeAgent];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in agent code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}

			currentProject.projectAgentCode = output;
			doneFlag = YES;
		}

		if (currentProject.projectDeviceCodeBookmark != nil)
		{
			NSURL *deviceCodeURL = [self urlForBookmark:currentProject.projectDeviceCodeBookmark];

			[self writeToLog:[NSString stringWithFormat:@"Processing device code file: \"%@\"...", deviceCodeURL.absoluteString.lastPathComponent] :YES];
			output = [self processSource:deviceCodeURL.absoluteString :kCodeTypeDevice :YES];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in device code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}

			output = [self processDefines:output :kCodeTypeDevice];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in device code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}

			currentProject.projectDeviceCode = output;
			doneFlag = YES;
		}
	}
	else
	{
		if (currentProject.projectAgentCodePath != nil)
		{
			[self writeToLog:[NSString stringWithFormat:@"Processing agent code file: \"%@\"...", currentProject.projectAgentCodePath.lastPathComponent] :YES];
			output = [self processSource:currentProject.projectAgentCodePath :kCodeTypeAgent :YES];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in agent code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}
			
			output = [self processDefines:output :kCodeTypeAgent];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in agent code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}
			
			currentProject.projectAgentCode = output;
			doneFlag = YES;
		}

		if (currentProject.projectDeviceCodePath != nil)
		{
			[self writeToLog:[NSString stringWithFormat:@"Processing device code file: \"%@\"...", currentProject.projectDeviceCodePath.lastPathComponent] :YES];
			output = [self processSource:currentProject.projectDeviceCodePath :kCodeTypeDevice :YES];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in device code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}
			
			output = [self processDefines:output :kCodeTypeDevice];
			if (output == nil)
			{
				[self writeToLog:@"Compilation halted: cannot continue due to errors in device code" :YES];
				currentProject.projectSquinted = 0;
				[self setProjectMenu];
				return;
			}
			
			currentProject.projectDeviceCode = output;
			doneFlag = YES;
		}
	}
	if (doneFlag)
	{
		// Activate compilation-related UI items
		
		logDeviceCodeMenuItem.enabled = YES;
		externalOpenMenuItem.enabled = YES;
		externalOpenDeviceItem.enabled = YES;
		externalOpenBothItem.enabled = YES;
	}
	
	// Sort out the libraries and files found in this compilation
	
	[self processLibraries];
	
	// Update project's compilation status record, 'projectSquinted'
	
	NSString *resultString = @"";
	
	if (currentProject.projectAgentCode != nil)
    {
        if (currentProject.projectDeviceCode != nil)
        {
            // Project has Device *and* Agent code

            resultString = @"Project compiled - agent and device code ready to upload.";
            currentProject.projectSquinted = 3;
        }
        else
        {
            // Project has only Agent code

            resultString = @"Project compiled - agent code ready to upload.";
            currentProject.projectSquinted = currentProject.projectSquinted | 2;
        }
    }
    else
    {
        if (currentProject.projectDeviceCode != nil)
        {
            // Project has only Device code

            resultString = @"Project compiled - device code ready to upload.";
            currentProject.projectSquinted = currentProject.projectSquinted | 1;
        }
        else
        {
            // Project has no code

            resultString = @"Project has no code to compile and upload.";
        }
    }

    [self writeToLog:resultString :YES];
	
	// Update libraries menu with updated list of local, EI libraries and local files
	
	[self updateLibraryMenu];
	[self updateFilesMenu];
	[self setProjectMenu];
	[saveLight setFull:!currentProject.projectHasChanged];
}



- (void)processLibraries
{
	// This method wrangles the collection of current libraries found in the source code files
	// It looks for Electric Imp links and for local files and libraries

	// PROCESS EI LIBRARIES

	// Do we have any Electric Imp libraries #required in the source code?
	
	if (currentProject.projectImpLibs.count > 0)
	{
		if (currentProject.projectImpLibs.count == 1)
		{
			[self writeToLog:@"1 Electric Imp library included." :YES];
		}
		else
		{
			[self writeToLog:[NSString stringWithFormat:@"%lu Electric Imp libraries included.", (long)currentProject.projectImpLibs.count] :YES];
		}

		[self checkElectricImpLibs];
	}
	else
	{
		[self writeToLog:@"No Electric Imp libraries included." :YES];
	}
	
	// PROCESS LOCAL LIBRARIES

	// Do we have any local libraries #included or #imported in the source code?
	
	// Check for a disparity between the number of known libraries and those found in the compilation
	// If there is a disparity, the project has changed so set the 'need to save' flag. Note if there
	// is no disparity, there may still have been changes made - we check for these below
	
	if (currentProject.projectAgentLibraries.count + currentProject.projectDeviceLibraries.count != foundLibs.count) currentProject.projectHasChanged = YES;
	
	// Local libraries #included or #imported in the source code will all be stored in 'foundLibs'
	
	if (foundLibs.count == 0)
	{
		// There are no libraries #included or #imported in the current code,
		// so clear the counts and the lists stored in the project
		
		currentDeviceLibCount = 0;
		currentAgentLibCount = 0;
		
		if (currentProject.projectAgentLibraries != nil && currentProject.projectAgentLibraries.count > 0)
		{
			if (currentProject.projectDeviceLibraries.count == 1)
			{
				[self writeToLog:@"1 local library no longer referenced in the project's agent code." :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the project's agent code.", (long)currentProject.projectAgentLibraries.count] :YES];
			}

			[currentProject.projectAgentLibraries removeAllObjects];
		}

		if (currentProject.projectDeviceLibraries != nil && currentProject.projectDeviceLibraries.count > 0)
		{
			if (currentProject.projectDeviceLibraries.count == 1)
			{
				[self writeToLog:@"1 local library no longer referenced in the project's device code." :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the project's device code.", (long)currentProject.projectDeviceLibraries.count] :YES];
			}

			[currentProject.projectDeviceLibraries removeAllObjects];
		}
	}
	else
	{
		// Calculate and display the number of library references removed from the source

		NSUInteger aCount = 0;
		NSUInteger dCount = 0;

		for (NSDictionary *item in foundLibs)
		{
			NSNumber *codeNumber = [item objectForKey:@"libType"];
			NSUInteger codeType = codeNumber.integerValue;

			if (codeType == kCodeTypeAgent)
			{
				++aCount;
			}
			else
			{
				++dCount;
			}
		}

		NSInteger total = currentProject.projectAgentLibraries.count - aCount;

		if (total == 1)
		{
			[self writeToLog:@"1 local library no longer referenced in the project's agent code." :YES];
		}
		else if (total > 1)
		{
			[self writeToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the project's agent code.", (long)total] :YES];
		}

		total = currentProject.projectDeviceLibraries.count - aCount;

		if (total == 1)
		{
			[self writeToLog:@"1 local library no longer referenced in the project's device code." :YES];
		}
		else if (total > 1)
		{
			[self writeToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the project's device code.", (long)total] :YES];
		}

		NSMutableDictionary *projectLibList;
		
		// First, run through the contents of 'foundLibs' to see if there is a 1:1 match with
		// the lists of known local librariess; if not, mark that the project has changed
		
		for (NSUInteger i = 0 ; i < foundLibs.count ; ++i)
		{
			NSDictionary *aLib = [foundLibs objectAtIndex:i];
			NSString *libName = [aLib objectForKey:@"libName"];
			NSNumber *codeNumber = [aLib objectForKey:@"libType"];
			NSString *libLoc = [aLib objectForKey:@"libPath"];
			NSInteger codeType = codeNumber.integerValue;

			if (codeType == kCodeTypeAgent)
			{
				if (currentProject.projectAgentLibraries == nil) currentProject.projectAgentLibraries = [[NSMutableDictionary alloc] init];
				projectLibList = currentProject.projectAgentLibraries;
			}
			else
			{
				if (currentProject.projectDeviceLibraries == nil) currentProject.projectDeviceLibraries = [[NSMutableDictionary alloc] init];
				projectLibList = currentProject.projectDeviceLibraries;
			}
			
			BOOL match = NO;
			
			if (projectLibList.count > 0) 
			{
				// Does the library name match an existing one?

				NSArray *keys = [projectLibList allKeys];
				
				for (NSUInteger j = 0 ; j < keys.count ; ++j)
				{
					NSString *key = [keys objectAtIndex:j];
					if ([key compare:libName] == NSOrderedSame)
					{
						match = YES;
						break;
					}
				}
			}
			
			if (!match)
			{
				// The found library isn't known, so we'll have to add it

				currentProject.projectHasChanged = YES;
			}
			else
			{
				// The found library does match. We should check if it has moved.

				NSString *aPath = [projectLibList objectForKey:libName];

				if ([aPath compare:libLoc] != NSOrderedSame)
				{
					// Names match but the path doesn't. Ergo library has moved

					currentProject.projectHasChanged = YES;
					[self writeToLog:[NSString stringWithFormat:@"Local library \"%@\" has been moved from \"%@\" to \"%@\".", libName, [aPath stringByDeletingLastPathComponent], [libLoc stringByDeletingLastPathComponent]] :YES];
				}
			}
		}
		
		// Now clear out the recorded library lists and add in the new ones from 'foundLibs'
		
		if (currentProject.projectDeviceLibraries) [currentProject.projectDeviceLibraries removeAllObjects];
		if (currentProject.projectAgentLibraries) [currentProject.projectAgentLibraries removeAllObjects];
		
		for (NSUInteger i = 0 ; i < foundLibs.count ; ++i)
		{
			NSDictionary *aLib = [foundLibs objectAtIndex:i];
			NSString *libName = [aLib objectForKey:@"libName"];
			NSString *libPath = [aLib objectForKey:@"libPath"];
			NSNumber *codeNumber = [aLib objectForKey:@"libType"];
			// NSString *libVersion = [aLib objectForKey:@"libVer"];

			NSInteger codeType = codeNumber.integerValue;
			
			if (codeType == kCodeTypeAgent)
			{
				[currentProject.projectAgentLibraries setObject:libPath forKey:libName];
			}
			else
			{
				[currentProject.projectDeviceLibraries setObject:libPath forKey:libName];
			}
		}
	}
	
	// Update library counts
	
	currentDeviceLibCount = currentProject.projectDeviceLibraries.count;
	currentAgentLibCount = currentProject.projectAgentLibraries.count;
	NSUInteger count = currentDeviceLibCount + currentAgentLibCount;
	
	if (count > 0)
	{
		if (count == 1)
		{
			[self writeToLog:@"1 local library inserted." :YES];
		}
		else
		{
			[self writeToLog:[NSString stringWithFormat:@"%lu local libraries inserted.", (long)count] :YES];
		}
	}
	else
	{
		[self writeToLog:@"No local libraries included." :YES];
	}
	
	// PROCESS LOCAL FILES

	// Do we have any local files #included or #imported in the source code?
	
	// Local files #included or #imported in the source code will all be stored in 'foundFiles'
	// Clear out the recorded files lists and add in the new ones from 'foundFiles'
	
	if (currentProject.projectAgentFiles.count + currentProject.projectDeviceFiles.count != foundFiles.count) currentProject.projectHasChanged = YES;

	if (foundFiles.count == 0)
	{
		if (currentProject.projectAgentFiles != nil && currentProject.projectAgentFiles.count > 0)
		{
			if (currentProject.projectAgentFiles.count == 1)
			{
				[self writeToLog:@"1 local file no longer referenced in the project's agent code." :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"%li local files no longer referenced in the project's agent code.", (long)currentProject.projectAgentFiles.count] :YES];
			}

			[currentProject.projectAgentFiles removeAllObjects];
		}

		if (currentProject.projectDeviceFiles != nil && currentProject.projectDeviceFiles.count > 0)
		{
			if (currentProject.projectAgentFiles.count == 1)
			{
				[self writeToLog:@"1 local file no longer referenced in the project's device code." :YES];
			}
			else
			{
				[self writeToLog:[NSString stringWithFormat:@"%li local files no longer referenced in the project's device code.", (long)currentProject.projectDeviceFiles.count] :YES];
			}

			[currentProject.projectDeviceFiles removeAllObjects];
		}
	}
	else
	{
		NSUInteger aCount = 0;
		NSUInteger dCount = 0;

		for (NSDictionary *item in foundFiles)
		{
			NSNumber *codeNumber = [item objectForKey:@"fileType"];
			NSUInteger codeType = codeNumber.integerValue;

			if (codeType == kCodeTypeAgent)
			{
				++aCount;
			}
			else
			{
				++dCount;
			}
		}

		NSInteger total = currentProject.projectAgentFiles.count - aCount;

		if (total == 1)
		{
			[self writeToLog:@"1 local file no longer referenced in the project's agent code." :YES];
		}
		else if (total > 1)
		{
			[self writeToLog:[NSString stringWithFormat:@"%li local files no longer referenced in the project's agent code.", (long)total] :YES];
		}

		total = currentProject.projectDeviceFiles.count - aCount;

		if (total == 1)
		{
			[self writeToLog:@"1 local file no longer referenced in the project's device code." :YES];
		}
		else if (total > 1)
		{
			[self writeToLog:[NSString stringWithFormat:@"%li local files no longer referenced in the project's device code.", (long)total] :YES];
		}
		
		NSMutableDictionary *projectFileList;

		for (NSUInteger i = 0 ; i < foundFiles.count ; ++i)
		{
			NSDictionary *aFile = [foundFiles objectAtIndex:i];
			NSString *fileName = [aFile objectForKey:@"fileName"];
			NSNumber *codeNumber = [aFile objectForKey:@"fileType"];
			NSString *fileLoc = [aFile objectForKey:@"filePath"];
			NSInteger codeType = codeNumber.integerValue;

			if (codeType == kCodeTypeAgent)
			{
				if (currentProject.projectAgentFiles == nil) currentProject.projectAgentFiles = [[NSMutableDictionary alloc] init];
				projectFileList = currentProject.projectAgentFiles;
			}
			else
			{
				if (currentProject.projectDeviceFiles == nil) currentProject.projectDeviceFiles = [[NSMutableDictionary alloc] init];
				projectFileList = currentProject.projectDeviceFiles;
			}

			BOOL match = NO;

			if (projectFileList.count > 0)
			{
				NSArray *keys = [projectFileList allKeys];

				for (NSUInteger j = 0 ; j < keys.count ; ++j)
				{
					NSString *key = [keys objectAtIndex:j];
					if ([key compare:fileName] == NSOrderedSame)
					{
						match = YES;
						break;
					}
				}
			}

			if (!match)
			{
				currentProject.projectHasChanged = YES;
			}
			else
			{
				NSString *aPath = [projectFileList objectForKey:fileName];

				if ([aPath compare:fileLoc] != NSOrderedSame)
				{
					currentProject.projectHasChanged = YES;
					[self writeToLog:[NSString stringWithFormat:@"Local file \"%@\" has been moved from \"%@\" to \"%@\".", fileName, [aPath stringByDeletingLastPathComponent], [fileLoc stringByDeletingLastPathComponent]] :YES];
				}
			}
		}

		// Now clear out the recorded library lists and add in the new ones from 'foundLibs'

		if (currentProject.projectDeviceFiles) [currentProject.projectDeviceFiles removeAllObjects];
		if (currentProject.projectAgentFiles) [currentProject.projectAgentFiles removeAllObjects];

		for (NSUInteger i = 0 ; i < foundFiles.count ; ++i)
		{
			NSDictionary *aFile = [foundFiles objectAtIndex:i];
			NSString *fileName = [aFile objectForKey:@"fileName"];
			NSString *filePath = [aFile objectForKey:@"filePath"];
			NSNumber *codeNumber = [aFile objectForKey:@"fileType"];
			NSInteger codeType = codeNumber.integerValue;

			if (codeType == kCodeTypeAgent)
			{
				[currentProject.projectAgentFiles setObject:filePath forKey:fileName];
			}
			else
			{
				[currentProject.projectDeviceFiles setObject:filePath forKey:fileName];
			}
		}
	}

	count = currentProject.projectDeviceFiles.count + currentProject.projectAgentFiles.count;
	
	if (count > 0)
	{
		if (count == 1)
		{
			[self writeToLog:@"1 local file inserted." :YES];
		}
		else
		{
			[self writeToLog:[NSString stringWithFormat:@"%lu local files inserted.", (long)count] :YES];
		}
	}
	else
	{
		[self writeToLog:@"No local files included." :YES];
	}

	// Finally, clear and register the new libraries for changes

	[self addFileWatchPaths:currentProject.projectAgentLibraries.allValues];
	[self addFileWatchPaths:currentProject.projectAgentFiles.allValues];
	[self addFileWatchPaths:currentProject.projectDeviceLibraries.allValues];
	[self addFileWatchPaths:currentProject.projectDeviceFiles.allValues];
}



- (void)addFileWatchPaths:(NSArray *)paths
{
	for (NSUInteger i = 0 ; i < paths.count ; ++i)
	{
		NSString *path = [paths objectAtIndex:i];
		if (![fileWatchQueue isPathBeingWatched:path]) [fileWatchQueue addPath:path];
	}
}



- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(BOOL)willReturnCode
{
    // Loads the contents of the source code file referenced by 'codePath' - 'codeType' indicates whether the code
	// is agent or device - and parses it for multi-line comment blocks. Only code outside these blocks is passed
	// on for further processing, ie. parsing for #require, #include or #import directives.
	
	// 'willReturnCode' is set to YES if we want compiled code back; if we are only parsing the code for a list
	// of included files and libraries, we can pass in NO.
	
	
	NSRange commentStartRange, commentEndRange;
    NSString *compiledCode = @"";

    // Attempt to load in the source text file's contents

    NSError *error;
    NSString *sourceCode = [NSString stringWithContentsOfFile:codePath encoding:NSUTF8StringEncoding error:&error];
	if (error)
	{
		[self writeToLog:[NSString stringWithFormat:@"[ERROR] Unable to load source file \"%@\" - aborting compile.", codePath] :YES];
		return nil;
	}

    // Run through the loaded source code searching for multi-line comment blocks
    // When we find one, we examine all the code between the newly found comment block
	// and the previously found one (or the start of the file). 'index' records the location
	// of the start of file or the end of the previous comment block

    NSUInteger index = 0;
    BOOL done = NO;
	
	while (done == NO)
    {
        commentStartRange = [sourceCode rangeOfString:@"/*" options:NSCaseInsensitiveSearch range:NSMakeRange(index, sourceCode.length - index)];

        if (commentStartRange.location != NSNotFound)
        {
            // We have found a comment block.
            // Get the code *ahead* of the comment block that has not yet been processed,
            // ie. between locations 'index' and 'commentStartRange.location'

            NSRange preCommentRange = NSMakeRange(index, commentStartRange.location - index);
            NSString *codeToProcess = [sourceCode substringWithRange:preCommentRange];

            // Check for #requires
			// 'processRequires:' finds EI libraries, so it doesn't return compiled code

            [self processRequires:codeToProcess];

            // Check for #imports
			// 'processImports:' will return compiled code if 'willReturnCode' is true, else nil
			
            NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :willReturnCode];

            if (willReturnCode)
            {
                // If we are compiling code (ie. 'willReturnCode' is YES), then
                // use the compiled code for the next stage of processing.
				// 'processedCode' is nil if there are no #imports in the code

                if (processedCode != nil) codeToProcess = processedCode;
            }

			// Check for #includes
			
			processedCode = [self processImports:codeToProcess :@"#include" :codeType :willReturnCode];

            if (willReturnCode)
            {
                if (processedCode != nil) codeToProcess = processedCode;
            }

            // 'codeToProcess' contains compiled code (or the raw code if we are not compiling), so add it to any code we have already

            compiledCode = [compiledCode stringByAppendingString:codeToProcess];

            // We have processed the block of valid code *before* the /*, so find the end of the commment block: */

            commentEndRange = [sourceCode rangeOfString:@"*/" options:NSCaseInsensitiveSearch range:NSMakeRange(commentStartRange.location + 2, sourceCode.length - commentStartRange.location - 2)];

            if (commentEndRange.location != NSNotFound)
            {
                // Found the end of the comment block and it's within the file. Add it to the compiled code store (ie. keep the comment block)
				// NOTE Can make this a preference later, ie. upload code with comments stripped
				
                NSRange commentRange = NSMakeRange(commentStartRange.location, (commentEndRange.location + 2 - commentStartRange.location));
                compiledCode = [compiledCode stringByAppendingString:[sourceCode substringWithRange:commentRange]];
				
				// Move 'index' to the end of the comment block
				
                index = commentStartRange.location + commentRange.length;
            }
            else
            {
                // Got to the end of the source code without finding the end of the comment block so we can ignore all of what remains

                compiledCode = [compiledCode stringByAppendingString:[sourceCode substringFromIndex:commentStartRange.location]];
                done = YES;
            }
        }
        else
        {
            // There are no comment blocks in the remaining code, so just take the remaining code and process it to the end

            NSString *codeToProcess = [sourceCode substringFromIndex:index];

            [self processRequires:codeToProcess];

            NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :willReturnCode];

            if (willReturnCode)
            {
                if (processedCode != nil) codeToProcess = processedCode;
            }

            processedCode = [self processImports:codeToProcess :@"#include" :codeType :willReturnCode];

            if (willReturnCode)
            {
                if (processedCode != nil) codeToProcess = processedCode;
            }

            compiledCode = [compiledCode stringByAppendingString:codeToProcess];
            done = YES;
        }
    }

    // Device/Agent code has been processed: libraries and linked files found and stored
	// If we have asked to receive compiled code, return it now, or return nil

    if (willReturnCode) return compiledCode;
    return nil;
}



- (void)processRequires:(NSString *)sourceCode
{
    // Parses the passed in 'sourceCode' for #require directives. If any are found,
	// their names and version numbers are stored in the current project's 'projectImpLibs' array
	
	NSRange requireRange, commentRange;
    NSUInteger lineStartIndex;
    NSString *libName;

    BOOL done = NO;
    NSUInteger index = 0;

    // Remove the list of currently known EI libs?

    while (done == NO)
    {
        // Look for the NEXT occurrence of the #require directive

        requireRange = [sourceCode rangeOfString:@"#require" options:NSCaseInsensitiveSearch range:NSMakeRange(index, sourceCode.length - index)];

        if (requireRange.location != NSNotFound)
        {
            // We have found at least one '#require'. Find the line it is in and then run through the
            // line char by char to see if we have a single-line comment mark ahead of the #require

            [sourceCode getLineStart:&lineStartIndex end:NULL contentsEnd:NULL forRange:requireRange];

            commentRange = NSMakeRange(NSNotFound, 0);

            // If the #require is not at the start of a line, see if it is preceded by comment marks

            if (requireRange.location != lineStartIndex) commentRange = [sourceCode rangeOfString:@"//" options:NSLiteralSearch range:NSMakeRange(lineStartIndex, requireRange.location - lineStartIndex)];

            if (commentRange.location == NSNotFound)
            {
                // No Comment mark found ahead of the #require on the same line, so we can get the EI library's name

                libName = [sourceCode substringFromIndex:(requireRange.location + 8)];
                commentRange = [libName rangeOfString:@"\""];
                libName = [libName substringFromIndex:(commentRange.location + 1)];
                commentRange = [libName rangeOfString:@"\""];
                libName = [libName substringToIndex:commentRange.location];

                // Check for spaces and remove

                libName = [libName stringByReplacingOccurrencesOfString:@" " withString:@""];

                // Separate name from version, eg. "lib.class.nut:1.0.0"

                NSArray *elements = [libName componentsSeparatedByString:@":"];

                // Log and record the found library's name

                [self writeToLog:[NSString stringWithFormat:@"Electric Imp Library \"%@\" version %@ included in project \"%@\".", [elements objectAtIndex:0], [elements objectAtIndex:1], currentProject.projectName] :YES];

                // Add the library to the project - name and version (as string)

                if (currentProject.projectImpLibs == nil)
                {
                    currentProject.projectImpLibs = [[NSMutableArray alloc] init];
                    NSArray *library = [NSArray arrayWithObjects:[elements objectAtIndex:0], [elements objectAtIndex:1], nil];
                    [currentProject.projectImpLibs addObject:library];
                }
                else
                {
                    BOOL match = NO;

                    for (NSUInteger k = 0 ; k < currentProject.projectImpLibs.count ; ++k)
                    {
                        // See if the library is already listed

                        NSArray *aLib = [currentProject.projectImpLibs objectAtIndex:k];
                        NSString *libName = [aLib objectAtIndex:0];
                        NSString *libVersion = [aLib objectAtIndex:1];
                        if (([libName compare:[elements objectAtIndex:0]] == NSOrderedSame) && ([libVersion compare:[elements objectAtIndex:1]] == NSOrderedSame)) match = YES;
                    }

                    if (!match) {
                        NSArray *library = [NSArray arrayWithObjects:[elements objectAtIndex:0], [elements objectAtIndex:1], nil];
                        [currentProject.projectImpLibs addObject:library];
                    }
                }
            }
            
            // Move the file pointer along and look for the next library
            
            index = requireRange.location + 9;
        }
        else
        {
            // There are no more occurrences of '#require' in the rest of the file, so mark search as done
            
            done = YES;
        }
    }
}



- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(BOOL)willReturnCode
{
    // Parses the passed in 'sourceCode' for occurences of 'searchString' - here either "#import" or "#include".
	// The value of 'codeType' indicates whether the source is agent or device code.
	// The value of 'willReturnCode' indicates whether the method should returne compiled code or not. If it is
	// being used to gather a list of #included libraries and files, 'willReturnCode' will be NO.
	
	
	NSUInteger lineStartIndex;
    NSRange includeRange, commentRange;
    NSMutableArray *deadLibs, *deadFiles;
	
	NSString *returnCode = sourceCode;
	NSUInteger index = 0;
    BOOL done = NO;
    BOOL found = NO;

    while (done == NO)
    {
        /*
		 Loop through the code looking any and all appearances of 'searchString':
		 
		 <---- codeStart ---->#import "some.lib"<---- codeEnd ---->
		 ^
		 index
		 
		 after processing becomes
		 
		 <---- codeStart ----><libCode><---- codeEnd ---->
		                               ^
									   index
		 */

        includeRange = [returnCode rangeOfString:searchString options:NSCaseInsensitiveSearch range:NSMakeRange(index, returnCode.length - index)];

        if (includeRange.location != NSNotFound)
        {
            NSString *libPath, *libCode, *libName;

            // We have found at least one #import or #include. Now find the line it's in,
            // then check to see if we have a comment mark ahead of the directive

            [returnCode getLineStart:&lineStartIndex end:NULL contentsEnd:NULL forRange:includeRange];
            commentRange = NSMakeRange(NSNotFound, 0);

            // Look for '//' between the start of the line and the occurence of the directive

            if (includeRange.location != lineStartIndex) commentRange = [returnCode rangeOfString:@"//" options:NSLiteralSearch range:NSMakeRange(lineStartIndex, includeRange.location - lineStartIndex)];

            if (commentRange.location == NSNotFound)
            {
				// No Comment mark found ahead of the #import on the same line, so we can get the lib's name
				
				NSString *codeStart, *codeEnd;
				
				found = YES;
	
                libName = [returnCode substringFromIndex:(includeRange.location + searchString.length)];
                codeStart = [returnCode substringToIndex:includeRange.location];
                commentRange = [libName rangeOfString:@"\""];
                libName = [libName substringFromIndex:(commentRange.location + 1)];
                commentRange = [libName rangeOfString:@"\""];
                codeEnd = [libName substringFromIndex:(commentRange.location + 1)];
                libName = [libName substringToIndex:commentRange.location];

                // Look for path indicators in libName, ie. /

                commentRange = [libName rangeOfString:@"/" options:NSLiteralSearch];

                if (commentRange.location != NSNotFound)
                {
                    // Found at least one / so there must be directory info here,
                    // even if it's just ~/lib.class.nut

                    // Get the path component from the source file's library name info

                    libPath = [libName stringByDeletingLastPathComponent];
                    libPath = [libPath stringByStandardizingPath];

                    // Get the actual library name

                    libName = [libName lastPathComponent];
                }
                else
                {
                    // Didn't find any / characters so we can assume we just have a file name
                    // eg. library.class.nut

                    libPath = workingDirectory;
                }
				
				// Assume library or file will be added to the project

                BOOL addToCodeFlag = YES;
                BOOL addToProjectFlag = YES;
                BOOL isLibraryFlag = NO;

				// Is the #include a library or a regular file? ie. check for *.class.nut and *.library.nut
				
				NSRange aRange = [libName rangeOfString:@"class"];
                if (aRange.location != NSNotFound) isLibraryFlag = YES;

                aRange = [libName rangeOfString:@"library"];
                if (aRange.location != NSNotFound) isLibraryFlag = YES;

                // Attempt to load in the contents of the referenced file

                NSError *error = nil;
                libCode = [NSString stringWithContentsOfFile:[libPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

                if (libCode == nil)
                {
                    // Library or file is not in the named directory, so try the working directory
					// Note: this is repeated test if the user only #includes the library file name

                    libCode = [NSString stringWithContentsOfFile:[workingDirectory stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

                    if (libCode == nil)
                    {
                        // Library or file is not in the working directory, try the saved directory, if we have one

                        NSString *savedPath = nil;

                        if (codeType == kCodeTypeAgent)
                        {
                            if (isLibraryFlag)
							{
								savedPath = [currentProject.projectAgentLibraries valueForKey:libName];
							}
							else
							{
								savedPath = [currentProject.projectAgentFiles valueForKey:libName];
							}
                        }
                        else if (codeType == kCodeTypeDevice)
                        {
							if (isLibraryFlag)
							{
								savedPath = [currentProject.projectDeviceLibraries valueForKey:libName];
							}
							else
							{
								savedPath = [currentProject.projectDeviceFiles valueForKey:libName];
							}
                        }

                        if (savedPath != nil)
                        {
                            // We have a saved path for this file, so try it

                            libCode = [NSString stringWithContentsOfFile:savedPath encoding:NSUTF8StringEncoding error:&error];

                            if (libCode == nil)
                            {
                                // The library in not in the working directory or in its saved location, so bail if we are compiling
								// We can't really continue the compilation, but we can look for other libraries if that's all we're doing

								if (isLibraryFlag)
								{
									//[self writeToLog:[NSString stringWithFormat:@"[ERROR] Listed local library \"%@\" not found.", libName ] :YES];
									if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
									[deadLibs addObject:libName];
								}
								else
								{
									//[self writeToLog:[NSString stringWithFormat:@"[ERROR] Listed local files \"%@\" not found.", libName ] :YES];
									if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
									[deadFiles addObject:libName];
								}

                                //libPath = @"";
                                addToCodeFlag = NO;
                                addToProjectFlag = NO;
								if (willReturnCode) done = YES;

                            }
                            else
                            {
                                // Found the file, so use the saved path

                                libPath = savedPath;
                            }
                        }
                        else
                        {
                            // The library or file is not in the named or working directory, and we have no saved location for it, so bail
							// We can't really continue the compilation, but we can look for other libraries

							if (isLibraryFlag)
							{
								//[self writeToLog:[NSString stringWithFormat:@"[ERROR] Listed local library \"%@\" not found.", libName ] :YES];
								if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
								[deadLibs addObject:libName];
							}
							else
							{
								//[self writeToLog:[NSString stringWithFormat:@"[ERROR] Listed local files \"%@\" not found.", libName ] :YES];
								if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
								[deadFiles addObject:libName];
							}

							//libPath = @"";
							addToCodeFlag = NO;
							addToProjectFlag = NO;
							if (willReturnCode) done = YES;
                        }
                    }
                    else
                    {
                        // The library is in the working directory, so use that as its path
						
						libPath = [workingDirectory stringByAppendingFormat:@"/%@", libName];
                    }
                }
                else
                {
                    // We've got the file, so just add the name to complete the path
					
					libPath = [libPath stringByAppendingFormat:@"/%@", libName];
                }

                BOOL match = NO;

				if (addToProjectFlag)
				{
					// 'addToProjectFlag' defaults to YES, ie. if we find a library we want to
					// add it to the project. It becomes NO if a located library can't be found
					// in the file system, ie. we *can't* add it to the project

					if (isLibraryFlag)
					{
						// Item is a library or class
						// Check we haven't found it already

						for (NSDictionary *lib in foundLibs)
						{
							NSString *aName = [lib objectForKey:@"libName"];

							if ([aName compare:libName] == NSOrderedSame)
							{
								// We have match, but the library may have been included in the agent
								// code and we are now looking at the device code (agent always comes first)
								// so check this before setting 'match'

								NSNumber *type = [lib objectForKey:@"libType"];

								if (type.integerValue == codeType)
								{
									// Library matches with a library already found in this file

									match = YES;
								}
								else
								{
									// Library matches with a library found in a different file,
									// ie. no need to add it to the found list again BUT we DO want
									// to compile it in

									addToProjectFlag = NO;
								}
							}
						}

						if (match == NO && addToProjectFlag == YES)
						{
							NSString *vString = [NSString stringWithString:[self getLibraryVersionNumber:libCode]];
							NSArray *values = [NSArray arrayWithObjects:libPath, libName, [NSNumber numberWithInteger:codeType], vString, nil];
							NSArray *keys = [NSArray arrayWithObjects:@"libPath", @"libName", @"libType", @"libVer", nil];
							NSDictionary *aDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
							[foundLibs addObject:aDict];
							[self writeToLog:[NSString stringWithFormat:@"Local library \"%@\" found in project \"%@\".", libName, currentProject.projectName] :YES];
						}
					}
					else
					{
						// File name lacks neither a library or class tagging so assume it's a general file
						// Check we haven't found it already

						for (NSDictionary *file in foundFiles)
						{
							NSString *aName = [file objectForKey:@"fileName"];
							if ([aName compare:libName] == NSOrderedSame) match = YES;
						}

						if (match == NO && addToProjectFlag == YES)
						{
							NSArray *values = [NSArray arrayWithObjects:libPath, libName, [NSNumber numberWithInteger:codeType], nil];
							NSArray *keys = [NSArray arrayWithObjects:@"filePath", @"fileName", @"fileType", nil];
							NSDictionary *aDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
							[foundFiles addObject:aDict];
							[self writeToLog:[NSString stringWithFormat:@"Local file \"%@\" found in project \"%@\".", libName, currentProject.projectName] :YES];
						}
					}
				}

                // Compile in the code if this is required (it may not be if we're just scanning for libraries and files

                if (addToCodeFlag)
				{
					// 'addToCodeFlag' defaults to YES - we assume that if we have found a library in the
					// source code, that we want to add it to the return code. It is set to NO of the library
					// *can't* be located in the file system

					if (!match)
					{
						// Haven't placed the referenced code yet so do it now
						
						returnCode = [codeStart stringByAppendingString:libCode];
						returnCode = [returnCode stringByAppendingString:codeEnd];

						// Set 'index' to the start of the code that has yet to be checked,
						// after 'codeStart' and 'libCode'
						
						index = codeStart.length + libCode.length;
					}
					else
					{
						// We have placed this file already so simply remove the reference from the code

						returnCode = [codeStart stringByAppendingString:codeEnd];
						
						// Set 'index' to the start of the code that has yet to be checked, ie 'codeEnd'
						
						index = codeStart.length;
					}
				}
				else
				{
					// We couldn't locate the library/file source in the file system, so ignore the library/file and move on

					index = codeStart.length + [libPath stringByAppendingFormat:@"/%@", libName].length;
				}
            }
			else
			{
				// The #include is commented out, so move the file pointer along and look for the next library
				// 'includeRange.location' is the location of the #import or #include, so set 'index' to
				// just past the discovered #import or #include

				index = includeRange.location + searchString.length;
			}
        }
        else
        {
            // There are no more occurrences of '#import' in the rest of the file, so mark search as done

            done = YES;
        }
    }

    // If there were no #includes, we can bail

    if (!found) return nil;

    // If any libraries have been removed, these are listed in 'deadLibs' and 'codeType' flags this

    if (deadLibs.count > 0)
    {
        // One or more libraries in the source file are neither in the working directory nor
        // their recorded location.

        // NOTE Do we care if we're not returning code???

        NSString *mString = nil;

        if (deadLibs.count == 1)
        {
            mString = [NSString stringWithFormat:@"1 local library, \"%@\", can’t be located in the file system and will be removed from the project.", [deadLibs firstObject]];
        }
        else
        {
            NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadLibs.count ; ++i)
            {
                dString = [dString stringByAppendingFormat:@"%@, ", [deadLibs objectAtIndex:i]];
            }

            dString = [dString substringToIndex:dString.length - 2];
            mString = [NSString stringWithFormat:@"%li local libraries - %@ - can’t be located in the file system and will be removed from the project.", deadLibs.count, dString];
        }

        [self writeToLog:mString :YES];
		NSString *tString = ((codeType == kCodeTypeDevice) ? @"You should check the library locations specified in your device code." : @"You should check the library locations specified in your agent code.");
		[self writeToLog:tString :YES];
    }

	if (deadFiles.count > 0)
	{
		NSString *mString = nil;

		if (deadFiles.count == 1)
		{
			mString = [NSString stringWithFormat:@"1 local file, \"%@\", can’t be located in the file system and will be removed from the project.", [deadFiles firstObject]];
		}
		else
		{
			NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadFiles.count ; ++i)
			{
				dString = [dString stringByAppendingFormat:@"%@, ", [deadFiles objectAtIndex:i]];
			}

			dString = [dString substringToIndex:dString.length - 2];
			mString = [NSString stringWithFormat:@"%li local files - %@ - can’t be located in the file system and will be removed from the project.", deadLibs.count, dString];
		}

		[self writeToLog:mString :YES];
		[self writeToLog:@"You should check the file locations specified in your source code." :YES];
	}

    // At this point, 'foundlibs' contains zero or more local libraries and 'foundFiles' contains zero or more local files

    if (willReturnCode == YES) return returnCode;
    return nil;
}



- (NSString *)processDefines:(NSString *)sourceCode :(NSInteger)codeType
{
    NSRange defineRange, commentRange;
    NSUInteger lineStartIndex;
	NSString *defString, *defName, *defValue;
	
	NSString *compiledCode = @"";
    NSUInteger index = 0;
    BOOL done = NO;

    // Pass One - Look for #define directives
	
	if (projectDefines != nil) projectDefines = nil;

    while (done == NO)
    {
        // Look for the next occurrence of the #define directive

        defineRange = [sourceCode rangeOfString:@"#define" options:NSCaseInsensitiveSearch range:NSMakeRange(index, sourceCode.length - index)];

        if (defineRange.location != NSNotFound)
        {
            // We have found at least one '#define'. Now find the line it's in,
            // then run through char by char to see if we have a comment marks

			NSUInteger len = 0;
			
			[sourceCode getLineStart:&lineStartIndex end:NULL contentsEnd:NULL forRange:defineRange];

            commentRange = NSMakeRange(NSNotFound, 0);

            // If the #define is not at the start of a line, see if it is preceded by comment marks

            if (defineRange.location != lineStartIndex) commentRange = [sourceCode rangeOfString:@"//" options:NSLiteralSearch range:NSMakeRange(lineStartIndex, defineRange.location - lineStartIndex)];

            if (commentRange.location == NSNotFound)
            {
                // Get the define's name
				
				defString = [sourceCode substringFromIndex:defineRange.location + 7];
                commentRange = [defString rangeOfString:@"="];
				defName = [defString substringWithRange:NSMakeRange(0, commentRange.location)];
				len = defName.length + 1;
                
				// Remove spaces
				
				defName = [defName stringByReplacingOccurrencesOfString:@" " withString:@""];
				
				// Get the value
				
				defString = [defString substringFromIndex:commentRange.location + 1];
				commentRange = [defString rangeOfString:@"\n"];
				defValue = [defString substringWithRange:NSMakeRange(0, commentRange.location)];				
				len = len + defValue.length;
				defValue = [defValue stringByReplacingOccurrencesOfString:@" " withString:@""];
				
				if (defName.length == 0 || defValue.length == 0) 
				{
					NSUInteger lineNumber = [self getLineNumber:sourceCode :defineRange.location];					
					[self writeToLog:[NSString stringWithFormat:@"[ERROR] Malformed #define at line %li", lineNumber] :YES];
					return nil;
				}
				else
				{
					BOOL match = NO;
					
					if (projectDefines.count > 0)
					{
						NSArray *keys = [projectDefines allKeys];
						
						for (NSUInteger i = 0 ; i < keys.count ; ++i)
						{
							NSString *dName = [keys objectAtIndex:i];
							if ([defName compare:dName] == NSOrderedSame) match = YES;
						}
					}
					
					if (!match) 
					{
						if (projectDefines == nil) projectDefines = [[NSMutableDictionary alloc] init];
						[projectDefines setObject:defValue forKey:defName];
					}
					else
					{
						NSUInteger lineNumber = [self getLineNumber:sourceCode :defineRange.location];
						[self writeToLog:[NSString stringWithFormat:@"[ERROR] %@ redefined at line %li", defName, lineNumber] :YES];
						return nil;
					}
				}
            }
			
			// Add the code from 'index' to the #define
			compiledCode = [compiledCode stringByAppendingString:[sourceCode substringWithRange:NSMakeRange(index, defineRange.location - index)]];
			
			// Move the file pointer along and look for the next library

            index = defineRange.location + len + 8;
        }
        else
        {
            // There are no more occurrences of '#define' in the rest of the file, so mark search as done

            done = YES;
			
			// Add the code from 'index' to the #define
			compiledCode = [compiledCode stringByAppendingString:[sourceCode substringWithRange:NSMakeRange(index, sourceCode.length - index)]];
        }
    }

    // Pass Two - Now run through and replace all instances of each key with value
	
	NSArray *keys = [projectDefines allKeys];
	for (NSUInteger i = 0 ; i < keys.count ; ++i)
	{
		NSString *key = [keys objectAtIndex:i];
		NSString *value = [projectDefines valueForKey:key];
		compiledCode = [compiledCode stringByReplacingOccurrencesOfString:key withString:value];
	}

    return compiledCode;
}



- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index
{
	NSArray *lines = [[code substringToIndex:index] componentsSeparatedByString:@"\n"];
	return lines.count;
}



- (NSString *)getLibraryVersionNumber:(NSString *)libcode
{
	NSString *returnString = @"";

	NSError *err;
	NSString *pattern = @"static\\s*version\\s*=\[\\s*\\d*\\s*,\\s*\\d*\\s*,\\s*\\d*\\s*]";
	NSRegularExpressionOptions regexOptions =  NSRegularExpressionCaseInsensitive;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&err];
	if (err) return @"";
	NSTextCheckingResult *result = [regex firstMatchInString:libcode options:0 range:NSMakeRange(0, libcode.length)];
	NSRange vRange = result.range;

	// TODO check for comments

	if (vRange.location != NSNotFound)
	{
		libcode = [libcode substringFromIndex:vRange.location];
		vRange = [libcode rangeOfString:@"[" options:NSCaseInsensitiveSearch];
		NSRange eRange = [libcode rangeOfString:@"]" options:NSCaseInsensitiveSearch];

		if (eRange.location != NSNotFound)
		{
			NSString *rString = [libcode substringWithRange:NSMakeRange(vRange.location + 1, eRange.location - vRange.location - 1)];
			NSArray *vParts = [rString componentsSeparatedByString:@","];

			for (NSString *part in vParts)
			{
				rString = [part stringByReplacingOccurrencesOfString:@" " withString:@""];
				if (rString.length == 0) rString = @"0";
				returnString = [returnString stringByAppendingFormat:@"%@.", rString];
			}

			returnString = [returnString substringToIndex:returnString.length - 1];
		}
	}

	return returnString;
}



#pragma mark - Library and Project Menu Methods


- (IBAction)cleanProject:(id)sender
{
    // Clean the project by clearing saved data – a compile will re-populate it

    if (currentProject == nil)
    {
        [self writeToLog:@"[ERROR] You have no open project to clean." :YES];
        return;
    }
	
	// Warn user what cleaning the project means
	
	NSAlert *ays = [[NSAlert alloc] init];
	[ays addButtonWithTitle:@"No"];
	[ays addButtonWithTitle:@"Yes"];
    [ays setMessageText:[NSString stringWithFormat:@"You are about to clean project \"%@\". Are you sure you want to proceed?", currentProject.projectName]];
	[ays setInformativeText:@"Cleaning a project will remove its source code files, libraries and any association it has with a model."];
	[ays setAlertStyle:NSCriticalAlertStyle];
	[ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){
		
		// Only clean if 'Yes' selected
		
		if (returnCode == 1001) [self cleanProjectTwo];
	}];
}



- (void)cleanProjectTwo
{
	// Clear all the project's settings
	
	currentProject.projectSquinted = 0;
	currentProject.projectHasChanged = YES;
	currentProject.projectImpLibs = nil;
	[currentProject.projectDeviceLibraries removeAllObjects];
	currentProject.projectDeviceLibraries = nil;
	[currentProject.projectAgentLibraries removeAllObjects];
	currentProject.projectAgentLibraries = nil;
	currentProject.projectModelID = nil;
	currentProject.projectAgentCode = nil;
	currentProject.projectDeviceCode = nil;
	currentProject.projectAgentCodePath = nil;
	currentProject.projectDeviceCodePath = nil;
	
	// Indicate the project needs saving
	
	[saveLight setFull:NO];
	[self updateMenus];
	[self setToolbar];
}



- (void)updateLibraryMenu
{
    NSMenuItem *item;
    NSArray *keyArray;
	
    // Update the external library menu. First clear the current menu
    
    if (externalLibsMenu.numberOfItems > 0) [externalLibsMenu removeAllItems];
	
	// Add agent libraries, if any

    if (currentProject.projectAgentLibraries.count > 0)
    {
		keyArray = [currentProject.projectAgentLibraries allKeys];
        [self libAdder:keyArray];

    }
	
	// Add device libraries, if any
    
    if (currentProject.projectDeviceLibraries.count > 0)
    {
		keyArray = [currentProject.projectDeviceLibraries allKeys];
        [self libAdder:keyArray];
    }

    // Add EI Libraries, if any

    if (currentProject.projectImpLibs.count > 0)
    {
        if (externalLibsMenu.numberOfItems > 0) [externalLibsMenu addItem:[NSMenuItem separatorItem]];

        if (currentProject.projectSquinted == 0)
        {
            item = [[NSMenuItem alloc] initWithTitle:@"Electric Imp Libraries (uncompiled)" action:nil keyEquivalent:@""];
        }
        else
        {
            item = [[NSMenuItem alloc] initWithTitle:@"Electric Imp Libraries" action:nil keyEquivalent:@""];
        }

        [externalLibsMenu addItem:item];
        [item setEnabled:NO];

        for (NSUInteger i = 0 ; i < currentProject.projectImpLibs.count ; ++i)
        {
            NSString *libName = [self getLibraryTitle:[currentProject.projectImpLibs objectAtIndex:i]];
            [self addLibraryToMenu:libName :YES];
        }
    }

	// Tidy up the menu

	if (externalLibsMenu.numberOfItems == 0)
	{
		// If there are no library files in place, just put a greyed out 'none' there instead
		
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
		[externalLibsMenu addItem:item];
		[item setEnabled:NO];
	}
    else
    {
        // Check for duplications, ie. if agent and device both use the same lib
        // TODO someone may have the same library name in separate files, so we need to
        // check for this too.

        for (NSUInteger i = 0 ; i < externalLibsMenu.numberOfItems ; ++i)
        {
            NSMenuItem *libItem = [externalLibsMenu itemAtIndex:i];

            if (libItem.enabled == YES)
            {
                for (NSUInteger j = 0 ; j < externalLibsMenu.numberOfItems ; ++j)
                {
                    if (j != i)
                    {
                        NSMenuItem *aLibItem = [externalLibsMenu itemAtIndex:j];

                        if (aLibItem.enabled == YES)
                        {
                            if ([libItem.title compare:aLibItem.title] == NSOrderedSame)
                            {
                                // The names match, so remove the matcher

                                [externalLibsMenu removeItemAtIndex:j];
                            }
                        }
                    }
                }
            }
        }
    }
}



- (void)libAdder:(NSArray *)keyArray
{
    NSMenuItem *item;

    for (NSUInteger i = 0 ; i < keyArray.count ; ++i)
    {
        if (externalLibsMenu.numberOfItems == 0)
        {
            // This is the first item on the list, so make sure it’s preceded
            // by a suitable header entry

            if (currentProject.projectSquinted == 0)
            {
                item = [[NSMenuItem alloc] initWithTitle:@"Local Libraries (uncompiled)" action:nil keyEquivalent:@""];
            }
            else
            {
                item = [[NSMenuItem alloc] initWithTitle:@"Local Libraries" action:nil keyEquivalent:@""];
            }

            [externalLibsMenu addItem:item];
            [item setEnabled:NO];
        }

        NSString *libTitle = [self getLibraryTitle:[keyArray objectAtIndex:i]];
        [self addLibraryToMenu:libTitle :NO];
    }
}



- (void)addLibraryToMenu:(NSString *)libName :(BOOL)isEILib
{
    // Create a new menu entry for the Projects menu

    NSMenuItem *item;

    if (isEILib)
    {
        item = [[NSMenuItem alloc] initWithTitle:libName action:@selector(launchLibsPage) keyEquivalent:@""];
    }
    else
    {
        item = [[NSMenuItem alloc] initWithTitle:libName action:@selector(externalLibOpen:) keyEquivalent:@""];

    }

    [externalLibsMenu addItem:item];
}



- (void)updateFilesMenu
{
    NSArray *keyArray;

    // Update the external files menu. First clear the current menu

    if (externalFilesMenu.numberOfItems > 0) [externalFilesMenu removeAllItems];

    // Add agent linked files, if any

    if (currentProject.projectAgentFiles.count > 0)
    {
        keyArray = [currentProject.projectAgentFiles allKeys];
        [self fileAdder:keyArray];
    }

    // Add device linked files, if any (Comments as above)

    if (currentProject.projectDeviceFiles.count > 0)
    {
        keyArray = [currentProject.projectDeviceFiles allKeys];
        [self fileAdder:keyArray];
    }

	// Tidy up the menu

    if (externalFilesMenu.numberOfItems == 0)
    {
        // If there are no files to add, just put a greyed out 'none' there instead

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
        [externalFilesMenu addItem:item];
        [item setEnabled:NO];
    }
    else
    {
        // Check for duplications, ie. if agent and device both use the same lib
        // TODO someone may have the same library name in separate files, so we need to
        // check for this too.

        for (NSUInteger i = 0 ; i < externalFilesMenu.numberOfItems ; ++i)
        {
            NSMenuItem *libItem = [externalFilesMenu itemAtIndex:i];

            if (libItem.enabled == YES)
            {
                for (NSUInteger j = 0 ; j < externalFilesMenu.numberOfItems ; ++j)
                {
                    if (j != i)
                    {
                        NSMenuItem *aLibItem = [externalFilesMenu itemAtIndex:j];
                        
                        if (aLibItem.enabled == YES)
                        {
                            if ([libItem.title compare:aLibItem.title] == NSOrderedSame)
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



- (void)fileAdder:(NSArray *)keyArray
{
    for (NSUInteger i = 0 ; i < keyArray.count ; ++i)
    {
        [self addFileToMenu:[keyArray objectAtIndex:i]];
    }
}



- (void)addFileToMenu:(NSString *)filename
{
    NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:filename action:@selector(externalFileOpen:) keyEquivalent:@""];
    [externalFilesMenu addItem:item];
}



- (NSString *)getLibraryTitle:(id)item
{
    if ([item isKindOfClass:[NSString class]])
    {
        return (NSString *)item;
    }
    else
    {
        NSString *title = [item objectAtIndex:0];
        title = [title stringByAppendingFormat:@" (%@)", [item objectAtIndex:1]];
        return title;
    }
}



- (void)launchLibsPage
{
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://electricimp.com/docs/libraries/"]];
}



- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle
{
	// Create a new menu entry to the Projects menu’s Open Projects submenu
	// and to the Current Project popup
	
	NSMenuItem *item;
	
	// Run through the existing menu items, to check that we're not adding one already there
	// If there are no menu items, we can proceed safely
	
	if (noProjectsFlag)
	{
		// There are no open projects yet (the one we're adding is the first
		// so clear the 'None' entries from the menu pop-up
		
		[projectsMenu removeAllItems];
		[projectsPopUp removeAllItems];
	}
	
	if (projectsMenu.numberOfItems > 0)
	{
		for (NSUInteger i = 0 ; i < projectsMenu.numberOfItems ; ++i)
		{
			item = [projectsMenu itemAtIndex:i];
			
			if ([item.title compare:currentProject.projectName] == NSOrderedSame)
			{
				// The new project is already on the menu, so return failure
				
				return NO;
			}
			
			// Otherwise untick the menu item
			
			item.state = NSOffState;
		}
	}
	
	// If we have got this far, we can safely add the project to the submenu...
	
	item = [[NSMenuItem alloc] initWithTitle:menuItemTitle action:@selector(chooseProject:) keyEquivalent:@""];
	item.state = NSOnState;
	[projectsMenu addItem:item];
	
	// ...and to the popup
	
	[projectsPopUp addItemWithTitle:menuItemTitle];
	NSUInteger index = [projectsPopUp indexOfItemWithTitle:menuItemTitle];
	[projectsPopUp selectItemAtIndex:index];
	if (projectsPopUp.enabled == NO) projectsPopUp.enabled = YES;

	// Return success
	
	return YES;
}



#pragma mark - Pasteboard Methods


- (IBAction)copyDeviceCodeToPasteboard:(id)sender
{
    // If there is no device code to copy, bail
	
    if (currentProject.projectDeviceCode == nil)
    {
        [self writeToLog:@"[WARNING] This project has no device code to copy: compile the project first." :YES];
        return;
    }
    
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString:currentProject.projectDeviceCode forType:NSStringPboardType];
    [self writeToLog:@"Compiled device code copied to clipboard." :YES];
}



- (IBAction)copyAgentCodeToPasteboard:(id)sender
{
    // If there is no agent code to copy, bail
    
    if (currentProject.projectAgentCode == nil)
    {
        [self writeToLog:@"[WARNING] This project has no agent code to copy: compile the project first." :YES];
        return;
    }
    
    NSPasteboard *pb = [NSPasteboard generalPasteboard];
    NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
    [pb declareTypes:types owner:self];
    [pb setString:currentProject.projectAgentCode forType:NSStringPboardType];
    [self writeToLog:@"Compiled agent code copied to clipboard." :YES];
}



- (IBAction)copyAgentURL:(id)sender
{
	if (currentDevice == -1)
	{
		// This should never appear: without a selected device, the menu item will be disabled

		[self writeToLog:@"[ERROR] You have not selected a device." :YES];
		return;
	}

	NSDictionary *device = [ide.devices objectAtIndex:currentDevice];
	NSString *uString = [NSString stringWithFormat:@"https://agent.electricimp.com/%@", [device objectForKey:@"agent_id"]];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
	[pb declareTypes:types owner:self];
	[pb setString:uString forType:NSStringPboardType];
	[self writeToLog:[NSString stringWithFormat:@"The agent URL of device \"%@\" has been copied to the clipboard.", [device objectForKey:@"name"]] :YES];
}



#pragma mark - Model and Device Methods


- (IBAction)getProjectsFromServer:(id)sender
{
	// Calls ide method getInitialData: which acquires models *and* devices
	// Ensure it zaps the selected model and device

	[self getApps];
	return;

	/* Below is the code for single-device streaming


    if (streamFlag == YES)
    {
        if (currentDevice != -1)
        {
            // Are we logging? If so warn the user

            NSDictionary *device = [ide.devices	objectAtIndex:currentDevice];
            NSAlert *ays = [[NSAlert alloc] init];
            [ays addButtonWithTitle:@"No"];
            [ays addButtonWithTitle:@"Yes"];
            [ays setMessageText:[NSString stringWithFormat:@"You are currently logging from device \"%@\". Are you sure you want to proceed?", [device objectForKey:@"name"]]];
            [ays setInformativeText:@"Updating the models list will stop device logging."];
            [ays setAlertStyle:NSWarningAlertStyle];
            [ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){

                if (returnCode == 1001)
                {
                    // User wants to continue with the change, so turn off streaming

                    [self streamLogs:nil];
                    [self setCurrentDeviceFromSelection:sender];
                    [self getApps];
                }
            }];
        }
        else
        {
            // Don't have a current device, so shouldn't be streaming – turn it off
            
            [self streamLogs:nil];
			streamFlag = NO;
        }
    }
    else
    {
        [self getApps];
    }
	 
	 */
}



- (void)getApps
{
    // currentDevice = -1;
    // currentModel = -1;

	// Make copies of the current device and model records (if they exists)
	// We require copies because the ide arrays may be repopulated

	if (currentDevice != -1) cDevice = [[ide.devices objectAtIndex:currentDevice] copy];
	if (currentModel != -1) cModel = [[ide.models objectAtIndex:currentModel] copy];

	[self writeToLog:@"Getting a list of models from the server..." :YES];
    PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
    [ide setk:[ide decodeBase64String:[pc stringForKey:@"com.bps.Squinter.ak.notional.tally"]]];
	[ide getModels:YES];
}



- (void)listModels
{
	
	// This method should ONLY be called by the BuildAPI instance AFTER loading a list of models

	[modelsMenu removeAllItems];
	
	// currentModel = -1;
	
	if (ide.models.count == 0)
	{
		// No models in the list so warn and bail

		[self writeToLog:@"[WARNING] There are no models listed on the server."  :YES];
		return;
	}

	for (NSDictionary *aModel in ide.models)
	{
		// Run through the list of models (in the ide object) and add a menu item for each

		NSString *title = [aModel valueForKey:@"name"];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:title action:@selector(chooseModel:) keyEquivalent:@""];
		[modelsMenu addItem:item];

		if (newModelFlag == YES)
		{
			// We are here after creating a new model successfully and getting a fresh list of models, 
			// so we auto-select the new model

			NSString *name = [aModel objectForKey:@"name"];

			if ([name compare:currentProject.projectName] == NSOrderedSame)
			{
				
				// Select the model in the menu (can't use chooseModel: as menu not built yet)

				item.state = NSOnState;
                currentModel = [modelsMenu indexOfItem:item];
				currentProject.projectModelID = [aModel objectForKey:@"id"];
			}
		}
		else
		{
			if (currentProject != nil)
			{
				// If we have a project open, see if it is linked to one of the newly loaded models

				NSString *modelID = [aModel objectForKey:@"id"];

				if ([modelID compare:currentProject.projectModelID] == NSOrderedSame)
				{
					// Select the model in the menu (can't use chooseModel: as menu not built yet)

					item.state = NSOnState;
                    currentModel = [modelsMenu indexOfItem:item];
                }
            }
			else
			{
				// No selected project so select previously selected model

				if (cModel)
				{
					NSString *mName = [cModel objectForKey:@"name"];

					if ([mName compare:title] == NSOrderedSame)
					{
						// Select the model in the menu (can't use chooseModel: as menu not built yet)

						item.state = NSOnState;
						currentModel = [modelsMenu indexOfItem:item];
						cModel = nil;
					}
				}
			}
        }
	}

    [self updateMenus];
	[self setToolbar];

	if (newModelFlag == YES) newModelFlag = NO;

	if (checkModelsFlag)
	{
		checkModelsFlag = NO;
		return;
	}
	
	// Should not need to trigger a device list update here as it will have been handled by BuildAPI
	// It's sufficient to simply tell the user what is happening

	[self writeToLog:@"List of models loaded, now acquiring list of devices..." :YES];
}



- (void)chooseModel:(id)sender
{
    // Records the index of the selected model – this is the index within ide.models
    // Called in response to project selection, device selection; called directly by
    // 'Current Models' menu items
	
	NSMenuItem *item = (NSMenuItem *)sender;
    NSInteger itemNumber = [modelsMenu indexOfItem:item];
	NSInteger newModelIndex = -1;
    
    for (NSUInteger i = 0; i < modelsMenu.numberOfItems ; ++i)
    {
        // Turn off all the menu items except the current one
        
        item = [modelsMenu itemAtIndex:i];
        
        if (i == itemNumber)
        {
            // Turn on the selected model, make it the current model
            // and turn on the project link menu, if necessary

            item.state = NSOnState;
			newModelIndex = i;
			NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
			
			if ([defaults boolForKey:@"com.bps.squinter.autoselectdevice"] && fromDeviceSelectFlag == NO)
			{
				// Preference to auto-select model's first device (if it has one) so select it
				
				if ([item submenu] != nil)
				{
					// This model has one or more devices so get and select the first one
					
					NSMenuItem *dItem = [[item submenu] itemAtIndex:0];
					[self chooseDevice:dItem];
				}
			}
        }
        else
        {
            // Turn off all other menu items...
			
			item.state = NSOffState;
			
			// ...and any device sub-menus too
			
			NSMenu *smenu = [item submenu];
			
			if (smenu)
			{
				for (NSUInteger j = 0 ; j < smenu.numberOfItems ; ++j)
				{
					NSMenuItem *sitem = [smenu itemAtIndex:j];
					sitem.state = NSOffState;
				}
			}
        }
    }
	
	if (currentModel != newModelIndex)
	{
		if (fromDeviceSelectFlag == NO)
		{
			// If we are NOT coming from device selection, and we have changed
			// models, we must also de-select any previously selected device
			
			if (![[NSUserDefaults standardUserDefaults] boolForKey:@"com.bps.squinter.autoselectdevice"])
			{
				currentDevice = -1;
				[self setDeviceMenu];
			}
		}
		
		currentModel = newModelIndex;
	}

    [self updateMenus];
	[self setToolbar];
}



- (IBAction)modelToProjectStageOne:(id)sender
{
    if (currentModel == -1)
    {
        [self writeToLog:@"[ERROR] You have not selected a model for the project to be built from." :YES];
        return;
    }

	// Set up savingProject to hold the new project we will save
	
	NSDictionary *model = [ide.models objectAtIndex:currentModel];
	savingProject = [[Project alloc] init];
	savingProject.projectName = [model objectForKey:@"name"];
	savingProject.projectAgentCodePath = [savingProject.projectName stringByAppendingString:@".agent.nut"];
	savingProject.projectAgentCodePath = [workingDirectory stringByAppendingFormat:@"/%@", savingProject.projectAgentCodePath];
	savingProject.projectDeviceCodePath = [savingProject.projectName stringByAppendingString:@".device.nut"];
	savingProject.projectDeviceCodePath = [workingDirectory stringByAppendingFormat:@"/%@", savingProject.projectDeviceCodePath];

	showCodeFlag = NO;
    [ide getCode:[model valueForKey:@"id"]];
}



- (void)modelToProjectStageTwo
{
    // This method is called by ToolsAPI ONLY
	
	if (showCodeFlag == YES)
    {
        // We're not saving the code, just showing it in the log

		[self writeToLog:@"\n" :NO];
		[self writeToLog:@"Agent code:" :NO];
		[self writeToLog:@" " :NO];
        [self listCode:ide.agentCode :-1 :-1 :-1];
		[self writeToLog:@"\n" :NO];
        [self writeToLog:@"Device code:" :NO];
		[self writeToLog:@" " :NO];
        [self listCode:ide.deviceCode :-1 :-1 :-1];
        showCodeFlag = NO;
        return;
    }

    savingProject.projectDeviceCode = ide.deviceCode;
	savingProject.projectAgentCode = ide.agentCode;
	savingProject.projectHasChanged	= YES;
	saveProjectSubFilesFlag = YES;
	
	// Get the model ID and save it
	
	NSDictionary *model = [ide.models objectAtIndex:currentModel];
	savingProject.projectModelID = [model objectForKey:@"id"];
	
	[self saveProjectAs:nil];
}



- (void)createdModel
{
	// This is called by the BuildAPI instance in response to a new model being created
	// The BuildAPI instance automatically updates its model and device lists

	[self writeToLog:[NSString stringWithFormat:@"Created model \"%@\". Refreshing Current Models menu...", itemToCreate] :YES];
}



- (IBAction)uploadCode:(id)sender
{
	if (currentProject == nil)
	{
		[self writeToLog:@"[ERROR] You have not selected a project to upload." :YES];
		return;
	}
	
	if (currentModel == -1)
	{
		[self writeToLog:@"[ERROR] You have not selected a model for the code to be uploaded to." :YES];
		return;
	}

    if ((currentProject.projectDeviceCode == nil || [currentProject.projectDeviceCode compare:@""] == NSOrderedSame) && (currentProject.projectAgentCode == nil || [currentProject.projectAgentCode compare:@""] == NSOrderedSame))
    {
        // Project lacks agent AND device code, ie. nothing to upload

        [self writeToLog:[NSString stringWithFormat:@"Project \"%@\" has no code to upload. You may need to compile it.", currentProject.projectName] :YES];
        return;
    }
	
	// Check that currentModel points to the project's model (it may have changed)
	
	__block BOOL modelCheckFlag = NO;
	
	if (currentProject.projectModelID.length != 0)
	{
		NSString *mID = currentProject.projectModelID;
		for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
		{
			NSDictionary *aModel = [ide.models objectAtIndex:i];
			NSString *aID = [aModel objectForKey:@"id"];
			if ([mID compare:aID] == NSOrderedSame)
			{
				if (currentModel == i)
				{
					// currentModel matches the one assigned to the project
					
					modelCheckFlag = YES;
					break;
				}
			}
		}
	}
	else
	{
		modelCheckFlag = YES;
	}
	
	if (modelCheckFlag)
	{
        [self writeToLog:[NSString stringWithFormat:@"Uploading agent and device code from project \"%@\" to model \"%@\".", currentProject.projectName, [[modelsMenu itemAtIndex:currentModel] title]] :YES];
        [ide uploadCode:[self getModelID:currentModel] :currentProject.projectDeviceCode :currentProject.projectAgentCode];
	}
	else
	{
		// Present warning dialog
		
		NSDictionary *model;
		NSString *mID = currentProject.projectModelID;
		for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
		{
			model = [ide.models objectAtIndex:i];
			NSString *aID = [model objectForKey:@"id"];
			if ([mID compare:aID] == NSOrderedSame) break;
		}
		
		NSDictionary *aModel = [ide.models objectAtIndex:currentModel];
		NSString *aName = [aModel objectForKey:@"name"];
		NSAlert *ays = [[NSAlert alloc] init];
		NSPanel *panel = (NSPanel *)ays.window;
		NSRect f = panel.frame;
		f.size.width = 600;
		[panel setFrame:f display:NO];
		[ays addButtonWithTitle:@"No"];
		[ays addButtonWithTitle:@"Yes"];
        [ays setMessageText:[NSString stringWithFormat:@"You are about to upload code associated with model \"%@\" to model “%@.\" Are you sure you want to proceed?", [model objectForKey:@"name"], aName]];
		[ays setInformativeText:@"This is probably because you selected a device whose assigned model is not the one associated with the current project. Uploading code will overwrite a model’s existing code."];
		[ays setAlertStyle:NSCriticalAlertStyle];
		[ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){
			
			if (returnCode == 1001)
			{
				// User wants to upload
				
				[self writeToLog:[NSString stringWithFormat:@"Uploading agent and device code from project \"%@\" to model \"%@\".", currentProject.projectName, [[modelsMenu itemAtIndex:currentModel] title]] :YES];
				[ide uploadCode:[self getModelID:currentModel] :currentProject.projectDeviceCode :currentProject.projectAgentCode];
			}
			else
			{
				[self writeToLog:@"[WARNING] Code not uploaded - model target changed." :YES];
			}
		}];
	}	
}



- (void)uploadCodeStageTwo
{
	[self writeToLog:@"Agent and device code uploaded. Restart the model\'s assigned device(s) to run the new code." :YES];
}



- (IBAction)refreshDevices:(id)sender
{
    if (ide.models.count == 0)
    {
        // Can't display devices without models. We have no models yet, so get both

        [self getApps];
    }
    else
    {
        if (currentDevice != -1) cDevice = [[ide.devices objectAtIndex:currentDevice] copy];

		[self writeToLog:@"Updating devices’ status information." :YES];
		[ide getDevices];
    }
}



- (void)listDevices
{
	// This method should ONLY be called by the ToolsAPI object instance AFTER loading a list of devices

	BOOL allDevicesUnassignedFlag = NO;
	BOOL addedUnassignedMenu = NO;
	NSMutableArray *autoRenameList = nil;
	NSMutableArray *deviceList = [[NSMutableArray alloc] init];

	// Bail if we're in the process of auto-renaming multiple devices
	// The last device on the rename flag will clear this so that everything
	// gets listed correctly and devices aren't renamed multiple times

	if (autoRenameFlag == YES) return;

	if (ide.devices.count == 0)
	{
		[self writeToLog:@"[WARNING] There are no devices listed on the server."  :YES];
		return;
	}

	if (ide.models.count == 0)
	{
		allDevicesUnassignedFlag = YES;
		[self writeToLog:@"[WARNING] There are no models listed on the server. All your devices are unnassigned."  :YES];
	}

    // Remove existing model menu device sub-menus (needed after reassignment)

    NSMenuItem *aMenuItem = nil;

    for (NSUInteger i = 0 ; i < modelsMenu.numberOfItems ; ++i)
    {
        aMenuItem = [modelsMenu itemAtIndex:i];

		if (aMenuItem.submenu != nil)
		{
			[aMenuItem.submenu removeAllItems];
			aMenuItem.submenu = nil;
		}
	}
	
	// Clear the unassigned section if there is one (we add it back if required; it may not be)

    aMenuItem = [modelsMenu itemAtIndex:modelsMenu.numberOfItems - 1];

    if ([aMenuItem.title compare:@"Unassigned"] == NSOrderedSame)
    {
        // There is an Unassigned entry (+ spacer) so remove both 

        [modelsMenu removeItemAtIndex:modelsMenu.numberOfItems - 1];
        [modelsMenu removeItemAtIndex:modelsMenu.numberOfItems - 1];
    }

	// Clear the devices list pop up

	[devicesPopUp removeAllItems];

	// Run through the current list of devices from the server and add them to the model menu submenus
	// We store a fresh list of device names in 'deviceList'

	for (NSMutableDictionary *device in ide.devices)
	{
		NSString *wantedModel = [device objectForKey:@"model_id"];

		if ((NSNull *)wantedModel == [NSNull null]) wantedModel = @"Unassigned";

		if ((([wantedModel compare:@"Unassigned"] == NSOrderedSame) || (allDevicesUnassignedFlag)) && (addedUnassignedMenu == NO))
		{
			// We need to add an 'Unassigned' category to the models menu

			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"Unassigned" action:nil keyEquivalent:@""];
			[modelsMenu addItem:item];
			addedUnassignedMenu = YES;
		}
		
        NSString *deviceMenuName = [device objectForKey:@"name"];

		if ((NSNull *)deviceMenuName == [NSNull null])
		{
			if (autoRenameList == nil) autoRenameList = [[NSMutableArray alloc] init];
			deviceMenuName = [device objectForKey:@"id"];
			[autoRenameList addObject:deviceMenuName];
		}

        /*
		 NSString *deviceState = [device valueForKey:@"powerstate"];

        // Add a tick or cross to the name to indicate online status

        if ([deviceState compare:@"online"] != NSOrderedSame)
        {
            deviceMenuName = [deviceMenuName stringByAppendingString:kOfflineTag];
        }


		if ([ide isDeviceLogging:(NSString *)[device objectForKey:@"id"]])
		{
			deviceMenuName = [deviceMenuName stringByAppendingString:@" Logging"];
		}
		*/

		// deviceMenuName = [deviceMenuName stringByAppendingString:[self menuString:[device objectForKey:@"id"]]];

        NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:deviceMenuName action:@selector(chooseDevice:) keyEquivalent:@""];

		[deviceList addObject:deviceMenuName];

		// Add the device to a model-menu entry's submenu
		
		if ([wantedModel compare:@"Unassigned"] == NSOrderedSame)
		{
			// Add the device to the Unassigned menu

			for (NSUInteger j = 0 ; j < modelsMenu.numberOfItems ; ++j)
			{
				NSMenuItem *aMenuItem = [modelsMenu itemAtIndex:j];

				if ([aMenuItem.title compare:@"Unassigned"] == NSOrderedSame)
				{
					NSMenu *submenu = aMenuItem.submenu;

					if (submenu == nil)
					{
						submenu = [[NSMenu alloc] initWithTitle:aMenuItem.title];
						submenu.autoenablesItems = YES;
						aMenuItem.submenu = submenu;
					}

					[submenu addItem:item];
					item.enabled = YES;
					break;
				}
			}
		}
		else
		{
			// Go through all the models to find the one with the ID we want

			for (NSDictionary *model in ide.models)
			{
				NSString *modelID = [model objectForKey:@"id"];

				if ([modelID compare:wantedModel] == NSOrderedSame)
				{
					// The model's id and the device's model_id match

					for (NSUInteger j = 0 ; j < modelsMenu.numberOfItems ; ++j)
					{
						NSMenuItem *aMenuItem = [modelsMenu itemAtIndex:j];

						// Find the menu that matches the selected model's name

						if ([aMenuItem.title compare:[model objectForKey:@"name"]] == NSOrderedSame)
						{
							NSMenu *submenu = aMenuItem.submenu;
						
							if (submenu == nil)
							{
								submenu = [[NSMenu alloc] initWithTitle:aMenuItem.title];
								submenu.autoenablesItems = YES;
								aMenuItem.submenu = submenu;
							}
							
							[submenu addItem:item];
							item.enabled = YES;
							break;
						}
					}

					break;
				}
			}
		}
	}
	
	// Make up the device pop up 

	if (deviceList.count > 0)
	{
		// Sort the list of devices by name
		
		[devicesPopUp addItemsWithTitles:[deviceList sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)]];
		
		if (cDevice)
		{
			NSString *dId = [cDevice objectForKey:@"id"];

			for (NSDictionary *aDev in ide.devices)
			{
				NSString *aDevId = [aDev objectForKey:@"id"];

				if ([aDevId compare:dId] == NSOrderedSame)
				{
					[devicesPopUp selectItemWithTitle:(NSString *)[aDev objectForKey:@"name"]];
					currentDevice = [ide.devices indexOfObject:aDev];
					break;
				}
			}
		}
		else
		{
			// No devices, so add a 'None' item at the top
			
			[devicesPopUp addItemWithTitle:@"None"];
			NSMenuItem *item = [devicesPopUp itemWithTitle:@"None"];
			[devicesPopUp selectItemWithTitle:@"None"];
			item.enabled = NO;
		}
	}

	
	// Sort the models menu's submenus
	
	for (NSUInteger i = 0 ; i < modelsMenu.numberOfItems ; ++i)
	{
		NSMenuItem *item = [modelsMenu itemAtIndex:i];
		if (item.submenu != nil)
		{
			NSArray *items = item.submenu.itemArray;
			[item.submenu removeAllItems];
			
			NSSortDescriptor* alphaDesc = [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
			items = [items sortedArrayUsingDescriptors:[NSArray arrayWithObjects:alphaDesc, nil]];
			
			for (NSMenuItem	*ditem in items)
			{
				[item.submenu addItem:ditem];
				if (ditem.isHidden) ditem.hidden = false;
			}
		}
	}
	
	
	if (addedUnassignedMenu)
	{
		// We added an ‘Unassigned’ entry in the models menu - we should move it to the end
		// but only if it's not the only entry

		if (modelsMenu.numberOfItems > 1)
		{
			NSMenuItem *unassMenuItem = [modelsMenu itemWithTitle:@"Unassigned"];
			NSUInteger unassIndex = [modelsMenu indexOfItemWithTitle:@"Unassigned"];
			[modelsMenu removeItemAtIndex:unassIndex];
			[modelsMenu addItem:[NSMenuItem separatorItem]];
			[modelsMenu addItem:unassMenuItem];
		}
	}

    // Modify the report line according to past action
    // ie. if we've reassigned devices, say so

	if (reDeviceIndex == -1)
    {
        // Reselect current model if there is one
		
		if (cDevice)
		{
			NSDictionary *dDict = [ide.devices objectAtIndex:currentDevice];
			NSString *dString = [dDict objectForKey:@"name"];
			
			for (NSInteger i = 0 ; i < modelsMenu.numberOfItems ; ++i)
			{
				NSMenuItem *modelItem = [modelsMenu itemAtIndex:i];
				NSMenu *devMenu = [modelItem submenu];
				if (devMenu)
				{
					for (NSInteger j = 0 ; j < devMenu.numberOfItems ; ++j)
					{
						NSMenuItem *devItem = [devMenu itemAtIndex:j];
						NSString *aString = devItem.title;
						NSArray *parts = [aString componentsSeparatedByString:@" "];
						aString = [parts objectAtIndex:0];
						if ([aString compare:dString] == NSOrderedSame) [self chooseDevice:devItem];
					}
				}
			}

			cDevice = nil;
		}
    }
    else
    {
        reDeviceIndex = -1;
        reModelIndex = -1;
    }

	[self writeToLog:@"Your models and devices lists have been updated." :YES];

    // This method deselects devices, so disable the Devices menu items

    for (NSUInteger i = 0 ; i < deviceMenu.numberOfItems ; ++i)
    {
        NSMenuItem *item = [deviceMenu itemAtIndex:i];
        if (item != refreshMenuItem) item.enabled = NO;
    }
	
	// Enable model menu items that require the presence of loaded devices

    assignDeviceModelMenuItem.enabled = YES;

	// Finally, did we 'rename' any unassigned devices? If so, actually rename them

	if (autoRenameList.count > 0)
	{
		[self writeToLog:@"[WARNING] There are new, unassigned devices present. These will now be processed." :YES];
		autoRenameFlag = YES;

		for (NSUInteger i = 0 ; i < autoRenameList.count ; ++i)
		{
			NSString *devId = [autoRenameList objectAtIndex:i];
			[ide autoRenameDevice:devId];

			// Is this the last change on the list?
			// If so, ermit listDevice: to actually list the devices

			if (i == autoRenameList.count - 1) autoRenameFlag = NO;
		}
	}

    if (devicesPopUp.numberOfItems > 0) devicesPopUp.enabled = YES;

	// Update the devices' state indicators

	[self updateDeviceLists];

	// Update other related parts of the UI
	
	[self updateMenus];
	[self setToolbar];
}



- (IBAction)chooseDevice:(id)sender
{
	// The user has selected a device from a Models menu item’s sub-menu
    // or has selected a device by some other means, eg. switching projects
	
	if (streamFlag == YES)
	{
		// NOTE THIS SECTION SHOULD NOT BE RUN NOW WE HAVE MULTI-DEVICE STREAMING

		if (currentDevice != -1)
		{
            NSDictionary *device = [ide.devices	objectAtIndex:currentDevice];

            if (selectDeviceFlag == NO)
            {
				// Are we logging? If so warn the user
                
                NSAlert *ays = [[NSAlert alloc] init];
                [ays addButtonWithTitle:@"No"];
                [ays addButtonWithTitle:@"Yes"];
                [ays setMessageText:[NSString stringWithFormat:@"You are currently logging from device \"%@\". Are you sure you want to proceed?", [device objectForKey:@"name"]]];
                [ays setInformativeText:@"Selecting another device will stop device logging."];
                [ays setAlertStyle:NSWarningAlertStyle];
                [ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){

                    if (returnCode == 1001)
                    {
                        // User wants to continue with the change, so turn off streaming
                        
                        [self streamLogs:nil];
                        [self setCurrentDeviceFromSelection:sender];
                    }
                }];
            }
            else
            {
                [self writeToLog:[NSString stringWithFormat:@"Reminder: you are currently logging from device \"%@\"", [device objectForKey:@"name"]] :YES];
            }
		}
        else
        {
            // Don't have a current device, so shouldn't be streaming – turn it off

            [self streamLogs:nil];
            [self setCurrentDeviceFromSelection:sender];
        }
	}
	else
	{
		[self setCurrentDeviceFromSelection:sender];
	}
}



- (void)setCurrentDeviceFromSelection:(id)sender
{
	// Sets currentDevice: based on (unique) name of device as presented by the menu
	
	NSMenuItem *item;
	NSString *dName;
	NSString *rawName;
	
	if (sender == devicesPopUp)
	{
		// Device selected from the popup rather than the menu
		
		item = devicesPopUp.selectedItem;
		
		if ([item.title compare:@"None"] == NSOrderedSame) 
		{
			item.enabled = NO;
			return;
		}
		
		NSMenuItem *nitem = [devicesPopUp itemWithTitle:@"None"];
		if (nitem != nil) [devicesPopUp removeItemWithTitle:@"None"];
	}
	else
	{
		item = (NSMenuItem *)sender;
	}
	
	rawName = item.title;
	
	//dName = [rawName substringToIndex:item.title.length - kStatusIndicatorWidth];    // For offline bullet

	// Extract the device name from the menu title

	NSArray *nameItems = [rawName componentsSeparatedByString:@" "];
	dName = [nameItems objectAtIndex:0];


	/*

	 NSRange oRange = [rawName rangeOfString:kOfflineTag];
	 
	 if (oRange.location != NSNotFound)
	{
		dName = [rawName substringToIndex:oRange.location];
	}
	else
	{
		dName = rawName;
	}
	 
	 */

	for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
	{
		// Get the device data from the devices list by name not index
		
		NSDictionary *dDict = [ide.devices objectAtIndex:i];
		NSString *dString = [dDict objectForKey:@"name"];
		
		if ([dString compare:dName] == NSOrderedSame) currentDevice = i;
	}
	
	// Update menus with new selection's name as necessary
	
	for (NSUInteger i = 0 ; i < modelsMenu.numberOfItems ; ++i)
	{
		NSMenuItem *model = [modelsMenu itemAtIndex:i];
		
		if (sender == devicesPopUp)
		{
			NSMenu *smenu = model.submenu;
			
			if (smenu != nil)
			{
				// Model has a submenu - see if it contains the selected device
				
				for (NSUInteger j = 0 ; j < smenu.numberOfItems ; ++j)
				{
					NSMenuItem *sdev = [smenu itemAtIndex:j];
					sdev.state = NSOffState;
					NSString *sName = @"";

					// [sdev.title substringToIndex:item.title.length - kStatusIndicatorWidth]; // For offline bullet

					NSRange oRange = [sdev.title rangeOfString:dName];

					if (oRange.location != NSNotFound)
					{
						sName = dName;
					}
					else
					{
						sName = sdev.title;
					}
					
					if ([sName compare:dName] == NSOrderedSame)
					{
						// We have a match so select the model, unless it's 'unassigned'
						
						if ([model.title compare:@"Unassigned"] != NSOrderedSame)
						{
							// Device’s assigned model can be selected so call chooseModel:
							// to select the model to ensure menus are enabled. This will
							// deselect all other device sub-menus but this one
							
							fromDeviceSelectFlag = YES;
							[self chooseModel:model];
							fromDeviceSelectFlag = NO;
						}
						else
						{
							// The device is unassigned, so don't select the model and clear the menu selection
							
							for (NSUInteger k = 0 ; k < modelsMenu.numberOfItems ; ++k)
							{
								NSMenuItem *aModel = [modelsMenu itemAtIndex:k];
								aModel.state = NSOffState;
							}
							
							currentModel = -1;
						}
						
						// Select the device itself
						
						sdev.state = NSOnState;
					}
				}
			}
		}
		else
		{
			if (model == item.parentItem)
			{
				// Select the device in its models menu submenu...
				
				if (model.submenu != nil)
				{
					for (NSUInteger j = 0 ; j < model.submenu.numberOfItems ; ++j)
					{
						NSMenuItem *sitem = [model.submenu itemAtIndex:j];
						sitem.state = NSOffState;
					}
				}
				
				item.state = NSOnState;
				
				// ...and in the devices popup
				
				[devicesPopUp selectItemWithTitle:rawName];
				
				// Is the device in the Unassigned section?
				
				if ([model.title compare:@"Unassigned"] == NSOrderedSame)
				{
					// The device is unassigned, so don't select the model and clear the menu selection
					
					for (NSUInteger j = 0 ; j < modelsMenu.numberOfItems ; ++j)
					{
						NSMenuItem *aModel = [modelsMenu itemAtIndex:j];
						aModel.state = NSOffState;
					}
					
					currentModel = -1;
				}
				else
				{
					// Device’s assigned model can be selected so call chooseModel:
					// to select the model to ensure menus are enabled. This will
					// deselect all other device sub-menus but this one
					
					fromDeviceSelectFlag = YES;
					[self chooseModel:model];
					fromDeviceSelectFlag = NO;
				}
			}
		}
	}

	// Set the Stream toolbar item according to state

	if (currentDevice != -1)
	{
		NSDictionary *dDict = [ide.devices objectAtIndex:currentDevice];
		NSString *dId = [dDict objectForKey:@"id"];

		streamLogsItem.isOn = [ide isDeviceLogging:dId];

		[streamLogsItem validate];
	}

	// Update Menus etc
	
	[self setDeviceMenu];
	[self updateMenus];
	[self setToolbar];
}



- (IBAction)restartDevice:(id)sender
{
    if (currentDevice == -1)
	{
		[self writeToLog:@"[ERROR] You have not selected a device to restart." :YES];
		return;
	}
	
	// Single devices can be restarted by assigning them to the model to which they
	// are already assigned.	
	
	restartFlag = YES;
	reDeviceIndex = currentDevice;
	
	[ide restartDevice:[self getDeviceID:currentDevice]];
}



- (IBAction)restartDevices:(id)sender
{
    if (currentModel == -1)
    {
        [self writeToLog:@"[ERROR] You have not selected a model. Go to Models > Current Models to select one." :YES];
        return;
    }

    NSMenuItem *mItem = [modelsMenu itemAtIndex:currentModel];
    if (mItem.submenu == nil)
    {
        [self writeToLog:@"[ERROR] You have selected a model with no assigned devices." :YES];
        return;
    }

    [ide restartDevices:[self getModelID:currentModel]];
}



- (void)restarted
{
    // This method should ONLY be called by the BuildAPI instance AFTER loading a list of models

	if (restartFlag == YES)
	{
		NSDictionary *dDict = [ide.devices objectAtIndex:reDeviceIndex];
		[self writeToLog:[NSString stringWithFormat:@"Device \"%@\" restarted.", [dDict objectForKey:@"name"]] :YES];
		restartFlag = NO;
		reDeviceIndex = -1;
		
	}
	else
	{
   		NSMenuItem *mItem = [modelsMenu itemAtIndex:currentModel];
    	[self writeToLog:[NSString stringWithFormat:@"Devices assigned to model \"%@\" have restarted.", mItem.title] :YES];
	}
}



- (IBAction)assignProject:(id)sender
{
	if (currentModel == -1)
	{
		[self writeToLog:@"[ERROR] You have not selected a model. Go to Models > Current Models to select one." :YES];
		return;
	}
	
	if (currentProject == nil)
	{
		[self writeToLog:@"[ERROR] You have not selected a project. Go to Project > Currently Open Projects to select one." :YES];
		return;
	}
	
	NSDictionary *model = [ide.models objectAtIndex:currentModel];
	currentProject.projectModelID = [model objectForKey:@"id"];
	currentProject.projectHasChanged = YES;
	[saveLight setFull:!currentProject.projectHasChanged];
}



- (IBAction)assignDevice:(id)sender
{
	if (ide.models.count == 0)
	{
		[self writeToLog:@"[ERROR] You have no models in your account. You will need to create one before any device can be assigned to a model." :YES];
		return;
	}

	if (ide.devices.count == 0)
	{
		[self writeToLog:@"[ERROR] You have no devices in your account." :YES];
		return;
	}
		
	// If we have got this far, we have a list of one or more models and one or more devices

	[assignDeviceMenuDevices removeAllItems];
	[assignDeviceMenuModels removeAllItems];

    assignDeviceMenuModels.autoenablesItems = NO;

    if (ide.devices.count > 0)
    {
        for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
        {
            NSDictionary *device = [ide.devices objectAtIndex:i];
            [assignDeviceMenuDevices addItemWithTitle:[device objectForKey:@"name"]];
        }
    }
    else
    {
        [assignDeviceMenuDevices addItemWithTitle:@"No devices"];
        assignDeviceMenuDevices.enabled = NO;
    }

    if (ide.models.count > 0)
    {
        for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
        {
            NSDictionary *model = [ide.models objectAtIndex:i];
            [assignDeviceMenuModels addItemWithTitle:[model objectForKey:@"name"]];
        }
    }
    else
    {
        [assignDeviceMenuModels addItemWithTitle:@"No models"];
        assignDeviceMenuModels.enabled = NO;
    }

    if (currentModel != -1) [assignDeviceMenuModels selectItemAtIndex:currentModel];
    if (currentDevice != -1) [assignDeviceMenuDevices selectItemAtIndex:currentDevice];

    [_window beginSheet:assignDeviceSheet completionHandler:nil];
}



- (IBAction)assignDeviceSheetCancel:(id)sender
{
	[_window endSheet:assignDeviceSheet];
}



- (IBAction)assignDeviceSheetAssign:(id)sender
{
	reDeviceIndex = [assignDeviceMenuDevices indexOfSelectedItem];
	reModelIndex = [assignDeviceMenuModels indexOfSelectedItem];

    [_window endSheet:assignDeviceSheet];
    [ide assignDevice:[self getDeviceID:reDeviceIndex] toModel:[self getModelID:reModelIndex]];
}



- (void)reassigned
{
    // This method should ONLY be called by the ToolsAPI instance AFTER loading a list of models,
	// possibly in response to a single device restart. reDeviceIndex may or may not equal currentDevice

    NSString *deviceName = [[ide.devices objectAtIndex:reDeviceIndex] objectForKey:@"name"];
	NSString *modelName = [[ide.models objectAtIndex:reModelIndex] objectForKey:@"name"];
	[self writeToLog:[NSString stringWithFormat:@"Device \"%@\" now assigned to model \"%@\".", deviceName, modelName] :YES];
}



- (IBAction)deleteModel:(id)sender
{
    if (currentModel == -1)
    {
        [self writeToLog:@"[ERROR] You have not selected a model. Go to Models > Current Models to select a model." :YES];
        return;
    }

    NSDictionary *mDict = [ide.models objectAtIndex:currentModel];
    NSString *mId = [mDict objectForKey:@"id"];
    NSString *devs = @"";
    BOOL flag = NO;
    toDelete = nil;

    for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
    {
        NSDictionary *dDict = [ide.devices objectAtIndex:i];
		NSString *m = [dDict objectForKey:@"model_id"];
		if ((NSNull *)m != [NSNull null])
		{
			if ([mId compare:m] == NSOrderedSame)
			{
				// Set flag to show at least one device is assigned to this model

				flag = YES;
				devs = [devs stringByAppendingFormat:@", %@", [dDict objectForKey:@"name"]];
			}
		}
    }

    if (flag == NO)
    {
        // No devices are assigned to this model, so proceed with the delete attempt

        NSAlert *ays = [[NSAlert alloc] init];
        [ays addButtonWithTitle:@"No"];
        [ays addButtonWithTitle:@"Yes"];
        [ays setMessageText:[NSString stringWithFormat:@"You are about to delete model \"%@\". Are you sure you want to proceed?", [mDict objectForKey:@"name"]]];
        [ays setInformativeText:@"Selecting ‘Yes’ will permanently delete the model."];
        [ays setAlertStyle:NSWarningAlertStyle];
        [ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){

            if (returnCode == 1001)
            {
                // Proceed with the deletion

                // TODO Remove link to open projects

                NSString *mID = [mDict objectForKey:@"id"];
                if (projectArray.count > 0)
                {
                    for (NSUInteger i = 0 ; i < projectArray.count ; ++i)
                    {
                        Project *aProject = [projectArray objectAtIndex:i];
                        if ([aProject.projectModelID compare:mID] == NSOrderedSame)
                        {
                            [self writeToLog:[NSString stringWithFormat:@"Unlinking model \"%@\" from project \"%@\".", [mDict objectForKey:@"name"], aProject.projectName] :YES];
                            aProject.projectModelID = @"";
                            aProject.projectHasChanged = YES;
                            if (aProject == currentProject) [saveLight setFull:NO];
                        }
                    }
                }

                toDelete = [mDict objectForKey:@"name"];
                [ide deleteModel:[self getModelID:currentModel]];
            }
        }];
    }
    else
    {
        devs = [devs substringFromIndex:2];
        NSString *s = @"this device";
        if ([devs componentsSeparatedByString:@","].count > 1) s = @"these devices";
        NSString *message = [NSString stringWithFormat:@"[ERROR] The model \"%@\" has one or more devices (%@) assigned to it. You must re-assign \"%@\" before deleting the model.", [mDict objectForKey:@"name"], devs, s];
        [self writeToLog:message :YES];
    }
}



- (void)deleteModelStageTwo
{
	// This method should ONLY be called by the ToolsAPI instance AFTER deleting a model
	
	[self writeToLog:[NSString stringWithFormat:@"Deleted model \"%@\". Refreshing your list of models.", toDelete] :YES];
}



- (IBAction)deleteDevice:(id)sender
{
	if (currentDevice == -1)
	{
		[self writeToLog:@"[ERROR] You have not selected a device to delete." :YES];
		return;
	}
	
	NSDictionary *dDict = [ide.devices objectAtIndex:currentDevice];
	NSAlert *ays = [[NSAlert alloc] init];
	[ays addButtonWithTitle:@"No"];
	[ays addButtonWithTitle:@"Yes"];
	[ays setMessageText:[NSString stringWithFormat:@"You are about to delete device \"%@\". Are you sure you want to proceed?", [dDict objectForKey:@"name"]]];
	[ays setInformativeText:@"Selecting ‘Yes’ will remove the device from your account."];
	[ays setAlertStyle:NSWarningAlertStyle];
	[ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode){
		
		if (returnCode == 1001)
		{
			// Proceed with the deletion
			
			toDelete = [dDict objectForKey:@"name"];
			[ide deleteDevice:[self getDeviceID:currentDevice]];
		}
	}];
}



- (void)deleteDeviceStageTwo
{
	// This method should ONLY be called by the ToolsAPI instance AFTER deleting a device
	
	[self writeToLog:[NSString stringWithFormat:@"Deleted device \"%@\". Refreshing your list of devices.", toDelete] :YES];
}



- (IBAction)renameModel:(id)sender
{
    renameLabel.stringValue = @"Select a model:";
    [renameMenu removeAllItems];

    for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
    {
        NSDictionary *mDict = [ide.models objectAtIndex:i];
        [renameMenu addItemWithTitle:[mDict objectForKey:@"name"]];
    }

    if (currentModel != -1) [renameMenu selectItemAtIndex:currentModel];

    [_window beginSheet:renameSheet completionHandler:nil];
}



- (IBAction)renameDevice:(id)sender
{
    // NOTE The outer checking code is probably unnecessary: you can't select this
	// menu option unless there is at least one device
	
	if (ide.devices.count > 0)
	{
		// Provided we have devices to list, set the Rename sheet’s title 
		// and clear its pop-up menu
		
		renameLabel.stringValue = @"Select a device:";
		[renameMenu removeAllItems];
		
		// Add devices’ names to the heet’s pop-up
		
		for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
		{
			NSDictionary *dDict = [ide.devices objectAtIndex:i];
			[renameMenu addItemWithTitle:[dDict objectForKey:@"name"]];
		}

		// If we have a device selected, makes sure it is also selected in the sheet pop-up
		
		if (currentDevice != -1)
		{
			NSDictionary *dDict = [ide.devices objectAtIndex:currentDevice];
			[renameMenu selectItemAtIndex:[ide.devices indexOfObject:dDict]];
		}
		
		// Present the sheet
		
		[_window beginSheet:renameSheet completionHandler:nil];
	}
	else
	{
		// The user has no devices, so post a warning

		[self writeToLog:@"[WARNING] You have no devices in your account." :YES];
	}
}



- (IBAction)closeRenameSheet:(id)sender
{
	[_window endSheet:renameSheet];
}



- (IBAction)saveRenameSheet:(id)sender
{
	NSString *newName = renameName.stringValue;
    NSInteger index = [renameMenu indexOfSelectedItem];

    [_window endSheet:renameSheet];
	
	if ([renameLabel.stringValue compare:@"Select a device:"] == NSOrderedSame)
    {
		NSDictionary *dDict = [ide.devices objectAtIndex:index];
		NSString *dString = [dDict objectForKey:@"name"];
		
		// Has the name actually been changed?
		
		if ([dString compare:newName] == NSOrderedSame)
		{
			// User hasn't changed the name
			
			[self writeToLog:[NSString stringWithFormat:@"[WARNING] The name of device \"%@\" remains unchanged.", newName] :YES];
			return;			
		}
		
		// Check for existing device name usage

		BOOL usedFlag = NO;
		
		for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
		{
			dDict = [ide.devices objectAtIndex:i];
			dString = [dDict objectForKey:@"name"];
			if ([dString compare:newName] == NSOrderedSame) usedFlag = YES;
		}

		if (usedFlag == YES)
		{
			[self writeToLog:[NSString stringWithFormat:@"[ERROR] The device name \"%@\" is already in use.", newName] :YES];
		}
		else
		{
			[ide updateDevice:[self getDeviceID:index] :@"name" :newName];
		}
    }
    else
    {
		NSDictionary *mDict = [ide.models objectAtIndex:index];
		NSString *mString = [mDict objectForKey:@"name"];
		
		// Has the name actually been changed?
		
		if ([mString compare:newName] == NSOrderedSame)
		{
			// User hasn't changed the name
			
			[self writeToLog:[NSString stringWithFormat:@"[WARNING] The name of model \"%@\" remains unchanged.", newName] :YES];
			return;			
		}
		
		// Check for existing model name usage

		BOOL usedFlag = NO;
		
		for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
		{
			mDict = [ide.models objectAtIndex:i];
			mString = [mDict objectForKey:@"name"];
			if ([mString compare:newName] == NSOrderedSame) usedFlag = YES;
		}

		if (usedFlag == YES)
		{
			[self writeToLog:[NSString stringWithFormat:@"[ERROR] The model name \"%@\" is already in use.", newName] :YES];
		}
		else
		{
			[ide updateModel:[self getModelID:index] :@"name" :newName];
		}
    }
}



- (void)renameDeviceStageTwo
{
	NSString *mString;
	
	if (unassignDeviceFlag) {
		
		mString = @"Device unassigned. Refreshing the list of your models and devices.";
		unassignDeviceFlag = NO;
		
	} else {
		
		mString = @"Device renamed. Refreshing the list of your models and devices.";
	}
	
	[self writeToLog:mString :YES];
}



- (void)renameModelStageTwo
{

	[self writeToLog:@"Model renamed. Refreshing the list of your models and devices." :YES];
}



- (IBAction)unassignDevice:(id)sender
{
	unassignDeviceFlag = YES;
	
	// Pass an empty string as the model_id to unassign a device

	[ide updateDevice:[self getDeviceID:currentDevice] :@"model_id" :@""];
}



#pragma mark - Device Log Methods


- (IBAction)getLogs:(id)sender
{
    if (currentModel == -1 || currentDevice == -1)
    {
        [self writeToLog:@"[ERROR] You have not selected a device. Go to Models > Current Models to select a model and one of its devices." :YES];
        return;
    }

    if (ide.models.count == 0)
    {
        [self writeToLog:@"[ERROR] You have no models in your account. You will need to create one before any device can be assigned to a model." :YES];
        return;
    }

    if (ide.devices.count == 0)
    {
        [self writeToLog:@"[ERROR] You have no devices in your account." :YES];
        return;
    }
    
    [ide getLogsForDevice:[self getDeviceID:currentDevice] :@"" :NO];
}



- (void)listLogs:(NSNotification *)note
{
    // This methiod should only be called by Tools API

	if (currentDevice == -1)
	{
		// This should never appear: without a selected device, the menu item will be disabled
		
		[self writeToLog:@"[ERROR] You have not selected a device to restart." :YES];
		return;
	}
	
	NSDictionary *device = [ide.devices objectAtIndex:currentDevice];

    // Shouldn't need to trap for failure (device == nil) as we only get the selected device
    // to acquire its name; this method wouldn't have been called if there *hadn't* been
    // a device selected

    [self writeToLog:[NSString stringWithFormat:@"Latest log entries for device \"%@\":", [device objectForKey:@"name"]] :NO];
	NSArray *theLogs = (NSArray *)note.object;

	// Calculate the width of the widest status message for spacing the output into columns

	NSUInteger width = 0;

	for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
	{
		NSDictionary *aLog = [theLogs objectAtIndex:i];
		NSString *sString = [aLog objectForKey:@"type"];
		if (sString.length > width) width = sString.length;
	}

	for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
	{
		NSDictionary *aLog = [theLogs objectAtIndex:i];
		NSString *dString = [aLog objectForKey:@"timestamp"];
		dString = [dString stringByReplacingOccurrencesOfString:@"T" withString:@" "];
		dString = [dString substringToIndex:19];
		NSString *tString = [aLog objectForKey:@"type"];
		NSString *sString = [@"                    " substringToIndex:width - tString.length];
		NSString *lString = [NSString stringWithFormat:@"%@ [%@] %@%@", dString, tString, sString, [aLog objectForKey:@"message"]];
		[self writeToLog:lString :NO];
	}
}



- (IBAction)printLog:(id)sender
{
	NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, 800, 1024)];
	[printView setEditable:YES];
	[printView insertText:logTextView.string];
	[printView setFont:logTextView.font];
	[printView setEditable:NO];

	NSPrintInfo *pInfo = [[NSPrintInfo alloc] init];
	[pInfo setHorizontalPagination:NSFitPagination];
	[pInfo setVerticallyCentered:NO];
	[pInfo setBottomMargin:34.0];
	[pInfo setTopMargin:34.0];
	[pInfo setRightMargin:34.0];
	[pInfo setLeftMargin:34.0];
	NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView
															   printInfo:pInfo];
	[printOp setCanSpawnSeparateThread:YES];
	[printOp runOperationModalForWindow:_window delegate:self didRunSelector:@selector(printDone) contextInfo:nil];
}



- (void)printDone
{
	[self writeToLog:@"Log contents printed." :YES];
}



- (IBAction)streamLogs:(id)sender
{
	if (currentDevice == -1)
	{
		// This should never appear: without a selected device, the menu item will be disabled
		
		[self writeToLog:@"[ERROR] You have not selected a device to monitor." :YES];
		return;
	}
	
	NSDictionary *device = [ide.devices	objectAtIndex:currentDevice];
	NSString *devId = [device objectForKey:@"id"];
    
	if (![ide isDeviceLogging:devId])
	{
		// Format the current date and time into ISO8601 and send to the API to get the poll_url
		
		NSDateFormatter *df = [[NSDateFormatter alloc] init];
		df.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss";
		NSString *tString = [df stringFromDate:[NSDate date]];

        [self writeToLog:[NSString stringWithFormat:@"Streaming logs from device \"%@\".", [device objectForKey:@"name"]] :YES];
		streamLogsItem.isOn = YES;

		if ([ide loggingCount] == 0)
		{
			[self setLoggingColours];
		}

        [ide getLogsForDevice:[device objectForKey:@"id"] :tString :YES];

		NSString *devName = [device objectForKey:@"name"];
		if (devName.length > logPaddingLength) logPaddingLength = devName.length;


	}
	else
	{
		[self writeToLog:[NSString stringWithFormat:@"Steaming logs from device \"%@\" stopped.", [device objectForKey:@"name"]] :YES];
		streamLogsItem.isOn = NO;
		[ide stopLogging:[device objectForKey:@"id"]];

		// Reset the log padding to the longest logging device name

		logPaddingLength = 0;

		for (NSMutableDictionary *aDevice in ide.devices)
		{
			NSString *aDevId = [aDevice objectForKey:@"id"];
			if ([ide isDeviceLogging:aDevId])
			{
				NSString *aDevName = [aDevice objectForKey:@"name"];
				if (aDevName.length > logPaddingLength) logPaddingLength = aDevName.length;
			}
		}
	}

	[streamLogsItem validate];
    [self setDeviceMenu];
	[self updateDeviceLists];
}



- (void)presentLogEntry:(NSNotification *)note
{
	NSDictionary *logItem = (NSDictionary *)note.object;
	NSArray *theLogs = [logItem objectForKey:@"logs"];
	NSString *devID = [logItem objectForKey:@"id"];
	NSString *dString = @"";

    NSUInteger width = 12;

    for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
    {
        NSDictionary *aLog = [theLogs objectAtIndex:i];
        NSString *sString = [aLog objectForKey:@"type"];
        if (sString.length > width) width = sString.length;
    }

	for (NSMutableDictionary *aDevice in ide.devices)
	{
		NSString *aID = [aDevice objectForKey:@"id"];

		if ([aID compare:devID] == NSOrderedSame)
		{
			dString = [aDevice objectForKey:@"name"];
		}
	}

	// Calculate colour table index

	NSUInteger index = [ide indexForID:devID];
	BOOL done = NO;
	while (done == NO)
	{
		if (index > logColors.count)
		{
			index = index - logColors.count;
		}
		else
		{
			done = YES;
		}
	}

	for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
    {
		NSArray *values;
		NSDictionary *aLog = [theLogs objectAtIndex:i];
        NSString *tString = [aLog objectForKey:@"type"];
        NSString *sString = [@"                                      " substringToIndex:width - tString.length];
		NSString *lString;

		if ([ide loggingCount] > 1)
		{
			NSString *pString = [@"                                      " substringToIndex:logPaddingLength - dString.length];
			lString = [NSString stringWithFormat:@"Streamed from \"%@\"%@: [%@] %@%@", dString, pString, tString, sString, [aLog objectForKey:@"message"]];
			values = [NSArray arrayWithObjects:[logColors objectAtIndex:index], nil];
		}
		else
		{
			lString = [NSString stringWithFormat:@"Streamed from \"%@\": [%@] %@%@", dString, tString, sString, [aLog objectForKey:@"message"]];
			values = [NSArray arrayWithObjects:textColour, nil];
		}

		lString = [[def stringFromDate:[NSDate date]] stringByAppendingFormat:@" %@", lString];
		NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, nil];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:lString attributes:attributes];

		[self writeStreamToLog:attrString];
    }
}



- (void)endLogging:(NSNotification *)note
{
	// Notification-triggered method called when logging ends because of a connection break

	NSString *devID = (NSString *)note.object;

	for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
	{
		NSMutableDictionary *aDev = [ide.devices objectAtIndex:i];
		NSString *aDevID = [aDev objectForKey:@"id"];

		if ([aDevID compare:devID] == NSOrderedSame)
		{
			// We have the device signalled by the end-of-logging notification

			if (i == currentDevice)
			{
				// Device about which we have been notified is the current device,
				// so fix the visible UI: update the stream logs toolbar item

				streamLogsItem.isOn = NO;
			}

			// Notify the user via the log
			
			[self writeToLog:[NSString stringWithFormat:@"[CONNECTION ERROR] Can no longer stream logs from device \"%@\"", [aDev objectForKey:@"name"]] :YES];
		}
	}

	[streamLogsItem validate];
	[self setDeviceMenu];
	[self updateDeviceLists];
}



- (IBAction)showAppCode:(id)sender
{
	// Request the latest code revision for the specified model

	NSDictionary *mDict = [ide.models objectAtIndex:currentModel];
    NSString *mID = [mDict objectForKey:@"id"];
    showCodeFlag = YES;
    [ide getCode:mID];
}



- (void)listCode:(NSString *)code :(NSInteger)from :(NSInteger)to :(NSInteger)at
{
	// Display 'code' as a listing in the log

    __block NSInteger lineStart = 1;
    __block NSInteger lineEnd = 0;
    __block NSInteger lineHighlight = -1;
	__block NSInteger lineTotal = 0;
	__block NSInteger numberLength = 1;
    __block NSInteger lineCount = 0;
	__block NSString *outputString = @"";

	NSString *zeroes = @"0000000000";

    // Run through the code string to count lines
	
	[code enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {
		++lineTotal;
	}];

    // Check the parameters

    lineStart = from;
    if (lineStart < 1) lineStart = 1;

    lineEnd = to;
    if (lineEnd > lineTotal || lineEnd < 1) lineEnd = lineTotal;

    if (lineEnd < lineStart)
    {
        // End comes before Start, so swap them around

        NSInteger a = lineStart;
        lineStart = lineEnd;
        lineEnd = a;
    }
    else if (lineEnd == lineStart)
    {
        // End equals Start, so just list the whole code

        lineEnd = lineTotal;
        lineStart = 1;
    }

    lineHighlight = at;
    if (lineHighlight > lineEnd || lineHighlight < lineStart) lineHighlight = -1;

    // Set the max number of characters in the biggest line number
	
	if (lineTotal > 99999)
	{
		numberLength = 6;
	}
	else if (lineTotal > 9999)
	{
		numberLength = 5;
	}
	else if (lineTotal > 999)
	{
		numberLength = 4;
	}
	else if (lineTotal > 99)
	{
		numberLength = 3;
	}
	else if (lineTotal > 9)
	{
		numberLength = 2;
	}

    // Run through the code again, this time to display
	
	[code enumerateLinesUsingBlock:^(NSString *line, BOOL *stop) {

        ++lineCount;

        if (lineCount >= lineStart && lineCount <= lineEnd)
        {
            NSString *num = [NSString stringWithFormat:@"%li", lineCount];
            NSString *initialZeroes = [zeroes substringToIndex:numberLength - num.length];

            if (lineHighlight != -1)
            {
                if (lineCount == lineHighlight)
                {
                    initialZeroes = [@"-> " stringByAppendingString:initialZeroes];
                    num = [initialZeroes stringByAppendingFormat:@"%@  %@", num, line];
                }
                else
                {
                    initialZeroes = [@"   " stringByAppendingString:initialZeroes];
                    num = [initialZeroes stringByAppendingFormat:@"%@  %@", num, line];
                }
            }
            else
            {
                num = [initialZeroes stringByAppendingFormat:@"%@  %@", num, line];
            }

			outputString = [outputString stringByAppendingFormat:@"%@\n", num];
        }
	}];

	// Get main thread to output the string
	listString = outputString;
	[self performSelectorOnMainThread:@selector(logCode) withObject:nil waitUntilDone:NO];
}



- (void)logCode
{
	[self writeToLog:listString :NO];
}


#pragma mark - Log Methods


- (IBAction)getProjectInfo:(id)sender
{
    // If there is no currently selected project, bail
	
    if (currentProject == nil)
	{
		[self writeToLog:@"[ERROR] There are no open projects." :YES];
		return;
	}
	
    NSArray *array;
    NSString *string = nil;
	
    [self writeToLog:@"------------------------------------------------------------------------------------" :YES];

	if (ide.models != nil && ide.models.count > 0)
	{
		for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
		{
			NSDictionary *model = [ide.models objectAtIndex:i];
            NSString *mID = [model objectForKey:@"id"];
            if ([mID compare:currentProject.projectModelID] == NSOrderedSame)
            {
				string = [model valueForKey:@"name"];
			}
		}
	}
	
    [self writeToLog:[NSString stringWithFormat:@"Project \"%@\"", currentProject.projectName] :YES];

	if (string) [self writeToLog:[NSString stringWithFormat:@"Project linked to model \"%@\"", string] :YES];

	[self writeToLog:[NSString stringWithFormat:@"Project directory: %@", currentProject.projectPath] :YES];
    [self writeToLog:[NSString stringWithFormat:@"Current working directory: %@", workingDirectory] :YES];
    [self writeToLog:@" " :YES];

    if (currentProject.projectAgentCodePath != nil)
    {
        string = @"Project has agent code";

        if (currentProject.projectSquinted > 1)
        {
            string = [string stringByAppendingString:@" which has been compiled."];
        }
        else
        {
            string = [string stringByAppendingString:@" which has not been compiled."];
        }
        
        [self writeToLog:string :YES];
        [self writeToLog:[NSString stringWithFormat:@"Agent code path: %@", currentProject.projectAgentCodePath] :YES];

        if (currentProject.projectAgentLibraries.count == 0)
        {
            [self writeToLog:@"There are no local libraries in the agent code." :YES];
        }
        else if (currentProject.projectAgentLibraries.count == 1)
        {
            [self writeToLog:@"There is 1 local library in the agent code:" :YES];
        }
        else
        {
            [self writeToLog:[NSString stringWithFormat:@"There are %li local libraries in the agent code:", (long)currentProject.projectAgentLibraries.count] :YES];
        }

        if (currentProject.projectAgentLibraries.count > 0)
        {
            array = [currentProject.projectAgentLibraries allValues];
            for (NSUInteger i = 0 ; i < array.count ; ++i)
            {
                [self writeToLog:[NSString stringWithFormat:@"%li. %@", (long)i+1, [array objectAtIndex:i]] :YES];
            }
        }

        //[self writeToLog:@" " :YES];

        if (currentProject.projectAgentFiles.count == 0)
        {
            [self writeToLog:@"There are no local files in the agent code." :YES];
        }
        else if (currentProject.projectAgentFiles.count == 1)
        {
            [self writeToLog:@"There is 1 local file in the agent code:" :YES];
        }
        else
        {
            [self writeToLog:[NSString stringWithFormat:@"There are %li local files in the agent code:", (long)currentProject.projectAgentFiles.count] :YES];
        }

        if (currentProject.projectAgentFiles.count > 0)
        {
            array = [currentProject.projectAgentFiles allValues];
            for (NSUInteger i = 0 ; i < array.count ; ++i)
            {
                [self writeToLog:[NSString stringWithFormat:@"%li. %@", (long)i+1, [array objectAtIndex:i]] :YES];
            }
        }

        [self writeToLog:@" " :YES];
    }
    else
    {
        [self writeToLog:@"Project has no agent code." :YES];
    }


    if (currentProject.projectDeviceCodePath != nil)
	{
        string = @"Project has device code";

        if (currentProject.projectSquinted == 1 || currentProject.projectSquinted == 3)
		{
			string = [string stringByAppendingString:@" which has been compiled."];
		}
		else
		{
			string = [string stringByAppendingString:@" which has not been compiled."];
		}

		[self writeToLog:string :YES];
        [self writeToLog:[NSString stringWithFormat:@"Device Code path: %@", currentProject.projectDeviceCodePath] :YES];

        if (currentProject.projectDeviceLibraries.count == 0)
        {
            [self writeToLog:@"There are no local libraries in the device code." :YES];
        }
        else if (currentProject.projectDeviceLibraries.count == 1)
        {
            [self writeToLog:@"There is 1 local library in the device code:" :YES];
        }
        else
        {
            [self writeToLog:[NSString stringWithFormat:@"There are %li local libraries in the device code:", (long)currentProject.projectDeviceLibraries.count] :YES];
        }

        if (currentProject.projectDeviceLibraries.count > 0)
        {
            array = [currentProject.projectDeviceLibraries allValues];
            for (NSUInteger i = 0 ; i < array.count ; ++i)
            {
                [self writeToLog:[NSString stringWithFormat:@"%li. %@", (long)i+1, [array objectAtIndex:i]] :YES];
            }
        }

        //[self writeToLog:@" " :YES];

        if (currentProject.projectDeviceFiles.count == 0)
        {
            [self writeToLog:@"There are no local files in the device code." :YES];
        }
        else if (currentProject.projectDeviceFiles.count == 1)
        {
            [self writeToLog:@"There is 1 local file in the device code:" :YES];
        }
        else
        {
            [self writeToLog:[NSString stringWithFormat:@"There are %li local files in the device code:", (long)currentProject.projectDeviceFiles.count] :YES];
        }

        if (currentProject.projectDeviceFiles.count > 0)
        {
            array = [currentProject.projectDeviceFiles allValues];
            for (NSUInteger i = 0 ; i < array.count ; ++i)
            {
                [self writeToLog:[NSString stringWithFormat:@"%li. %@", (long)i+1, [array objectAtIndex:i]] :YES];
            }
        }

        [self writeToLog:@" " :YES];

	}
	else
	{
		[self writeToLog:@"Project has no device code." :YES];
	}

	if (currentProject.projectImpLibs.count > 0)
    {
        if (currentProject.projectImpLibs.count == 1)
        {
            [self writeToLog:@"The Project includes the following Electric Imp library:" :YES];
        }
        else
        {
            [self writeToLog:@"The Project includes the following Electric Imp libraries:" :YES];
        }

		for (NSUInteger i = 0 ; i < currentProject.projectImpLibs.count ; ++i)
		{
            [self writeToLog:[NSString stringWithFormat:@"%li. %@", (long)i+1, [self getLibraryTitle:[currentProject.projectImpLibs objectAtIndex:i]]] :YES];
		}
    }
    else
    {
        [self writeToLog:@"The Project contains no Electric Imp libraries." :YES];
    }
	
	[self writeToLog:@"------------------------------------------------------------------------------------" :YES];
}



- (IBAction)showDeviceInfo:(id)sender
{
	if (currentDevice == -1)
	{
		// This should never appear: without a selected device, the menu item will be disabled
		
		[self writeToLog:@"[ERROR] You have not selected a device to restart." :YES];
		return;
	}
	
	NSDictionary *device = [ide.devices objectAtIndex:currentDevice];
							
	// If the device is unassigned, it will have a null model id

	NSString *mId = [device objectForKey:@"model_id"];
	NSString *modelName = nil;

	if ((NSNull *)mId != [NSNull null])
	{
		for (NSUInteger i = 0 ; i < ide.models.count ; ++i)
		{
			NSDictionary *model = [ide.models objectAtIndex:i];
			if ([[model objectForKey:@"id"] compare:mId] == NSOrderedSame) modelName = [NSString stringWithFormat:@"Model: %@", [model objectForKey:@"name"]];
		}
	}
	else
	{
		modelName = @"This device is not assigned to a model.";
	}

	[self writeToLog:@"--------------------------------------------------------------" :YES];
	[self writeToLog:[NSString stringWithFormat:@"Device: %@", [device objectForKey:@"name"]] :YES];
	[self writeToLog:[NSString stringWithFormat:@"Device ID: %@", [device objectForKey:@"id"]] :YES];
	[self writeToLog:[NSString stringWithFormat:@"State: %@", [device objectForKey:@"powerstate"]] :YES];
	[self writeToLog:modelName :YES];

	NSString *agentId = [device objectForKey:@"agent_id"];

	// If the device has never been assigned to a model, agentId will be NSNull, so check for this

	if ((NSNull *)agentId != [NSNull null])
	{
		[self writeToLog:[NSString stringWithFormat:@"Agent State: %@", [device objectForKey:@"agent_status"]] :YES];
		[self writeToLog:[NSString stringWithFormat:@"Agent URL: https://agent.electricimp.com/%@", [device objectForKey:@"agent_id"]] :YES];

		// Briefly switch on editing to activate the Agent URL link

		logTextView.editable = YES;
		[logTextView checkTextInDocument:nil];
		logTextView.editable = NO;
	}
	else
	{
		[self writeToLog:@"This device has no agent. You must assign it to a model first." :YES];
	}

	[self writeToLog:@"--------------------------------------------------------------" :YES];
}



- (IBAction)showModelInfo:(id)sender
{
    NSUInteger index = -1;

    if (currentModel == -1)
    {
        // No currently selected model, so check the menu

        if (ide.models.count > 0)
        {


            for (NSUInteger i = 0 ; i < modelsMenu.numberOfItems ; ++i)
            {
                NSMenuItem *item = [modelsMenu itemAtIndex:i];
                if (item.state == NSOnState) index = i;
            }

            if (index == -1)
            {
                [self writeToLog:@"[ERROR] You have not selected a model. Select one from the Models menu’s Current Models list." :YES];
                return;
            }
        }
        else
        {
            // No models to select

            [self writeToLog:@"[ERROR] You need to get your list of models from the server." :YES];
            return;
        }
    }
    else
    {
        index = currentModel;
    }

    NSDictionary *model = [ide.models objectAtIndex:index];
    NSString *mid = [model objectForKey:@"id"];

    [self writeToLog:@"------------------------------------------------------------" :YES];
    [self writeToLog:[NSString stringWithFormat:@"Model: %@", [model objectForKey:@"name"]] :YES];
    [self writeToLog:[NSString stringWithFormat:@"Model ID: %@", mid] :YES];

    NSString *dString = @"";
    NSUInteger dCount = 0;
    for (NSUInteger i = 0 ; i < ide.devices.count ; ++i)
    {
        NSDictionary *dev = [ide.devices objectAtIndex:i];
        NSString *dMid = [dev objectForKey:@"model_id"];
		if ((NSNull *)dMid == [NSNull null]) dMid = @"";
        if ([mid compare:dMid] == NSOrderedSame)
        {
            dString = [dString stringByAppendingFormat:@"%@, ", [dev objectForKey:@"name"]];
            ++dCount;
        }
    }

    if (dCount > 0)
    {
        // Remove final comma and space

        dString = [dString substringToIndex:dString.length - 2];
        NSString *cString = @"device";
        if (dCount > 1) cString = @"devices";
        [self writeToLog:[NSString stringWithFormat:@"%lu %@ assigned to this model: %@", (unsigned long)dCount, cString, dString] :YES];
    }
    else
    {
        [self writeToLog:@"No devices assigned to this model" :YES];
    }

    [self writeToLog:@"------------------------------------------------------------" :YES];
}



- (IBAction)logDeviceCode:(id)sender
{
    if (currentProject == nil) return;
	
	if (currentProject.projectDeviceCodePath.length < 1 || currentProject.projectDeviceCode.length < 1)
	{
		[self writeToLog:@"This project currently has no device code." :YES];
		return;
	}
	
	if (!(currentProject.projectSquinted & 0x01))
	{
		[self writeToLog:@"This project has not been compiled using the latest device code." :YES];
		[self writeToLog:@"This listing may not reflect your source code." :YES];
	}
	
	[self writeToLog:@"Device Code:" :NO];
	[self writeToLog:@" " :NO];

	//[self listCode:currentProject.projectDeviceCode :-1 :-1 :-1];
	//[self writeToLog:@" " :NO];

	[extraOpQueue addOperationWithBlock:^{[self listCode:currentProject.projectDeviceCode :-1 :-1 :-1];}];
}



- (IBAction)logAgentCode:(id)sender
{
    if (currentProject == nil) return;
    
	if (currentProject.projectAgentCodePath.length < 1 || currentProject.projectAgentCode.length < 1)
	{
		[self writeToLog:@"This project currently has no agent code." :YES];
		return;
	}
	
	if (!(currentProject.projectSquinted > 1))
	{
		[self writeToLog:@"This project has not been compiled using the latest agent code." :YES];
		[self writeToLog:@"This listing may not reflect your source code." :YES];
	}
	
	[self writeToLog:@"Agent Code:" :NO];
	[self writeToLog:@" " :NO];

	//[self listCode:currentProject.projectAgentCode :-1 :-1 :-1];
	//[self writeToLog:@" " :NO];

	[extraOpQueue addOperationWithBlock:^{[self listCode:currentProject.projectAgentCode :-1 :-1 :-1];}];
}



- (void)writeToLog:(NSString *)string :(BOOL)addTimestamp
{
    logTextView.editable = YES;
	
	// Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)
	
	[logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];
    
    if (addTimestamp)
    {
        [logTextView insertText:[def stringFromDate:[NSDate date]]];
        [logTextView insertText:@" "];
    }
    
    if (string != nil) [logTextView insertText:string];
    [logTextView insertText:@"\n"];
	logTextView.editable = NO;
}



- (void)writeStreamToLog:(NSAttributedString *)string
{
	logTextView.editable = YES;

	// Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

	[logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];
	if (string != nil) [logTextView insertText:string];
	[logTextView insertText:@"\n"];
	logTextView.editable = NO;
}



- (IBAction)clearLog:(id)sender
{
    [logTextView setString:@""];
}



- (void)displayError
{
    // Relay a Build API error, held in the Build API object instance's errorMessage property

    if (ide.errorMessage != nil)
    {
        if (ide.codeErrors.count > 0)
        {
            // Ignore all of this type of error message but for first line

            NSArray *lines = [ide.errorMessage componentsSeparatedByString:@"\n"];
            [self writeToLog:[lines firstObject] :YES];

            // Get the agent code then device code errors

            [self listCodeErrors:currentProject.projectAgentCode :@"Agent"];
            [self listCodeErrors:currentProject.projectDeviceCode :@"Device"];
            [self writeToLog:@" " :NO];
            [self writeToLog:@"Server-reported syntax-check code errors listed above." :YES];

            // Clear the list of errors for next time

            [ide.codeErrors removeAllObjects];
        }
        else
        {
            [self writeToLog:ide.errorMessage :YES];
        }
    }
    else
    {
        [self writeToLog:@"Connection error" :YES];
    }
}



- (void)listCodeErrors:(NSString *)code :(NSString *)codeKind
{
    NSDictionary *codeError;
    NSString *codeType;
    BOOL flag = NO;

    for (NSUInteger i = 0 ; i < ide.codeErrors.count ; ++i)
    {
        codeError = [ide.codeErrors objectAtIndex:i];
        codeType = [codeError valueForKey:@"type"];

        if ([codeType compare:[codeKind lowercaseString]] == NSOrderedSame)
        {
            if (!flag)
            {
                [self writeToLog:[NSString stringWithFormat:@"\n%@ code syntax errors:", codeKind] :NO];
                flag = YES;
            }

            NSNumber *r = [codeError valueForKey:@"row"];
            NSUInteger row = r.longValue;
            [self writeToLog:[codeError objectForKey:@"message"] :NO];
            [self listCode:code :row - 5 :row + 5 :row];
        }
    }
}



#pragma mark - Model and Device ID Look-up Methods


- (NSString *)getModelID:(NSInteger)index
{
    if (index < 0 || index > ide.models.count) return nil;
    NSDictionary *mDict = [ide.models objectAtIndex:index];
    return [mDict objectForKey:@"id"];
}



- (NSString *)getDeviceID:(NSInteger)index
{
    if (index < 0 || index > ide.devices.count) return nil;
    NSDictionary *dDict = [ide.devices objectAtIndex:index];
    return [dDict objectForKey:@"id"];
}



#pragma mark - External Editor Methods


- (IBAction)externalOpen:(id)sender
{
    // Open the original source code files an external editor
    
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
    
    if (sender == externalOpenDeviceItem || sender == externalOpenMenuItem || sender == viewDeviceCode)
    {
        if (currentProject.projectDeviceCodePath) [workspace openFile:currentProject.projectDeviceCodePath];
    }
    
    if (sender == externalOpenAgentItem || sender == externalOpenMenuItem || sender == viewAgentCode)
    {
        if (currentProject.projectAgentCodePath) [workspace openFile:currentProject.projectAgentCodePath];
    }
}



- (IBAction)externalLibOpen:(id)sender
{
    // Open class libraries in an external editor
    
    NSArray *keyArray;
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];
	
    if (sender == externalOpenLibItem)
    {
        if (currentProject.projectAgentLibraries.count > 0)
        {
            keyArray = [currentProject.projectAgentLibraries allKeys];
            
            for (NSUInteger i = 0 ; i < keyArray.count ; ++i)
            {
				// Yosemite seems to require a delay between NSWorkspace accesses, or not all files will be loaded
				
				[NSThread sleepForTimeInterval:0.2];
				[workspace openFile:[currentProject.projectAgentLibraries objectForKey:[keyArray objectAtIndex:i]] withApplication:nil andDeactivate:NO];
            }
        }
        
        if (currentProject.projectDeviceLibraries.count > 0)
        {
            keyArray = [currentProject.projectDeviceLibraries allKeys];
            
			for (NSUInteger i = 0 ; i < currentProject.projectDeviceLibraries.count ; ++i)
            {
				[NSThread sleepForTimeInterval:0.2];
				[workspace openFile:[currentProject.projectDeviceLibraries objectForKey:[keyArray objectAtIndex:i]] withApplication:nil andDeactivate:NO];
			}
        }
    }
    else
    {
        NSMenuItem *item = (NSMenuItem *)sender;
        NSInteger itemNumber = [item.menu indexOfItem:item];
        
        // We always present agent libs then device libs, so if the itemNumber is greater than
        // the number of items in the AgentProjectLibraryPaths, it's device code
        
        if (itemNumber - 1 < currentProject.projectAgentLibraries.count)
        {
			[workspace openFile:[currentProject.projectAgentLibraries objectForKey:item.title] withApplication:nil andDeactivate:NO];
        }
        else
        {
            [workspace openFile:[currentProject.projectDeviceLibraries objectForKey:item.title] withApplication:nil andDeactivate:NO];
        }
    }
}



- (IBAction)externalFileOpen:(id)sender
{
    // Open class libraries in an external editor

    NSArray *keyArray;
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];

    if (sender == externalOpenFileItem)
    {
        if (currentProject.projectAgentFiles.count > 0)
        {
            keyArray = [currentProject.projectAgentFiles allKeys];

            for (NSUInteger i = 0 ; i < keyArray.count ; ++i)
            {
                // Yosemite seems to require a delay between NSWorkspace accesses, or not all files will be loaded

                [NSThread sleepForTimeInterval:0.2];
                [workspace openFile:[currentProject.projectAgentFiles objectForKey:[keyArray objectAtIndex:i]] withApplication:nil andDeactivate:NO];
            }
        }

        if (currentProject.projectDeviceFiles.count > 0)
        {
            keyArray = [currentProject.projectDeviceFiles allKeys];

            for (NSUInteger i = 0 ; i < currentProject.projectDeviceFiles.count ; ++i)
            {
                [NSThread sleepForTimeInterval:0.2];
                [workspace openFile:[currentProject.projectDeviceFiles objectForKey:[keyArray objectAtIndex:i]] withApplication:nil andDeactivate:NO];
            }
        }
    }
    else
    {
        NSMenuItem *item = (NSMenuItem *)sender;
        NSInteger itemNumber = [item.menu indexOfItem:item];

        // We always present agent libs then device libs, so if the itemNumber is greater than
        // the number of items in the AgentProjectLibraryPaths, it's device code

        if (itemNumber < currentProject.projectAgentFiles.count)
        {
            [workspace openFile:[currentProject.projectAgentFiles objectForKey:item.title] withApplication:nil andDeactivate:NO];
        }
        else
        {
            [workspace openFile:[currentProject.projectDeviceFiles objectForKey:item.title] withApplication:nil andDeactivate:NO];
        }
    }
}



- (IBAction)externalOpenAll:(id)sender
{
    NSWorkspace *workspace = [NSWorkspace sharedWorkspace];

	if (currentProject.projectVersion.floatValue > 2.0)
	{
		NSURL *agentFileURL = [self urlForBookmark:currentProject.projectAgentCodeBookmark];
		NSString *agentFilePath = [agentFileURL absoluteString];
		[workspace openFile:agentFilePath withApplication:nil andDeactivate:NO];

		[NSThread sleepForTimeInterval:0.2];

		NSURL *deviceFileURL = [self urlForBookmark:currentProject.projectDeviceCodeBookmark];
		NSString *deviceFilePath = [deviceFileURL absoluteString];
		[workspace openFile:deviceFilePath withApplication:nil andDeactivate:NO];
	}
	else
	{
		if (currentProject.projectDeviceCodePath) [workspace openFile:currentProject.projectDeviceCodePath withApplication:nil andDeactivate:NO];

		// Add a delay, or the second open is somehow missed out

		[NSThread sleepForTimeInterval:0.2];

		if (currentProject.projectAgentCodePath) [workspace openFile:currentProject.projectAgentCodePath withApplication:nil andDeactivate:NO];

		if (sender != externalOpenBothItem)
		{
			[self externalLibOpen:externalOpenLibItem];
			[self externalFileOpen:externalOpenFileItem];
		}
	}
}



- (IBAction)openAgentURL:(id)sender
{
	if (currentDevice == -1)
	{
		// This should never appear: without a selected device, the menu item will be disabled

		[self writeToLog:@"[ERROR] You have not selected a device." :YES];
		return;
	}

	NSDictionary *device = [ide.devices objectAtIndex:currentDevice];
	NSString *uString = [NSString stringWithFormat:@"https://agent.electricimp.com/%@", [device objectForKey:@"agent_id"]];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:uString]];
}



#pragma mark - Preferences Methods


- (IBAction)showPrefs:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    // Set working directory

	workingDirectoryField.stringValue = @"";
	workingDirectoryField.stringValue = workingDirectory;

    // Set colour wells

    float r = [[defaults objectForKey:@"com.bps.squinter.text.red"] floatValue];
    float b = [[defaults objectForKey:@"com.bps.squinter.text.blue"] floatValue];
    float g = [[defaults objectForKey:@"com.bps.squinter.text.green"] floatValue];
    textColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    r = [[defaults objectForKey:@"com.bps.squinter.back.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.back.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.back.green"] floatValue];
    backColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    textColorWell.color = textColour;
    [textColorWell setAction:@selector(showPanelForText)];
    backColorWell.color = backColour;
    [backColorWell setAction:@selector(showPanelForBack)];

    // Set font name and size menus

    [fontsMenu selectItemAtIndex:[[defaults objectForKey:@"com.bps.squinter.fontNameIndex"] integerValue]];
    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.fontSizeIndex"] integerValue] - 9;
    if (index == 9) index = 6;
    [sizeMenu selectItemAtIndex:index];

    // Set checkboxes

    if ([defaults boolForKey:@"com.bps.squinter.preservews"])
    {
        preserveCheckbox.state = NSOnState;
    }
    else
    {
        preserveCheckbox.state = NSOffState;
    }
	
	if ([defaults boolForKey:@"com.bps.squinter.autocompile"])
	{
		autoCompileCheckbox.state = NSOnState;
	}
	else
	{
		autoCompileCheckbox.state = NSOffState;
	}
	
	if ([defaults boolForKey:@"com.bps.squinter.autoload"])
	{
		loadModelsCheckbox.state = NSOnState;
	}
	else
	{
		loadModelsCheckbox.state = NSOffState;
	}
	
	if ([defaults boolForKey:@"com.bps.squinter.autoselectdevice"])
	{
		autoSelectDeviceCheckbox.state = NSOnState;
	}
	else
	{
		autoSelectDeviceCheckbox.state = NSOffState;
	}
	
	if ([defaults boolForKey:@"com.bps.squinter.autocheckupdates"])
	{
		autoUpdateCheckCheckbox.state = NSOnState;
	}
	else
	{
		autoUpdateCheckCheckbox.state = NSOffState;
	}

	if ([defaults boolForKey:@"com.bps.squinter.showboldtext"])
	{
		boldTestCheckbox.state = NSOnState;
	}
	else
	{
		boldTestCheckbox.state = NSOffState;
	}

    // Show the sheet

    [_window beginSheet:preferencesSheet completionHandler:nil];

    // Save request for credentials until after the sheet has appeared
    // (Makes connection between credential request and field more obvious)

    if ([[defaults stringForKey:@"com.bps.squinter.ak.count"] compare:@"xxx"] == NSOrderedSame)
    {
        akTextField.stringValue = @"";
    }
    else
    {
        PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
        akTextField.stringValue = [ide decodeBase64String:[pc stringForKey:@"com.bps.Squinter.ak.notional.tally"]];
    }
}



- (IBAction)cancelPrefs:(id)sender
{
    [_window endSheet:preferencesSheet];
}



- (IBAction)setPrefs:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    workingDirectory = workingDirectoryField.stringValue;

    if (preserveCheckbox.state == NSOnState)
    {
        [defaults setBool:YES forKey:@"com.bps.squinter.preservews"];
    }
    else
    {
        [defaults setBool:NO forKey:@"com.bps.squinter.preservews"];
    }
	
	if (autoCompileCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autocompile"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autocompile"];
	}
	
	if (autoSelectDeviceCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autoselectdevice"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autoselectdevice"];
	}
	
	if (autoUpdateCheckCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autocheckupdates"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autocheckupdates"];
	}
	
	if ([akTextField.stringValue compare:@""] != NSOrderedSame)
	{
		[defaults setObject:@"something" forKey:@"com.bps.squinter.ak.count"];

        // Keychain

        PDKeychainBindings *pk = [PDKeychainBindings sharedKeychainBindings];
        [pk setObject:[ide encodeBase64String:akTextField.stringValue] forKey:@"com.bps.Squinter.ak.notional.tally"];
	}
    else
    {
        // Clear credo

        [defaults setObject:@"xxx" forKey:@"com.bps.squinter.ak.count"];
        [ide clrk];

        PDKeychainBindings *pk = [PDKeychainBindings sharedKeychainBindings];
        [pk setObject:@"" forKey:@"com.bps.Squinter.ak.notional.tally"];
    }

	if (loadModelsCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autoload"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autoload"];
	}

	if (boldTestCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.showboldtext"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.showboldtext"];
	}

    textColour = textColorWell.color;
    backColour = backColorWell.color;

    float r = (float)[textColour redComponent];
    float b = (float)[textColour blueComponent];
    float g = (float)[textColour greenComponent];

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.text.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.text.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.text.blue"];

    r = (float)[backColour redComponent];
    b = (float)[backColour blueComponent];
    g = (float)[backColour greenComponent];

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.back.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.back.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.back.blue"];

    if (r == 0) r = 0.1;
    if (b == 0) b = 0.1;
    if (g == 0) g = 0.1;

    NSUInteger a = 100 * r * b * g;
    if (a < 30)
    {
        [logScrollView setScrollerKnobStyle:NSScrollerKnobStyleLight];
    }
    else
    {
        [logScrollView setScrollerKnobStyle:NSScrollerKnobStyleDark];
    }

    NSString *fontName = [self getFontName:fontsMenu.indexOfSelectedItem];
    NSInteger fontSize = kInitialFontSize + sizeMenu.indexOfSelectedItem;
    if (fontSize == 15) fontSize = 18;

	logTextView.font = [self setLogViewFont:fontName :fontSize :(boldTestCheckbox.state == NSOnState)];
	[logTextView setTextColor:textColour];
    [logClipView setBackgroundColor:backColour];

    [defaults setObject:[NSNumber numberWithInteger:fontsMenu.indexOfSelectedItem] forKey:@"com.bps.squinter.fontNameIndex"];
    [defaults setObject:[NSNumber numberWithInteger:fontSize] forKey:@"com.bps.squinter.fontSizeIndex"];

    // Close the sheet

    [_window endSheet:preferencesSheet];
}



- (IBAction)chooseWorkingDirectory:(id)sender
{
    if (choosePanel) choosePanel = nil;
    choosePanel = [NSOpenPanel openPanel];
    choosePanel.message = @"Select a directory for your projects...";
    choosePanel.canChooseFiles = NO;
    choosePanel.canChooseDirectories = YES;
    choosePanel.canCreateDirectories = YES;
    choosePanel.allowsMultipleSelection = NO;
    choosePanel.delegate = self;

    // Run the NSOpenPanel

    [choosePanel beginSheetModalForWindow:preferencesSheet
                       completionHandler:^(NSInteger result)
     {
         // Close sheet first to stop it hogging the event queue

         [NSApp stopModal];
         [NSApp endSheet:choosePanel];
         [choosePanel orderOut:self];

         if (result == NSFileHandlingPanelOKButton) [self setWorkingDirectory:[choosePanel URLs]];
     }
     ];

    [NSApp runModalForWindow:choosePanel];
    [choosePanel makeKeyWindow];
}



- (void)setWorkingDirectory:(NSArray *)urls
{
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    workingDirectoryField.stringValue = path;
}



- (NSString *)getFontName:(NSInteger)index
{
    NSString *fontName = @"";

    switch (index)
    {
        case 0:
            fontName = @"Andale Mono";
            break;

        case 1:
            fontName = @"Courier";
            break;

        case 2:
            fontName = @"Menlo";
            break;

        case 3:
            fontName = @"Monaco";
            break;

		case 4:
            fontName = @"Source Code Pro";
            break;

        default:
            fontName = @"Menlo";
            break;
    }

    return fontName;
}



- (void)showPanelForText
{
    [textColorWell setColor:[NSColorPanel sharedColorPanel].color];
}



- (void)showPanelForBack
{
    [backColorWell setColor:[NSColorPanel sharedColorPanel].color];
}



#pragma mark - About and Help Sheet Methods


- (IBAction)showAboutSheet:(id)sender
{
    [aboutVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@.%@",
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
    [_window beginSheet:aboutSheet completionHandler:nil];
}



- (IBAction)closeAboutSheet:(id)sender
{
    [_window endSheet:aboutSheet];
}



- (IBAction)showHideToolbar:(id)sender
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	if (squinterToolbar.isVisible)
    {
        squinterToolbar.visible = NO;
        showHideToolbarMenuItem.title = @"Show Toolbar";
        [defaults setValue:[NSNumber numberWithBool:NO] forKey:@"com.bps.squinter.toolbarstatus"];
    }
    else
    {
        squinterToolbar.visible = YES;
        showHideToolbarMenuItem.title = @"Hide Toolbar";
		[defaults setValue:[NSNumber numberWithBool:YES] forKey:@"com.bps.squinter.toolbarstatus"];
    }
}



- (IBAction)showAuthor:(id)sender
{
    if (sender == author01) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/carlbrown/PDKeychainBindingsController"]];
    if (sender == author02) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/bdkjones/VDKQueue"]];
    if (sender == author03) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/uliwitness/UliKit"]];
    if (sender == author04) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://electricimp.com/docs/buildapi/"]];
	if (sender == author05) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/adobe-fonts/source-code-pro"]];
	if (sender == author06) [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://github.com/sparkle-project/Sparkle/blob/master/LICENSE"]];
}



#pragma mark - UI Update Methods


- (void)updateMenus
{
    // Single point to run all the menu-setting methods
	
	[self setDeviceMenu];
    [self setModelsMenu];
    [self setProjectMenu];
    [self setViewMenu];
}



- (void)setDeviceMenu
{
    // Sets the state of various device menu entries

    if (currentDevice != -1)
    {
        // There is a current device, so add its name to the menus
		
		NSDictionary *device = [ide.devices objectAtIndex:currentDevice];
		NSString *dString = [device objectForKey:@"name"];
		NSString *dId = [device objectForKey:@"id"];

        showSelectedMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", dString];
		restartSelectedMenuItem.title = [NSString stringWithFormat:@"Restart “%@”", dString];
		copySelectedMenuItem.title = [NSString stringWithFormat:@"Copy ”%@” Agent URL", dString];
		openAgentURLMenuItem.title = [NSString stringWithFormat:@"Open ”%@” Agent URL", dString];
        unassignSelectedMenuItem.title = [NSString stringWithFormat:@"Unassign “%@”", dString];
        removeSelectedMenuItem.title = [NSString stringWithFormat:@"Remove “%@” from Your Account", dString];
        getLogsSelectedMenuItem.title = [NSString stringWithFormat:@"Get Logs from “%@”", dString];
        
		// Update the stream item according to whether we are streaming or not
		
        if ([ide isDeviceLogging:dId])
        {
            streamLogsMenuItem.title = [NSString stringWithFormat:@"Stop Log Stream from “%@”", dString];
        }
        else
        {
            streamLogsMenuItem.title = [NSString stringWithFormat:@"Start Log Stream from “%@”", dString];
        }
		
		// Enable all the menu items
		
		for (NSUInteger i = 0 ; i < deviceMenu.numberOfItems ; ++i)
		{
			NSMenuItem *item = [deviceMenu itemAtIndex:i];
			item.enabled = YES;
		}
		
		// But if the selected device is unassigned, turn off the unassign menu item
		
		if ((NSNull *)[device objectForKey:@"model_id"] == [NSNull null]) unassignSelectedMenuItem.enabled = NO;
    }
    else
    {
        // No device is current, so apply generic menu names
		
		showSelectedMenuItem.title = @"Show Selected Device Info";
		restartSelectedMenuItem.title = @"Restart Selected Device";
		copySelectedMenuItem.title = @"Copy Selected Device’s Agent URL";
		openAgentURLMenuItem.title = @"Open Selected Device’s Agent URL";
		unassignSelectedMenuItem.title = @"Unassign Selected Device";
        removeSelectedMenuItem.title = @"Remove Selected Device from Your Account";
        getLogsSelectedMenuItem.title = @"Get Logs from Selected Device";
        streamLogsMenuItem.title = @"Start Log Stream from Selected Device";
        
		// Disable all menu items but the last - no device selected so nothing to action
		
		for (NSUInteger i = 0 ; i < deviceMenu.numberOfItems - 1 ; ++i)
		{
            // Assumes last item on menu (Update Devices’ Status) is always last

            NSMenuItem *item = [deviceMenu itemAtIndex:i];
			item.enabled = NO;
		}
		
		// Enable last item (update status)
		
		NSMenuItem *item = [deviceMenu itemAtIndex:(deviceMenu.numberOfItems - 1)];
		item.enabled = YES;
		
		// If we have devices, make sure the rename device menu item is enabled
		
		if (ide.devices.count > 0) renameDeviceMenuItem.enabled = YES;
    }
	
	// Enable or disable the devices popup according to whether we have devices listed or not
	
	if (ide.devices.count == 0) 
	{
		devicesPopUp.enabled = NO;
	}
	else
	{
		devicesPopUp.enabled = YES;
	}
}



- (void)setModelsMenu
{
	// Sets the state of various model menu entries
	
	if (currentModel != -1)
    {
        // A model has been chosen so update menu items with selected model's name

        NSString *mString = [[modelsMenu itemAtIndex:currentModel] title];
        showModelInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", mString];
        showModelCodeMenuItem.title = [NSString stringWithFormat:@"Show “%@” Code in Log", mString];
        deleteModelMenuItem.title = [NSString stringWithFormat:@"Delete “%@”", mString];
        saveModelProjectMenuItem.title = [NSString stringWithFormat:@"Save “%@” as a Project...", mString];
		restartDevicesModelMenuItem.title = [NSString stringWithFormat:@"Restart All “%@” Devices", mString];

        // Enable model menu items that require a model selection

        showModelInfoMenuItem.enabled = YES;
		showModelCodeMenuItem.enabled = YES;
		deleteModelMenuItem.enabled = YES;
        saveModelProjectMenuItem.enabled = YES;
        
        // Enable or disable items that also require a project selection

        if (currentProject != nil)
        {
            // Project selected and a model selected

            linkMenuItem.title = [NSString stringWithFormat:@"Link Model “%@” to Project “%@”", mString, currentProject.projectName];
            linkMenuItem.enabled = YES;
        }
        else
        {
            // Model selected but no project selected

            linkMenuItem.title = [NSString stringWithFormat:@"Link Model “%@” to a Project", mString];
            linkMenuItem.enabled = NO;
        }

		// Enable or disable items that also require models with devices


		NSMutableDictionary *aModel = [ide.models objectAtIndex:currentModel];
		NSArray *mDevs = [aModel objectForKey:@"devices"];

		if (mDevs.count > 0)
		{
			restartDevicesModelMenuItem.enabled = YES;
		}
		else
		{
			restartDevicesModelMenuItem.enabled = NO;
		}
    }
    else
    {
        // There's no selected model, so zero everything; make names generic

        showModelInfoMenuItem.title = @"Show Selected Model Info";
        showModelCodeMenuItem.title = @"Show Selected Model Code in Log";
        deleteModelMenuItem.title = @"Delete Selected Model";
        saveModelProjectMenuItem.title = @"Save Selected Model as a Project...";
		restartDevicesModelMenuItem.title = @"Restart All Selected Model’s Devices";

        showModelInfoMenuItem.enabled = NO;
        showModelCodeMenuItem.enabled = NO;
        deleteModelMenuItem.enabled = NO;
        saveModelProjectMenuItem.enabled = NO;
		restartDevicesModelMenuItem.enabled = NO;

        // Update items that may have a project selection

        if (currentProject != nil)
        {
            // Project selected but no model selected

            linkMenuItem.title = [NSString stringWithFormat:@"Link a Model to Project “%@”", currentProject.projectName];
        }
        else
        {
            // Neither project nor model selected

            linkMenuItem.title = @"Link a Model to a Project";
        }

        linkMenuItem.enabled = NO;
    }

    // Update items that only need a list of apps

	if (ide.models.count > 0)
	{
		renameModelMenuItem.enabled = YES;
		assignDeviceModelMenuItem.enabled = YES;
	}
	else
	{
		renameModelMenuItem.enabled = NO;
		assignDeviceModelMenuItem.enabled = NO;
	}
}



- (void)setProjectMenu
{
    // Set the Project menu's state 
	// NOTE this does not manage the Current Open Projects submenu - this is handled
	// by closeProject: and addProjectMenuItem:
	
	if (currentProject != nil)
    {
        // A project has been selected - update the menu items with its name
		
		squintMenuItem.title = [NSString stringWithFormat:@"Compile Project “%@”", currentProject.projectName];
        cleanMenuItem.title = [NSString stringWithFormat:@"Clean Project “%@”", currentProject.projectName];
		squintMenuItem.enabled = YES;
		cleanMenuItem.enabled = YES;
		
		externalOpenMenuItem.title = [NSString stringWithFormat:@"Open “%@” Main Files in Editor", currentProject.projectName];
		externalOpenLibItem.title = [NSString stringWithFormat:@"Open “%@” Library Files in Editor", currentProject.projectName];
        externalOpenFileItem.title = [NSString stringWithFormat:@"Open “%@” Linked Files in Editor", currentProject.projectName];
		
		copyAgentCodeItem.enabled = (currentProject.projectSquinted > 1);
		copyDeviceCodeItem.enabled = (currentProject.projectSquinted == 1 || currentProject.projectSquinted == 3);
		
		if (currentModel != -1)
        {
            // Model and Project selected

            NSDictionary *mDict = [ide.models objectAtIndex:currentModel];
            projectLinkMenuItem.title = [NSString stringWithFormat:@"Link Project “%@” to Model “%@”", currentProject.projectName, [mDict objectForKey:@"name"]];
			projectLinkMenuItem.enabled = YES;
        }
        else
        {
            // Project selected but no Model

            projectLinkMenuItem.title = [NSString stringWithFormat:@"Link “%@’ to a Model", currentProject.projectName];
            projectLinkMenuItem.enabled = NO;
        }

		if (currentProject.projectModelID != nil)
		{
			// Does the current project have a linked model?

			NSString *mName;
			BOOL nameFlag = NO;

			for (NSDictionary *model in ide.models)
			{
				NSString *mID = [model objectForKey:@"id"];

				if ([currentProject.projectModelID compare:mID] == NSOrderedSame)
				{
					mName = [model objectForKey:@"name"];
					nameFlag = YES;
					break;
				}
			}


			if (nameFlag)
			{
				uploadMenuItem.title = [NSString stringWithFormat:@"Upload Project “%@” to Model “%@”", currentProject.projectName, mName];
				uploadMenuItem.enabled = YES;
			}
			else
			{
				uploadMenuItem.title = [NSString stringWithFormat:@"Upload Project “%@” to a Model", currentProject.projectName];
				uploadMenuItem.enabled = NO;
			}
		}
		else
		{
			// We have no linked model, so suggest the currently selected one

			uploadMenuItem.title = [NSString stringWithFormat:@"Upload Project “%@” to a Model", currentProject.projectName];
			uploadMenuItem.enabled = NO;
		}

    }
    else
    {
        // No project selected
		
		squintMenuItem.title = @"Compile Current Project";
		cleanMenuItem.title = @"Clean Current Project";
		squintMenuItem.enabled = NO;
		cleanMenuItem.enabled = NO;
		copyAgentCodeItem.enabled = NO;
		copyDeviceCodeItem.enabled = NO;
		
		externalOpenMenuItem.title = @"Open Main Files in Editor";
		externalOpenLibItem.title = @"Open Library Files in Editor";
		externalOpenFileItem.title = @"Open Linked Files in Editor";

		// Reset Open Libs submenu
		
		[externalLibsMenu removeAllItems];
		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
		[externalLibsMenu addItem:item];
		item.enabled = NO;

        // Reset Open Files submenu

        [externalFilesMenu removeAllItems];
        item = [[NSMenuItem alloc] initWithTitle:@"None" action:NULL keyEquivalent:@""];
        [externalFilesMenu addItem:item];
        item.enabled = NO;

        if (currentModel != -1)
        {
            // Model selected but no project

            NSDictionary *mDict = [ide.models objectAtIndex:currentModel];
            uploadMenuItem.title = [NSString stringWithFormat:@"Upload a Project to Model “%@”", [mDict objectForKey:@"name"]];
            projectLinkMenuItem.title = [NSString stringWithFormat:@"Link a Project to Model “%@”", [mDict objectForKey:@"name"]];
		}
        else
        {
            // Neither Project nor Model selected

            projectLinkMenuItem.title = @"Link a Project to a Model";
            uploadMenuItem.title = @"Upload a Project to a Model";
        }
		
		uploadMenuItem.enabled = NO;
		projectLinkMenuItem.enabled = NO;
	}
}



- (void)setViewMenu
{
    // The View menu has two items. These are only actionable if there is a selected project
	// and that project has been compiled
	
	if (currentProject != nil && currentProject.projectSquinted > 0)
    {
        logDeviceCodeMenuItem.enabled = YES;
        logAgentCodeMenuItem.enabled = YES;
    }
    else
    {
        logDeviceCodeMenuItem.enabled = NO;
        logAgentCodeMenuItem.enabled = NO;
    }
}



- (void)setProjectLists
{
	[projectsMenu removeAllItems];
	[projectsPopUp removeAllItems];

	if (projectArray.count > 0)
	{
		// There are projects to list, so add them all to the menu and the pop-up

		for (NSUInteger i = 0 ; i < projectArray.count ; ++i)
		{
			Project *project = [projectArray objectAtIndex:i];
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:project.projectName action:@selector(chooseProject:) keyEquivalent:@""];
			[projectsMenu addItem:item];
			[projectsPopUp addItemWithTitle:project.projectName];
		}

		if (currentProject != nil)
		{
			// We have a project selected, so mark it as such in the menu and pop-up

			NSMenuItem *selected = [projectsMenu itemWithTitle:currentProject.projectName];
			for (NSUInteger i = 0 ; i < projectsMenu.numberOfItems ; ++i)
			{
				NSMenuItem *anItem = [projectsMenu itemAtIndex:i];

				if (anItem == selected)
				{
					anItem.state = NSOnState;
					[projectsPopUp selectItemWithTitle:selected.title];
				}
				else
				{
					anItem.state = NSOffState;
				}
			}
		}
	}
	else
	{
		// No projects open, so just add 'None' items to the menu and the pop-up

		NSMenuItem *noneItem = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
		[projectsMenu addItem:noneItem];
		[projectsPopUp addItemWithTitle:@"None"];
	}
}



- (void)updateDeviceLists
{
	// Rename all menus based on online state and logging state
	// Note we only use the existing info; we don't reload the device
	// list from the server

	// Do the popup

	NSUInteger len = 24;

	for (NSMenuItem *item in devicesPopUp.itemArray)
	{
		NSArray *itemTitleParts = [item.title componentsSeparatedByString:@" "];
		NSString *itemTitle = [itemTitleParts objectAtIndex:0];
		if (itemTitle.length > len) len = itemTitle.length;
	}

	for (NSMenuItem *item in devicesPopUp.itemArray)
	{
		NSArray *itemTitleParts = [item.title componentsSeparatedByString:@" "];
		NSString *itemTitle = [itemTitleParts objectAtIndex:0];

		for (NSMutableDictionary *device in ide.devices)
		{
			NSString *deviceName = [device objectForKey:@"name"];

			if ((NSNull *)deviceName == [NSNull null])
			{
				// We have to check for null device

				deviceName = [device objectForKey:@"id"];
			}

			if ([itemTitle compare:deviceName] == NSOrderedSame)
			{
				itemTitle = [itemTitle stringByAppendingString:[self menuString:[device objectForKey:@"id"]]];

				/* 
				 
				NSDictionary *attributes;
				NSRange aRange = [iTitle rangeOfString:@"offline"];
				itemTitle = [NSString stringWithFormat:@"%@%@", itemTitle, [@"                        " substringToIndex:(len - itemTitle.length)]];
				if (aRange.location == NSNotFound)
				{
					attributes = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSColor colorWithRed:0.0 green:1.0 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,
										[NSFont menuFontOfSize:[NSFont systemFontSize]],
										NSFontAttributeName, nil];
				}
				else
				{
					attributes = [NSDictionary dictionaryWithObjectsAndKeys:
										[NSColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,
										[NSFont menuFontOfSize:[NSFont systemFontSize]],
										NSFontAttributeName, nil];
				}

				NSMutableAttributedString *as1 = [[NSMutableAttributedString alloc] initWithString:@"• " attributes:attributes];

				attributes = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:1.0], NSForegroundColorAttributeName,
							  [NSFont menuFontOfSize:[NSFont systemFontSize]],
							  NSFontAttributeName, nil];

				NSMutableAttributedString *as2 = [[NSMutableAttributedString alloc] initWithString:itemTitle attributes:attributes];

				[as1 appendAttributedString:as2];

				// NSAttributedString *as = [[NSAttributedString alloc] initWithString:@"•" attributes:attributes];

				[item setAttributedTitle:as1];

				*/

				item.title = itemTitle;
			}
		}
	}

	// Do the models menu's submenus

	for (NSMenuItem *item in modelsMenu.itemArray)
	{
		// Does the model have any devices? If it does not, it will have no submenu

		if (item.submenu != nil)
		{
			NSMenu *submenu = item.submenu;

			for (NSMenuItem *submenuItem in submenu.itemArray)
			{
				NSArray *itemTitleParts = [submenuItem.title componentsSeparatedByString:@" "];
				NSString *itemTitle = [itemTitleParts objectAtIndex:0];

				for (NSMutableDictionary *device in ide.devices)
				{
					NSString *deviceName = [device objectForKey:@"name"];

					if ((NSNull *)deviceName == [NSNull null])
					{
						deviceName = [device objectForKey:@"id"];
					}

					if ([itemTitle compare:deviceName] == NSOrderedSame)
					{
						submenuItem.title = [itemTitle stringByAppendingString:[self menuString:[device objectForKey:@"id"]]];
					}
				}
			}
		}
	}
}



- (NSString *)menuString:(NSString *)deviceID
{
	// Creates the status readout that will be added to the device's name in menus
	// eg. "Action (logging)"

	NSString *statusString = @"";
	NSString *loggingString = @"";
	NSString *returnString = @"";

	for (NSMutableDictionary *device in ide.devices)
	{
		NSString *aDeviceID = [device objectForKey:@"id"];

		if ([aDeviceID compare:deviceID] == NSOrderedSame)
		{
			// Get the online state

			aDeviceID = [device objectForKey:@"powerstate"];
			if ([aDeviceID compare:@"online"] != NSOrderedSame) statusString = @"offline";
			break;
		}
	}

	if ([ide isDeviceLogging:deviceID]) loggingString = @"logging";

	// Assemble the menuString, eg.
	// "(offline)", "(offline, logging)", "(logging)"

	if (loggingString.length > 0 || statusString.length > 0)
	{
		// Start with a space and an open bracket

		returnString = @" (";

		if (statusString.length > 0) returnString = [returnString stringByAppendingString:statusString];
		if (loggingString.length > 0)
		{
			if (returnString.length > 2) returnString = [returnString stringByAppendingString:@", "];
			returnString = [returnString stringByAppendingString:loggingString];
		}

		returnString = [returnString stringByAppendingString:@")"];
	}

	return returnString;
}



- (void)setToolbar
{
    [squinterToolbar validateVisibleItems];
	
	// Enable or disable project-specific toolbar items
	// New Project, Clear, Print are always available

    if (currentProject != nil)
    {
		squintItem.enabled = YES;
		infoItem.enabled = YES;
        openAgentCode.enabled = YES;
        openDeviceCode.enabled = YES;
        openAllItem.enabled = YES;
		copyAgentItem.enabled = YES;
		copyDeviceItem.enabled = YES;

		// Display Upload button only if we have a linked model

		if (currentProject.projectModelID != nil)
		{
			uploadCodeItem.enabled = YES;
		}
		else
		{
			uploadCodeItem.enabled = NO;
		}
    }
    else
    {
		squintItem.enabled = NO;
		infoItem.enabled = NO;
        openAgentCode.enabled = NO;
        openDeviceCode.enabled = NO;
        openAllItem.enabled = NO;
		copyAgentItem.enabled = NO;
		copyDeviceItem.enabled = NO;
		uploadCodeItem.enabled = NO;
    }

    // Enable or disable model-specific toolbar items

    if (currentModel != -1)
    {
        restartDevicesItem.enabled = YES;
    }
    else
    {
        restartDevicesItem.enabled = NO;
    }
	
	// Enable or disable device-specific toolbar items
	
	if (currentDevice != -1)
	{
		streamLogsItem.enabled = YES;
	}
	else
	{
		streamLogsItem.enabled = NO;
	}
}



- (void)setColours
{
	// Populate the 'colors' array with a set of colours for logging different devices

	[colors addObject:[NSColor cyanColor]];
	[colors addObject:[NSColor magentaColor]];
	[colors addObject:[NSColor yellowColor]];
	[colors addObject:[NSColor orangeColor]];
	[colors addObject:[NSColor brownColor]];
	[colors addObject:[NSColor purpleColor]];
	[colors addObject:[NSColor greenColor]];
	[colors addObject:[NSColor redColor]];
	[colors addObject:[NSColor blueColor]];
}



- (void)setLoggingColours
{
	[logColors removeAllObjects];

	NSInteger back = [self perceivedBrightness:backColour];

	if (back > 130)
	{
		// Background is light

		for (NSColor *colour in colors)
		{
			NSInteger stock = [self perceivedBrightness:colour];

			if (back - stock > 20)
			{
				[logColors addObject:colour];
			}
		}
	}
	else
	{
		// Background is dark

		for (NSColor *colour in colors)
		{
			NSInteger stock = [self perceivedBrightness:colour];

			if (stock - back > 20)
			{
				[logColors addObject:colour];
			}
		}
	}
}



- (NSInteger)perceivedBrightness:(NSColor *)colour
{
	CGFloat red, blue, green, alpha;
	[colour colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	[colour getRed:&red green:&green blue:&blue alpha:&alpha];
	red = red * 255;
	blue = blue * 255;
	green = green * 255;
	return (NSInteger)sqrt((red * red * .241) + (green * green * .691) + (blue * blue * .068));
}



- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold
{
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font;

	if (isBold)
	{
		font = [fontManager fontWithFamily:fontName
									traits:NSBoldFontMask
									weight:0
									  size:fontSize];
	}
	else
	{
		font = [NSFont fontWithName:fontName size:fontSize];
	}

	return font;
}


#pragma mark - Progress Methods


- (void)startProgress
{
    connectionIndicator.hidden = NO;
    [connectionIndicator startAnimation:self];
}



- (void)stopProgress
{
    [connectionIndicator stopAnimation:self];
    connectionIndicator.hidden = YES;
}



#pragma mark - File Watching Methods


- (NSData *)bookmarkForURL:(NSURL *)url
{
	NSError *error = nil;
	NSData *bookmark = [url bookmarkDataWithOptions:NSURLBookmarkCreationSuitableForBookmarkFile
					 includingResourceValuesForKeys:nil
									  relativeToURL:[NSURL URLWithString:@"~"]
											  error:&error];
	if (error || (bookmark == nil))
	{
		return nil;
	}

	return bookmark;
}



- (NSURL *)urlForBookmark:(NSData *)bookmark
{
	BOOL bookmarkIsStale = NO;
	NSError *error = nil;
	NSURL *bookmarkURL = [NSURL URLByResolvingBookmarkData:bookmark
												   options:NSURLBookmarkResolutionWithoutUI
											 relativeToURL:[NSURL URLWithString:@"~"]
									   bookmarkDataIsStale:&bookmarkIsStale
													 error:&error];

	if (error != nil)
	{
		// Report error
		return nil;
	}

	if (bookmarkIsStale) {
		// Need to refresh the bookmark from the URL
		// Question is, what makes a bookmark stale?

		bookmark = [self bookmarkForURL:bookmarkURL];
	}

	return bookmarkURL;
}



-(void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath
{
    // A file has changed so notify the user
	// IMPORTANT: fpath is the ORIGINAL location. VDKQueue will continue watching this file wherever it is moved
	// or whatever it is renamed.
	
    if ([noteName compare:VDKQueueRenameNotification] == NSOrderedSame)
    {
        // Called when the file is MOVED or RENAMED

        // TODO pop up a dialog to prompt for search

        currentProject.projectSquinted = 0;
		currentProject.projectHasChanged = YES;
        [saveLight setFull:!currentProject.projectHasChanged];
		
		[self writeToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been renamed or moved. You will need to re-add it to this project.", [fpath lastPathComponent]] :YES];
    }
	
	if ([noteName compare:VDKQueueDeleteNotification] == NSOrderedSame)
	{
		// Only called when Trash is emptied
		
		NSString *string = [fpath lastPathComponent];
		NSRange range = [string rangeOfString:@"."];
		string = [string substringFromIndex:range.location + 1];
		range = [string rangeOfString:@"."];
		NSString *type = [string substringToIndex:range.location];
		
		// Remove file from project and clear appropriate libraries list
		
		if ([type compare:@"agent"] == NSOrderedSame)
		{
			currentProject.projectAgentCodePath = nil;
			[currentProject.projectAgentLibraries removeAllObjects];
			currentProject.projectAgentLibraries = nil;
			currentProject.projectSquinted = currentProject.projectSquinted = 0 & 0x01;
		}
		
		if ([type compare:@"device"] == NSOrderedSame)
		{
			currentProject.projectDeviceCodePath = nil;
			[currentProject.projectDeviceLibraries removeAllObjects];
			currentProject.projectDeviceLibraries = nil;
			currentProject.projectSquinted = currentProject.projectSquinted = 0 & 0x02;
		}
		
		currentProject.projectSquinted = 0;
		currentProject.projectHasChanged = YES;
		[saveLight setFull:!currentProject.projectHasChanged];
		
		[self writeToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been deleted.", [fpath lastPathComponent]] :YES];
	}
	
	if ([noteName compare:VDKQueueWriteNotification] == NSOrderedSame)
	{
		[self writeToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been edited - you may wish to recompile this project.", [fpath lastPathComponent]] :YES];
		currentProject.projectSquinted = 0;
	}
	
	// Update the Project Menu in case the 'projectSquinted' value has changed
	
	[self setProjectMenu];
}


#pragma mark - Check EI Libs Methods

- (void)checkElectricImpLibs
{
	// Initiate a read of the current Electric Imp library versions
	// Only do this if the project contains EI libraries and 1 hour has
	// passed since the last look-up

	BOOL performCheck = NO;

	if (currentProject.projectImpLibs.count > 0)
	{
		if (eiLibListTime)
		{
			NSDate *now = [NSDate date];
			NSTimeInterval interval = [eiLibListTime timeIntervalSinceDate:now];

			if (interval < kEILibCheckInterval)
			{
				// Last check was more than 1 hour earlier

				performCheck = YES;
			}
			else
			{
				// Last check was less than 1 hour earlier, so use existing list if it exists

				if (eiLibListData)
				{
					[self compareElectricImpLibs];
					return;
				}
				else
				{
					performCheck = YES;
				}
			}
		}
		else
		{
			performCheck = YES;
		}


		if (performCheck)
		{
			// Set/reset the time of the most recent check

			eiLibListTime = [NSDate date];

			if (connectionIndicator.hidden == YES)
			{
				// Start the connection indicator
				connectionIndicator.hidden = NO;
				[connectionIndicator startAnimation:self];
			}

			NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://electricimp.com/liblist.csv"]];
			[request setHTTPMethod:@"GET"];
			eiLibListData = [NSMutableData dataWithCapacity:0];
			NSURLSession *session = [NSURLSession sessionWithConfiguration: [NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
			eiLibListTask = [session dataTaskWithRequest:request];
			[eiLibListTask resume];
		}
	}
}


- (void)URLSession:(NSURLSession *)session
		  dataTask:(NSURLSessionDataTask *)dataTask
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
	// This delegate method is called when the server responds to the connection request
	// Use it to trap certain status codes

	NSHTTPURLResponse *rps = (NSHTTPURLResponse *)response;
	if (rps.statusCode != 200)
	{
		NSString *errString =[NSString stringWithFormat:@"[ERROR] Could not get list of Electric Imp libraries (Code: %ld)", (long)rps.statusCode];
		[self writeToLog:errString :YES];

		completionHandler(NSURLSessionResponseCancel);
		return;
	}

	completionHandler(NSURLSessionResponseAllow);
}



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	// This delegate method is called when the server sends some data back
	// Add the data to the correct connexion object

	[eiLibListData appendData:data];
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	// All the data has been supplied by the server in response to a connection - or an error has been encountered
	// Parse the data and, according to the connection activity - update device, create model etc – apply the results

	if (task == eiLibListTask)
	{
		if ([ide getConnectionCount] < 1)
		{
			// Only hide the connection indicator if 'ide' has no live connections

			[connectionIndicator stopAnimation:self];
			connectionIndicator.hidden = YES;
		}
		
		if (error)
		{
			// React to a passed client-side error - most likely a timeout or inability to resolve the URL
			// ie. the client is not connected to the Internet

			// 'error.code' will equal NSURLErrorCancelled when we kill all connections

			if (error.code == NSURLErrorCancelled) return;

			[task cancel];
			return;
		}

		// The connection has come to a conclusion without error

		[task cancel];
		[self compareElectricImpLibs];
	}
}



- (void)compareElectricImpLibs
{
	NSString *parsedData;

	if (eiLibListData != nil && eiLibListData.length > 0)
	{
		// If we have data, attempt to decode it assuming that it is JSON (if it's not, 'error' will not equal nil

		parsedData = [[NSString alloc] initWithData:eiLibListData encoding:NSASCIIStringEncoding];
	}
	else
	{
		[self writeToLog:@"[ERROR] Could not parse list of Electric Imp libraries" :YES];
		eiLibListData = nil;
		return;
	}

	if (parsedData != nil)
	{
		// 'parsedData' should contain the csv data

		BOOL allOKFlag = YES;
		NSArray *libraryList = [parsedData componentsSeparatedByString:@"\n"];
		for (NSString *library in libraryList)
		{
			// Watch out for single carriage-returns in .csv file

			if (library.length > 2)
			{
				NSArray *libParts = [library componentsSeparatedByString:@","];
				NSString *libName = [[libParts objectAtIndex:0] lowercaseString];
				NSString *libVer = [libParts objectAtIndex:1];

				for (NSArray *eiLib in currentProject.projectImpLibs)
				{
					NSString *eiLibName = [[eiLib objectAtIndex:0] lowercaseString];
					NSString *eiLibVer = [eiLib objectAtIndex:1];

					if ([eiLibName compare:libName] == NSOrderedSame)
					{
						// Local EI lib record and download lib record match
						// First check for deprecation
						if ([libVer compare:@"dep"] == NSOrderedSame)
						{
							// Library is marked as deprecated

							NSString *mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is deprecated. Please replace it with \"%@\".", libName, [libParts objectAtIndex:2]];
							[self writeToLog:mString :YES];
							allOKFlag = NO;
						}
						else if ([eiLibVer compare:libVer] != NSOrderedSame)
						{
							// Library versions are not the same, so report the discrepancy

							NSString *mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is at version %@ - you have version %@.", libName, libVer, eiLibVer];
							[self writeToLog:mString :YES];
							allOKFlag = NO;
						}
					}
				}
			}
		}

		if (allOKFlag)
		{
			[self writeToLog:[NSString stringWithFormat:@"All the Electric Imp libraries used in project \"%@\" are up to date.", currentProject.projectName] :YES];
		}
	}
}

/*

 - (IBAction)showHelpSheet:(id)sender
 {
	// NOTE This method is now redundant - replaced by Help System pages

	[self clearLog:nil];

 NSString *helpString = @"\nSquinter provides an easy way to manage the Squirrel code you are writing for your Electric Imp project, specifically the easy addition of multiple local library files to your Agent and Device code.\n\nSquinter expects application code files to be named in the standard Electric Imp schema: ‘*.agent.nut’ and ‘*.device.nut’ for, respectively, your agent and device code. The two identifiers (represented here by the wildcard *) need not be identical, but when creating a new project from source code files, Squinter will use the agent code filename as the basis for the project’s name.\n\nLocal library files should be entered into your Agent and Device source code using the following syntax:\n\n#import \"library_filepath\\library_filename\"\n\nThe name of the library file is arbitrary, but ‘*.class.nut’ and ‘*.library.nut’ are the recommended forms. You may include a full Unix filepath; if you only provide a filename, Squinter currently expects the file to reside in the same folder as the project file. New projects are saved in Squinter’s working directory, which you can set in the Preferences.\n\nProject files can be identified by the ‘.squirrelproj’ extension. Save these for future easy access to specific projects.\n\nMultiple projects may be open at the same time; open projects are listed in the ‘Project’ menu. From here, you may also open the project’s source and library files in your preferred text editor, or any other application registered to open ‘.nut’ files.\n\nProject code files may also include Electric Imp libraries. These are listed in the library menus alongside local libraries. Selecting one opens the Libraries page on the Electric Imp Dev Center site.\n\nYou can zero a project - remove its code, libraries and model association - by selecting ‘Clean’ from the ‘Project’ menu.\n\nClicking the ‘Compile’ toolbar button, or selecting ‘Compile’ from the ‘Project’ menu, will process the current project’s agent and/or device code source files, replacing #import statements with the local library code from the named file(s). The source files remain unchanged to facilitate editing. When compilation is complete, the ‘compiled’ code is ready for you to copy to the clipboard and paste it into the Electric Imp IDE — or to upload it directly to the Electric Imp server if you have access via API key. API keys can be obtained by logging in to the IDE and selecting ‘Build API Keys’ from the username menu. You can also view the compiled code in Squinter’s log - see the ‘View’ menu.\n\nSquinter can check the Electric Imp Cloud for your existing models and any devices they may be associated with. Once you have obtained list of current models and selected one (via the ‘Models’ menu’s ‘Current Models’ sub-menu), you can upload compiled code directly to it. You can also link a project with a specific model so that changes made to it will be uploaded to the correct model.\n\nIf you select a device (associated devices are listed under each model) you can use the ‘Devices’ menu item ‘Restart’ to reboot it once new code has been uploaded. The ‘Restart Devices’ toolbar item will restart all the devices associated with the selected model. The ‘Device’ menu contains the option ‘Show Device Info’ to inform you of the device’s online status, ID and agent URL. Devices with a dot after their name are currently online; those without are offline. You can select ‘Update Devices Status’ from the ‘Devices” menu to refresh this information.\n\nAccess to model and device lists, and to the code upload facility, requires an API key. API keys can be obtained by logging in to the IDE and selecting ‘Build API Keys’ from the username menu. Enter your key into the space provided in the Preferences panel.\n";

 [self writeToLog:helpString :NO];
 [logClipView scrollToPoint:NSMakePoint(0.0, 0.0)];
 }

 */





@end
