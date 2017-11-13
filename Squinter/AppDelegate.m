

#import "AppDelegate.h"


@implementation AppDelegate


#pragma mark - Initialization Methods


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
	//NSDocumentController *sc = [NSDocumentController sharedDocumentController];
	//[sc clearRecentDocuments:self];

	// Set up stock date formatter

    def = [[NSDateFormatter alloc] init];
    def.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZZ";
	def.timeZone = [NSTimeZone localTimeZone];

	logDef = [[NSDateFormatter alloc] init];
	logDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ"; // @"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSS'Z'";
	logDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    // Initialize app properties
	// NOTE 'currentXXX' indicates a selected Squinter object
	//      'selectedXXX' indicates a selected API object

	currentProject = nil;
	currentDevicegroup = nil;
	selectedProduct = nil;
	selectedDevice = nil;
	projectArray = nil;
	devicesArray = nil;
	productsArray = nil;
	downloads = nil;
	ide = nil;
	dockMenu = nil;

	eiLibListData = nil;
	eiLibListTask = nil;
	eiLibListTime = nil;

	newDevicegroupName = nil;

	newDevicegroupFlag = NO;
	deviceSelectFlag = NO;
	renameProjectFlag = NO;
	saveAsFlag = YES;
	stale = NO;

	syncItemCount = 0;
	logPaddingLength = 0;

	nswsw = NSWorkspace.sharedWorkspace;
	nsfm = NSFileManager.defaultManager;
	nsncdc = NSNotificationCenter.defaultCenter;
	defaults = NSUserDefaults.standardUserDefaults;

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
	
	[defaults setBool:YES forKey:@"NSDisabledDictationMenuItem"];
	[defaults setBool:YES forKey:@"NSDisabledCharacterPaletteMenuItem"];

	// File Menu

	fileMenu.autoenablesItems = NO;
	openRecentMenu.autoenablesItems = NO;

	[self refreshRecentFilesMenu];

	// Projects Menu

    projectsMenu.autoenablesItems = NO;

	[self refreshOpenProjectsMenu];
	[self refreshProjectsMenu];
	[self refreshProductsMenu];

	// Device Groups Menu

	externalSourceMenu.autoenablesItems = NO;

	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];
	[self refreshLibraryMenus];
	[self refreshFilesMenu];

	// Device Menu

	deviceMenu.autoenablesItems = NO;

	[self refreshDeviceMenu];
	[self refreshDevicesPopup];

	// NOTE refreshDevicegroupMenu: calls refreshDevicesMenus:
	// NOTE refreshDevicesPopup: calls refreshUnassignedDevices:

    // View Menu

    showHideToolbarMenuItem.title = @"Hide Toolbar";
	// NOTE refreshMainDevicegroupsMenu: calls refreshViewMenu:

    // Toolbar

    squintItem.onImageName = @"black_compile";
    squintItem.offImageName = @"black_compile_grey";
	squintItem.toolTip = @"Compile libraries and files into agent and device code for uploading";

	newProjectItem.onImageName = @"plus";
    newProjectItem.offImageName = @"plus_grey";
	newProjectItem.toolTip = @"Create a new Squinter project";

	infoItem.onImageName = @"info";
    infoItem.offImageName = @"info_grey";
	infoItem.toolTip = @"Display detailed project information";

	openAllItem.onImageName = @"open";
    openAllItem.offImageName = @"open_grey";
	openAllItem.toolTip = @"View the device group's code and library files in your external editor";

	viewDeviceCode.onImageName = @"open";
    viewDeviceCode.offImageName = @"open_grey";
	viewDeviceCode.toolTip = @"Display the device group's compiled device code";

	viewAgentCode.onImageName = @"open";
    viewAgentCode.offImageName = @"open_grey";
	viewAgentCode.toolTip = @"Display the device group's compiled agent code";

	uploadCodeItem.onImageName = @"upload2";
    uploadCodeItem.offImageName = @"upload2_grey";
	uploadCodeItem.toolTip = @"Upload the device group's compiled code to the impCloud";

	uploadCodeExtraItem.onImageName = @"uploadplus";
	uploadCodeExtraItem.offImageName = @"uploadplus_grey";
	uploadCodeExtraItem.toolTip = @"Upload the device group's compiled code and commit information to the impCloud";

	restartDevicesItem.onImageName = @"restart";
    restartDevicesItem.offImageName = @"restart_grey";
	restartDevicesItem.toolTip = @"Force all devices running the device group's code to reboot";

	clearItem.onImageName = @"clear";
    clearItem.offImageName = @"clear_grey";
	clearItem.toolTip = @"Clear the log window";

	copyAgentItem.onImageName = @"copy";
    copyAgentItem.offImageName = @"copy_grey";
	copyAgentItem.toolTip = @"Copy the device group's compiled agent code to the clipboard";

	copyDeviceItem.onImageName = @"copy";
    copyDeviceItem.offImageName = @"copy_grey";
	copyDeviceItem.toolTip = @"Copy the device group's compiled device code to the clipboard";

	printItem.onImageName = @"print";
    printItem.offImageName = @"print_grey";
	printItem.toolTip = @"Print the contents of the log window";

	refreshModelsItem.onImageName = @"refresh";
	refreshModelsItem.offImageName = @"refresh_grey";
	refreshModelsItem.toolTip = @"Refresh the list of devices from the impCloud";

	newDevicegroupItem.onImageName = @"plus";
	newDevicegroupItem.offImageName = @"plus_grey";
	newDevicegroupItem.toolTip = @"Create a new device group for your selected project";

	devicegroupInfoItem.onImageName = @"info";
	devicegroupInfoItem.offImageName = @"info_grey";
	devicegroupInfoItem.toolTip = @"Display detailed device group information";

	//streamLogsItem.onImageName = @"flag";
    //streamLogsItem.offImageName = @"streamon";
	//streamLogsItem.onImageNameGrey = @"flag_grey";
	//streamLogsItem.offImageNameGrey = @"streamon_grey";
    streamLogsItem.toolTip = @"Enable or disable live log streaming for the current device";
	streamLogsItem.state = kStreamToolbarItemStateOff;

	loginAndOutItem.openImageName = @"logout";
	loginAndOutItem.lockedImageName = @"login";
	loginAndOutItem.openImageNameGrey = @"logout_grey";
	loginAndOutItem.lockedImageNameGrey = @"login_grey";
	loginAndOutItem.toolTip = @"Login or logout of your Electric Imp account";
	loginAndOutItem.isLocked = YES;

	listCommitsItem.onImageName = @"commits";
	listCommitsItem.offImageName = @"commits_grey";
	listCommitsItem.toolTip = @"List the commits made to the current device group";

	downloadProductItem.onImageName = @"download";
	downloadProductItem.offImageName = @"download_grey";
	downloadProductItem.toolTip = @"Download the selected product as a project";

	projectsPopUp.toolTip = @"Select an open project";
	devicesPopUp.toolTip = @"Select a development device";
	saveLight.toolTip = @"Indicates whether the project has changes to be saved (outline) or not (filled)";

	// Other UI Items
    
    connectionIndicator.hidden = YES;
	
	[saveLight hide];
    [saveLight needSave:NO];
	[_window setDocumentEdited:NO];

	// Set the log NSTextView only to check for embedded URLs

	logTextView.enabledTextCheckingTypes = NSTextCheckingTypeLink;

    // Set initial working directory to user's Documents folder - this may be changed when we read in the defaults

    NSURL *dirURL = [nsfm URLForDirectory:NSDocumentDirectory
								 inDomain:NSUserDomainMask
						appropriateForURL:nil
								   create:NO
									error:nil];

    workingDirectory = [dirURL path];

    // Set up Key and Value arrays as template for Defaults

    NSArray *keyArray = [NSArray arrayWithObjects:@"com.bps.squinter.workingdirectory",
						 @"com.bps.squinter.windowsize",
						 @"com.bps.squinter.preservews",
						 @"com.bps.squinter.autocompile",
						 @"com.bps.squinter.ak.notional.tally",
						 @"com.bps.Squinter.ak.notional.telly",
						 @"com.bps.squinter.autoload",
						 @"com.bps.squinter.toolbarstatus",
						 @"com.bps.squinter.toolbarsize",
						 @"com.bps.squinter.toolbarmode",
						 @"com.bps.squinter.fontNameIndex",
						 @"com.bps.squinter.fontSizeIndex",
						 @"com.bps.squinter.text.red",
						 @"com.bps.squinter.text.blue",
						 @"com.bps.squinter.text.green",
						 @"com.bps.squinter.back.red",
						 @"com.bps.squinter.back.blue",
						 @"com.bps.squinter.back.green",
						 @"com.bps.squinter.autoselectdevice",
						 @"com.bps.squinter.autocheckupdates",
						 @"com.bps.squinter.showboldtext",
						 @"com.bps.squinter.useazure",
						 @"com.bps.squinter.displaypath",
						 @"com.bps.squinter.autoloadlists",
						 @"com.bps.squinter.autoloaddevlists",
						 @"com.bps.squinter.recentFiles",
						 @"com.bps.squinter.recentFilesCount",
						 @"com.bps.squinter.logListCount",nil];

    NSArray *objectArray = [NSArray arrayWithObjects:workingDirectory,
							[NSString stringWithString:NSStringFromRect(_window.frame)],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithBool:NO],
							@"xxxxxxxxxxxxxxxxx",
							@"xxxxxxxxxxxxxxxxx",
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithInteger:NSToolbarSizeModeRegular],
							[NSNumber numberWithInteger:NSToolbarDisplayModeIconAndLabel],
							[NSNumber numberWithInteger:1],
							[NSNumber numberWithInteger:12],
							[NSNumber numberWithFloat:0.0],
							[NSNumber numberWithFloat:0.0],
							[NSNumber numberWithFloat:0.0],
							[NSNumber numberWithFloat:1.0],
							[NSNumber numberWithFloat:1.0],
							[NSNumber numberWithFloat:1.0],
							[NSNumber numberWithBool:YES],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithInteger:1],
							[NSNumber numberWithBool:NO],
							[NSNumber numberWithBool:NO],
							[[NSArray alloc] init],
							[NSNumber numberWithInteger:5],
							[NSNumber numberWithInteger:200],nil];

    // Drop the arrays into the Defauts

    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
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

	// Set the selection colour to mirror the fore-back setup

	[logTextView setSelectedTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
											textColour, NSBackgroundColorAttributeName,
											backColour, NSForegroundColorAttributeName,
											nil]];

	// Set the recent files menu

	recentFiles = [NSMutableArray arrayWithArray:[defaults objectForKey:@"com.bps.squinter.recentFiles"]];

	[self refreshRecentFilesMenu];

	// Set up AppDelegate's observation of error, start and stop indication notifications

    [nsncdc	addObserver:self
		   selector:@selector(displayError:)
			   name:@"BuildAPIError"
			 object:ide];

	[nsncdc addObserver:self
		   selector:@selector(loggedIn:)
			   name:@"BuildAPILoggedIn"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(listProducts:)
			   name:@"BuildAPIGotProductsList"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(createProductStageTwo:)
			   name:@"BuildAPIProductCreated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(deleteProductStageThree:)
			   name:@"BuildAPIProductDeleted"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(updateProductStageTwo:)
			   name:@"BuildAPIProductUpdated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(createDevicegroupStageTwo:)
			   name:@"BuildAPIDeviceGroupCreated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(updateDevicegroupStageTwo:)
			   name:@"BuildAPIDeviceGroupUpdated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(deleteDevicegroupStageTwo:)
			   name:@"BuildAPIDeviceGroupDeleted"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(restarted:)
			   name:@"BuildAPIDeviceGroupRestarted"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(listDevices:)
			   name:@"BuildAPIGotDevicesList"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(reassigned:)
			   name:@"BuildAPIDeviceUnassigned"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(reassigned:)
			   name:@"BuildAPIDeviceAssigned"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(renameDeviceStageTwo:)
			   name:@"BuildAPIDeviceUpdated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(restarted:)
			   name:@"BuildAPIDeviceRestarted"
			 object:ide];

	[nsncdc addObserver:self
		   selector:@selector(deleteDeviceStageTwo:)
			   name:@"BuildAPIDeviceDeleted"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(uploadCodeStageTwo:)
			   name:@"BuildAPIDeploymentCreated"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(startProgress)
			   name:@"BuildAPIProgressStart"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(stopProgress)
			   name:@"BuildAPIProgressStop"
			 object:ide];

	[nsncdc addObserver:self
		   selector:@selector(showCodeErrors:)
			   name:@"BuildAPICodeErrors"
			 object:ide];

	[nsncdc	addObserver:self
		   selector:@selector(productToProjectStageTwo:)
			   name:@"BuildAPIGotDeviceGroupsList"
			 object:ide];

	[nsncdc	addObserver:self
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

	[nsncdc	addObserver:self
		   selector:@selector(presentLogEntry:)
			   name:@"BuildAPILogEntryReceived"
			 object:nil];

	[nsncdc	addObserver:self
		   selector:@selector(listLogs:)
			   name:@"BuildAPIGotLogs"
			 object:ide];

	[nsncdc	addObserver:self
			   selector:@selector(listCommits:)
				   name:@"BuildAPIGotDeploymentsList"
				 object:ide];

	[nsncdc	addObserver:self
			   selector:@selector(updateCodeStageTwo:)
				   name:@"BuildAPIGotDevicegroup"
				 object:ide];


	// **************

	[nsncdc	addObserver:self
		   selector:@selector(endLogging:)
			   name:@"BuildAPILogStreamEnd"
			 object:ide];

	// Get macOS version

	sysVer = [[NSProcessInfo processInfo] operatingSystemVersion];
}



- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // If the user launched Squinter by double-clicking a squirrelproj file, this method will be called
    // *before* applicationDidFinishLoading, so we need to instantiate the project array here. If it is
    // nil (ie. applicationDidFinishLoading hasn't yet been called) we know to create it.

    if (projectArray == nil) projectArray = [[NSMutableArray alloc] init];

    // Turn the opened file’s path into an NSURL an add to the array that openFileHandler: expects

    NSArray *array = [NSArray arrayWithObjects:[NSURL fileURLWithPath:filename], nil];
	NSLog(@"Squinter loading %@", filename);
    [self openFileHandler:array :kActionOpenSquirrelProject];
	return YES;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // We check for an uninstantiated projectArray because we don't want to zap one already
    // created by application:openFile if that was called before applicationDidFinishLoading,
    // as it would have been if the user launched Squinter with a .squirrelproj file double-click

    if (projectArray == nil) projectArray = [[NSMutableArray alloc] init];

	// Instantiate an IDE-access object
	
	ide = [[BuildAPIAccess alloc] init];
	ide.maxListCount = [defaults stringForKey:@"com.bps.squinter.logListCount"].integerValue;
	ide.pageSize = 50;

	// Load in working directory, reading in the location from the defaults in case it has been changed by a previous launch

    workingDirectory = [defaults stringForKey:@"com.bps.squinter.workingdirectory"];

	// Set up parallel operation queue and limit it to serial operation

	extraOpQueue = [[NSOperationQueue alloc] init];
	extraOpQueue.maxConcurrentOperationCount = 1;

	// Update UI

	[self setToolbar];
	[_window setTitle:@"Squinter Beta"];
    [_window makeKeyAndOrderFront:nil];

	// Check for updates if that is requested
	
	if ([defaults boolForKey:@"com.bps.squinter.autocheckupdates"]) [sparkler checkForUpdatesInBackground];

	// Login

	if ([defaults boolForKey:@"com.bps.squinter.autoload"])
	{
		// User wants to auto login on launch, ie. not display the login window
		// NOTE window will appear if there are no credentials stored

		[self autoLogin];
	}
	else
	{
		// Recommend logging in by showing the log in window
		// NOTE may remove this and leave users to select it from menu

		[self showLoginWindow];
	}
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
		if (aProject.haschanged) ++unsavedProjectCount;
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
            [saveChangesSheetLabel setStringValue:@"1 Project has unsaved changes."];
        }
        else
        {
            [saveChangesSheetLabel setStringValue:[NSString stringWithFormat:@"%li Projects have unsaved changes.", (long)unsavedProjectCount]];
        }

		// Open the save sheet

        [_window beginSheet:saveChangesSheet completionHandler:nil];

		// Tell the system we'll shutdown shortly

        return NSTerminateLater;
    }
}



- (void)applicationWillTerminate:(NSNotification *)notification
{
	// Stop watching for file-changes

    [fileWatchQueue removeAllPaths];

	// Kill any connections to the API

	[ide killAllConnections];

    // Record settings that are not set by the Prefs dialog

    [defaults setValue:workingDirectory forKey:@"com.bps.squinter.workingdirectory"];
    [defaults setValue:NSStringFromRect(_window.frame) forKey:@"com.bps.squinter.windowsize"];
	[defaults setObject:[NSArray arrayWithArray:recentFiles] forKey:@"com.bps.squinter.recentFiles"];

    // Stop watching for notifications

    [nsncdc removeObserver:self];
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

	// Clear the dock menu's list items because we may have new items to add

	[dockMenu removeAllItems];

	// Add the list of recently opened files
	
	if (recentFiles.count > 0)
	{
		for (NSDictionary *file in recentFiles)
		{
			item = [[NSMenuItem alloc] initWithTitle:[file objectForKey:@"name"] action:@selector(openRecent:) keyEquivalent:@""];
			item.representedObject = file;
			item.target = self;
			//item.image = [NSImage imageNamed:@"docpic"];
			//item.onStateImage = item.image;
			//item.offStateImage = item.image;
			//item.mixedStateImage = item.image;
			item.tag = -1;
			[dockMenu addItem:item];
		}

		item = [NSMenuItem separatorItem];
		[dockMenu addItem:item];
	}

	// Add the fixed items: directory and web links

	item = [[NSMenuItem alloc] initWithTitle:@"Open Working Directory" action:@selector(dockMenuAction:) keyEquivalent:@""];
	[item setImage:[NSImage imageNamed:@"folder"]];
	item.target = self;
	item.tag = 99;
	[dockMenu addItem:item];

	item = [NSMenuItem separatorItem];
	[dockMenu addItem:item];

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
				[nswsw openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/version2/"]];
				break;

			case 2:
				[nswsw openURL:[NSURL URLWithString:@"https://electricimp.com/docs/"]];
				break;

			case 3:
				[nswsw openURL:[NSURL URLWithString:@"https://forums.electricimp.com/"]];
				break;

			default:
				[nswsw openFile:workingDirectory withApplication:nil andDeactivate:YES];
		}
	}
}



#pragma mark - Login Methods


- (IBAction)loginOrOut:(id)sender
{
	// We come here when the log in/out menu option is selected

	if (!ide.isLoggedIn)
	{
		// We are not logged in, so show the log in sheet, but only if we're
		// not already trying to log in

		if (!loginFlag) [self showLoginWindow];
	}
	else
	{
		// We are logged in - or trying to log in - so log the user out

		loginMenuItem.title = @"Log in to your account";

		[ide logout];
		[self setToolbar];
		[self writeStringToLog:@"You are now logged out of the impCloud." :YES];
	}
}



- (void)autoLogin
{
	[self setLoginCreds];

	if (usernameTextField.stringValue.length == 0 || passwordTextField.stringValue.length == 0)
	{
		// We don't have a password or a username, so we'll need to show the login window

		saveDetailsCheckbox.state = NSOnState;

		[_window beginSheet:loginSheet completionHandler:nil];
	}
	else
	{
		// We've got the credentials so bypass the sheet and log straight in

		saveDetailsCheckbox.state = NSOffState;

		[self writeStringToLog:@"Automatically logging you into the impCloud. This can be disabled in Preferences." :YES];
		[self login:nil];
	}
}



- (void)showLoginWindow
{
	// Present the login sheet

	saveDetailsCheckbox.state = NSOnState;

	[self setLoginCreds];
	[_window beginSheet:loginSheet completionHandler:nil];
}



- (void)setLoginCreds
{
	// Pull the login credentials from the keychain

	PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
	NSString *un = [pc stringForKey:@"com.bps.Squinter.ak.notional.tully"];
	NSString *pw = [pc stringForKey:@"com.bps.Squinter.ak.notional.tilly"];

	// Set the login window fields with the data

	usernameTextField.stringValue = (un == nil) ? @"" : [ide decodeBase64String:un];
	passwordTextField.stringValue = (pw == nil) ? @"" : [ide decodeBase64String:pw];
}



- (IBAction)cancelLogin:(id)sender
{
	// Just hide the login sheet

	[_window endSheet:loginSheet];
}



- (IBAction)login:(id)sender
{
	// If we pass in nil to 'sender' we have called this method manually
	// so we don't need to remove the sheet from the window

	if (sender != nil) [_window endSheet:loginSheet];

	// Register that we're attempting a login

	loginFlag = YES;

	// Attempt to login with the current credentials

	[ide login:usernameTextField.stringValue
			  :passwordTextField.stringValue
			  :NO];

	// Pick up the action in 'loggedIn:' or 'displayError:', depending on success or failure
}



- (void)loginAlert:(NSString *)extra
{
	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = @"You are not logged in to the impCloud";
	alert.messageText = [NSString stringWithFormat:@"You must be logged in to %@. Do you wish to log in now?", extra];
	[alert addButtonWithTitle:@"Yes"];
	[alert addButtonWithTitle:@"No"];

	[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
		if (returnCode == 1000) [self autoLogin];
	}];
}



- (IBAction)setSecureEntry:(id)sender
{
	if (showPassCheckbox.state == NSOnState)
	{
		NSString *text = passwordTextField.stringValue;
		passwordTextField.cell = [[NSTextFieldCell alloc] init];
		passwordTextField.stringValue = text;
	}
	else
	{
		NSString *text = passwordTextField.stringValue;
		passwordTextField.cell = [[NSSecureTextFieldCell alloc] initTextCell:text];
		passwordTextField.stringValue = text;
	}

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
    if (selectedProduct != nil)
	{
        // If we have a selected product, we can potentially associate it with the new project...

        newProjectAssociateCheckbox.enabled = YES;
		newProjectAssociateCheckbox.title = [NSString stringWithFormat:@"Associate Project with Product \"%@\"", [self getValueFrom:selectedProduct withKey:@"name"]];
	}
	else
	{
		// ...otherwise we can't

		newProjectAssociateCheckbox.enabled = NO;
		newProjectAssociateCheckbox.title = @"Associate Project with currently selected Product";
	}

	// Set the associate product default state to unchecked

	newProjectAssociateCheckbox.state = NSOffState;

	if (ide.isLoggedIn)
	{
		// If we are logged in, we can offer to create a product, which we'll set as the default...

		newProjectNewProductCheckbox.enabled = YES;
		newProjectNewProductCheckbox.state = NSOnState;
		//if (productsArray == nil || productsArray.count == 0) [self getProductsFromServer:nil];
	}
	else
	{
		// ...otherwise we can't

		newProjectNewProductCheckbox.enabled = NO;
		newProjectNewProductCheckbox.state = NSOffState;
	}

	// Clear the fields

	newProjectNameTextField.stringValue = @"";
	newProjectDescTextField.stringValue = @"";

    [_window beginSheet:newProjectSheet completionHandler:nil];
}



- (IBAction)newProjectSheetCancel:(id)sender
{
    [_window endSheet:newProjectSheet];
}



- (IBAction)newProjectSheetCreate:(id)sender
{
	// The handler for creating a new project, which may or may not (user choice)
	// involve the creation of a product. It does NOT involve the creation of any
	// device groups - the user has to add these later, as required

	NSString *pName = newProjectNameTextField.stringValue;
	NSString *pDesc = newProjectDescTextField.stringValue;
	BOOL makeNewProduct = newProjectNewProductCheckbox.state;
	BOOL associateProduct = newProjectAssociateCheckbox.state;
    
    [_window endSheet:newProjectSheet];

	if (pName.length > 80)
	{
		// Project name is too long — go back and ask for another
		// NOTE the textfield checking should prevent this in any case

		newProjectLabel.stringValue = @"That name is too long. Please choose another name, or cancel.";
		[_window beginSheet:newProjectSheet completionHandler:nil];
		return;
	}

	if (pName.length == 0)
	{
		// Project name is too short - go back and ask for another

		newProjectLabel.stringValue = @"You must enter a name. Please choose another name, or cancel.";
		[NSThread sleepForTimeInterval:1.0];
		[_window beginSheet:newProjectSheet completionHandler:nil];
		return;
	}

	if (pDesc.length > 255)
	{
		// Project description is too long — go back and ask for another
		// NOTE the textfield checking should prevent this in any case

		newProjectLabel.stringValue = @"That description is too long. Please enter another one, or cancel.";
		[_window beginSheet:newProjectSheet completionHandler:nil];
		return;
	}

	if (projectArray.count > 0)
    {
        // We only need to check the new name against open ones when there ARE open projects
        
        for (Project *project in projectArray)
        {
			if ([project.name compare:pName] == NSOrderedSame)
            {
                // The name already exists, so re-run the New Project sheet with a suitable message
                
                newProjectLabel.stringValue = @"A project with that name is already open. Please choose another name, or cancel.";
				[_window beginSheet:newProjectSheet completionHandler:nil];
				return;
            }
        }
    }

	if ((makeNewProduct || !associateProduct) && productsArray != nil && productsArray.count > 0)
	{
		// User wants to make a new product or doesn't want to associate with an exitsting one
		// so compare the new product's name against existing product names

        for (NSDictionary *product in productsArray)
		{
			NSString *aName = [self getValueFrom:product withKey:@"name"];

			if ([aName compare:pName] == NSOrderedSame)
			{
				[newProjectLabel setStringValue:@"A product with that name already exists. Please choose another project name, or cancel."];
				[_window beginSheet:newProjectSheet completionHandler:nil];
				return;
			}
		}
	}

	// Make the new project

	currentProject = [[Project alloc] init];
	currentProject.name = pName;
	currentProject.description = pDesc;
	currentProject.path = workingDirectory;
	currentProject.filename = [pName stringByAppendingString:@".squirrelproj"];
	currentProject.haschanged = YES;
	currentProject.devicegroupIndex = -1;
	currentDevicegroup = nil;

	[projectArray addObject:currentProject];

	if (makeNewProduct)
	{
		// User wants to create a new product for this project. We will pick up saving
		// this project AFTER the product has been created (to make sure it is created)

		[self writeStringToLog:@"Creating Project's Product on the server..." :YES];

		NSDictionary *dict = @{ @"action" : @"newproject",
								@"project" : currentProject };

		[ide createProduct:pName :pDesc :dict];
		return;

		// We need to handle the result of this at 'createProductStageTwo:'
	}

	// Finally, check whether we're connecting this project to a product (new or selected)

	if (associateProduct)
	{
		// User wants to associate the new project with the selected product, so set 'pid'
		// NOTE user can't select this if there is no 'selectedProduct'

		currentProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
	}

	// Add the new project to the project menu. We've already checked for a name clash,
	// so we needn't care about the return value

	[self addProjectMenuItem:pName :currentProject];

	// Enable project-related UI items

	[self refreshOpenProjectsMenu];
	[self refreshProjectsMenu];
	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];
	[self refreshDeviceMenu];
	[self setToolbar];

	// Mark the status light as empty, ie. in need of saving

	[saveLight show];
	[saveLight needSave:YES];
	[_window setDocumentEdited:YES];

	// Save the new project - this gives the user the chance to re-locate it

	savingProject = currentProject;
	[self saveProjectAs:nil];
}



- (IBAction)newProjectCheckboxStateHandler:(id)sender
{
	// This method responds to attempts to select a new project dialog checkbox
	// to make sure contradictory responses are not permitted

	// TO DO - WARN USER

	if (sender == newProjectAssociateCheckbox)
	{
		// If user is checking the associate product box, we can't have the new product box checked

		if (newProjectAssociateCheckbox.state == NSOnState) newProjectNewProductCheckbox.state = NSOffState;
	}

	if (sender == newProjectNewProductCheckbox)
	{
		// If user is checking the new product box, we can't have the associate product box checked

		if (newProjectNewProductCheckbox.state == NSOnState) newProjectAssociateCheckbox.state = NSOffState;
	}
}



#pragma mark - Existing Project Methods


- (IBAction)pickProject:(id)sender
{
	// Selecting a project from the 'openProjectsMenu' calls 'chooseProject:' directly because we know
	// which project was selected. This is called by any click on 'projectsPopup'

	[self chooseProject:projectsPopUp];
}



- (void)chooseProject:(id)sender
{
    // Select one of the open projects from the Projects sub-menu or the Project menu
    
	NSMenuItem *item;
	NSUInteger itemNumber = 0;

	// 'item' will become the open projects menu item that has been selected, either
	// directly (via 'sender') or by the projects popup's tag value

	if (sender != projectsPopUp)
	{
		// The user has selected a projects from the 'openProjectsMenu' submenu

		item = (NSMenuItem *)sender;
	}
	else
	{
		// 'sender' is 'projectsPopUp',

		NSInteger tag = projectsPopUp.selectedItem.tag;
		item = [openProjectsMenu itemAtIndex:tag];
	}

	Project *chosenProject = nil;

	if (item.representedObject != nil)
	{
		chosenProject = item.representedObject;
		itemNumber = [openProjectsMenu indexOfItem:item];
	}
	else
	{
		// Just in case we didn't set the represented object for some reason

		for (NSUInteger i = 0 ; i < projectArray.count ; ++i)
    	{
        	chosenProject = [projectArray objectAtIndex:i];

			if ([chosenProject.name compare:item.title] == NSOrderedSame)
			{
				itemNumber = i;
				break;
			}
		}
	}

	// Have we chosen the already selected project? Bail

	if (currentProject == chosenProject) return;

	// Switch in the newly chosen project

	currentProject = chosenProject;
	currentDevicegroup = (currentProject.devicegroupIndex != -1) ? [currentProject.devicegroups objectAtIndex:currentProject.devicegroupIndex] : nil;

	// If we have

	if (currentDevicegroup != nil)
	{
		[self selectDevice];
	}
	else
	{
		// If we don't have a selected device group but we do have device groups in
		// this project, select the first one on the list

		if (currentProject.devicegroups.count > 0)
		{
			currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
			currentProject.devicegroupIndex = 0;

			[self selectDevice];
		}
	}

	// Update the save? indicator

	[saveLight needSave:currentProject.haschanged];
	[_window setDocumentEdited:currentProject.haschanged];

	// Is the project associated with a product? If so, select it

	if (currentProject.pid.length > 0)
	{
		if (productsArray.count > 0)
		{
			for (NSMenuItem *item in productsMenu.itemArray)
			{
				// TODO CHECK Do we need to cast item.representedObject

				NSDictionary *product = (NSDictionary *)item.representedObject;
				NSString *pid = [self getValueFrom:product withKey:@"id"];
				NSString *anid = currentProject.pid;
				item.state = NSOffState;

				if ([pid compare:anid] == NSOrderedSame)
				{
					// Call 'chooseProduct:' solely to set the UI

					[self chooseProduct:item];
				}
			}
		}
	}

	/*
    // We've made the selected project the current one, so adjust the project menu's tick marks
    
    for (NSUInteger i = 0; i < openProjectsMenu.numberOfItems ; ++i)
    {
        // Turn off all the menu items except the current one
        
        item = [openProjectsMenu itemAtIndex:i];
		item.state = (i == itemNumber) ? NSOnState : NSOffState;
    }

	// Update the Project list popup

	[projectsPopUp selectItemAtIndex:[projectsPopUp indexOfItemWithTag:itemNumber]];
	 */

	// Update the Menus and the Toolbar (left until now in case models etc are selected)

	[self refreshProjectsMenu];
	[self refreshOpenProjectsMenu];
	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];
    [self setToolbar];
}



- (IBAction)openProject:(id)sender
{
	// Locate and open an existing project file

	// Set up an open panel to request a .squirrelproj file
    
    openDialog = [NSOpenPanel openPanel];
    openDialog.message = @"Select a Squirrel Project file...";
    openDialog.allowedFileTypes = [NSArray arrayWithObjects:@"squirrelproj", nil];
    openDialog.allowsMultipleSelection = YES;
    
    // Set the panel's accessory view checkbox to OFF
    
    accessoryViewNewProjectCheckbox.state = NSOffState;
    
    // Hide the accessory view - though it's not shown, openFileHandler: checks its state
    
    openDialog.accessoryView = nil;

    [self presentOpenFilePanel:kActionOpenSquirrelProject];
}




- (IBAction)closeProject:(id)sender
{
	if (projectArray.count == 0) return;

	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

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

	if (currentProject.haschanged)
	{
		// The project has unsaved changes, so warn the user before closing

		[saveChangesSheetLabel setStringValue:@"Project has unsaved changes."];
		[_window beginSheet:saveChangesSheet completionHandler:nil];
		closeProjectFlag = YES;
		return;
	}

	// Stop watching all of the current project's files: each device group's models,
	// and then each model's various local libraries and files

	NSString *pPath = currentProject.path;

	if (currentProject.devicegroups.count > 0)
	{
		for (Devicegroup *devicegroup in currentProject.devicegroups)
		{
			if (devicegroup.models.count > 0)
			{
				for (Model *model in devicegroup.models)
				{
					NSString *path = [model.path stringByAppendingFormat:@"/%@", model.filename];

					if (path.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:pPath :path]];

					if (model.libraries.count > 0)
					{
						for (File *file in model.libraries)
						{
							NSString *fpath = [file.path stringByAppendingFormat:@"/%@", file.filename];

							if (fpath.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:pPath :fpath]];
						}
					}

					if (model.files.count > 0)
					{
						for (File *file in model.files)
						{
							NSString *fpath = [file.path stringByAppendingFormat:@"/%@", file.filename];

							if (fpath.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:pPath :fpath]];
						}
					}
				}
			}
		}
	}

	NSString *closedName = currentProject.name;

	if (projectArray.count == 1)
	{
		// If there is only one open project, which we're about to close,
		// we can clear everything project-related in the UI

		[self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" closed. There are no open Projects.", closedName] :YES];
		[projectArray removeAllObjects];
		[fileWatchQueue kill];
		fileWatchQueue = nil;
		currentProject = nil;

		// Fade the status light

		[saveLight hide];
		[saveLight needSave:NO];
		[_window setDocumentEdited:NO];
	}
	else
	{
		// There's at least one other project open, so just remove the current one

		[projectArray removeObjectAtIndex:[projectArray indexOfObject:currentProject]];

		// Set the first project to the current one, and update the UI

		currentProject = [projectArray objectAtIndex:0];

		currentDevicegroup = nil;
		currentProject.devicegroupIndex = -1;

		if (currentProject.devicegroups.count > 0)
		{
			currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
			currentProject.devicegroupIndex = 0;
		}

		NSString *confirmMessage = [NSString stringWithFormat:@"Project \"%@\" closed.", closedName];

		if (sender != closeAllMenuItem)
		{
			confirmMessage = [confirmMessage stringByAppendingFormat:@" %@ is now the current Project.", currentProject.name];

			if (projectArray.count == 1)
			{
				confirmMessage = [confirmMessage stringByAppendingString:@" There are no other open Projects."];
			}
			else
			{
				confirmMessage = [confirmMessage stringByAppendingFormat:@" There are %li open Projects.", projectArray.count];
			}

			[self writeStringToLog:confirmMessage :YES];
		}

		[saveLight needSave:currentProject.haschanged];
		[_window setDocumentEdited:currentProject.haschanged];
	}

	// Update the UI whether we've closed one of x projects, or the last one

	[self refreshProjectsMenu];
	[self refreshOpenProjectsMenu];
	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];
	[self setToolbar];
}



- (IBAction)renameCurrentProject:(id)sender
{
	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	[self renameProject:sender];
}



- (void)renameProject:(id)sender
{
	// Present the sheet, adapting it according to sender ('rename Peroject' or 'rename Device Group')

	renameProjectFlag = (sender == renameProjectMenuItem) ? YES : NO;

	NSString *desc = (renameProjectFlag) ? currentProject.description : currentDevicegroup.description;
	NSString *name = (renameProjectFlag) ? currentProject.name : currentDevicegroup.name;

	renameProjectLabel.stringValue = (renameProjectFlag) ? @"Enter a new Project name or update the description:" : @"Enter a new Device Group name or update the description:";

	renameProjectLinkCheckbox.title = (renameProjectFlag) ? @"Also update the Product linked to this Project" : @"Also update the Device Group in the impCloud";

	if (renameProjectFlag)
	{
		renameProjectLinkCheckbox.enabled = (currentProject.pid != nil && currentProject.pid.length > 0 && ide.isLoggedIn) ? YES : NO;
		renameProjectHintField.stringValue = @"If this checkbox is greyed out, the project isn’t associated with a product in the impCloud, or you are not logged in to your account.";
	}
	else
	{
		renameProjectLinkCheckbox.enabled = (currentDevicegroup.did != nil && currentDevicegroup.did.length > 0 && ide.isLoggedIn) ? YES : NO;
		renameProjectHintField.stringValue = @"If this checkbox is greyed out, the device group isn’t associated with a device group in the impCloud, or you are not logged in to your account.";
	}

	renameProjectLinkCheckbox.state = (renameProjectLinkCheckbox.enabled) ? NSOnState : NSOffState;

	if (desc.length > 0)
	{
		renameProjectDescTextField.stringValue = desc;
		renameProjectDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)currentProject.description.length];
	}
	else
	{
		renameProjectDescTextField.stringValue = @"";
		renameProjectDescCountField.stringValue = @"0/255";
	}

	renameProjectTextField.stringValue = name;
	renameProjectCountField.stringValue = [NSString stringWithFormat:@"%li/80", (long)name.length];

	[_window beginSheet:renameProjectSheet completionHandler:nil];
}



- (IBAction)closeRenameProjectSheet:(id)sender
{
	[_window endSheet:renameProjectSheet];
}



- (IBAction)saveRenameProjectSheet:(id)sender
{
	NSString *newName = renameProjectTextField.stringValue;
	NSString *newDesc = renameProjectDescTextField.stringValue;

	[_window endSheet:renameProjectSheet];

	if (newName.length == 0)
	{
		renameProjectLabel.stringValue = @"You must enter a name. Please choose another name, or cancel.";
		[_window beginSheet:renameProjectSheet completionHandler:nil];
		return;
	}

	if (newName.length > 80)
	{
		renameProjectLabel.stringValue = @"That name is too long. Please choose another name, or cancel.";
		[_window beginSheet:renameProjectSheet completionHandler:nil];
		return;
	}

	if (newDesc.length > 255)
	{
		renameProjectLabel.stringValue = @"That description is too long. Please choose another name, or cancel.";
		[_window beginSheet:renameProjectSheet completionHandler:nil];
		return;
	}

	if (renameProjectFlag)
	{
		// Check name and if necessary go back and ask again for a new one

		if ([self checkProjectNames:currentProject :newName])
		{
			renameProjectLabel.stringValue = @"That name is in use. Please choose another name, or cancel.";
			[_window beginSheet:renameProjectSheet completionHandler:nil];
			return;
		}

		if (renameProjectLinkCheckbox.state == NSOnState)
		{
			// Update the source product before doing anything else, so that if there is an
			// error, we don't affect the local version either

			BOOL changed = NO;

			NSMutableArray *keys = [[NSMutableArray alloc] init];
			NSMutableArray *values = [[NSMutableArray alloc] init];

			if ([currentProject.name compare:newName] != NSOrderedSame)
			{
				[keys addObject:@"name"];
				[values addObject:newName];
				changed = YES;
			}

			if ([currentProject.description compare:newDesc] != NSOrderedSame)
			{
				[keys addObject:@"description"];
				[values addObject:newDesc];
				changed = YES;
			}

			if (changed)
			{
				NSDictionary *dict = @{ @"action" : @"projectchanged",
										@"project" : currentProject };

				[ide updateProduct:currentProject.pid :(NSArray *)keys :(NSArray *)values :dict];

				// Pick up the action at 'updateProductStageTwo:'
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"No changes made to Project \"%@\".", currentProject.name] :YES];
			}
		}
		else
		{
			// Do all the work here because we're not making an async operation

			if ([currentProject.name compare:newName] != NSOrderedSame)
			{
				currentProject.name = newName;
				currentProject.haschanged = YES;

				// Update the UI only if the name has changed

				[self refreshOpenProjectsMenu];
				[self refreshProjectsMenu];
				[self refreshDevicegroupMenu];
				[self refreshMainDevicegroupsMenu];
			}

			if ([currentProject.description compare:newDesc] != NSOrderedSame)
			{
				currentProject.description = newDesc;
				currentProject.haschanged = YES;
				[self refreshOpenProjectsMenu];
			}

			if (!currentProject.haschanged) [self writeStringToLog:[NSString stringWithFormat:@"No changes made to Project \"%@\".", currentProject.name] :YES];

			// Update the save indicator if anything has changed

			[saveLight needSave:currentProject.haschanged];
			[_window setDocumentEdited:currentProject.haschanged];
		}
	}
	else
	{
		// Check name and if necessary go back and ask again for a new one

		if ([self checkDevicegroupNames:currentDevicegroup :newName])
		{
			renameProjectLabel.stringValue = @"That name is in use. Please choose another name, or cancel.";
			[_window beginSheet:renameProjectSheet completionHandler:nil];
			return;
		}

		if (renameProjectLinkCheckbox.state == NSOnState)
		{
			// Update the source device group before doing anything else, so that if there is an
			// error, we don't affect the local version either

			BOOL changed = NO;

			NSMutableArray *keys = [[NSMutableArray alloc] init];
			NSMutableArray *values = [[NSMutableArray alloc] init];

			if ([currentDevicegroup.name compare:newName] != NSOrderedSame)
			{
				[keys addObject:@"name"];
				[values addObject:newName];
				changed = YES;
			}

			if ([currentDevicegroup.description compare:newDesc] != NSOrderedSame)
			{
				[keys addObject:@"description"];
				[values addObject:newDesc];
				changed = YES;
			}

			if (changed)
			{
				NSDictionary *dict = @{ @"action" : @"devicegroupchanged",
										@"devicegroup" : currentDevicegroup };

				[ide updateDevicegroup:currentDevicegroup.did :(NSArray *)keys :(NSArray *)values :dict];

				// Pick up the action at 'updateDevicegroupStageTwo:'
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"No changes made to Device Group \"%@\".", currentDevicegroup.name] :YES];
			}
		}
		else
		{
			// The device group lacks a device group ID, so it has no equivalent on the
			// server, so we can process the changes immediately

			if ([currentDevicegroup.name compare:newName] != NSOrderedSame)
			{
				currentDevicegroup.name = newName;
				currentProject.haschanged = YES;

				// Update the UI; in the above code the UI will be updated
				// in response to notification from the server

				[self refreshOpenProjectsMenu];
				[self refreshDevicegroupMenu];
				[self refreshMainDevicegroupsMenu];
			}

			if ([currentDevicegroup.description compare:newDesc] != NSOrderedSame)
			{
				currentDevicegroup.description = newDesc;
				currentProject.haschanged = YES;
				[self refreshOpenProjectsMenu];
			}

			if (!currentProject.haschanged) [self writeStringToLog:[NSString stringWithFormat:@"No changes made to Device Group \"%@\".", currentDevicegroup.name] :YES];

			// Update the save indicator if anything has changed

			[saveLight needSave:currentProject.haschanged];
			[_window setDocumentEdited:currentProject.haschanged];
		}
	}
}



- (IBAction)doSync:(id)sender
{
	// This is an start point for the UI to trigger a project sync
	// NOTE this may yet be merged with 'syncProject:'

	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	[self uploadProject:currentProject];
}



- (void)uploadProject:(Project *)project
{
	// We can't sync if we're not logged in

	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"upload this Project"];
		return;
	}

	if (project.pid == nil || project.pid.length == 0)
	{
		// Project has no PID so just create a new product

		[self writeStringToLog:[NSString stringWithFormat:@"Uploading Project \"%@\" to impCloud: making a Product...", project.name] :YES];

		// Start by creating the product

		NSDictionary *dict = @{ @"action" : @"uploadproject",
								@"project" : project };

		[ide createProduct:project.name :project.description :dict];

		// Pick up in 'createProductStageTwo:'

		return;
	}
	else
	{
		// Project has a PID, but has it been orphaned?

		if (productsArray == nil)
		{
			// We don't have the products list populated yet, so we need to get it first

			[self writeStringToLog:@"Retrieving a list of your Products" :YES];

			NSDictionary *dict = @{ @"action" : @"uploadproject",
									@"project" : currentProject };

			[ide getProducts:dict];

			// Pick up the action at 'listProducts:'
		}
		else if (productsArray.count > 0)
		{
			BOOL deadpid = YES;

			for (NSDictionary *product in productsArray)
			{
				NSString *pid = [product objectForKey:@"id"];

				if ([currentProject.pid compare:pid] == NSOrderedSame)
				{
					[self writeErrorToLog:@"[ERROR] This Project already exists as a Product in the impCloud." :YES];
					deadpid = NO;
					break;
				}
			}

			if (deadpid)
			{
				// We have an orphan project - its product has been deleted and its PID is dead
				// so clear the pid and proceed with the upload.

				[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Project \"%@\" is linked to a deleted Product. Deleting the link.", project.name] :YES];

				project.pid = @"";

				NSDictionary *dict = @{ @"action" : @"uploadproject",
										@"project" : project };

				[ide createProduct:project.name :project.description :dict];

				// Pick up in 'createProductStageTwo:'

				return;
			}

			// Project PID is still valid, so do a sync

			// [self syncProject:project];
		}
		else
		{
			// We've got a list of products and there aren't any, so just upload

			NSDictionary *dict = @{ @"action" : @"uploadproject",
									@"project" : project };

			[ide createProduct:project.name :project.description :dict];

			// Pick up in 'createProductStageTwo:'
		}
	}
}



- (void)syncProject:(Project *)project
{
	// We can't sync if we're not logged in

	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"upload or sync this Project"];
		return;
	}

	if (project.pid != nil && project.pid.length > 0)
	{
		if (productsArray == nil)
		{
			// We need to get the list of products to match because we have no such list yet

			[self writeStringToLog:@"Retrieving a list of your Products" :YES];

			NSDictionary *dict = @{ @"action" : @"syncproject",
									@"project" : project };

			[ide getProducts:dict];

			// Pick up the action at 'listProducts:'

			return;
		}

		NSDictionary *syncProduct = nil;

		for (NSDictionary *product in productsArray)
		{
			NSString *pid = [self getValueFrom:product withKey:@"id"];

			if ([project.pid compare:pid] == NSOrderedSame)
			{
				syncProduct = product;
				break;
			}
		}

		if (syncProduct != nil)
		{
			NSString *updated = [self getValueFrom:syncProduct withKey:@"updated_at"];

			if (updated == nil) updated = [self getValueFrom:syncProduct withKey:@"created_at"];

			NSDate *pdDate = [self convertTimestring:updated];
			NSDate *prDate = [self convertTimestring:currentProject.updated];

			if ([prDate earlierDate:pdDate] == pdDate)
			{
				// Product is older than the project

				NSDictionary *dict = @{ @"action" : @"none",
										@"project" : project };

				//[ide updateProduct:project.pid :@"name" :project.name :dict];

				dict = @{ @"action" : @"syncproject",
						  @"project" : project };

				//[ide updateProduct:project.pid :@"description" :project.description :dict];

				// Pick up the action at 'updateProductStageTwo:'
			}
			else
			{
				// Project is older than the product

				project.name = [self getValueFrom:syncProduct withKey:@"name"];
				project.description = [self getValueFrom:syncProduct withKey:@"description"];

				// Now we need to compare device groups

				NSDictionary *dict = @{ @"action" : @"syncproject",
										@"project" : project };

				[ide getDevicegroupsWithFilter:@"product.id" :[self getValueFrom:syncProduct withKey:@"id"] :dict];

				// Pick up the action in 'listDevicegroups:'
			}
		}
		else
		{
			// WHOOPS
		}
	}
	else
	{
		// Just in case...

		[self uploadProject:project];
	}
}



- (IBAction)cancelSync:(id)sender
{
	[ide killAllConnections];
}



- (IBAction)openRecent:(id)sender
{
	// Open a project from the recent projects menu
	// The menu item title is the name of the file; its represented object is the file location

	NSMenuItem *item = (NSMenuItem *)sender;
	NSDictionary *data = item.representedObject;
	NSData *bookmark = [data valueForKey:@"bookmark"];
	NSString *filename = [data valueForKey:@"name"];

	// Check that the file exists at the recoreded location
	// We do this here (it will be checked in 'openSquirrelProject:' too) so that we can update the
	// recent files list and menu if the file has gone missing

	NSURL *url = [self urlForBookmark:bookmark];

	if (url == nil)
	{
		// The file is AWOL so warn the user and remove it from the list

		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" has been moved or deleted. Removing it from the recent files list", item.title] :YES];

		[recentFiles removeObject:data];
		[self refreshRecentFilesMenu];
	}
	else
	{
		if (stale)
		{
			// The project's bookmark is stale, ie. it has changed location.
			// 'url' contains the new location

			stale = NO;

			// Update recent files list and UI

			NSDictionary *newDict = @{ @"name" : filename,
									   @"path" : [url.path stringByDeletingLastPathComponent],
									   @"bookmark" : [self bookmarkForURL:url] };

			[recentFiles removeObject:data];
			[recentFiles insertObject:newDict atIndex:0];
			[self refreshRecentFilesMenu];
		}

		NSMutableArray *urls = [NSMutableArray arrayWithObject:url];
		[self openSquirrelProjects:urls];
	}
}



- (void)openRecentAll
{
	if (recentFiles.count > 0)
	{
		NSMutableArray *urls = [[NSMutableArray alloc] init];
		NSMutableArray *newRecentFiles = [[NSMutableArray alloc] init];

		for (NSDictionary *recent in recentFiles)
		{
			stale = NO;
			NSURL *url = [self urlForBookmark:[recent valueForKey:@"bookmark"]];

			if (stale)
			{
				if (url != nil)
				{
					[self writeStringToLog:[NSString stringWithFormat:@"Updating location of Project file \"%@\".", [recent valueForKey:@"name"]] :YES];

					NSDictionary *newRecent = @{ @"name" : [recent valueForKey:@"name"],
												 @"path" : [url.path stringByDeletingLastPathComponent],
												 @"bookmark" : [self bookmarkForURL:url] };

					[newRecentFiles addObject:newRecent];
				}
				else
				{
					[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] The file \"%@\" has been moved or deleted. Removing it from the recent files list", [recent valueForKey:@"name"]] :YES];
					break;
				}
			}
			else
			{
				[newRecentFiles addObject:recent];
			}

			[urls addObject:url];
		}

		// newRecentFiles contains all the files we have found; use it to replace recentFiles

		if (recentFiles.count != newRecentFiles.count)
		{
			// We removed one or more files from recentFiles, so re-process this menu

			[self refreshRecentFilesMenu];
		}

		recentFiles = newRecentFiles;
		
		if (urls.count > 0) [self openSquirrelProjects:urls];
	}
}



- (IBAction)clearRecent:(id)sender
{
	// The user has clicked on the recent files menu's 'clear menu' option

	if (recentFiles != nil)
	{
		// If we have any recent files (the menu option won't be selectable otherwise)
		// then clear the file list and then the menu

		[recentFiles removeAllObjects];
		[self refreshRecentFilesMenu];
	}
}



- (void)addToRecentMenu:(NSString *)filename :(NSString *)path
{
	// Following the creation of a new project or opening a project file, add it to the recent files list

	// First, check whether the newly opened file is already on the list

	NSDictionary *got = nil;

	if (recentFiles == nil) recentFiles = [[NSMutableArray alloc] init];

	if (recentFiles.count > 0)
	{
		for (NSDictionary *recent in recentFiles)
		{
			// Check both the filename and the path - we may be dealing with the same filename
			// in different locations. Presumably they are different (eg. have different project names)

			if ([filename compare:[recent objectForKey:@"name"]] == NSOrderedSame && [path compare:[recent objectForKey:@"path"]] == NSOrderedSame)
			{
				got = recent;
				break;
			}
		}
	}

	if (got == nil)
	{
		// Create a new file entry and add it to the top of the list
		// Each 'recent file' is a dictionry with the following keys:
		// 'name' - the filename (string)
		// 'path' - the file's path (string)
		// 'bookmark' - a bookmark (data)

		NSInteger max = [[defaults objectForKey:@"com.bps.squinter.recentFilesCount"] integerValue];

		NSURL *url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/%@", path, filename]];
		NSData *bookmark = [self bookmarkForURL:url];

		NSDictionary *newEntry = @{ @"name" : filename,
									@"path" : path,
									@"bookmark" : bookmark };

		// Always add the new entry to the top of the list

		[recentFiles insertObject:newEntry atIndex:0];

		// Is the list too long? If so prune it

		while (recentFiles.count > max) [recentFiles removeLastObject];
 	}
	else
	{
		// We have the opened file in the list already, so just move it to the top

		[recentFiles removeObject:got];
		[recentFiles insertObject:got atIndex:0];
	}

	// Rebuild the menu

	[self refreshRecentFilesMenu];
}



#pragma mark - Product Methods


- (void)chooseProduct:(id)sender
{
	// We only need to update the Projects menu's product-specific entries when a product is chosen

	NSMenuItem *item = (NSMenuItem *)sender;
	if (item.representedObject != nil) selectedProduct = item.representedObject;

	[self refreshProductsMenu];
	[self refreshProjectsMenu];
	[self setToolbar];
}



- (IBAction)getProductsFromServer:(id)sender
{
	// Get a list of the host account's products to populate the products sub-menu

	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"restart devices"];
		return;
	}

	[self writeStringToLog:@"Getting a list of Products from the impCloud..." :YES];
	[ide getProducts];

	// Pick up the action in 'listProducts:'
}



- (IBAction)deleteProduct:(id)sender
{
	if (selectedProduct == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProduct] :YES];
		return;
	}

	BOOL flag = NO;

	// If the product is linked to a projetc, re-flight the deletion
	// by checking the product's device groups for assigned devices

	if (projectArray.count > 0)
	{
		for (Project *project in projectArray)
		{
			NSString *apid = [self getValueFrom:selectedProduct withKey:@"id"];

			if ([project.pid compare:apid] == NSOrderedSame)
			{
				// This product has a matching project

				if (devicesArray.count > 0)
				{
					for (Devicegroup *devicegroup in project.devicegroups)
					{
						if (devicegroup.devices.count > 0)
						{
							flag = YES;
							break;
						}
					}
				}
			}

			if (flag) break;
		}
	}

	if (!flag)
	{
		// The selected product is not associated with an open project -
		// or if it is, its device groups are all empty

		NSAlert *alert = [[NSAlert alloc] init];
		[alert addButtonWithTitle:@"No"];
		[alert addButtonWithTitle:@"Yes"];
		[alert setMessageText:[NSString stringWithFormat:@"You are about to delete the Product \"%@\". Are you sure you want to proceed?", [self getValueFrom:selectedProduct withKey:@"name"]]];
		[alert setInformativeText:@"Selecting ‘Yes’ will permanently delete the Product — but only if its Device Groups have no devices assigned to any of them."];
		[alert setAlertStyle:NSWarningAlertStyle];
		[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {

			if (returnCode == 1001)
			{
				// Proceed with the deletion

				NSMutableDictionary *dp = [[NSMutableDictionary alloc] init];
				[dp setObject:selectedProduct forKey:@"product"];
				[dp setObject:[NSNumber numberWithInteger:0] forKey:@"count"];

				// First, get a list of the product's device groups

				NSDictionary *dict = @{ @"action" : @"deleteproduct",
										@"product" : dp };

				[self writeStringToLog:[NSString stringWithFormat:@"Deleting Product \"%@\" - checking its Device Groups...", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];

				[ide getDevicegroupsWithFilter:@"product.id" :[selectedProduct objectForKey:@"id"] :dict];

				// Pick up the action in 'productToProjectStageTwo:'
			}
		}];
	}
	else
	{
		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Cannot delete Project \"%@\" as it appears to have Device Groups with assigned devices", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];
	}
}



- (IBAction)downloadProduct:(id)sender
{
	if (selectedProduct == nil)
	{
		[self writeErrorToLog:@"[ERROR] You have not selected a Product as the new project's source." :YES];
		return;
	}

	[self writeStringToLog:[NSString stringWithFormat:@"Retrieving Device Groups and source code for Product \"%@\".", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];
	[self writeStringToLog:@"This may take a moment or two..." :YES];

	Project *newProject = [[Project alloc] init];

	// Set new project's name, id and desc to match that of the source product

	newProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
	newProject.description = [self getValueFrom:selectedProduct withKey:@"description"];
	newProject.path = workingDirectory;
	newProject.devicegroups = [[NSMutableArray alloc] init];

	NSInteger count = 1;
	BOOL done = YES;
	NSString *name = [self getValueFrom:selectedProduct withKey:@"name"];

	// Update the name if it matches - the user can change this at the saving stage

	do
	{
		for (Project *project in projectArray)
		{
			if ([name compare:project.name] == NSOrderedSame)
			{
				name = [project.name stringByAppendingFormat:@" %li", (long)count];
				++count;
				done = NO;
				break;
			}
			else
			{
				done = YES;
			}
		}
	}
	while (!done);

	newProject.name = name;

	NSDictionary *dict = @{ @"action" : @"downloadproduct",
							@"project" : newProject };

	// Add the project to the list of current downloading products
	// TODO Do we need this? Probably not (we can refresh list at the end

	if (downloads == nil) downloads = [[NSMutableArray alloc] init];

	[downloads addObject:newProject];

	// Now retrieve the device groups for this specific product id

	[ide getDevicegroupsWithFilter:@"product.id" :newProject.pid :dict];

	// At this point the we have to wait for the async call to 'productToProjectStageTwo'
}



- (IBAction)linkProjectToProduct:(id)sender
{
	if (selectedProduct == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProduct] :YES];
		return;
	}

	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	NSString *pid = [selectedProduct objectForKey:@"id"];

	if (currentProject.pid != nil && [currentProject.pid compare:pid] == NSOrderedSame)
	{
		[self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" is already linked to Product \"%@\".", currentProject.name, [self getValueFrom:selectedProduct withKey:@"name"]] :YES];
	}
	else
	{
		currentProject.pid = pid;
		currentProject.haschanged = YES;
		[self refreshOpenProjectsMenu];

		[self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" is now linked to Product \"%@\".", currentProject.name, [self getValueFrom:selectedProduct withKey:@"name"]] :YES];
	}

	// Update UI

	[saveLight needSave:YES];
	[_window setDocumentEdited:YES];
}



#pragma mark - New Device Group Mehods


- (IBAction)newDevicegroup:(id)sender
{
	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	if (sender != nil)
	{
		newDevicegroupLabel.stringValue = @"What would you like to call the new Device Group?";
		newDevicegroupNameTextField.stringValue = @"";
		newDevicegroupDescTextField.stringValue = @"";
	}

	// Set the 'add files' checkbox according to how we're calling up this dialog:
	// It should be off and deactivated if we're coming from adding new files to project, otherwise it's active

	if (newDevicegroupFlag)
	{
		newDevicegroupCheckbox.state = NSOffState;
		newDevicegroupCheckbox.enabled = NO;
	}
	else
	{
		newDevicegroupCheckbox.state = NSOnState;
		newDevicegroupCheckbox.enabled = YES;
	}

	targetAccessoryLabel.enabled = NO;
	targetAccessoryLabel.textColor = [NSColor grayColor];

	[targetAccessoryPopup removeAllItems];

	for (Devicegroup *devicegroup in currentProject.devicegroups)
	{
		if ([devicegroup.type compare:@"production_devicegroup"] == NSOrderedSame) [targetAccessoryPopup addItemWithTitle:devicegroup.name];
	}

	if (targetAccessoryPopup.itemArray.count == 0)
	{
		[targetAccessoryPopup addItemWithTitle:@"No production device groups in this project"];
		NSMenuItem *item = [targetAccessoryPopup.itemArray objectAtIndex:0];
		item.tag = 99;
	}

	targetAccessoryPopup.enabled = NO;

	[_window beginSheet:newDevicegroupSheet completionHandler:nil];
}



- (IBAction)newDevicegroupSheetCancel:(id)sender
{
	[_window endSheet:newDevicegroupSheet];

	if (newDevicegroupFlag)
	{
		// We are cancelling after adding files so check the user is sure

		NSAlert *ays = [[NSAlert alloc] init];
		[ays addButtonWithTitle:@"No"];
		[ays addButtonWithTitle:@"Yes"];
		[ays setMessageText:@"If you cancel, you will not add the selected file(s). Are you sure you want to proceed?"];
		[ays setAlertStyle:NSWarningAlertStyle];
		[ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
			if (returnCode == 1001)
			{
				// Proceed with the cancellation - currentDevicegroup indicates the new device group

				[currentProject.devicegroups removeObject:currentDevicegroup];

				if (currentProject.devicegroups.count > 0)
				{
					// We have other device groups in the project - select the first

					currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
					currentProject.devicegroupIndex = 0;
				}
				else
				{
					currentDevicegroup.models = nil;
					currentDevicegroup = nil;
					currentProject.devicegroupIndex = -1;
				}

				[self refreshMainDevicegroupsMenu];
				[self refreshDevicegroupMenu];

				saveUrls = nil;
			}
			else
			{
				// Cancel the cancellation. Make sure we pass in nil so that
				// the fields are not cleared

				[self newDevicegroup:nil];
			}
		}];
	}
}



- (IBAction)newDevicegroupSheetCreate:(id)sender
{
	NSString *dgname = newDevicegroupNameTextField.stringValue;
	NSString *dgdesc = newDevicegroupDescTextField.stringValue;
	BOOL makeNewFiles = newDevicegroupCheckbox.state;

	[_window endSheet:newDevicegroupSheet];

	if (dgname.length > 80)
	{
		// Device Group name is too long

		newDevicegroupLabel.stringValue = @"The name you chose is too long. Please choose another name, or cancel.";
		[NSThread sleepForTimeInterval:2.0];
		[self newDevicegroup:nil];
		return;
	}

	if (dgdesc.length > 255)
	{
		// Device Group description is too long

		newDevicegroupLabel.stringValue = @"The description you chose is too long. Please choose another name, or cancel.";
		[NSThread sleepForTimeInterval:2.0];
		[self newDevicegroup:nil];
		return;
	}

	if (dgname.length == 0)
	{
		// Device Group name is too short

		newDevicegroupLabel.stringValue = @"You must choose a Device Group name. Please choose a name, or cancel.";
		[NSThread sleepForTimeInterval:2.0];
		[self newDevicegroup:nil];
		return;
	}

	Devicegroup *newdg = (newDevicegroupFlag == YES) ? currentDevicegroup : [[Devicegroup alloc] init];

	if (currentProject.devicegroups == nil) currentProject.devicegroups = [[NSMutableArray alloc] init];

	// Check we're not matching an existing name

	if (currentProject.devicegroups.count > 0)
	{
		for (Devicegroup *adg in currentProject.devicegroups)
		{
			if ([adg.name compare:dgname] == NSOrderedSame)
			{
				newDevicegroupLabel.stringValue = @"The current Project already has a Device Group with that name. Please choose another, or cancel.";
				[NSThread sleepForTimeInterval:2.0];
				[self newDevicegroup:nil];
				return;
			}
		}
	}

	newdg.name = dgname;
	newdg.description = dgdesc;
	newdg.type = [self convertDevicegroupType:newDevicegroupTypeMenu.selectedItem.title :YES];
	newdg.type = @"development_devicegroup";

	if (currentProject.pid != nil && currentProject.pid.length > 0)
	{
		// The current project is associated with a product so we can create the device group on the server

		NSDictionary *dict = @{ @"action" : @"newdevicegroup",
							    @"devicegroup" : newdg,
								@"project" : currentProject,
								@"files" : [NSNumber numberWithBool:makeNewFiles] };

		[self writeStringToLog:[NSString stringWithFormat:@"Uploading Device Group \"%@\" to the impCloud.", newdg.name] :YES];

		NSDictionary *details;

		if (![newdg.type containsString:@"factoryfixture"])
		{
			details = @{ @"name" : newdg.name,
						 @"description" : newdg.description,
						 @"productid" : currentProject.pid,
						 @"type" : newdg.type };

			[ide createDevicegroup:details :dict];

			// We will handle the addition of the device group and UI updates later - it will call
			// the following code separately in 'createDevicegroupStageTwo:'
		}
		else
		{
			// TODO Need to specify a target production device group

			// POPUP and ask
		}
	}
	else
	{
		// The project is local only so far

		// If we were adding source files, head back to that flow

		if (newDevicegroupFlag)
		{
			[self processAddedFiles:saveUrls];
			return;
		}

		// Select the new Device Group

		if (currentDevicegroup != newdg)
		{
			[currentProject.devicegroups addObject:newdg];
			currentDevicegroup = newdg;
			currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
		}

		// Update the UI

		[self refreshDevicegroupMenu];
		[self refreshMainDevicegroupsMenu];
		[self setToolbar];

		currentProject.haschanged = YES;
		[saveLight needSave:YES];
		[_window setDocumentEdited:YES];
		[self refreshOpenProjectsMenu];

		// Create the new device group's files as requested

		if (makeNewFiles) [self createFilesForDevicegroup:newdg.name :@"agent"];
	}
}



- (void)createFilesForDevicegroup:(NSString *)filename :(NSString *)filetype
{
	// We come here if we have to create source code files for a new device group

	// Configure the NSSavePanel

	saveProjectDialog = [NSSavePanel savePanel];
	[saveProjectDialog setNameFieldStringValue:[filename stringByAppendingFormat:@".%@.nut", filetype]];
	[saveProjectDialog setCanCreateDirectories:YES];
	[saveProjectDialog setDirectoryURL:[NSURL fileURLWithPath:currentProject.path isDirectory:YES]];

	if ([filetype compare:@"agent"] == NSOrderedSame)
	{
		saveProjectDialog.accessoryView = saveDevicegroupFilesAccessoryView;
		saveDevicegroupFilesAccessoryViewCheckbox.state = NSOnState;
	}
	else
	{
		saveProjectDialog.accessoryView = nil;
		saveDevicegroupFilesAccessoryViewCheckbox.state = NSOffState;
	}

	[saveProjectDialog beginSheetModalForWindow:_window
							  completionHandler:^(NSInteger result)
	 {
		 // Close sheet first to stop it hogging the event queue

		 [NSApp stopModal];
		 [NSApp endSheet:saveProjectDialog];
		 [saveProjectDialog orderOut:self];

		 if (result == NSFileHandlingPanelOKButton)
		 {
			 if (saveDevicegroupFilesAccessoryViewCheckbox.state == NSOnState)
			 {
				 [self saveDevicegroupfiles:[saveProjectDialog directoryURL] :[saveProjectDialog nameFieldStringValue]: kActionNewDGBothFiles];
			 }
			 else
			 {
				 if (saveProjectDialog.accessoryView == saveDevicegroupFilesAccessoryView)
				 {
					 [self saveDevicegroupfiles:[saveProjectDialog directoryURL] :[saveProjectDialog nameFieldStringValue]: kActionNewDGAgentFile];
				 }
				 else
				 {
					 [self saveDevicegroupfiles:[saveProjectDialog directoryURL] :[saveProjectDialog nameFieldStringValue]: kActionNewDGDeviceFile];
				 }
			 }
		 }
	 }
	 ];

	[NSApp runModalForWindow:saveProjectDialog];
}



- (void)saveDevicegroupfiles:(NSURL *)saveDirectory :(NSString *)newFileName :(NSInteger)action
{
	// Save the savingProject project. This may be a newly created project and may not currentProject

	BOOL success = NO;
	NSString *savePath = [[saveDirectory path] stringByAppendingFormat:@"/%@", newFileName];
	NSString *dataString = nil;

	if (action == kActionNewDGBothFiles)
	{
		// The user wants the two files in the same place, so write the agent file now
		// then recall this method to write the device file

		if (newFileName == nil) newFileName = @"untitled.agent.nut";
		dataString = @"// Agent Code\n\n";
	}
	else
	{
		if (newFileName == nil && action == kActionNewDGAgentFile) newFileName = @"untitled.agent.nut";
		if (newFileName == nil && action == kActionNewDGDeviceFile) newFileName = @"untitled.device.nut";

		dataString = (action == kActionNewDGDeviceFile) ? @"// Device Code\n\n" : @"// Agent Code\n\n";
	}

	NSData *data = [dataString dataUsingEncoding:NSUTF8StringEncoding];

	if ([nsfm fileExistsAtPath:savePath])
	{
		// The file already exists. We can safely overwrite it because that's what the user intended:
		// They asked for it implicitly with a Save command, or told the Save As... dialog to replace the file

		// Write the new version to a separate file

		NSString *altPath = [savePath stringByAppendingString:@".new"];
		success = [nsfm createFileAtPath:altPath contents:data attributes:nil];

		if (success)
		{
			// We have successfully written the new file, so we can replace the old one with the new one

			NSError *error;
			NSURL *url;
			success = [nsfm replaceItemAtURL:[NSURL fileURLWithPath:savePath]
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

		success = [nsfm createFileAtPath:savePath contents:data attributes:nil];
	}

	if (success == YES)
	{
		// The new file was successfully written, so make a new model for it

		Model *newModel = [[Model alloc] init];
		newModel.filename = [savePath lastPathComponent];
		newModel.path = [self getRelativeFilePath:currentProject.path :[savePath stringByDeletingLastPathComponent]];

		if (currentDevicegroup.models == nil) currentDevicegroup.models = [[NSMutableArray alloc] init];

		if (action == kActionNewDGBothFiles)
		{
			// We have just written the agent code file, so now go and write the device file in the same place

			newModel.type = @"agent";
			newFileName = [currentDevicegroup.name stringByAppendingString:@".device.nut"];
			[currentDevicegroup.models addObject:newModel];
			[self saveDevicegroupfiles:saveDirectory :newFileName :kActionNewDGDeviceFile];
		}
		else if (action == kActionNewDGAgentFile)
		{
			// User wants to save the device file separately, so add the model
			// then re-present the save dialog

			newModel.type = @"agent";
			[currentDevicegroup.models addObject:newModel];

			// Now go and pick the (different) device code file location

			[self createFilesForDevicegroup:currentDevicegroup.name :@"device"];
		}
		else
		{
			newModel.type = @"device";
			[currentDevicegroup.models addObject:newModel];

			// Update the UI

			[self refreshMainDevicegroupsMenu];
		}
	}
	else
	{
		[self writeErrorToLog:@"[ERROR] The file could not be saved." :YES];
	}
}



- (IBAction)chooseType:(id)sender
{
	NSInteger type = [newDevicegroupTypeMenu indexOfSelectedItem];

	if (type == 1)
	{
		// Only activate the accessory items for factory fixture device groups

		targetAccessoryLabel.textColor = [NSColor blackColor];
		targetAccessoryLabel.enabled = YES;

		// If the target list is empty, don't enable it

		NSMenuItem *item = [targetAccessoryPopup.itemArray objectAtIndex:0];
		targetAccessoryPopup.enabled = item.tag == 99 ? NO : YES;
	}
	else
	{
		targetAccessoryLabel.textColor = [NSColor grayColor];
		targetAccessoryLabel.enabled = NO;
		targetAccessoryPopup.enabled = NO;
	}
}


#pragma mark - Existing Device Group Methods

- (void)chooseDevicegroup:(id)sender
{
	// User has selected a device group
	// So we need to set 'currentDevicegroup' to the chosen device group
	// And, depending on prefs, select the first device, if there is one
	// then update the UI

	NSMenuItem *item = (NSMenuItem *)sender;
	currentDevicegroup = item.representedObject;
	currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];

	// Switch off unselected menus - and submenus

	for (NSMenuItem *dgitem in deviceGroupsMenu.itemArray)
	{
		if (dgitem != item)
		{
			dgitem.state = NSOffState;

			if (dgitem.submenu != nil)
			{
				for (NSMenuItem *sitem in dgitem.submenu.itemArray)
				{
					sitem.state = NSOffState;
				}
			}
		}
		else
		{
			dgitem.state = NSOnState;

			// Use the flag to make sure we don't reselect the device
			// after coming here from 'chooseDevice:'

			if (!deviceSelectFlag)
			{
				if (dgitem.submenu != nil)
				{
					NSMenuItem *sitem = [dgitem.submenu.itemArray objectAtIndex:0];

					// Select the device using 'chooseDevice:' as this manages 'selectedDevice'

					[self chooseDevice:sitem];
				}
			}
		}
	}

	deviceSelectFlag = NO;

	// Update the UI: the Device Groups menu and the View menu (in case
	// the selected device group has compiled code)

	[self refreshLibraryMenus];
	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];
	[self setToolbar];
}



- (IBAction)deleteDevicegroup:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (currentDevicegroup.did != nil && currentDevicegroup.did.length > 0)
	{
		if (!ide.isLoggedIn)
		{
			// The user is not logged in, but the device group is associated with a device group on the server.

			[self loginAlert:[NSString stringWithFormat:@"delete device group \"%@\"", currentDevicegroup.name]];
			return;
		}

		if (devicesArray.count > 0)
		{
			// We have a list of device so we can check if the the device group is populated or not

			for (NSDictionary *device in devicesArray)
			{
				NSDictionary *dvdg = [self getValueFrom:device withKey:@"devicegroup"];
				NSString *dvdgid = [dvdg objectForKey:@"id"];

				if (dvdgid != nil && [dvdgid compare:currentDevicegroup.did] == NSOrderedSame)
				{
					// The device group has at least one device assigned to it so we can't delete

					NSAlert *alert = [[NSAlert alloc] init];
					alert.messageText = [NSString stringWithFormat:@"Device Group \"%@\" can’t be deleted.", currentDevicegroup.name];
					alert.informativeText = [NSString stringWithFormat:@"Device Group \"%@\" has devices assigned to it. A Device Group can’t be deleted until all of its devices have been re-assigned.", currentDevicegroup.name];
					[alert addButtonWithTitle:@"OK"];
					[alert beginSheetModalForWindow:_window
								  completionHandler:^(NSModalResponse response)
								 {

								 }
					 ];

					return;
				}
			}
		}

		// If we are here, the device group has no devices assigned, or we can't check at this time.
		// So just try to delete it anyway - the server will warn if the group can't be deleted

		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = [NSString stringWithFormat:@"Are you sure you wish to delete Device Group \"%@\"?", currentDevicegroup.name];
		[alert addButtonWithTitle:@"No"];
		[alert addButtonWithTitle:@"Yes"];
		[alert beginSheetModalForWindow:_window
					  completionHandler:^(NSModalResponse response)
		 {
			 if (response != NSAlertFirstButtonReturn)
			 {
				 // User wants to delete the device group

				 NSDictionary *dict = @{ @"action" : @"deletedevicegroup",
										 @"devicegroup" : currentDevicegroup };

				 [ide deleteDevicegroup:currentDevicegroup.did :dict];

				 // We will pick up this thread in 'deleteDevicegroupStageTwo:'
			 }
		 }
		 ];

		return;
	}
	else
	{
		// Device group in an unassociated project, so it can't have device associated with it.
		// Remove it and select the project's first device group if it has one

		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = [NSString stringWithFormat:@"Are you sure you wish to delete Device Group \"%@\"?", currentDevicegroup.name];
		[alert addButtonWithTitle:@"No"];
		[alert addButtonWithTitle:@"Yes"];
		[alert beginSheetModalForWindow:_window
					  completionHandler:^(NSModalResponse response)
		 {
			 if (response != NSAlertFirstButtonReturn)
			 {
				 // User wants to delete the device group

				 [currentProject.devicegroups removeObject:currentDevicegroup];

				 currentDevicegroup = currentProject.devicegroups.count > 0 ? [currentProject.devicegroups objectAtIndex:0] : nil;
				 currentProject.devicegroupIndex = currentDevicegroup != nil ? [currentProject.devicegroups indexOfObject:currentDevicegroup] : -1;
				 currentProject.haschanged = YES;

				 [saveLight needSave:YES];
				 [_window setDocumentEdited:YES];

				 [self refreshOpenProjectsMenu];
				 [self refreshMainDevicegroupsMenu];
				 [self refreshDevicegroupMenu];
			 }
		 }
		 ];
	}
}



- (IBAction)renameDevicegroup:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	[self renameProject:sender];
}



- (IBAction)uploadCode:(id)sender
{
	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"upload code"];
		return;
	}

	if (currentDevicegroup == nil)
	{
		[self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (currentDevicegroup.did == nil || currentDevicegroup.did.length == 0)
	{
		[self writeErrorToLog:@"[ERROR] Cannot upload: the selected Device Group is not associated with a Device Group in the impCloud." :YES];
		return;
	}

	if (currentDevicegroup.models.count == 0)
	{
		[self writeErrorToLog:@"[ERROR] The selected Device Group contains no code to upload." :YES];
		return;
	}

	if ((currentDevicegroup.squinted & 0x08) != 0)
	{
		// Project has been uploaded, so do we want to continue?

		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = @"You have already uploded this code";
		alert.informativeText = @"This code has been uploaded to the device group. Are you sure you want to upload it again?";
		[alert addButtonWithTitle:@"Upload"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
			// If user hits Upload, re-run the method
			if (returnCode == 1000)
			{
				currentDevicegroup.squinted = currentDevicegroup.squinted - 0x08;
				[self uploadCode:nil];
			}
		}];

		return;
	}

	NSString *agentCode, *deviceCode;

	for (Model *model in currentDevicegroup.models)
	{
		if (!model.squinted)
		{
			[self writeErrorToLog:@"[ERROR] The selected Device Group contains uncompiled code. Please compile before uploading." :YES];
			return;
		}

		if ([model.type compare:@"agent"] == NSOrderedSame)
		{
			agentCode = model.code;
		}
		else
		{
			deviceCode = model.code;
		}
	}

	if (sender == uploadExtraMenuItem || sender == uploadCodeExtraItem)
	{
		// The user seleted the alterntive menu to upload extra info so do that and bail from here

		uploadCommitTextField.stringValue = @"";
		uploadOriginTextField.stringValue = @"";
		uploadTagsTextField.stringValue = @"";
		uploadDevicegroupTextField.stringValue = [NSString stringWithFormat:@"Upload code and extra information to device group “%@”...", currentDevicegroup.name];

		[_window beginSheet:uploadSheet completionHandler:nil];

		return;
	}

	// We're doing a direct upload, so just prep the deployment data and send it

	NSString *dt = [def stringFromDate:[NSDate date]];

	NSDictionary *dg = @{ @"type" : currentDevicegroup.type,
						  @"id" : currentDevicegroup.did };

	NSDictionary *relationships = @{ @"devicegroup" : dg };
	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

	[attributes setObject:(deviceCode != nil ? deviceCode : @"") forKey:@"device_code"];
	[attributes setObject:(agentCode != nil ? agentCode : @"") forKey:@"agent_code"];
	[attributes setObject:[NSString stringWithFormat:@"Uploaded from Squinter 2.0 at %@", dt] forKey:@"description"];

	NSDictionary *deployment = @{ @"type" : @"deployment",
								  @"attributes" : [NSDictionary dictionaryWithDictionary:attributes],
								  @"relationships" : relationships };

	NSDictionary *data = @{ @"data" : deployment };

	NSDictionary *dict = @{ @"action" : @"uploadcode",
							@"devicegroup" : currentDevicegroup };

	[ide createDeployment:data :dict];

	// Pick up the action at uploadCodeStageTwo:
}



- (IBAction)uploadCodeExtraCancel:(id)sender
{
	// The user wants to cancel, so just close the sheet

	[_window endSheet:uploadSheet];
}



- (IBAction)uploadCodeExtraSkip:(id)sender
{
	// The user wants to skip uploading extra data, so just go and do a basic upload

	[_window endSheet:uploadSheet];

	[self uploadCode:nil];
}



- (IBAction)uploadCodeExtraUpload:(id)sender
{
	// Process the extra information from the dialog box and upload it with the model
	// code as a new deployment

	NSString *description = uploadCommitTextField.stringValue;
	NSString *origin = uploadOriginTextField.stringValue;
	NSString *tags = uploadTagsTextField.stringValue;
	NSMutableArray *tagArray = [[NSMutableArray alloc] init];

	[_window endSheet:uploadSheet];

	if (description == nil) description = @"";
	if (origin == nil) origin = @"";
	if (tags == nil) tags = @"";

	// Check tags for illegal characters

	if (tags.length > 0)
	{
		NSError *err;
		NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern: @"^[A-Za-z0-9_-*.]$"
																			   options: NSRegularExpressionCaseInsensitive
																				 error: &err];
		NSArray *parts = [tags componentsSeparatedByString:@","];
		NSInteger indices[parts.count];

		for (NSUInteger i = 0 ; i < parts.count ; ++i)
		{
			indices[i] = 1;
		}

		if (!err)
		{
			for (NSUInteger i = 0 ; i < parts.count ; ++i)
			{
				NSString *part = [parts objectAtIndex:i];

				NSTextCheckingResult *result = [regex firstMatchInString: part
																 options: 0
																   range: NSMakeRange(0, part.length)];

				if (result == nil)
				{
					[self writeStringToLog:[NSString stringWithFormat:@"Tag \"%@\" is illegal and will be removed.", part] :YES];

					indices[i] = 0;
				}
				else
				{
					indices[i] = 1;
				}
			}
		}

		for (NSUInteger i = 0 ; i < parts.count ; ++i)
		{
			if (indices[i] != 0)
			{
				NSString *part = [parts objectAtIndex:i];

				// Top and tail whitespace from the tag

				part = [part stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

				// Add the tag back to the 'tags' string

				if (part.length != 0) [tagArray addObject:part];
			}
		}
	}

	NSString *agentCode, *deviceCode;

	for (Model *model in currentDevicegroup.models)
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

	NSDictionary *dg = @{ @"type" : currentDevicegroup.type,
						  @"id" : currentDevicegroup.did };

	NSDictionary *relationships = @{ @"devicegroup" : dg };

	NSMutableDictionary *attributes = [[NSMutableDictionary alloc] init];

	if (deviceCode != nil) [attributes setObject:deviceCode forKey:@"device_code"];
	if (agentCode != nil) [attributes setObject:agentCode forKey:@"agent_code"];
	if (description != nil && description.length > 0) [attributes setObject:description forKey:@"description"];
	if (origin != nil && origin.length > 0) [attributes setObject:origin forKey:@"origin"];
	if (tagArray != nil && tagArray.count > 0) [attributes setObject:tagArray forKey:@"tags"];

	NSDictionary *deployment = @{ @"type" : @"deployment",
								  @"attributes" : [NSDictionary dictionaryWithDictionary:attributes],
								  @"relationships" : relationships };

	NSDictionary *data = @{ @"data" : deployment };

	NSDictionary *dict = @{ @"action" : @"uploadcode",
							@"devicegroup" : currentDevicegroup };

	[ide createDeployment:data :dict];

	// Pick up the action at uploadCodeStageTwo:
}



- (IBAction)removeSource:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = @"Are you sure you wish to remove the source code files from this Device Group?";
	alert.informativeText = @"This will remove all source code files from the Device Group but not delete them. You can re-add source code files to the Device Group at any time.";
	[alert addButtonWithTitle:@"No"];
	[alert addButtonWithTitle:@"Yes"];
	[alert beginSheetModalForWindow:_window
				  completionHandler:^(NSModalResponse response)
	 {
		 if (response != NSAlertFirstButtonReturn)
		 {
			 if (currentDevicegroup.models.count > 0) [currentDevicegroup.models removeAllObjects];

			 currentProject.haschanged = YES;
			 [saveLight needSave:YES];
			 [_window setDocumentEdited:YES];
			 [self refreshOpenProjectsMenu];
			 [self refreshMainDevicegroupsMenu];
		 }
	 }
	 ];
}



- (IBAction)getCommits:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	NSDictionary *dict = @{ @"action" : @"getcommits",
							@"devicegroup" : currentDevicegroup };

	[ide getDeploymentsWithFilter:@"devicegroup.id" :currentDevicegroup.did :dict];

	// Pick up the action in getCommitsStageTwo:
}



- (IBAction)updateCode:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	NSDictionary *dict = @{ @"action" : @"updatecode",
							@"devicegroup" : currentDevicegroup };

	[ide getDevicegroup:currentDevicegroup.did :dict];

	// Pick up the action in updateCodeStageTwo:
}



#pragma mark - Existing Device Methods


- (void)selectDevice
{
	// Select the first device in the current device group

	if (currentDevicegroup.devices.count > 0 && devicesArray.count > 0)
	{
		NSString *devId = [currentDevicegroup.devices objectAtIndex:0];

		for (NSDictionary *device in devicesArray)
		{
			NSString *aDevId = [self getValueFrom:device withKey:@"name"];

			if ([aDevId compare:devId] == NSOrderedSame)
			{
				selectedDevice = (NSMutableDictionary *)device;
				[self refreshDevicesPopup];
				[self refreshDeviceMenu];
				break;
			}
		}
	}
}



- (IBAction)updateDevicesStatus:(id)sender
{
	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"update devices' status information"];
		return;
	}

	[self writeStringToLog:@"Updating devices’ status information - this may take a moment..." :YES];

	// Get all the devices from development device groups and unassigned devices

	NSDictionary *dict = @{ @"action" : @"getdevices" };

	[ide getDevices:dict];
}



- (IBAction)restartDevice:(id)sender
{
	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"restart devices"];
		return;
	}

	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	// Is the device unassigned? If so, it can't be restarted

	NSString *did = [self getValueFrom:selectedDevice withKey:@"id"];

	if (did == nil || did.length == 0)
	{
		[self writeWarningToLog:[NSString stringWithFormat:@"Device \"%@\" can't be restarted as it has not yet been assigned to a device group.", [self getValueFrom:selectedDevice withKey:@"name"]] :YES];
		return;
	}

	// Proceed with the restart

	[self writeStringToLog:[NSString stringWithFormat:@"Restarting \"%@\"", [self getValueFrom:selectedDevice withKey:@"name"]] :YES];

	NSDictionary *dict = @{ @"action" : @"restartdevice",
							@"device" : selectedDevice };

	[ide restartDevice:[self getValueFrom:selectedDevice withKey:@"id"] :dict];

	// Pick up the action at 'restarted:'
}



- (IBAction)restartDevices:(id)sender
{
	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"restart devices"];
		return;
	}

	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	NSDictionary *dict = @{ @"action" : @"restartdevices",
							@"devicegroup" : currentDevicegroup };

	[ide restartDevices:currentDevicegroup.did :dict];

	// Pick up the action at 'restarted:'
}



- (IBAction)unassignDevice:(id)sender
{
	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"unassign a device"];
		return;
	}

	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSMutableDictionary *devicegroup = [self getValueFrom:selectedDevice withKey:@"devicegroup"];

	if (devicegroup == nil)
	{
		[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Device \"%@\" is already unassigned.", [self getValueFrom:selectedDevice withKey:@"name"]]:YES];
		return;
	}

	NSDictionary *dict = @{ @"action" : @"unassign",
							@"device" : selectedDevice };

	[ide unassignDevice:selectedDevice :dict];

	// Pick up the action at 'reassigned:'
}



- (IBAction)assignDevice:(id)sender
{
	// Remember, we assign a device to a device group of the right type, not to a product
	// For now we are only assigning development devices to devicegroups we know about

	if (!ide.isLoggedIn)
	{
		[self loginAlert:@"assign a device"];
		return;
	}

	if (devicesArray == nil || devicesArray.count == 0)
	{
		// We have no device(s) to assign

		[self writeErrorToLog:@"[ERROR] You have no devices listed. You may need to retrieve the list from the impCloud." :YES];
		return;
	}

	if (projectArray == nil || projectArray.count == 0)
	{
		// We have no projects open - so we can't assign a device to an open device group

		[self writeErrorToLog:@"[ERROR] You have no Projects open. You will need to create or open a Project and add a Device Group to assign a device." :YES];
		return;
	}

	[assignDeviceMenuDevices removeAllItems];
	[assignDeviceMenuModels removeAllItems];

	assignDeviceMenuModels.autoenablesItems = NO;

	// Assemble the devices list

	for (NSDictionary *device in devicesArray)
	{
		[assignDeviceMenuDevices addItemWithTitle:[self getValueFrom:device withKey:@"name"]];
		NSMenuItem *item = [assignDeviceMenuDevices.itemArray lastObject];
		item.representedObject = device;
	}

	// Assemble the projects list with device groups

	NSMenuItem *item;

	for (Project *project in projectArray)
	{
		if (project.devicegroups.count > 0)
		{
			// Add the project name as a section header but disable it - it's a marker

			[assignDeviceMenuModels addItemWithTitle:[NSString stringWithFormat:@"Project \"%@\":", project.name]];
			item = [assignDeviceMenuModels.itemArray lastObject];
			item.enabled = NO;
			item.representedObject = nil;

			// Add all the device groups' names

			for (Devicegroup *dg in project.devicegroups)
			{
				[assignDeviceMenuModels addItemWithTitle:dg.name];
				item = [assignDeviceMenuModels.itemArray lastObject];
				item.representedObject = dg;
			}
		}
	}

	if (assignDeviceMenuModels.itemArray.count == 0)
	{
		// We have no device groups to assign

		[self writeErrorToLog:@"[ERROR] None of your open Projects have any Device Groups. You will need to create a Device Group to assign a device." :YES];
		return;
	}

	if (currentDevicegroup != nil)
	{
		// Select the current device group on the list

		[assignDeviceMenuModels selectItemWithTitle:currentDevicegroup.name];
	}
	else
	{
		// There's no current device group, so select the first on the list
		// This is at index 1 because index 0 will be the project name

		[assignDeviceMenuModels selectItemAtIndex:1];
	}

	if (selectedDevice != nil)
	{
		// Select the current device on the list, otherwise the first device will be listed automatically

		[assignDeviceMenuDevices selectItemAtIndex:[assignDeviceMenuDevices indexOfItemWithRepresentedObject:selectedDevice]];
	}

	[_window beginSheet:assignDeviceSheet completionHandler:nil];
}



- (IBAction)assignDeviceSheetCancel:(id)sender
{
	[_window endSheet:assignDeviceSheet];
}



- (IBAction)assignDeviceSheetAssign:(id)sender
{
	// Get the referenced device group and device

	NSInteger devIndex = [assignDeviceMenuDevices indexOfSelectedItem];
	NSInteger dgIndex = [assignDeviceMenuModels indexOfSelectedItem];

	NSMenuItem *item = [assignDeviceMenuDevices itemAtIndex:devIndex];
	NSMutableDictionary *device = item.representedObject;

	item = [assignDeviceMenuModels itemAtIndex:dgIndex];
	Devicegroup *dg = item.representedObject;

	// Remove the sheet

	[_window endSheet:assignDeviceSheet];

	if (dg.did == nil || dg.did.length == 0)
	{
		// The device group is not synced, so we can't proceed with the assignment

		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device \"%@\" not assigned because the chosen Device Group, \"%@\" is not yet associated with a Device Group in the impCloud.", [self getValueFrom:device withKey:@"name"], dg.name] :YES];
		return;
	}

	// Assign the device to the device group

	NSDictionary *dict = @{ @"action" : @"assign",
							@"device" : device,
							@"devicegroup" : dg };

	[ide assignDevice:device :dg.did :dict];

	// Pick up the action at 'reassigned:'
}



- (IBAction)renameDevice:(id)sender
{
	if (devicesArray == nil || devicesArray.count == 0)
	{
		// We have no device to rename

		[self writeErrorToLog:@"[ERROR] You have no devices listed. You may need to retrieve the list from the impCloud." :YES];
		return;
	}

	// Assemble the devices list

	[renameMenu removeAllItems];

	for (NSMutableDictionary *device in devicesArray)
	{
		NSString *dname = [self getValueFrom:device withKey:@"name"];
		[renameMenu addItemWithTitle:dname];
		NSMenuItem *item = [renameMenu itemWithTitle:dname];
		item.representedObject = device;
	}

	// If we have a device selected, makes sure it is also selected in the sheet pop-up

	if (selectedDevice != nil) [renameMenu selectItemWithTitle:[self getValueFrom:selectedDevice withKey:@"name"]];

	// Present the sheet

	renameName.stringValue = @"";

	[_window beginSheet:renameSheet completionHandler:nil];
}



- (IBAction)closeRenameSheet:(id)sender
{
	[_window endSheet:renameSheet];
}



- (IBAction)saveRenameSheet:(id)sender
{
	// Get the selected device

	NSString *newName = renameName.stringValue;
	NSMutableDictionary *device = renameMenu.selectedItem.representedObject;

	// Remove the sheet

	[_window endSheet:renameSheet];

	NSString *dname = [self getValueFrom:device withKey:@"name"];

	// Has the name actually been changed?

	if ([dname compare:newName] == NSOrderedSame)
	{
		// The user hasn't changed the name

		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] The name of device \"%@\" remains unchanged.", newName] :YES];
		return;
	}

	// Prep the relayed data in case we need it

	NSDictionary *dict = @{ @"action" : @"rename",
						    @"old" : dname,
							@"new" : newName,
							@"device" : device };

	// Check for existing device name usage

	BOOL used = NO;

	for (NSMutableDictionary *aDevice in devicesArray)
	{
		dname = [self getValueFrom:aDevice withKey:@"name"];

		if ([dname compare:newName] == NSOrderedSame) used = YES;
	}

	if (used)
	{
		// The device name is already in use. This is legal, but we should confirm with the user

		NSAlert *alert = [[NSAlert alloc] init];
		alert.messageText = [NSString stringWithFormat:@"The device name \"%@\" is already in use. Having multiple devices with the same name may cause confusion. Are you sure you want to rename this device?", newName];
		[alert addButtonWithTitle:@"No"];
		[alert addButtonWithTitle:@"Yes"];
		[alert addButtonWithTitle:@"Cancel"];
		[alert beginSheetModalForWindow:_window
					  completionHandler:^(NSModalResponse response)
		 {
			 if (response == NSAlertFirstButtonReturn)
			 {
				 // User doesn't want wants to rename the device, but clicked 'No' so re-present the rename sheet

				 [_window beginSheet:renameSheet completionHandler:nil];
				 return;
			 }

			 if (response == NSAlertSecondButtonReturn)
			 {
				 // User does want to rename, so proceed

				 [ide updateDevice:[self getValueFrom:device withKey:@"id"] :newName :dict];
				 return;
			 }

			 // If we're here, the user click cancel, so we can just ignore everything
		 }
		 ];
	}
	else
	{
		// The new name is unused so process it

		[ide updateDevice:[self getValueFrom:device withKey:@"id"] :newName :dict];

		// Pick up the action at 'renameDeviceStageTwo:'
	}
}



- (IBAction)chooseDevice:(id)sender
{
	// The user has selected a device from one of three places:
	// - Device PopUp
	// - Unassigned Devices submenu
	// - Device Groups submenu

	NSMenuItem *item;
	BOOL isUnassigned = NO;
	BOOL isAssigned = NO;
	BOOL isPopup = NO;

	if (sender == devicesPopUp)
	{
		// Device selected from the popup rather than the menu

		item = devicesPopUp.selectedItem;

		if ([item.title compare:@"None"] == NSOrderedSame)
		{
			item.enabled = NO;
			return;
		}

		selectedDevice = item.representedObject;
		isPopup = YES;
	}
	else
	{
		item = (NSMenuItem *)sender;

		// We may be here from the Unassigned Device menu or from a Device Groups submenu

		if (item.menu == unassignedDevicesMenu)
		{
			isUnassigned = YES;
		}
		else
		{
			isAssigned = YES;
		}

		selectedDevice = item.representedObject;
	}

	// Run through the Device Groups submenus and switch all the entries off
	// EXCEPT the entry matching 'selectedDevice' IF we came here from this menu

	for (NSMenuItem *dgitem in deviceGroupsMenu.itemArray)
	{
		if (dgitem.submenu != nil)
		{
			for (NSMenuItem *sitem in dgitem.submenu.itemArray)
			{
				sitem.state = NSOffState;

				if (isAssigned || isPopup)
				{
					if (sitem.representedObject == selectedDevice)
					{
						sitem.state = NSOnState;
						if (dgitem.representedObject != currentDevicegroup)
						{
							deviceSelectFlag = YES;
							[self chooseDevicegroup:dgitem];
						}
					}
				}
			}
		}
	}

	// Run through the Unassigned Devices menu and switch all the entries off
	// EXCEPT the one matching 'selectedDevice' IF we came here from this menu

	for (NSMenuItem *unitem in unassignedDevicesMenu.itemArray)
	{
		unitem.state = NSOffState;

		if (isUnassigned || isPopup)
		{
			if (unitem.representedObject == selectedDevice)
			{
				unitem.state = NSOnState;
			}
		}
	}

	NSInteger index = [devicesArray indexOfObject:selectedDevice];
	[devicesPopUp selectItemWithTag:index];

	// Update the UI

	[self refreshDevicegroupMenu];
	[self refreshDeviceMenu];
	[self setToolbar];
}



- (IBAction)deleteDevice:(id)sender
{
	if (selectedDevice == nil)
	{
		return;
	}

	NSAlert *alert = [[NSAlert alloc] init];
	alert.messageText = [NSString stringWithFormat:@"You are about to remove device \"%@\" from your account. Are you sure?", [self getValueFrom:selectedDevice withKey:@"name"]];
	alert.informativeText = @"You can always re-add the device using BlinkUp.";

	[alert addButtonWithTitle:@"No"];
	[alert addButtonWithTitle:@"Yes"];

	[alert beginSheetModalForWindow:_window
				  completionHandler:^(NSModalResponse response)
		{
			if (response != NSAlertFirstButtonReturn)
			{
				NSDictionary *dict = @{ @"action" : @"deletedevice",
										@"device" : selectedDevice };

				[ide deleteDevice:[selectedDevice objectForKey:@"id"] :dict];
			}
		}
	];
}



- (IBAction)getLogs:(id)sender
{
	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSDictionary *dict;

	if (sender == getLogsMenuItem)
	{
		dict = @{ @"action" : @"getlogs" ,
				  @"device" : selectedDevice };

		[ide getDeviceLogs:[self getValueFrom:selectedDevice withKey:@"id"] :dict];
	}
	else
	{
		dict = @{ @"action" : @"gethistory" ,
				  @"device" : selectedDevice };

		[ide getDeviceHistory:[self getValueFrom:selectedDevice withKey:@"id"] :dict];
	}
}



- (IBAction)streamLogs:(id)sender
{
	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSString *devid = [self getValueFrom:selectedDevice withKey:@"id"];
	NSString *devname = [self getValueFrom:selectedDevice withKey:@"name"];

	if (![ide isDeviceLogging:devid])
	{
		if (ide.numberOfLogStreams == 0) [self setLoggingColours];

		if (ide.numberOfLogStreams == 5)
		{
			NSAlert *alert = [[NSAlert alloc] init];
			alert.messageText = @"You are already logging five devices";
			alert.informativeText = @"The impCentral API only supports logging for up to five devices simultaneously. To stream logs from another device, you will need to stop logging from one of the current streaming devices.";
			[alert addButtonWithTitle:@"OK"];
			[alert beginSheetModalForWindow:_window
						  completionHandler:^(NSModalResponse response)
			 {
				 return;
			 }
			 ];

			return;
		}

		streamLogsItem.state = 1;

		[ide startLogging:devid :@{ @"device" : selectedDevice }];

		if (devname.length > logPaddingLength) logPaddingLength = devname.length;
	}
	else
	{
		[ide stopLogging:devid];

		// Reset the log padding to the longest logging device name

		logPaddingLength = 0;

		for (NSMutableDictionary *device in devicesArray)
		{
			devid = [self getValueFrom:device withKey:@"id"];

			if ([ide isDeviceLogging:devid])
			{
				devname = [self getValueFrom:device withKey:@"name"];

				if (devname.length > logPaddingLength) logPaddingLength = devname.length;
			}
		}

		streamLogsItem.state = 1;
	}

	// Update the UI elements showing device names

	[squinterToolbar validateVisibleItems];
	[self refreshDevicesPopup];
	[self refreshDevicegroupMenu];
}



#pragma mark - File Location and Opening Methods


- (void)presentOpenFilePanel:(NSInteger)openActionType
{
	// Complete the open file dialog settings with generic preferences

	openDialog.canChooseFiles = YES;
	openDialog.canChooseDirectories = NO;
	openDialog.delegate = self;

	// Start off at the working directory

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
							 return;
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
			[alert beginSheetModalForWindow:_window
						  completionHandler:^(NSModalResponse response)
							 {
								 return;
							 }
			 ];

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
			[currentProject.devicegroups addObject:currentDevicegroup];
			currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];

			// This flag tracks the establishment of a newDeviceGroup, but it needs to be NO for now

			newDevicegroupFlag = NO;
		}

		// Process the added file(s)

		[self processAddedFiles:[NSMutableArray arrayWithArray:urls]];
	}
}



#pragma mark Open Squirrel Projects


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
	filePath = [url path];
	[urls removeObjectAtIndex:0];
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

			[self writeStringToLog:[NSString stringWithFormat:@"Converting an earlier Squirrel project file (%@) to a current one (%@)", aProject.version, kSquinterCurrentVersion] :YES];

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
			aProject.version = @"3.0";
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

						[self writeStringToLog:[NSString stringWithFormat:@"A Project called \"%@\" is already loaded so the new Project's filename, \"%@.squirrelproj\", will be used", aName, newName] :YES];
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

			[self writeStringToLog:[NSString stringWithFormat:@"Loading Project \"%@\" from file \"%@\".", currentProject.name, filePath] :YES];

			// Are the loaded and stored paths different?

			if ([oldPath compare:currentProject.path] != NSOrderedSame)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"Project file has moved from %@ to %@ since it was last opened.", oldPath, currentProject.path] :YES];
				projectMoved = YES;
				//currentProject.haschanged = YES;
			}

			// Add the opened project to the array of open projects

			[projectArray addObject:currentProject];

			// Is the project associated with a product? If so, select it

			if (currentProject.pid.length > 0 && productsArray.count > 0)
			{
				if ([currentProject.pid compare:@"old"] == NSOrderedSame)
				{
					// We have a converted project we probably need to upload becuase it won't
					// be associated with a product yet, and its device group (see above) won't
					// have an ID yet either

					if (ide.isLoggedIn)
					{
						[self writeStringToLog:[NSString stringWithFormat:@"Uploading project \"%@\" to the impCloud as a product...", currentProject.name] :YES];

						// Run the transfer as a standard upload, though we bypass uploadProject: at first

						NSDictionary *dict = @{ @"action" : @"uploadproject",
												@"project" : currentProject };

						[ide createProduct:currentProject.name :currentProject.description :dict];

						// Asynchronous pick up in 'createProductStageTwo:' but we continue here
					}
					else
					{
						// We're not logged in so warn the user
						// This is important so pop up an alert this time

						NSAlert *alert = [[NSAlert alloc] init];
						[alert addButtonWithTitle:@"OK"];
						[alert setMessageText:@"You are not logged in to your account."];
						[alert setInformativeText:[NSString stringWithFormat:@"You will need to upload project \"%@\" manually later, after you have logged in.", currentProject.name]];
						[alert setAlertStyle:NSWarningAlertStyle];
						[alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) { }];
					}
				}
				else
				{
					for (NSMenuItem *item in productsMenu.itemArray)
					{
						NSMutableDictionary *product = (NSMutableDictionary *)item.representedObject;
						NSString *pid = [self getValueFrom:product withKey:@"id"];

						if (pid != nil && [pid compare:currentProject.pid] == NSOrderedSame)
						{
							[self chooseProduct:item];
							break;
						}
					}
				}
			}

			// Update the Project menu’s 'openProjectsMenu' sub-menu by adding the project's name
			// (or 'newName' if we are using a temporary name because of a match)

			[self addProjectMenuItem:(newName != nil ? newName : currentProject.name) :currentProject];

			// Do we have any device groups in the project?

			if (currentProject.devicegroups.count > 0)
			{
				// Choose the first device group in the list

				currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
				currentProject.devicegroupIndex = 0;

				// Auto-compile all of the project's device groups, if required by the user

				if ([defaults boolForKey:@"com.bps.squinter.autocompile"])
				{
					[self writeStringToLog:@"Auto-compiling the Project's Device Groups. This can be disabled in Preferences." :YES];

					for (Devicegroup *dg in currentProject.devicegroups)
					{
						if (dg.models.count > 0) [self compile:dg :NO];

						// Duplicate the details of assigned devices in the device group

						[self setDevicegroupDevices:dg];
					}

					[self selectDevice];

					// Add the project's files to the watch list

					[self watchfiles:currentProject];
				}
				else
				{
					// We're not autocompiling the the project, so we just add the known files and libraries to the file-watch queue

					NSString *modelAbsPath, *modelRelPath, *fileRelPath, *fileAbsPath;
					BOOL result;

					for (Devicegroup *dg in currentProject.devicegroups)
					{
						// Add in the devices, if any

						[self setDevicegroupDevices:dg];

						if (dg.models.count > 0)
						{
							for (Model *md in dg.models)
							{
								// Get the model's expected location (this is relative to 'oldPath')

								modelRelPath = [NSString stringWithFormat:@"%@/%@", md.path, md.filename];

								NSRange range = [md.path rangeOfString:@"../"];

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
	NSLog(@"M: %@", modelAbsPath);
#endif
								// Check that the file is where we think it is

								result = [self checkFile:modelAbsPath];
								modelAbsPath = [modelAbsPath stringByDeletingLastPathComponent];

								if (!result)
								{
									// We can't locate the model file at the expected location, whether the project has moved or not

									[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Could not find source file \"%@\" at expected location %@.", md.filename, [self getPrintPath:currentProject.path :md.path]] :YES];

									[self writeStringToLog:[NSString stringWithFormat:@"Device Group \"%@\" cannot be compiled until this is resolved.", dg.name] :YES];

									md.hasMoved = YES;
								}
								else
								{
									// Update the model file location if the project has moved and we found the file using the old project path

									if (projectMoved)
									{
										if (range.location != NSNotFound)
										{
											// Model file is still above the project - ie. we found it at oldPath - so recalculate relative path

											md.path = [self getRelativeFilePath:currentProject.path :modelAbsPath];

											[self writeStringToLog:[NSString stringWithFormat:@"Updating saved source file \"%@\" path to %@ - source or project file has moved.", md.filename, [self getPrintPath:currentProject.path :md.path]] :YES];

											currentProject.haschanged = YES;
										}
									}

									// Now check the subsidiary files
									// NOTE These are just the known locations - they may not reflect what is actually
									// in the file, which is which is why we compile on load as the default

									if (md.libraries.count > 0)
									{
										for (File *fl in md.libraries)
										{
											// Get the path of the file, which is relative to 'oldPath'

											fileRelPath = [NSString stringWithFormat:@"%@/%@", fl.path, fl.filename];

											NSRange range = [fl.path rangeOfString:@"../"];

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
	NSLog(@"R: %@-%@", fl.path, fl.filename);
	NSLog(@"A: %@", fileAbsPath);
#endif

											result = [self checkFile:fileAbsPath];
											fileAbsPath = [fileAbsPath stringByDeletingLastPathComponent];

											if (!result)
											{
												[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Could not find library \"%@\" at expected location %@ - source or project file has moved.", fl.filename, [self getPrintPath:currentProject.path :fl.path]] :YES];

												[self writeStringToLog:[NSString stringWithFormat:@"Device Group \"%@\" cannot be compiled until this is resolved.", dg.name] :YES];

												fl.hasMoved = YES;
											}
											else
											{
												if (projectMoved)
												{
													if (range.location != NSNotFound)
													{
														// File is still above the project - ie. we found it at oldPath - so recalculate relative path

														fl.path = [self getRelativeFilePath:currentProject.path :fileAbsPath];

														[self writeStringToLog:[NSString stringWithFormat:@"Updating stored library \"%@/%@\" - source or project file has has moved.", [self getPrintPath:currentProject.path :fl.path], fl.filename] :YES];

														currentProject.haschanged = YES;

#ifdef DEBUG
	NSLog(@"N: %@", fl.path);
#endif

													}
												}
											}
										}
									}

									if (md.files.count > 0)
									{
										for (File *fl in md.files)
										{
											fileRelPath = [NSString stringWithFormat:@"%@/%@", fl.path, fl.filename];

											NSRange range = [fl.path rangeOfString:@"../"];

											if (range.location != NSNotFound)
											{
												fileAbsPath = [self getAbsolutePath:oldPath :fileRelPath];
											}
											else
											{
												fileAbsPath = [self getAbsolutePath:currentProject.path :fileRelPath];
											}

#ifdef DEBUG
	NSLog(@"R: %@-%@", fl.path, fl.filename);
	NSLog(@"A: %@", fileAbsPath);
#endif

											result = [self checkFile:fileAbsPath];
											fileAbsPath = [fileAbsPath stringByDeletingLastPathComponent];

											if (!result)
											{
												[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Could not find file \"%@\" at expected location %@ - file or project has moved.", fl.filename, [self getPrintPath:currentProject.path :fl.path]] :YES];

												[self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" cannot be compiled until this is resolved.", dg.name] :YES];

												fl.hasMoved = YES;
											}
											else
											{
												if (projectMoved)
												{
													if (range.location != NSNotFound)
													{
														// File is still above the project - ie. we found it at oldPath - so recalculate relative path

														fl.path = [self getRelativeFilePath:currentProject.path :fileAbsPath];

														[self writeStringToLog:[NSString stringWithFormat:@"Updating stored library \"%@/%@\" - source or project file has moved.", [self getPrintPath:currentProject.path :fl.path], fl.filename] :YES];

														currentProject.haschanged = YES;

#ifdef DEBUG
	NSLog(@"N: %@", fl.path);
#endif
													}
												}
											}
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
			}

			// Update the Menus and the Toolbar

			[self refreshOpenProjectsMenu];
			[self refreshProjectsMenu];
			[self refreshDevicegroupMenu];
			[self refreshMainDevicegroupsMenu];
			[self refreshDeviceMenu];
			[self setToolbar];

			// Set the status light - light is YES to be not greyed out; full is YES (solid) or NO (empty)

			[saveLight show];
			[saveLight needSave:currentProject.haschanged];
			[_window setDocumentEdited:currentProject.haschanged];

			// Add the newly opened project to the recent files list
			
			[self addToRecentMenu:currentProject.filename :currentProject.path];
		}
	}
	else
	{
		// Project didn't load for some reason so warn the user
		
		[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Could not load project file \"%@\".", fileName] :YES];
	}

	// Call the method again in case there are any URLs left to deal with

	[self openSquirrelProjects:urls];
}



- (void)watchfiles:(Project *)project
{
	// Work throgh project's files and add them to the queue

	if (fileWatchQueue == nil)
	{
		fileWatchQueue = [[VDKQueue alloc] init];
		[fileWatchQueue setDelegate:self];
	}

	NSString *aPath = [NSString stringWithFormat:@"%@/%@", project.path, project.filename];
	BOOL added = [self checkFile:aPath];

	if (project.devicegroups.count > 0)
	{
		for (Devicegroup *dg in project.devicegroups)
		{
			if (dg.models.count > 0)
			{
				for (Model *md in dg.models)
				{
					aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", md.path, md.filename]];
					added = [self checkFile:aPath];

					if (md.libraries.count > 0)
					{
						for (File *lib in md.libraries)
						{
							aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", lib.path, lib.filename]];
							added = [self checkFile:aPath];
						}
					}

					if (md.files.count > 0)
					{
						for (File *file in md.files)
						{
							aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", file.path, file.filename]];
							added = [self checkFile:aPath];
						}
					}
				}
			}
		}
	}

	if (!added) NSLog(@"Some files couldn't be added");
}


- (BOOL)checkProjectPaths:(Project *)byProject :(NSString *)orProjectPath
{
	// Method runs through the list of open projects and returns YES if the
	// passed project's full path matches one of them, otherwise NO

	if (projectArray.count > 0)
	{
		for (Project *aProject in projectArray)
		{
			NSString *aName = aProject.filename;
			NSString *aPath = aProject.path;
			aPath = [NSString stringWithFormat:@"%@/%@", aPath, aName];

			if (orProjectPath != nil && [orProjectPath compare:aPath] == NSOrderedSame) return YES;

			if (byProject != nil)
			{
				NSString *bName = byProject.filename;
				NSString *bPath = byProject.path;
				bPath = [NSString stringWithFormat:@"%@/%@", bPath, bName];

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



- (BOOL)checkDevicegroupNames:(Devicegroup *)byDevicegroup :(NSString *)orName
{
	if (currentProject.devicegroups.count > 0)
	{
		for (Devicegroup *adg in currentProject.devicegroups)
		{
			if (byDevicegroup != nil && orName == nil)
			{
				// Caller has passed just a project

				if ([byDevicegroup.name compare:adg.name] == NSOrderedSame) return YES;
			}
			else if (byDevicegroup == nil && orName != nil)
			{
				// Caller has passed just a name string

				if ([orName compare:adg.name] == NSOrderedSame) return YES;
			}
			else
			{
				// Caller has passed a project AND a name, that if the name matches
				// on projects that are NOT the passed one

				if ([orName compare:adg.name] == NSOrderedSame && byDevicegroup != adg) return YES;
			}
		}
	}
	
	return NO;
}



- (BOOL)checkFile:(NSString *)filePath
{
	// This method takes an ABSOLUTE file path and checks first that the file exists at that path
	// If if doesn't, it returns NO, otherwise it attempts to add the file to the watch queue, in
	// which case it returns YES

	BOOL result = [nsfm fileExistsAtPath:filePath];

	if (result)
	{
		[fileWatchQueue addPath:filePath
				 notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
	}

	return result;
}



#pragma mark Add files to Device Groups


- (IBAction)selectFile:(id)sender
{
	// Called by 'Add Files to Device Group...' File menu item
	// If no current project is selected, warn and bail - but we shouldn't
	// do this because the menu will be disabled on 'currentProject' = nil

	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
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
		accessoryViewNewProjectCheckbox.title = [NSString stringWithFormat:@"Create a new Device Group with the file(s) – or uncheck to add the file(s) to Group \"%@\"", currentDevicegroup.name];
	}
	else
	{
		accessoryViewNewProjectCheckbox.state = NSOnState;
		accessoryViewNewProjectCheckbox.title = @"Create a new Device Group with the file(s)";
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
		alert.messageText = @"You have no Device Group selected. To add files, you must create a new Device Group for the added files";
		alert.informativeText = @"Alternatively, cancel the 'add files' process and create a new Device Group separately.";
		[alert beginSheetModalForWindow:openDialog
					  completionHandler:^(NSModalResponse response)
						{
							accessoryViewNewProjectCheckbox.state = NSOnState;
						}
		 ];
	}
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
			[saveLight needSave:YES];
			[_window setDocumentEdited:YES];
		}

		// Compile added files if required

		if ([defaults boolForKey:@"com.bps.squinter.autocompile"]) [self compile:currentDevicegroup :NO];

		// Update the UI

		[self refreshOpenProjectsMenu];
		[self refreshDevicegroupMenu];
		[self refreshMainDevicegroupsMenu];
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

		[_window beginSheet:sourceTypeSheet completionHandler:nil];
	}
	else
	{
		// Move on to the next stage of file processing

		[self processAddedFilesStageTwo:urls :fileType];
	}
}



- (IBAction)endSourceTypeSheet:(id)sender
{
	// Triggered by clicking 'Agent Code' or 'Device Code' in the 'sourceTypeSheet' dialog

	NSString *type = (sender == sourceTypeDeviceButton) ? @"device" : @"agent";

	[_window endSheet:sourceTypeSheet];
	[self processAddedFilesStageTwo:saveUrls :type];

	saveUrls = nil;
}



- (IBAction)cancelSourceTypeSheet:(id)sender
{
	// User has cancelled
	// TODO - Just this file or all of them?

	[_window endSheet:sourceTypeSheet];

	// Remove the current file and process the next

	[saveUrls removeObjectAtIndex:0];
	[self processAddedFiles:saveUrls];

	saveUrls = nil;
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
					alert.messageText = [NSString stringWithFormat:@"Device Group \"%@\" already has %@ code. Do you wish to replace it?", currentDevicegroup.name, fileType];
					[alert addButtonWithTitle:@"Yes"];
					[alert addButtonWithTitle:@"No"];
					[alert beginSheetModalForWindow:_window
								  completionHandler:^(NSModalResponse response)
									 {
										 if (response == NSAlertFirstButtonReturn)
										 {
											 // User wants to replace the existing code file

											 model.filename = [filePath lastPathComponent];
											 model.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];
											 currentProject.haschanged = YES;
											 [saveLight needSave:YES];
											 [_window setDocumentEdited:YES];
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
	}

	// Having added the first file on the current list, we remove it from the list
	// then re-call the method to proces the next file on the list

	[urls removeObjectAtIndex:0];
	[self processAddedFiles:urls];
}



#pragma mark - Save Project Methods



- (void)savePrep:(NSURL *)saveDirectory :(NSString *)newFileName
{
	// Save the savingProject project. This may be a newly created project and may not currentProject

	BOOL success = NO;
	BOOL nameChange = NO;
	NSString *savePath = [saveDirectory path];

	if (newFileName == nil)
	{
		// No filename passed in, so we have come from 'saveProject:'

		if (savingProject.filename != nil)
		{
			// We have an existing filename - use it

			newFileName = savingProject.filename;
		}
		else
		{
			// We have no saved filename and no passed in filename, so create one

			newFileName = [savingProject.name stringByAppendingString:@".squirrelproj"];
			nameChange = YES;
		}
	}
	else
	{
		// We have come from 'saveProjectAs:'

		// First add '.squirrelproj' to the file name if it has been removed

		NSRange r = [newFileName rangeOfString:@".squirrelproj"];

		if (r.location == NSNotFound) newFileName = [newFileName stringByAppendingString:@".squirrelproj"];

		if (savingProject.filename != nil)
		{
			// We have an existing filename - is the new one different?

			if ([savingProject.filename compare:newFileName] != NSOrderedSame) nameChange = YES;
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

		savingProject.path = [savePath stringByDeletingLastPathComponent];
		savingProject.filename = newFileName;
		savingProject.haschanged = NO;

		if (savingProject == currentProject)
		{
			// The saved project is the one on view in the UI, so update the save indicator

			[saveLight needSave:NO];
			[_window setDocumentEdited:NO];

			// Add the project to the list
			// Don't need to do this is just saving, only save as...

			if (saveAsFlag) [self addToRecentMenu:savingProject.filename :savingProject.path];

			saveAsFlag = NO;
		}

		[self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" saved at %@.", savingProject.name, [savePath stringByDeletingLastPathComponent]] :YES];
	}
	else
	{
		[self writeErrorToLog:@"[ERROR] The Project could not be saved." :YES];
	}

	// Saved the project, but are there models to save, from a 'download product' operation?

	Project *sp = nil;

	for (Project *ap in downloads)
	{
		if (ap == savingProject) sp = ap;
	}

	// Done saving so clear 'savingProject'

	savingProject = nil;

	// Did we come here from a 'close project'? If so, re-run to actually close the project

	if (closeProjectFlag) [self closeProject:nil];

	// Save the model files if we have any

	if (sp != nil) [self saveModelFiles:sp];
}



- (IBAction)saveProjectAs:(id)sender
{
    // This method can be called by menu, to save the current project,
	// or directly if 'savingProject' is pre-set

	if (sender == fileSaveAsMenuItem || sender == fileSaveMenuItem) savingProject = currentProject;

	if (savingProject == nil)
	{
		// Just in case...

		[self writeWarningToLog:@"[WARNING] You have not selected a Project to save." :YES];
		return;
	}

	if (savingProject == currentProject) saveAsFlag = YES;

	// Configure the NSSavePanel.

	saveProjectDialog = [NSSavePanel savePanel];
	[saveProjectDialog setNameFieldStringValue:savingProject.filename];
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
	[saveProjectDialog makeKeyWindow];
}



- (IBAction)saveProject:(id)sender
{
    // Call this method to save the current project by overwriting the previous version
    
	// This method should only be called by menu, to save the current project, which is added to the save list

	if (sender == fileSaveMenuItem) savingProject = currentProject;

	if (savingProject == nil)
	{
		[self writeWarningToLog:@"[WARNING] You have not selected a Project to save." :YES];
		return;
	}

	// Do we need to save? If there have been no changes, then no

	if (!savingProject.haschanged) return;

	if (savingProject.path == nil)
    {
        // Current project has no saved path (ie. it hasn't yet been saved or opened)
        // so force a Save As...
        
		[self saveProjectAs:sender];
        return;
    }
    
    // Handle the save. Note 'path' does not include the filename (we add it in savePrep:)

	[self savePrep:[NSURL fileURLWithPath:savingProject.path] :nil];
}




- (IBAction)cancelChanges:(id)sender
{
	// The user doesn't care about the changes so close the sheet then tell the system to shut down the app

	[_window endSheet:saveChangesSheet];

	if (!closeProjectFlag)
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

	if (!closeProjectFlag)
	{
		[NSApp replyToApplicationShouldTerminate:YES];
	}
	else
	{
		closeProjectFlag = NO;
		currentProject.haschanged = NO;
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

		if (aProject.haschanged)
		{
			currentProject = aProject;
			[self saveProject:fileSaveMenuItem];
		}
	}

	// Projects saved (or not), we can now tell the app to quit

	[NSApp replyToApplicationShouldTerminate:YES];
}



- (void)saveModelFiles:(Project *)project
{
	// Save all the model files from a downloaded product

	[downloads removeObject:project];

	NSMutableArray *files = [[NSMutableArray alloc] init];

	if (project.devicegroups.count > 0)
	{
		for (Devicegroup *dg in project.devicegroups)
		{
			if (dg.models.count > 0)
			{
				for (Model *model in dg.models)
				{
					// NOTE we save a model file even if it contains no code - the user may add code later
					
					model.path = project.path;
					model.filename = [dg.name stringByAppendingFormat:@".%@.nut", model.type];

					[files addObject:model];
				}
			}
		}
	}

	if (files.count > 0) [self saveFiles:files];

	// Load in the project

	[projectArray addObject:project];
	currentProject = project;

	// Update the UI

	[saveLight show];
	[saveLight needSave:NO];
	[_window setDocumentEdited:NO];

	[self refreshOpenProjectsMenu];
	[self refreshProjectsMenu];
	[self refreshDevicegroupMenu];
	[self refreshMainDevicegroupsMenu];

	// We now need to re-save the project file, which now contains the locations
	// of the various model files. We do this programmatically rather than indicate
	// to the user that they need to (re)save the project

	currentProject.haschanged = YES;
	savingProject = currentProject;

	[self saveProject:nil];
}

//<- String editing 

- (void)saveFiles:(NSMutableArray *)files
{
	if (files.count == 0) return;

	BOOL success = NO;
	Model *file = [files firstObject];
	NSData *data = [file.code dataUsingEncoding:NSUTF8StringEncoding];
	NSString *path = [file.path stringByAppendingFormat:@"/%@", file.filename];

	if ([nsfm fileExistsAtPath:path])
	{
		path = [path stringByAppendingString:@".new"];
		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" exists in chosen location - renaming file \"%@.new\".", file.filename, file.filename] :YES];
	}

	success = [nsfm createFileAtPath:path contents:data attributes:nil];

	if (success)
	{
		file.filename = [path lastPathComponent];
		file.path = [self getRelativeFilePath:file.path :[path stringByDeletingLastPathComponent]];
	}

	[files removeObjectAtIndex:0];
	[self saveFiles:files];
}



#pragma mark - Squint Methods


- (IBAction)squint:(id)sender
{
    // This method is a hangover from a previous version. 
	// Now it simply calls the version which replaces it.
	
	[self compile:currentDevicegroup :NO];
}



- (void)compile:(Devicegroup *)devicegroup :(BOOL)justACheck
{
    // Compile runs through a device group's two prime source code files - agent and device - and (via subsidiary methods)
    // looks for #require, #import and #include directives. For the last two of these, it updates the project's
    // lists of recorded libraries and files, and compiles the code into an upload-ready form

    // If we have no currently selected device group, bail

    if (devicegroup == nil)
    {
        [self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

	Project *thisProject;
	BOOL agentDoneFlag = NO;
	BOOL deviceDoneFlag = NO;
	NSString *output, *aPath;
	NSUInteger squinted = 0;

	[self writeStringToLog:[NSString stringWithFormat:@"Processing device group \"%@\"...", devicegroup.name] :YES];

	if (devicegroup.models.count == 0 || devicegroup.models == nil)
	{
		// This device group has no software - warn the user and bail

		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device group \"%@\" has no source code files - there is nothing to compile.", devicegroup.name] :YES];
		return;
	}

	// Get the model's parent project

	for (Project *project in projectArray)
	{
		NSMutableArray *dgs = project.devicegroups;

		for (Devicegroup *dg in dgs)
		{
			if (dg == devicegroup)
			{
				thisProject = project;
				break;
			}
		}
	}

	// Process each of the device group's models in turn

	for (Model *model in devicegroup.models)
	{
		// Clear the lists of local libraries and files found in the model
		// 'foundLibs' - all the libraries #imported or #included in the source files, each stored as a File
		// 'foundFiles' - all the non-libraries #imported or #included in the source files, each stored as a File
		// 'foundEILibs' - all the EI libraries #required in the source files, each stored as a File, with the path set to the version

		if (foundFiles != nil) foundFiles = nil;
		if (foundLibs != nil) foundLibs = nil;
		if (foundEILibs != nil) foundEILibs = nil;

		foundFiles = [[NSMutableArray alloc] init];
		foundLibs = [[NSMutableArray alloc] init];
		foundEILibs = [[NSMutableArray alloc] init];

		output = nil;
		
		NSInteger typeValue = ([model.type compare:@"agent"] == NSOrderedSame) ? kCodeTypeAgent : kCodeTypeDevice;

		// Get the source code full file path - model paths should be relative to the project

		aPath = [NSString stringWithFormat:@"%@/%@", model.path, model.filename];
		aPath = [self getAbsolutePath:thisProject.path :aPath];

		if (aPath != nil)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"Processing %@ code file: \"%@\"...", model.type, aPath.lastPathComponent] :YES];

			output = [self processSource:aPath :typeValue :thisProject.path :model :!justACheck];

			if (output == nil && !justACheck)
			{
				// This is a compile action, so we treat 'output == nil' as a failure

				[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Compilation halted: cannot continue due to errors in %@ code", model.type] :YES];
				model.squinted = NO;
				return;
			}

			if (!justACheck)
			{
				// We are not just checking the code for libraries and includes, so
				// save the compiled code into the model and set the compiled flags

				model.code = output;
				model.squinted = YES;

				if (typeValue == kCodeTypeAgent)
				{
					agentDoneFlag = YES;
					squinted = (squinted | 0x02);
				}

				if (typeValue == kCodeTypeDevice)
				{
					deviceDoneFlag = YES;
					squinted = (squinted | 0x01);
				}
			}

			// Wrangle the libraries and files found in this compilation

			[self processLibraries:model];
		}
	}

	if (!justACheck)
	{
		// We are not just checking the code for libraries and includes,
		// so update the UI as required

		if (agentDoneFlag || deviceDoneFlag)
		{
			// Activate compilation-related UI items
			
			externalOpenMenuItem.enabled = agentDoneFlag;
			externalOpenDeviceItem.enabled = deviceDoneFlag;
			externalOpenBothItem.enabled = YES;
			logDeviceCodeMenuItem.enabled = deviceDoneFlag;
			logAgentCodeMenuItem.enabled = agentDoneFlag;
		}
			
		// Update project's compilation status record, 'devicegroup.squinted'
		// NOTE this clears bit 4, ie. the uploaded marker is set to 'not uploaded'
		
		NSString *resultString = @"";
		
		switch(squinted)
		{
			case 0:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" has no code to compile and upload.", devicegroup.name];
				break;

			case 1:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - no agent code; device code ready to upload.", devicegroup.name];
				break;

			case 2:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - no device code; agent code ready to upload.", devicegroup.name];
				break;

			case 3:
				resultString = [NSString stringWithFormat:@"Device group \"%@\" source compiled - agent and device code ready to upload.", devicegroup.name];
		}

		[self writeStringToLog:resultString :YES];
		devicegroup.squinted = squinted;
	}
	
	// Update libraries menu with updated list of local, EI libraries and local files

	[self refreshMainDevicegroupsMenu];
	[self refreshLibraryMenus];
	[self refreshFilesMenu];
	[self setToolbar];
	[saveLight needSave:thisProject.haschanged];
	[_window setDocumentEdited:thisProject.haschanged];
}



- (NSString *)processSource:(NSString *)codePath :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode
{
	// Loads the contents of the source code file referenced by 'codePath' - 'codeType' indicates whether the code
	// is agent or device - and parses it for multi-line comment blocks. Only code outside these blocks is passed
	// on for further processing, ie. parsing for #require, #include or #import directives.

	// 'willReturnCode' is set to YES if we want compiled code back; if we are only parsing the code for a list
	// of included files and libraries, we can pass in NO.

	// We return nil if there is a compilation error, otherwise the processed code

	NSRange commentStartRange, commentEndRange;
	NSString *compiledCode = @"";

	// Attempt to load in the source text file's contents

	NSError *error;
	NSString *sourceCode = [NSString stringWithContentsOfFile:codePath encoding:NSUTF8StringEncoding error:&error];

	if (error)
	{
		[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Unable to load source file \"%@\" - aborting compile.", codePath] :YES];
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

			NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :projectPath :model :willReturnCode];

			// 'processedCode' returns nil for an error, 'none' for no #imports or checks, and processed code otherwise

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			// Check for #includes

			processedCode = [self processImports:codeToProcess :@"#include" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
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

			NSString *processedCode = [self processImports:codeToProcess :@"#import" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			processedCode = [self processImports:codeToProcess :@"#include" :codeType :projectPath :model :willReturnCode];

			if (processedCode != nil)
			{
				if (([processedCode compare:@"none"] != NSOrderedSame) && willReturnCode)
				{
					// If we are compiling code (ie. 'willReturnCode' is YES), then
					// use the compiled code for the next stage of processing.

					codeToProcess = processedCode;
				}
			}
			else
			{
				// Compilation error: missing file or somesuch, so bail

				if (willReturnCode) return nil;
			}

			compiledCode = [compiledCode stringByAppendingString:codeToProcess];
			done = YES;
		}
	}

	// Code has been processed: any libraries and linked files that have been found are now stored
	// If we have asked to receive compiled code, return it now, or return nil

	if (willReturnCode) return compiledCode;

	return nil;
}



- (NSString *)processImports:(NSString *)sourceCode :(NSString *)searchString :(NSUInteger)codeType :(NSString *)projectPath :(Model *)model :(BOOL)willReturnCode 
{
	// Parses the passed in 'sourceCode' for occurences of 'searchString' - either "#import" or "#include".
	// The value of 'codeType' indicates whether the source is agent or device code.
	// The value of 'willReturnCode' indicates whether the method should returne compiled code or not. If it is
	// being used to gather a list of #included libraries and files, 'willReturnCode' will be NO.

	// NOTE 'projectPath' should be an absolute path to the source file

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
			NSString *libPath, *libCode, *libName, *libVer;

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

				// We have a library or file name and path. Now we need to parse the path:
				// is it absolute (/Users/smitty/GitHub/Project/file.class.nut)
				// relative to home (~/GitHub/Project/file.class.nut)
				// or relative to the source file (../aProject/file.class.nut)

				// First, look for path indicators in libName, ie. /

				commentRange = [libName rangeOfString:@"/" options:NSLiteralSearch];

				if (commentRange.location != NSNotFound)
				{
					// Found at least one / so there must be directory info here,
					// even if it's just ~/lib.class.nut

					// Get the path component from the source file's library name info

					libPath = [libName stringByDeletingLastPathComponent];
					libPath = [libPath stringByStandardizingPath];

					// Check for a relative path, ie. at least one ../

					commentRange = [libName rangeOfString:@"../" options:NSLiteralSearch];

					if (commentRange.location != NSNotFound)
					{
						// If we have a relative path, process it with 'getAbsolutePath:',
						// otherwise assume we have an absolute path and leave it unchanged

						libPath = [self getAbsolutePath:projectPath :libPath];
					}

					// Get the actual library name

					libName = [libName lastPathComponent];
				}
				else
				{
					// Didn't find any / characters so we can assume we just have a file name
					// eg. 'lib.class.nut'. Assume the file is in the same folder as the source file
					// (which is passed in, so can be the project path or the source path, despite the name)

					libPath = projectPath;
				}

#ifdef DEBUG
    NSLog(@"%@", libName);
    NSLog(@"%@", libPath);
#endif

				// At this point, 'libName' should be of the form 'lib.class.nut', and
				// 'libPath' should be the absolute path

				// Assume library or file will be added to the project

				BOOL addToCodeFlag = YES;
				BOOL addToModelFlag = YES;
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
					// Library or file is not in the named directory, so try the source directory

					libCode = [NSString stringWithContentsOfFile:[projectPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

					if (libCode == nil)
					{
						// Library or file is not in the named directory, so try the working directory
						// Note: this is repeated test if the project is in the working directory

						libCode = [NSString stringWithContentsOfFile:[workingDirectory stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

						if (libCode == nil)
						{
							// Library or file is not in the working directory, try the saved directory, if we have one

							NSString *savedPath = nil;

							if (isLibraryFlag)
							{
								for (File *lib in model.libraries)
								{
									if (([lib.filename compare:libName] == NSOrderedSame) && ([lib.type compare:@"library"] == NSOrderedSame)) savedPath = lib.path;
								}
							}
							else
							{
								for (File *file in model.files)
								{
									if (([file.filename compare:libName] == NSOrderedSame) && ([file.type compare:@"file"] == NSOrderedSame)) savedPath = file.path;
								}
							}

							if (savedPath != nil)
							{
								// We have a saved path for this file, so try it - remember it's relative

								savedPath = [self getAbsolutePath:projectPath :savedPath];

								libCode = [NSString stringWithContentsOfFile:[savedPath stringByAppendingFormat:@"/%@", libName] encoding:NSUTF8StringEncoding error:&error];

								if (libCode == nil)
								{
									// The library in not in the working directory or in its saved location, so bail if we are compiling
									// We can't really continue the compilation, but we can look for other libraries if that's all we're doing

									if (isLibraryFlag)
									{
										if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
										[deadLibs addObject:libName];
									}
									else
									{
										if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
										[deadFiles addObject:libName];
									}

									addToCodeFlag = NO;
									addToModelFlag = NO;

									// If we're compiling, bail

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
									if (deadLibs == nil) deadLibs = [[NSMutableArray alloc] init];
									[deadLibs addObject:libName];
								}
								else
								{
									if (deadFiles == nil) deadFiles = [[NSMutableArray alloc] init];
									[deadFiles addObject:libName];
								}

								addToCodeFlag = NO;
								addToModelFlag = NO;

								// If we are compiling, however, bail

								if (willReturnCode) done = YES;
							}
						}
						else
						{
							// The library is in the working directory, so use that as its path

							libPath = workingDirectory;
						}
					}
					else
					{
						// The library is in the source directory, so use that as its path

						libPath = projectPath;
					}
				}

				libVer = [self getLibraryVersionNumber:libCode];

				BOOL match = NO;

				if (addToModelFlag)
				{
					// 'addToProjectFlag' defaults to YES, ie. if we find a library we want to
					// add it to the model. It becomes NO if a located library can't be found
					// in the file system, ie. we *can't* add it to the model

					if (isLibraryFlag)
					{
						// Item is a library or class
						// Check we haven't found it already

						if (foundLibs.count > 0)
						{
							for (File *alib in foundLibs)
							{
								if ([alib.filename compare:libName] == NSOrderedSame)
								{
									// We have match, but the library may have been included in the agent
									// code and we are now looking at the device code (agent always comes first)
									// so check this before setting 'match'

									if (codeType == kCodeTypeAgent)
									{
										if ([model.type compare:@"agent"] == NSOrderedSame)
										{
											match = YES;
										}
										else
										{
											// Library matches with a library found in a different file,
											// ie. no need to add it to the found list again BUT we DO want
											// to compile it in

											addToModelFlag = NO;
										}
									}
									else
									{
										if ([model.type compare:@"device"] == NSOrderedSame)
										{
											match = YES;
										}
										else
										{
											addToModelFlag = NO;
										}
									}
								}
							}
						}

						if (!match && addToModelFlag)
						{
							// NOTE file path at this point is still absolute - we deal with that in 'processLibraries:'

							File *newLib = [[File alloc] init];
							newLib.type = @"library";
							newLib.filename = libName;
							newLib.path = libPath;
							newLib.version = libVer;

							[foundLibs addObject:newLib];
							[self writeStringToLog:[NSString stringWithFormat:@"Local library \"%@\" found in source.", libName] :YES];
						}
					}
					else
					{
						// File name lacks neither a library or class tagging so assume it's a general file
						// Check we haven't found it already

						if (foundFiles.count > 0)
						{
							for (File *file in foundFiles)
							{
								if ([file.filename compare:libName] == NSOrderedSame) match = YES;
							}
						}

						if (!match && addToModelFlag)
						{
							// NOTE file path at this point is still absolute - we deal with that in 'processLibraries:'

							File *newFile = [[File alloc] init];
							newFile.type = @"file";
							newFile.filename = libName;
							newFile.path = libPath;

							[foundFiles addObject:newFile];
							[self writeStringToLog:[NSString stringWithFormat:@"Local file \"%@\" found in source.", libName] :YES];
						}
					}
				}

				// Compile in the code if this is required (it may not be if we're just scanning for libraries and files

				if (addToCodeFlag)
				{
					// 'addToCodeFlag' defaults to YES - we assume that if we have found a library in the
					// source code, that we want to add it to the return code. It is set to NO of the library
					// *can't* be located in the file system. NOTE 'libCode' should be valid in this case

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

	if (!found) return @"none";

	// If any libraries / files can't be located, these are listed in 'deadLibs' / 'deadFiles'

	if (deadLibs.count > 0)
	{
		NSString *mString = nil;

		if (deadLibs.count == 1)
		{
			mString = [NSString stringWithFormat:@"1 local library, \"%@\", can’t be located in the file system.", [deadLibs firstObject]];
		}
		else
		{
			NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadLibs.count ; ++i)
			{
				dString = [dString stringByAppendingFormat:@"%@, ", [deadLibs objectAtIndex:i]];
			}

			dString = [dString substringToIndex:dString.length - 2];
			mString = [NSString stringWithFormat:@"%li local libraries - %@ - can’t be located in the file system.", deadLibs.count, dString];
		}

		[self writeErrorToLog:mString :YES];

		NSString *tString = ((codeType == kCodeTypeDevice) ? @"You should check the library locations specified in your device code." : @"You should check the library locations specified in your agent code.");
		[self writeStringToLog:tString :YES];

		// If we're compiling rather than just checking code, bail and indicate an error condition

		if (returnCode) return nil;
	}

	if (deadFiles.count > 0)
	{
		NSString *mString = nil;

		if (deadFiles.count == 1)
		{
			mString = [NSString stringWithFormat:@"1 local file, \"%@\", can’t be located in the file system.", [deadFiles firstObject]];
		}
		else
		{
			NSString *dString = @"";

			for (NSUInteger i = 0 ; i < deadFiles.count ; ++i)
			{
				dString = [dString stringByAppendingFormat:@"%@, ", [deadFiles objectAtIndex:i]];
			}

			dString = [dString substringToIndex:dString.length - 2];
			mString = [NSString stringWithFormat:@"%li local files - %@ - can’t be located in the file system.", deadLibs.count, dString];
		}

		[self writeStringToLog:mString :YES];
		[self writeStringToLog:@"You should check the file locations specified in your source code." :YES];

		if (returnCode) return nil;
	}

	// At this point, 'foundlibs' contains zero or more local libraries and 'foundFiles' contains zero or more local files
	// 'deadLibs' and 'deadFiles' will be empty - ie. there are no libraries and files included that could not be located

	if (willReturnCode == YES) return returnCode;

	return @"none";
}



- (void)processRequires:(NSString *)sourceCode
{
	// Parses the passed in 'sourceCode' for #require directives. If any are found,
	// their names and version numbers are stored in 'foundEILibs' for later processing

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

				// Add the library to the project - name and version (as string)

				File *newLib = [[File alloc] init];
				newLib.filename = elements.count > 0 ? [elements objectAtIndex:0] : nil;
				newLib.version = elements.count > 1 ? [elements objectAtIndex:1] : nil;
				newLib.type = @"eilib";

				if (newLib.filename != nil)
				{
					// Only manage the library if we've found one
					// NOTE is this belts and braces?

					// Add a warning if the library has no version value

					if (newLib.version == nil || newLib.version.length == 0)
					{
						// EI Library has no version number - which will compile here, but not in the impCloud

						[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Electric Imp Library \"%@\" included in source but has no version. Code will compile here but may be rejected by the impCloud.", newLib.filename] :YES];

						[self writeWarningToLog:@"          You should check Electric Imp Library versions to determine the latest version number." :YES];

						newLib.version = @"not set";
					}
					else
					{
						// Log and record the found library's name

						[self writeStringToLog:[NSString stringWithFormat:@"Electric Imp Library \"%@\" version %@ included in source.", newLib.filename, newLib.version] :YES];
					}

					if (foundEILibs.count == 0)
					{
						// Use the File object, just set the .path to the EI library version

						[foundEILibs addObject:newLib];
					}
					else
					{
						BOOL match = NO;

						for (File *aLib in foundEILibs)
						{
							// See if the library is already listed

							if (([aLib.filename compare:[elements objectAtIndex:0]] == NSOrderedSame) && ([aLib.path compare:[elements objectAtIndex:1]] == NSOrderedSame)) match = YES;
						}

						if (!match) [foundEILibs addObject:newLib];
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



- (void)processLibraries:(Model *)model
{
	// This method wrangles the collection of current libraries found in the source code files
	// It looks for Electric Imp links and for local files and libraries

	// Get the model's parent project

	Project *thisProject;
	//Devicegroup *thisDevicegroup;

	for (Project *project in projectArray)
	{
		if (project.devicegroups.count > 0)
		{
			for (Devicegroup *dg in project.devicegroups)
			{
				NSMutableArray *ms = dg.models;

				for (Model *m in ms)
				{
					if (m == model)
					{
						thisProject = project;
						//thisDevicegroup = dg;
						break;
					}
				}
			}
		}
	}

	if (thisProject == nil)
	{
		// WHOOPS

		NSLog(@"Found orphan model in processLibraries:");
		return;
	}

	// PROCESS EI LIBRARIES

	// Do we have any Electric Imp libraries #required in the source code?

	if (foundEILibs.count > 0 && model.impLibraries == nil) model.impLibraries = [[NSMutableArray alloc] init];

	NSMutableArray *iLibs = model.impLibraries;

	if (foundEILibs.count == 0)
	{
		// There are no EI libraries in the current code - though there may have been some included before

		if (iLibs.count > 0)
		{
			if (iLibs.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 Electric Imp library no longer included in this %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li Electric Imp libraries no longer included in this %@ code.", (long)iLibs.count, model.type] :YES];
			}

			[iLibs removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No Electric Imp libraries included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		// First, run through the contents of 'foundEILibs' to see if there is a 1:1 match with
		// the lists of known local librariess; if not, mark that the project has changed

		if (iLibs.count > 0)
		{
			for (File *aLib in foundEILibs)
			{
				NSString *match = nil;

				// Does the library name match an existing one?

				for (File *lib in iLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame)
					{
						// If there is a match, set the value of 'match' to the found library version

						match = lib.path;
					}
				}

				if (match == nil)
				{
					// There's a library here that is not in the original list

					++added;
				}
				else
				{
					// The found library does match, but we should check if its version has changed

					if ([match compare:aLib.path] != NSOrderedSame)
					{
						// Names match but the versions don't

						[self writeStringToLog:[NSString stringWithFormat:@"Electric Imp library \"%@\" has been changed from version \"%@\" to \"%@\".", aLib.filename, match, aLib.path] :YES];
					}
				}
			}

			for (File *lib in iLibs)
			{
				BOOL match = NO;

				for (File *aLib in foundEILibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match)
				{
					// There is a saved library that's no longer present

					++removed;
				}
			}
		}
		else
		{
			added = foundEILibs.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No Electric Imp libraries added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 Electric Imp library added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li Electric Imp libraries added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 Electric Imp library removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li Electric Imp libraries removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'
		// NOTE impLibraries is not saved

		model.impLibraries = foundEILibs;
	}

	// PROCESS LOCAL LIBRARIES

	// Do we have any local libraries #included or #imported in the source code?
	
	// Check for a disparity between the number of known libraries and those found in the compilation
	// If there is a disparity, the project has changed so set the 'need to save' flag. Note if there
	// is no disparity, there may still have been changes made - we check for these below

	// Local libraries #included or #imported in the source code will all be stored in 'foundLibs'

	if (foundLibs.count > 0 && model.libraries == nil) model.libraries = [[NSMutableArray alloc] init];

	NSMutableArray *mLibs = model.libraries;

	if (foundLibs.count == 0)
	{
		// There are no libraries #included or #imported in the current code,
		// so clear the counts and the lists stored in the project
		
		if (mLibs.count > 0)
		{
			if (mLibs.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 local library no longer referenced in the %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li local libraries no longer referenced in the %@ code.", (long)mLibs.count, model.type] :YES];
			}

			thisProject.haschanged = YES;
			[mLibs removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local libraries included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		// First, run through the contents of 'foundLibs' to see if there is a 1:1 match with
		// the lists of known local librariess; if not, mark that the project has changed

		if (mLibs.count > 0)
		{
			for (File *aLib in foundLibs)
			{
				BOOL match = NO;

				for (File *lib in mLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++added;
			}

			for (File *lib in mLibs)
			{
				BOOL match = NO;

				for (File *aLib in foundLibs)
				{
					if ([aLib.filename compare:lib.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++removed;
			}
		}
		else
		{
			added = foundLibs.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local libraries added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			thisProject.haschanged = YES;

			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 local library added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li local libraries added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 local library removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li local libraries removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'
		
		model.libraries = foundLibs;
	}

	// PROCESS LOCAL FILES

	// Do we have any local files #included or #imported in the source code?
	
	// Local files #included or #imported in the source code will all be stored in 'foundFiles'
	// Clear out the recorded files lists and add in the new ones from 'foundFiles'

	if (foundFiles.count > 0 && model.files == nil) model.files = [[NSMutableArray alloc] init];

	NSMutableArray *mFiles = model.files;

	if (foundFiles.count == 0)
	{
		// There are no libraries #included or #imported in the current code,
		// so clear the counts and the lists stored in the project

		if (mFiles.count > 0)
		{
			if (mFiles.count == 1)
			{
				[self writeStringToLog:[NSString stringWithFormat:@"1 local file no longer referenced in the %@ code.", model.type] :YES];
			}
			else
			{
				[self writeStringToLog:[NSString stringWithFormat:@"%li local file no longer referenced in the %@ code.", (long)mFiles.count, model.type] :YES];
			}

			thisProject.haschanged = YES;
			[mFiles removeAllObjects];
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local files included in this %@ code.", model.type] :YES];
		}
	}
	else
	{
		NSInteger added = 0;
		NSInteger removed = 0;

		if (mFiles.count > 0)
		{
			for (File *aFile in foundFiles)
			{
				BOOL match = NO;

				for (File *file in mFiles)
				{
					if ([aFile.filename compare:file.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++added;
			}

			for (File *file in mFiles)
			{
				BOOL match = NO;

				for (File *aFile in foundFiles)
				{
					if ([aFile.filename compare:file.filename] == NSOrderedSame) match = YES;
				}

				if (!match) ++removed;
			}
		}
		else
		{
			added = foundFiles.count;
		}

		if (removed == 0 && added == 0)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"No local files added to or removed from the %@ code.", model.type] :YES];
		}
		else
		{
			thisProject.haschanged = YES;

			NSString *as = @"";
			NSString *rs = @"";

			if (added == 1)
			{
				as = @"1 local file added to";
			}
			else if (added > 1)
			{
				as = [NSString stringWithFormat:@"%li local files added to", (long)added];
			}

			if (removed == 1)
			{
				rs = @"1 local file removed from";
			}
			else if (removed > 1)
			{
				rs = [NSString stringWithFormat:@"%li local file removed from", (long)added];
			}

			if (as.length > 0)
			{
				if (rs.length > 0) as = [as stringByAppendingFormat:@", and %@", rs];
			}
			else
			{
				as = rs;
			}

			if (as.length > 0) [self writeStringToLog:[as stringByAppendingFormat:@" the %@ code.", model.type] :YES];
		}

		// Now replace the recorded EI library list with the new one from 'foundEILibs'

		model.files = foundFiles;
	}

	// Finally, clear and register the new libraries for changes
	// NOTE 'mFiles' and 'mLibs' point to the old lists

	for (File *item in mFiles) { [fileWatchQueue removePath:[self getAbsolutePath:thisProject.path :item.path]]; }
	for (File *item in mLibs) { [fileWatchQueue removePath:[self getAbsolutePath:thisProject.path :item.path]]; }

	for (File *item in model.libraries)
	{

#ifdef DEBUG
		NSLog(@"Path: %@ Name: %@", item.path, item.filename);
#endif

		NSString *path = [item.path stringByAppendingFormat:@"/%@", item.filename];
		if (![fileWatchQueue isPathBeingWatched:path]) [fileWatchQueue addPath:path];
	}
	
	for (File *item in model.files)
	{

#ifdef DEBUG
		NSLog(@"Path: %@ Name: %@", item.path, item.filename);
#endif

		NSString *path = [item.path stringByAppendingFormat:@"/%@", item.filename];
		if (![fileWatchQueue isPathBeingWatched:path]) [fileWatchQueue addPath:path];
	}

	// Finally cnvert paths from absolute paths to relative paths for storage

	for (File *lib in model.libraries)
	{
		lib.path = [self getRelativeFilePath:thisProject.path :lib.path];

#ifdef DEBUG
		NSLog(@"Path: %@ Name: %@", lib.path, lib.filename);
#endif

	}

	for (File *file in model.files)
	{
		file.path = [self getRelativeFilePath:thisProject.path :file.path];

#ifdef DEBUG
		NSLog(@"Path: %@ Name: %@", file.path, file.filename);
#endif

	}
}



- (NSUInteger)getLineNumber:(NSString *)code :(NSInteger)index
{
	NSArray *lines = [[code substringToIndex:index] componentsSeparatedByString:@"\n"];
	return lines.count;
}



- (NSString *)getLibraryVersionNumber:(NSString *)libcode
{
	NSString *returnString = @"";

	if (libcode == nil) return returnString;

	NSError *err;
	NSString *pattern = @"static *VERSION *= *\"[0-9]*.[0-9]*.[0-9]*\"";
	NSRegularExpressionOptions regexOptions =  NSRegularExpressionCaseInsensitive;
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:regexOptions error:&err];
	if (err) return returnString;
	NSTextCheckingResult *result = [regex firstMatchInString:libcode options:0 range:NSMakeRange(0, libcode.length)];
	NSRange vRange = (result != nil) ? result.range : NSMakeRange(NSNotFound, 0);

	// TODO check for comments

	if (vRange.location != NSNotFound)
	{
		libcode = [libcode substringFromIndex:vRange.location];
		vRange = [libcode rangeOfString:@"\"" options:NSCaseInsensitiveSearch];
		libcode = [libcode substringFromIndex:vRange.location + 1];
		NSRange eRange = [libcode rangeOfString:@"\"" options:NSCaseInsensitiveSearch];

		if (eRange.location != NSNotFound)
		{
			NSString *rString = [libcode substringToIndex:eRange.location];
			NSArray *vParts = [rString componentsSeparatedByString:@"."];

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



#pragma mark - API Response Handler Methods

- (void)listProducts:(NSNotification *)note
{
	// This method should ONLY be called by BuildAPIAccess instance AFTER loading a list of products
	// At this point we typically need to select or re-select a product

	NSString *sid = nil;
	NSDictionary *dict = (NSDictionary *)note.object;
	NSDictionary *so = [dict objectForKey:@"object"];
	NSArray *data = [dict objectForKey:@"data"];
	NSString *action = [so objectForKey:@"action"];

	// 'selectedProduct' may point to an entry in the existing 'productsArray', but this is
	// about to be zapped, so preserved the ID of the product it points to

	if (selectedProduct != nil)
	{
		sid = [self getValueFrom:selectedProduct withKey:@"id"];
		selectedProduct = nil;
	}

	if (productsArray == nil)
	{
		productsArray = [[NSMutableArray alloc] init];
	}
	else
	{
		[productsArray removeAllObjects];
	}

	if (data != nil)
	{
		NSArray *prs = data;

		if (prs.count > 0)
		{
			for (NSDictionary *pr in prs)
			{
				// Convert incoming dictionary into a mutable one

				NSMutableDictionary *apr = [[NSMutableDictionary alloc] init];

				[apr setObject:[pr objectForKey:@"id"] forKey:@"id"];
				[apr setObject:[pr objectForKey:@"type"] forKey:@"type"];
				[apr setObject:[pr objectForKey:@"relationships"] forKey:@"relationships"];
				[apr setObject:[NSMutableDictionary dictionaryWithDictionary:[pr objectForKey:@"attributes"]] forKey:@"attributes"];
				[productsArray addObject:apr];

				// If we need to match against a previous 'selectedProduct' ID, do it now

				if (sid != nil && [sid compare:[pr objectForKey:@"id"]] == NSOrderedSame) selectedProduct = apr;
			}

			// Inform the user

			[self writeStringToLog:@"List of products loaded: see 'Projects' > 'Current Products'." :YES];
		}
		else
		{
			[self writeStringToLog:@"There are no products listed on the server." :YES];
		}

		[self refreshProductsMenu];
		[self refreshProjectsMenu];
		[self setToolbar];
	}

	if (action != nil && ([action compare:@"uploadproject"] == NSOrderedSame))
	{
		// We are coming here because we want to upload a new project, so go back
		// and re-check the product information

		[self uploadProject:[so objectForKey:@"project"]];
	}
}



- (void)productToProjectStageTwo:(NSNotification *)note
{
    // This method is called by BuildAPIAccess ONLY. It may be in response to 'downloadProduct:'
	// or to 'deleteProduct:' It should be responding with a list of the product's device groups

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *so = [data objectForKey:@"object"];
	NSMutableArray *dgs = [data objectForKey:@"data"];
	NSString *action = [so objectForKey:@"action"];

	if (action != nil)
	{
		if ([action compare:@"downloadproduct"] == NSOrderedSame)
		{
			// Perform the flow for downloading a product

			Project *np = [so objectForKey:@"project"];
			NSMutableArray *npdgs = np.devicegroups;

			// Record the total number of device groups to the product has, ie. the number of
			// device group deployments we will need to retrieve

			np.count = dgs.count;

			// Add the product's device group records to the new project
			
			for (NSDictionary *dg in dgs)
			{
				Devicegroup *ndg = [[Devicegroup alloc] init];
				ndg.name = [self getValueFrom:dg withKey:@"name"];
				ndg.did = [self getValueFrom:dg withKey:@"id"];
				ndg.description = [self getValueFrom:dg withKey:@"description"];
				ndg.type = [self getValueFrom:dg withKey:@"type"];
				ndg.models = [[NSMutableArray alloc] init];
				[npdgs addObject:ndg];

				NSDictionary *cd = [self getValueFrom:dg withKey:@"current_deployment"];

				if (cd != nil)
				{
					NSString *dpid = [cd objectForKey:@"id"];

					if (dpid != nil)
					{
						// Now retrieve the code using the devicegroup id

						NSDictionary *dict = @{ @"action" : action,
												@"devicegroup" : ndg,
												@"project" : np };

						[ide getDeployment:dpid :dict];

						// At this point we have to wait for multiple async calls to 'productToProjectStageThree:'
					}
					else
					{
						// Decrement the tally of downloadable device groups

						--np.count;
					}
				}
				else
				{
					// Decrement the tally of downloadable device groups

					--np.count;
				}

				// NOTE if 'cd' or 'dpid' is nil, the device group has no current deployment
				// TODO do we get a historical, or create an empty file?
			}
		}
		else
		{
			// Perform the flow for deleting a product

			NSMutableDictionary *dp = [so objectForKey:@"product"];
			NSDictionary *pd = [dp objectForKey:@"product"];
			[dp setObject:[NSNumber numberWithInteger:dgs.count] forKey:@"count"];
			[dp setObject:dgs forKey:@"devicegroups"];

			[self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - checking devicegroups for assigned devices...", [self getValueFrom:pd withKey:@"name"]] :YES];

			for (NSDictionary *dg in dgs)
			{
				NSDictionary *dict = @{ @"action" : action,
										@"devicegroup" : dg,
										@"product" : dp };

				// Get the list of devices assigned to this device group

				[ide getDevicesWithFilter:@"devicegroup.id" :[dg objectForKey:@"id"] :dict];
			}

			// Pick up the action in 'listDevices:'
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (productToProjectStageTwo:)"] :YES];
	}
}



- (void)productToProjectStageThree:(NSNotification *)note
{
	// This method is called by the BuildAPIAccess instance in response to
	// multiple requests to retrieve the current deployment for a given device group

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *deployment = [data objectForKey:@"data"];
	NSDictionary *dict = [data objectForKey:@"object"];
	NSString *action = [dict objectForKey:@"action"];
	Project *project = [dict objectForKey:@"project"];
	Devicegroup *newDevicegroup = [dict objectForKey:@"devicegroup"];

	if (newDevicegroup.models == nil) newDevicegroup.models = [[NSMutableArray alloc] init];

	if (deployment != nil)
	{
		if ([action compare:@"updatecode"] == NSOrderedSame)
		{
			// Compare the deployment we have with the one just downloaded

			if (newDevicegroup.models.count == 0)
			{
				// The target has no models, so create them using the code below


				return;
			}

			NSString *sha = [self getValueFrom:deployment withKey:@"sha"];
			NSString *updated = [self getValueFrom:deployment withKey:@"updated_at"];
			if (updated == nil) updated = [self getValueFrom:deployment withKey:@"created_at"];
			NSDate *deployDate = [logDef dateFromString:updated];

			for (Model *model in newDevicegroup.models)
			{
				// Check dates
				
				NSDate *modelDate = [logDef dateFromString:model.updated];

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
					[saveLight needSave:YES];
					[_window setDocumentEdited:YES];
				}
			}
		}
		else
		{
			// Create two models - one device, one agent - based on the deployment

			Model *model;
			NSString *code = [self getValueFrom:deployment withKey:@"device_code"];

			if (code != nil)
			{
				model = [[Model alloc] init];
				model.type = @"device";
				model.squinted = YES;
				model.code = code;
				model.path = project.path;
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
				model.squinted = YES;
				model.code = code;
				model.path = project.path;
				model.sha = [self getValueFrom:deployment withKey:@"sha"];
				model.updated = [self getValueFrom:deployment withKey:@"updated_at"];
				if (model.updated == nil) model.updated = [self getValueFrom:deployment withKey:@"created_at"];
				[newDevicegroup.models addObject:model];
			}
		}
	}

	// Decrement the tally of downloadable device groups to see if we've got them all yet

	--project.count;

	if (project.count == 0)
	{
		// We have now acquired all the device groups models, so we can save everything

		[self productToProjectStageFour:project];
	}
}



- (void)productToProjectStageFour:(Project *)project
{
	project.haschanged = YES;

	if (savingProject != nil)
	{
		// TODO

		return;
	}

	// Go and save the project
	
	savingProject = project;
	savingProject.filename = [savingProject.name stringByAppendingString:@".squirrelproj"];
	[self saveProjectAs:nil];
	[self setToolbar];
}



- (void)createProductStageTwo:(NSNotification *)note
{
	// This is called by the BuildAPIAccess instance in response to a new product being created
	// This is a result of the user creating a new project and asking for a product to be made too.

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *so = [data objectForKey:@"object"];
	NSString *action = [so objectForKey:@"action"];
	Project *pr = [so objectForKey:@"project"];
	data = [data objectForKey:@"data"];

	// Link the project to the new product

	pr.pid = [data objectForKey:@"id"];

	// Perform appropriate action flows

	if (action != nil)
	{
		if ([action compare:@"newproject"] == NSOrderedSame)
		{
			// This is the action flow for a new project

			selectedProduct = nil;

			[self writeStringToLog:[NSString stringWithFormat:@"Created product for project \"%@\".", pr.name] :YES];
			[self writeStringToLog:@"Refreshing your list of products..." :YES];
			[self getProductsFromServer:nil];

			// Add the new project to the project menu. We've already checked for a name clash,
			// so we needn't care about the return value.

			[self addProjectMenuItem:pr.name :pr];

			// Enable project-related UI items
			// NOTE It's a new project, so no device groups yet - just update the main device group menu

			[self refreshOpenProjectsMenu];
			[self refreshProjectsMenu];
			[self refreshMainDevicegroupsMenu];
			[self refreshDevicegroupMenu];
			[self refreshDeviceMenu];
			[self setToolbar];

			// Mark the status light as empty, ie. in need of saving

			[saveLight show];
			[saveLight needSave:YES];
			[_window setDocumentEdited:YES];

			// Save the new project - this gives the user the chance to re-locate it

			savingProject = currentProject;
			[self saveProjectAs:nil];
		}
		else if ([action compare:@"uploadproject"] == NSOrderedSame)
		{
			// This is the action flow for a project being uploaded
			// We now have to upload the device groups

			NSString *createdItem = [self getValueFrom:data withKey:@"name"];

			[self writeStringToLog:[NSString stringWithFormat:@"Uploaded project \"%@\" to the impCloud.", createdItem] :YES];

			selectedProduct = nil;

			[self writeStringToLog:@"Refreshing your list of products..." :YES];
			[self getProductsFromServer:nil];
			[self writeStringToLog:@"Uploading the project's device groups..." :YES];

			if (pr.devicegroups.count > 0)
			{
				pr.count = pr.devicegroups.count;

				for (Devicegroup *dg in pr.devicegroups)
				{
					[self writeStringToLog:[NSString stringWithFormat:@"Uploading device group \"%@\"...", dg.name] :YES];

					NSDictionary *dict = @{ @"action" : @"uploadproject",
											@"project" : pr,
											@"devicegroup" : dg };

					NSDictionary *details = @{ @"name" : dg.name,
											   @"description" : dg.description,
											   @"productid" : pr.pid,
											   @"type" : dg.type };

					[ide createDevicegroup:details :dict];
				}
			}
			
			// Pick up the action at 'createDevicegroupStageTwo:'
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createProductStageTwo:)"] :YES];
	}
}



- (void)deleteProductStageTwo:(NSMutableDictionary *)dict
{
	// We come here after checking all of a product's device groups to see if they can be deleted

	NSArray *devicegroups = [dict objectForKey:@"devicegroups"];
	NSDictionary *product = [dict objectForKey:@"product"];

	[dict setObject:[NSNumber numberWithInteger:devicegroups.count] forKey:@"count"];

	[self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - deleting devicegroups...", [self getValueFrom:product withKey:@"name"]] :YES];

	// Run through the device groups in the list and delete them

	for (NSDictionary *devicegroup in devicegroups)
	{
		NSDictionary *source = @{ @"action" : @"deleteproduct",
							      @"devicegroup" : devicegroup,
							      @"product" : dict };

		[ide deleteDevicegroup:[devicegroup objectForKey:@"id"] :source];
	}

	// Pick up the action in 'deleteDevicegroupStageTwo:'
}



- (void)deleteProductStageThree:(NSNotification *)note
{
	// This method should ONLY be called by the BuildAPIAccess instance AFTER deleting a product

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];
	NSDictionary *product = [source objectForKey:@"product"];
	NSDictionary *deletedProduct = [product objectForKey:@"product"];

	selectedProduct = nil;

	[self writeStringToLog:[NSString stringWithFormat:@"Deleted product \"%@\".", [self getValueFrom:deletedProduct withKey:@"name"]] :YES];
	[self writeStringToLog:@"Refreshing your list of products..." :YES];
	[ide getProducts];
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
					[ide getDevicegroup:dg.did];
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
			[saveLight needSave:YES];
			[_window setDocumentEdited:YES];

			// Update the UI

			[self refreshOpenProjectsMenu];
			[self refreshDevicegroupMenu];
			[self refreshMainDevicegroupsMenu];
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateProductStageTwo:)"] :YES];
	}
}



- (void)updateDevicegroupStageTwo:(NSNotification *)note
{
	// This method should ONLY be called by the BuildAPIAccess object instance AFTER updating a device group

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *response = [data objectForKey:@"data"];
	NSDictionary *source = [data objectForKey:@"object"];
	NSString *action = [source objectForKey:@"action"];
	Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];

	// Change the local device group data

	BOOL updated = NO;

	if (action != nil)
	{
		if ([action compare:@"devicegroupchanged"] == NSOrderedSame)
		{
			NSString *newName = [self getValueFrom:response withKey:@"name"];
			NSString *newDesc = [self getValueFrom:response withKey:@"description"];

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
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateDevicegroupStageTwo:)"] :YES];
	}

	if (updated)
	{
		// Mark the device group's parent project as changed, but only if it has
		// NOTE we check for nil, but this is very unlikely (project closed before server responded)

		Project *project = [self getParentProject:devicegroup];

		if (project != nil)
		{
			project.haschanged = YES;

			[saveLight needSave:YES];
			[_window setDocumentEdited:YES];
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
	// This method should ONLY be called by the BuildAPIAccess object instance AFTER loading a list of devices

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];
	NSString *action = [source objectForKey:@"action"];

	if (action != nil)
	{
		if ([action compare:@"deletedevicegroup"] == NSOrderedSame)
		{
			Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];

			Project *project = [self getParentProject:devicegroup];

			if (project != nil)
			{
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

				[saveLight setFull:NO];
				[_window setDocumentEdited:YES];
				[self refreshDevicegroupMenu];
				[self refreshMainDevicegroupsMenu];
			}
			else
			{
				[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device group \"%@\" is an orphan.", devicegroup.name] :YES];
			}

			return;
		}
		else
		{
			// Run the delete product flow

			NSDictionary *devicegroup = [source objectForKey:@"devicegroup"];
			NSMutableDictionary *product = [source objectForKey:@"product"];
			NSNumber *number = [product objectForKey:@"count"];
			NSArray *devicegroups = [product objectForKey:@"devicegroups"];
			NSInteger count = number.integerValue;

			--count;

			NSDictionary *deletedProduct = [product objectForKey:@"product"];

			[self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - device group \"%@\" deleted (%li of %li).", [self getValueFrom:deletedProduct withKey:@"name"], [self getValueFrom:devicegroup withKey:@"name"], (long)(devicegroups.count - count), (long)devicegroups.count] :YES];

			[product setObject:[NSNumber numberWithInteger:count] forKey:@"count"];

			if (count == 0)
			{
				// All the device groups are gone, now for the final product... phew

				[self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\"...", [self getValueFrom:deletedProduct withKey:@"name"]] :YES];

				[ide deleteProduct:[deletedProduct objectForKey:@"id"] :source];

				// Pick this up at 'deleteProductStageThree:'
			}
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (deleteDevicegroupStageTwo:)"] :YES];
	}
}



- (void)updateCodeStageTwo:(NSNotification *)note
{
	// This method should ONLY be called by the BuildAPIAccess object instance AFTER uploading code

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *devicegroup = [data objectForKey:@"data"];
	NSDictionary *source = [data objectForKey:@"object"];

	if (devicegroup != nil)
	{
		NSDictionary *currentDeployment = [self getValueFrom:devicegroup withKey:@"current_deployment"];

		if (currentDeployment != nil)
		{
			// Get the deployment

			[ide getDeployment:[self getValueFrom:currentDeployment withKey:@"id"] :source];

			// Pick up the action at productToProjectStageThree:
		}
		else
		{
			// Device group has no current deployment so just run an upload

			[self uploadCode:nil];
		}
	}
}



- (void)listDevices:(NSNotification *)note
{
	// This method should ONLY be called by the BuildAPIAccess object instance AFTER loading a list of devices

	NSDictionary *data = (NSDictionary *)note.object;
	NSArray *devices = [data objectForKey:@"data"];
	NSDictionary *source = [data objectForKey:@"object"];
	NSString *action = [source objectForKey:@"action"];

	if (action != nil)
	{
		if ([action compare:@"deleteproduct"] == NSOrderedSame)
		{
			// Perform the delete product flow. All we are doing here is checking the
			// number devices being provided so we can determine whether the product's
			// device groups are themselves able to be deleted

			NSMutableDictionary *deletedProduct = [source objectForKey:@"product"];
			NSDictionary *product = [deletedProduct objectForKey:@"product"];
			NSNumber *number = [deletedProduct objectForKey:@"count"];
			NSInteger count = number.integerValue;

			// First check if we've already discovered the presence of devices
			// If we have, there's no need to proceed

			if (count == kDoneChecking) return;

			// Does the device group have any devices? If so we can't proceed

			if (devices != nil && devices.count > 0)
			{
				// The device group has devices, so the API won't let us delete the devcie group and thus the product

				[deletedProduct setObject:[NSNumber numberWithInteger:kDoneChecking] forKey:@"count"];

				NSDictionary *devicegroup = [source objectForKey:@"devicegroup"];

				[self writeStringToLog:[NSString stringWithFormat:@"Product \"%@\" can't be deleted because device group \"%@\" has devices assigned. Aborting delete attempt.", [self getValueFrom:product withKey:@"name"], [self getValueFrom:devicegroup withKey:@"name"]] :YES];
			}
			else
			{
				// This device group has no devices, we can proceed - but have we got them all

				--count;

				if (count == 0)
				{
					// We've checked all the device groups and we're good to delete them

					[self deleteProductStageTwo:deletedProduct];
				}
				else
				{
					[deletedProduct setObject:[NSNumber numberWithInteger:count] forKey:@"count"];
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

#ifdef DEBUG
				if (newDevice == nil) NSLog(@"nil");
#endif

				[devicesArray addObject:newDevice];
			}

			// Sort the devices list by device name (inside the 'attributes' dictionary

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
							NSDictionary *relationships = [device objectForKey:@"relationships"];
							NSDictionary *devgrp = [relationships objectForKey:@"devicegroup"];
							NSString *deviceid = [devgrp objectForKey:@"id"];

							// Just check for a nil device group ID - to avoid unassigned devices
							
							if (deviceid != nil)
							{
								if ([deviceid compare:devicegroup.did] == NSOrderedSame) [devicegroup.devices addObject:deviceid];
							}
						}
					}
				}
			}
		}

		[self writeStringToLog:@"List of devices loaded: see 'Current Device' and 'Devices' > 'Unassigned Devices'." :YES];

		// Update the UI

		[self refreshDevicesPopup];
		[self refreshDeviceMenu];
		[self refreshDevicegroupMenu];
		[self setToolbar];
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (listDevices:)"] :YES];
	}
}



- (void)createDevicegroupStageTwo:(NSNotification *)note
{
	// We're back after creating the Device Group on the server
	// so extract the persisted data to get the new device group,
	// its project and the flag indicating whether the user wants
	// source files creating

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *response = [data objectForKey:@"data"];
	NSDictionary *source = [data objectForKey:@"object"];
	NSNumber *makeNewFiles = [source objectForKey:@"files"];
	Devicegroup	*devicegroup = [source objectForKey:@"devicegroup"];
	Project *project = [source objectForKey:@"project"];
	NSString *action = [source objectForKey:@"action"];

	// Record the new device group's ID

	devicegroup.did = [response objectForKey:@"id"];

	if (action != nil)
	{
		if ([action compare:@"newdevicegroup"] == NSOrderedSame)
		{
			if (newDevicegroupFlag)
			{
				// We are adding a device group for newly added file, so go and process those files
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
				[_window setDocumentEdited:YES];

				// And select the device group

				currentDevicegroup = devicegroup;
				currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];

				// Update the UI

				[self setToolbar];
				[self refreshDevicegroupMenu];
				[self refreshMainDevicegroupsMenu];
			}

			// Now we can produce the source code file, as the user requested

			if (makeNewFiles != nil && makeNewFiles.boolValue) [self createFilesForDevicegroup:devicegroup.name :@"agent"];
		}
		else if ([action compare:@"uploadproject"] == NSOrderedSame)
		{
			// We're here after creating a device group as part of a project upload

			// Record the new device group ID

			devicegroup.did = [response objectForKey:@"id"];

			// Decrement the device group processing count

			--project.count;

			if (project.count == 0)
			{
				// We have created all the device groups we need to, so it's now time to upload code

				[self uploadProjectStageThree:project];
			}
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createDevicegroupStageTwo:)"] :YES];
	}
}



- (void)uploadProjectStageThree:(Project *)project
{
	// NOTE We can't get here without one or more device groups
	// and there will be one deployment per devicegroup

	[self writeStringToLog:[NSString stringWithFormat:@"Uploading project \"%@\" code...", project.name] :YES];

	project.count = project.devicegroups.count;

	for (Devicegroup *devicegroup in project.devicegroups)
	{
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

				NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
				dateFormatter.dateStyle = NSDateFormatterMediumStyle;
				dateFormatter.timeStyle = NSDateFormatterNoStyle;

				NSString *desc = [dateFormatter stringFromDate:[NSDate date]];

				NSDictionary *adg = @{ @"type" : devicegroup.type,
									   @"id" : devicegroup.did };

				NSDictionary *relationships = @{ @"devicegroup" : adg };

				NSDictionary *attributes = @{ @"flagged" : @NO,
											  @"agent_code" : agentCode,
											  @"device_code" : deviceCode,
											  @"description" : [NSString stringWithFormat:@"Uploaded from Squinter 2.0 at %@", desc] };

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
			[self writeStringToLog:[NSString stringWithFormat:@"The code for device group \"%@\" has not been compiled - it will not be uploaded.", devicegroup.name] :YES];
		}
	}
}



- (void)restarted:(NSNotification *)note
{
	// This method ONLY called in response to a notification from BuildAPIAccess that a device or devices have restarted
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
			[self writeStringToLog:[NSString stringWithFormat:@"The devices assigned to device group \"%@\" have restarted.", devicegroup.name] :YES];
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (restarted:)"] :YES];
	}
}



- (void)reassigned:(NSNotification *)note
{
	// This method should ONLY be called by the BuildAPIAccess instance

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];
	NSString *action = [source objectForKey:@"action"];
	NSDictionary *device = [source objectForKey:@"device"];

	if (action != nil)
	{
		if ([action compare:@"unassign"] == NSOrderedSame)
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
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (reassigned:)"] :YES];
	}
}



- (void)renameDeviceStageTwo:(NSNotification *)note
{
	// Called ONLY in response to a notification from BuildAPIAccess that a device has been renamed

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];

	[self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" renamed \"%@\".", [source objectForKey:@"old"], [source objectForKey:@"new"]] :YES];

	selectedDevice = nil;

	// Now refresh the devices list

	[self updateDevicesStatus:nil];
}



- (void)deleteDeviceStageTwo:(NSNotification *)note
{
	// Called ONLY in response to a notification from BuildAPIAccess that a device has been deleted

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];
	NSDictionary *device = [source objectForKey:@"device"];

	[self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" removed from your account.", [self getValueFrom:device withKey:@"name"]] :YES];

	// If the selected device is the one we've just delete - likely it is

	if (selectedDevice == device) selectedDevice = nil;

	// Now refresh the devices list

	[self updateDevicesStatus:nil];
}



- (void)uploadCodeStageTwo:(NSNotification *)note
{
	// Called in response to a notification from BuildAPIAccess that a deployment has been created

	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *response = [data objectForKey:@"data"];
	NSDictionary *source = [data objectForKey:@"object"];
	Devicegroup	*devicegroup = [source objectForKey:@"devicegroup"];
	NSString *action = [source objectForKey:@"action"];

	// Get the code SHA and updated date and add to the device groups's two models

	NSString *sha = [self getValueFrom:response withKey:@"sha"];
	NSString *updated = [self getValueFrom:response withKey:@"updated_at"];
	if (updated == nil) updated = [self getValueFrom:response withKey:@"created_at"];

	for (Model *model in devicegroup.models)
	{
		model.sha = sha;
		model.updated = updated;
	}

	// Mark the parent product as changed

	Project *project = [self getParentProject:devicegroup];
	project.haschanged = YES;

	// Mark the devicegroup as uploaded

	devicegroup.squinted = devicegroup.squinted | 0x08;

	// Update the UI

	[saveLight needSave:YES];
	[_window setDocumentEdited:YES];

	if (action != nil)
	{
		if ([action compare:@"uploadproject"] == NSOrderedSame)
		{
			// Decrement the count of uploaded deployments

			--project.count;

			if (project.count == 0)
			{
				// All done!

				[self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" uploaded to impCloud. Please save your project file.", project.name] :YES];
				[self writeStringToLog:@"Refreshing product list." :YES];
				[ide getProducts];
			}
		}
		else
		{
			[self writeStringToLog:[NSString stringWithFormat:@"Code uploaded to device group \"%@\". Restart its assigned device(s) to run the new code.", devicegroup.name] :YES];
		}
	}
	else
	{
		[self writeStringToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (uploadCodeStageTwo:)"] :YES];
	}
}



- (void)loggedIn:(NSNotification *)note
{
	// BuildAPIAccess has signalled login success

	// Save credentials if they have changed required

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

	loginMenuItem.title = @"Log out of your account";

	[self setToolbar];

	// Register we are no longer trying to log in

	loginFlag = NO;

	// Inform the user he or she is logged in

	[self writeStringToLog:@"You now are logged in to the impCloud." :YES];

	// Check for any post-login actions that need to be performed

	if ([defaults boolForKey:@"com.bps.squinter.autoloadlists"])
	{
		// User wants the Device lists loaded on login

		[self getProductsFromServer:nil];
	}

	if ([defaults boolForKey:@"com.bps.squinter.autoloaddevlists"])
	{
		// User wants the Product lists loaded on login

		[self updateDevicesStatus:nil];
	}
}



#pragma mark - Log and Logging Methods


- (void)listCommits:(NSNotification *)note
{
	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *source = [data objectForKey:@"object"];

	__block Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
	__block NSMutableArray *deployments = [data objectForKey:@"data"];

	if (deployments.count > 0)
	{
		[extraOpQueue addOperationWithBlock:^(void){

			[self performSelectorOnMainThread:@selector(logLogs:)
								   withObject:@"--------------------------------------------------------------------------"
								waitUntilDone:NO];

			[self performSelectorOnMainThread:@selector(logLogs:)
								   withObject:[NSString stringWithFormat:@"Commits to Device Group \"%@\":", devicegroup.name]
								waitUntilDone:NO];

			for (NSUInteger i = deployments.count ; i > 0 ; --i)
			{
				NSDictionary *deployment = [deployments objectAtIndex:(i - 1)];
				NSString *sha = [self getValueFrom:deployment withKey:@"sha"];
				NSString *message = [self getValueFrom:deployment withKey:@"description"];
				NSString *timestamp = [self getValueFrom:deployment withKey:@"created_at"];
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
				NSString *ss = [@"                               " substringToIndex:ns.length];
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

				[self performSelectorOnMainThread:@selector(logLogs:)
									   withObject:cs
									waitUntilDone:NO];
			}

			[self performSelectorOnMainThread:@selector(logLogs:)
								   withObject:@"--------------------------------------------------------------------------"
								waitUntilDone:NO];
		}];
	}
}



- (void)listLogs:(NSNotification *)note
{
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
			// Calculate the width of the widest status message for spacing the output into columns

			NSUInteger width = 0;

			for (NSUInteger i = 0 ; i < theLogs.count ; ++i)
			{
				NSDictionary *aLog = [theLogs objectAtIndex:i];
				NSString *sString = [aLog objectForKey:@"type"];
				if (sString.length > width) width = sString.length;
			}

			if ([action compare:@"gethistory"] == NSOrderedSame)
			{
				[self performSelectorOnMainThread:@selector(logLogs:) withObject:[NSString stringWithFormat:@"History of device \"%@\":", [self getValueFrom:device withKey:@"name"]] waitUntilDone:NO];

				for (NSUInteger i = theLogs.count ; i > 0  ; --i)
				{
					NSDictionary *entry = [theLogs objectAtIndex:(i - 1)];
					NSString *timestamp = [entry objectForKey:@"timestamp"];
					timestamp = [def stringFromDate:[logDef dateFromString:timestamp]];
					timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
					timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

					NSString *event = [entry objectForKey:@"event"];
					NSString *owner = [entry objectForKey:@"owner_id"];
					NSString *actor = [entry objectForKey:@"actor_id"];
					NSString *doer = ([owner compare:actor] == NSOrderedSame) ? @"you." : @"someone else.";

					NSString *lString = [NSString stringWithFormat:@"%@ Device %@ by %@", timestamp, event, doer];

					[self performSelectorOnMainThread:@selector(logLogs:) withObject:lString waitUntilDone:NO];
				}
			}
			else
			{
				[self performSelectorOnMainThread:@selector(logLogs:) withObject:[NSString stringWithFormat:@"Latest log entries for device \"%@\":", [self getValueFrom:device withKey:@"name"]] waitUntilDone:NO];

				for (NSUInteger i = theLogs.count ; i > 0  ; --i)
				{
					NSDictionary *entry = [theLogs objectAtIndex:(i - 1)];
					NSString *timestamp = [entry objectForKey:@"ts"];
					timestamp = [def stringFromDate:[logDef dateFromString:timestamp]];
					timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
					timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

					NSString *type = [entry objectForKey:@"type"];
					NSString *msg = [entry objectForKey:@"msg"];

					NSString *spacer = [@"                                      " substringToIndex:13 - type.length];
					NSString *lString = [NSString stringWithFormat:@"%@ [%@]%@%@", timestamp, type, spacer, msg];
					
					[self performSelectorOnMainThread:@selector(logLogs:) withObject:lString waitUntilDone:NO];
				}
			}

			// Look for URLs etc one all the items have gone in

			[self performSelectorOnMainThread:@selector(parseLog) withObject:nil waitUntilDone:NO];
		}];
	}
	else
	{
		NSString *items = ([action compare:@"gethistory"] == NSOrderedSame) ? @"history" : @"logs";

		[self writeStringToLog:[NSString stringWithFormat:@"There are no %@ entries for device \"%@\"", items, [self getValueFrom:device withKey:@"name"]] :YES];
	}
}



- (void)logLogs:(NSString *)logLine
{
	[self writeStringToLog:logLine :NO];
}



- (void)parseLog
{
	logTextView.editable = YES;
	[logTextView checkTextInDocument:nil];
	logTextView.editable = NO;
}



- (IBAction)printLog:(id)sender
{
	// Get and update the app's NSPrintInfo object
	// NOTE This takes note of the user's 'Page Setup...' choices

	NSPrintInfo *pInfo = [NSPrintInfo sharedPrintInfo];
	pInfo.horizontalPagination = NSFitPagination;
	pInfo.verticalPagination = NSAutoPagination;
	pInfo.verticallyCentered = NO;
	pInfo.bottomMargin = 34.0;
	pInfo.topMargin = 34.0;
	pInfo.rightMargin = 34.0;
	pInfo.leftMargin = 34.0;

	// Determine the best point size for the orientation

	CGFloat textSize = (pInfo.orientation == NSPaperOrientationPortrait) ? 8.0 : 10.0;

	// Create an NSView for printing using the text from the log

	NSTextView *printView = [[NSTextView alloc] initWithFrame:NSMakeRect(0, 0, pInfo.paperSize.width, pInfo.paperSize.height)];
	printView.editable = YES;
	printView.string = logTextView.string;
	printView.font = [NSFont fontWithName:logTextView.font.fontName size:textSize];
	printView.editable = NO;

	// Create the print operation and print

	NSPrintOperation *printOp = [NSPrintOperation printOperationWithView:printView
															   printInfo:pInfo];
	[printOp setCanSpawnSeparateThread:YES];
	[printOp runOperationModalForWindow:_window delegate:self didRunSelector:@selector(printDone: success: contextInfo:) contextInfo:nil];
}



- (void)printDone:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo
{
	if (success) [self writeStringToLog:@"Log contents sent to print system." :YES];
}



- (void)loggingStarted:(NSNotification *)note
{
	// We come here via a notification from BuildAPIAccess that a device has been added to the log stream

	NSDictionary *data = (NSDictionary *)note.object;
	NSString *dvid = [data objectForKey:@"device"];
	NSDictionary *device;

	for (NSDictionary *aDevice in devicesArray)
	{
		NSString *advid = [aDevice objectForKey:@"id"];

		if ([advid compare:dvid] == NSOrderedSame)
		{
			device = aDevice;
			break;
		}
	}

	[self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" added to log stream", [self getValueFrom:device withKey:@"name"]] :YES];

	if (device == selectedDevice)
	{
		streamLogsItem.state = kStreamToolbarItemStateOn;
		streamLogsMenuItem.title = @"Stop Log Streaming";
	}

	[streamLogsItem validate];
	[self refreshDevicesMenus];
	[self refreshDevicesPopup];
}



- (void)loggingStopped:(NSNotification *)note
{
	// We come here via a notification from BuildAPIAccess that a device has been removed from the log stream

	NSDictionary *data = (NSDictionary *)note.object;
	NSString *dvid = [data objectForKey:@"device"];
	NSDictionary *device;

	for (NSDictionary *aDevice in devicesArray)
	{
		NSString *advid = [aDevice objectForKey:@"id"];

		if ([advid compare:dvid] == NSOrderedSame)
		{
			device = aDevice;
			break;
		}
	}

	[self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" removed from log stream", [self getValueFrom:device withKey:@"name"]] :YES];

	if (device == selectedDevice)
	{
		streamLogsItem.state = kStreamToolbarItemStateOff;
		streamLogsMenuItem.title = @"Start Log Streaming";
	}

	[streamLogsItem validate];
	[self refreshDevicesMenus];
	[self refreshDevicesPopup];
}



- (void)presentLogEntry:(NSNotification *)note
{
	// @"232390b030728cee 2017-05-19T17:28:19.095Z development server.log Connected by WiFi on SSID \"darkmatter\" with IP address 192.168.0.2"
	// or
	// @"subscribed 232390b030728cee"

	NSDictionary *data = (NSDictionary *)note.object;
	NSString *logItem = [data objectForKey:@"message"];
	NSArray *parts = [logItem componentsSeparatedByString:@" "];

	if (parts.count > 2)
	{
		// Indicates the first of the message formats listed above, ie.
		// {device ID} {timestamp} {log type} {event type} {message}
		// NOTE {message} comprises the remaining parts of the string

		NSUInteger width = 12;
		NSArray *values;
		NSString *device;
		NSString *log;

		NSString *type = [parts objectAtIndex:3];
		NSString *timestamp = [parts objectAtIndex:1];
		timestamp = [def stringFromDate:[logDef dateFromString:timestamp]];
		timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
		timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

		if (type.length > width) width = type.length;

		NSString *spacer = [@"                                      " substringToIndex:width - type.length];
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

		NSInteger index = [ide indexOfLoggedDevice:dvid];

		// Calculate colour table index

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

		NSRange range = [logItem rangeOfString:type];
		NSString *message = [logItem substringFromIndex:(range.location + type.length + 1)];

		if (ide.numberOfLogStreams > 1)
		{
			NSString *subspacer = [@"                                      " substringToIndex:logPaddingLength - device.length];
			log = [NSString stringWithFormat:@"\"%@\"%@: [%@] %@%@", device, subspacer, type, spacer, message];
			values = [NSArray arrayWithObjects:[logColors objectAtIndex:index], nil];
		}
		else
		{
			log = [NSString stringWithFormat:@"\"%@\": [%@] %@%@", device, type, spacer, message];
			values = [NSArray arrayWithObjects:[logColors objectAtIndex:index], nil];
		}

		log = [timestamp stringByAppendingFormat:@" %@", log];
		NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, nil];
		NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
		NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:log attributes:attributes];

		[self writeStreamToLog:attrString];
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



- (IBAction)showProjectInfo:(id)sender
{
	// If there is no currently selected project, bail

	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	NSMutableArray *lines = [[NSMutableArray alloc] init];
	NSString *string = nil;

	[lines addObject:[NSString stringWithFormat:@"Project: %@", currentProject.name]];

#ifdef DEBUG
	[lines addObject:[NSString stringWithFormat:@"Project file version: %@", currentProject.version]];
#endif

	if (currentProject.pid.length > 0)
	{
		if (productsArray.count > 0)
		{
			BOOL deadpid = YES;

			for (NSMutableDictionary *product in productsArray)
			{
				NSString *pid = [product objectForKey:@"id"];

				if ([pid compare:currentProject.pid] == NSOrderedSame)
				{
					string = [NSString stringWithFormat:@"Project linked to product \"%@\" (ID: %@)", [self getValueFrom:product withKey:@"name"], currentProject.pid];
					deadpid = NO;
				}
			}

			if (deadpid)
			{
				// We can't find a valid prodict for the project's PID

				if ([currentProject.pid compare:@"old"] == NSOrderedSame)
				{
					// However, this is because the project is a conversion from a previous version
					// of Squinter, so we should indicate this - the user may not have uploaded it yet

					string = @"Project not yet linked to a product becuase it has yet not been uploaded.";
				}
				else
				{
					string = @"Project linked to a product that may have been deleted.";
				}
			}
		}
		else
		{
			string = [NSString stringWithFormat:@"Project linked to product with ID \"%@\".", currentProject.pid];
		}

		[lines addObject:string];
	}
	else
	{
		[lines addObject:@"Project is not linked to a product"];
	}


	if (currentProject.path == nil)
	{
		// This will be case if it's a new project that has not been saved yet

		[lines addObject:@"Project has not yet been saved."];
	}
	else
	{
		// NOTE currentProject.path is always absolute

		[lines addObject:[NSString stringWithFormat:@"Project file location: %@/%@", currentProject.path, currentProject.filename]];
	}

	if (currentProject.devicegroups.count > 0)
	{
		if (currentProject.devicegroups.count == 1)
		{
			[lines addObject:@"Project has 1 device group:"];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"Project has %li device groups:", currentProject.devicegroups.count]];
		}

		for (NSUInteger i = 0 ; i < currentProject.devicegroups.count ; ++i)
		{
			Devicegroup *dg = [currentProject.devicegroups objectAtIndex:i];

			[self compileDevicegroupInfo:dg :2 :lines];

			// Add a line between device groups

			if (i < currentProject.devicegroups.count - 1) [lines addObject:@" "];
		}
	}
	else
	{
		[lines addObject:@"Project has no device groups."];
	}

	// If we have a project description add it in

	if (currentProject.description.length > 0)
	{
		// Calculate the width of the longest line

		NSUInteger dashCount = 0;

		for (NSString *string in lines)
		{
			if (string.length > dashCount) dashCount = string.length;
		}

		// Format the project description to fit that width

		NSArray *dLines = [self displayDescription:currentProject.description :dashCount :@""];

		// Insert the description lines into the ones we already have, ie. line 1 after the name

		for (NSInteger i = 0 ; i < dLines.count ; ++i)
		{
			[lines insertObject:[dLines objectAtIndex:i] atIndex:i + 1];
		}
	}

	// Finally, print out the lines in the log

	[self printInfoInLog:lines];
}



- (IBAction)showDeviceGroupInfo:(id)sender
{
	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	[self compileDevicegroupInfo:currentDevicegroup :0 :nil];
}



- (void)compileDevicegroupInfo:(Devicegroup *)devicegroup :(NSUInteger)inset :(NSMutableArray *)otherLines
{
	// Shows info for the selected device group.

	NSMutableArray *lines = [[NSMutableArray alloc] init];

	// Prepare the indent: should be 0 or 2 spaces

	NSString *spaces = @"";
	NSString *liner = @"";

	if (inset > 0)
	{
		for (NSUInteger i = 0 ; i < inset ; ++i)
		{
			spaces = [spaces stringByAppendingString:@" "];
		}
	}

	[lines addObject:[NSString stringWithFormat:@"%@Device group \"%@\"", spaces, devicegroup.name]];

	if (devicegroup.did != nil && devicegroup.did.length > 0 && [devicegroup.did compare:@"old"] != NSOrderedSame)
	{
		[lines addObject:[NSString stringWithFormat:@"%@Device group ID: %@", spaces, devicegroup.did]];
	}
	else
	{
		[lines addObject:[NSString stringWithFormat:@"%@Device group not uploaded to the impCloud", spaces]];
	}

	[lines addObject:[NSString stringWithFormat:@"%@Device group type: %@", spaces, [self convertDevicegroupType:devicegroup.type :NO]]];

	if (devicegroup.models.count > 0)
	{
		if (devicegroup.models.count == 1)
		{
			[lines addObject:[NSString stringWithFormat:@"\n%@This device group has 1 source code file:", spaces]];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"\n%@This device group has %li source code files:", spaces, (long)devicegroup.models.count]];
		}

		for (NSUInteger j = 0 ; j < devicegroup.models.count ; ++j)
		{
			Model *model = [devicegroup.models objectAtIndex:j];
			NSString *showPath = [self getPrintPath:currentProject.path :model.path];
			if (showPath.length > 0) showPath = [showPath stringByAppendingString:@"/"];
			if (j > 0) liner = @"\n";

			NSString *m = [NSString stringWithFormat:@"%@%@  %li. %@%@", liner, spaces, (long)(j + 1), showPath, model.filename];
			if (model.hasMoved) m = [m stringByAppendingString:@" ** FILE HAS MOVED FROM THIS LOCATION **"];
 			[lines addObject:m];
			[self compileModelInfo:model :(inset + 4) :lines];
		}
	}
	else
	{
		[lines addObject:[NSString stringWithFormat:@"%@This device group has no source code yet.", spaces]];
	}

	// Get devices for this device group

	if (devicesArray.count > 0)
	{
		BOOL first = YES;

		for (NSMutableDictionary *device in devicesArray)
		{
			NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
			NSString *dgid = [self getValueFrom:dg withKey:@"id"];

			if (devicegroup.did != nil && devicegroup.did.length > 0 && ([devicegroup.did compare:dgid] == NSOrderedSame))
			{
				if (first)
				{
					[lines addObject:[NSString stringWithFormat:@"\n%@The following device(s) have been assigned to this device group:", spaces]];
					first = NO;
				}

				[lines addObject:[NSString stringWithFormat:@"%@     %@ (%@)", spaces, [self getValueFrom:device withKey:@"name"], [self getValueFrom:device withKey:@"id"]]];
			}
		}
	}

	// Insert the description if there is one - we do this here in order to ensure the description
	// line width matches that of the longest line in the device group data

	if (devicegroup.description != nil && devicegroup.description.length > 0)
	{
		// Get the length of the widest line

		NSUInteger dashCount = 0;

		for (NSString *string in lines)
		{
			if (string.length > dashCount) dashCount = string.length;
		}

		// Format the description for that maximum line width

		NSArray *dLines = [self displayDescription:devicegroup.description :dashCount :spaces];

		// Add the description lines into the ones we already have, ie. on line 1 after the name

		for (NSInteger i = 0 ; i < dLines.count ; ++i)
		{
			[lines insertObject:[dLines objectAtIndex:i] atIndex:i + 1];
		}
	}

	// Add the new lines to either the passed in array, or a local one

	if (otherLines == nil)
	{
		[self printInfoInLog:lines];
	}
	else
	{
		[otherLines addObjectsFromArray:lines];
	}
}



- (void)compileModelInfo:(Model *)model :(NSUInteger)inset :(NSMutableArray *)otherLines
{
	NSString *path;

	NSMutableArray *lines = [[NSMutableArray alloc] init];

	// Prepare the indent: should be 4 or 6 spaces

	NSString *spaces = @"";

	if (inset > 0)
	{
		for (NSUInteger i = 0 ; i < inset ; ++i)
		{
			spaces = [spaces stringByAppendingString:@" "];
		}
	}

	if (model.libraries.count > 0)
	{
		if (model.libraries.count == 1)
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports the following local library:", spaces, model.type]];

			File *lib = [model.libraries objectAtIndex:0];

			path = [self getPrintPath:currentProject.path :lib.path];
			path = (path.length == 0) ? lib.filename : [path stringByAppendingFormat:@"/%@", lib.filename];

			[lines addObject:[NSString stringWithFormat:@"%@   %@ (version %@)", spaces, path, ((lib.version.length == 0) ? @"unknown" : lib.version)]];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports the following local libraries:", spaces, model.type]];

			for (NSUInteger i = 0 ; i < model.libraries.count ; ++i)
			{
				File *lib = [model.libraries objectAtIndex:i];

				path = [self getPrintPath:currentProject.path :lib.path];
				path = (path.length == 0) ? lib.filename : [path stringByAppendingFormat:@"/%@", lib.filename];

				[lines addObject:[NSString stringWithFormat:@"%@   %li. %@ (%@)", spaces, (long)(i + 1), path, ((lib.version.length == 0) ? @"unknown" : lib.version)]];
			}
		}
	}
	else
	{
		[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports no local libraries.", spaces, model.type]];
	}

	if (model.files.count > 0)
	{
		if (model.files.count == 1)
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports the following local file:", spaces, model.type]];

			File *file = [model.files objectAtIndex:0];

			path = [self getPrintPath:currentProject.path :file.path];
			path = (path.length == 0) ? file.filename : [path stringByAppendingFormat:@"/%@", file.filename];

			[lines addObject:[NSString stringWithFormat:@"%@   %@", spaces, path]];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports the following local files:", spaces, model.type]];

			for (NSUInteger i = 0 ; i < model.files.count ; ++i)
			{
				File *file = [model.files objectAtIndex:i];

				path = [self getPrintPath:currentProject.path :file.path];
				path = (path.length == 0) ? file.filename : [path stringByAppendingFormat:@"/%@", file.filename];
				
				[lines addObject:[NSString stringWithFormat:@"%@   %li. %@", spaces, (long)(i + 1), path]];
			}
		}
	}
	else
	{
		[lines addObject:[NSString stringWithFormat:@"%@ This %@ code imports no local files.", spaces, model.type]];
	}

	if (!model.squinted) [lines addObject:[NSString stringWithFormat:@"%@ [WARNING] This file has not been compiled so the list above may be out of date.", spaces]];

	if (model.impLibraries.count > 0)
	{
		if (model.impLibraries.count == 1)
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code loads the following Electric Imp library:", spaces, model.type]];

			File *elib = [model.impLibraries objectAtIndex:0];
			[lines addObject:[NSString stringWithFormat:@"%@   %@ (%@)", spaces, elib.filename, elib.version]];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"%@ This %@ code loads the following Electric Imp libraries:", spaces, model.type]];

			for (NSUInteger i = 0 ; i < model.impLibraries.count ; ++i)
			{
				File *elib = [model.impLibraries objectAtIndex:i];
				[lines addObject:[NSString stringWithFormat:@"%@   %li. %@ (%@)", spaces, (long)(i + 1), elib.filename, elib.version]];
			}
		}
	}
	else
	{
		[lines addObject:[NSString stringWithFormat:@"%@ This %@ code loads no Electric Imp libraries.", spaces, model.type]];
	}

	if (model.sha != nil && model.sha.length > 0)
	{
		[lines addObject:[NSString stringWithFormat:@"%@ Code uploaded at %@ as SHA %@", spaces, model.updated, model.sha]];
	}

	if (otherLines == nil)
	{
		[self printInfoInLog:lines];
	}
	else
	{
		[otherLines addObjectsFromArray:lines];
	}
}


- (IBAction)showDeviceInfo:(id)sender
{
	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSMutableArray *lines = [[NSMutableArray alloc] init];

	[lines addObject:[NSString stringWithFormat:@"Device: %@", [self getValueFrom:selectedDevice withKey:@"name"]]];
	[lines addObject:[NSString stringWithFormat:@"Device ID: %@", [selectedDevice objectForKey:@"id"]]];
	[lines addObject:[NSString stringWithFormat:@"Device Type: %@", [self getValueFrom:selectedDevice withKey:@"imp_type"]]];

	// [lines addObject:[NSString stringWithFormat:@"Free memory: %@ KB", [self getValueFrom:selectedDevice withKey:@"free_memory"]]];

	NSString *mac = [self getValueFrom:selectedDevice withKey:@"mac_address"];
	mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
	[lines addObject:[NSString stringWithFormat:@"MAC Address: %@", mac]];

	NSNumber *boolean = [self getValueFrom:selectedDevice withKey:@"device_online"];
	NSString *string = (boolean.boolValue) ? @"online" : @"offline";

	if ([string compare:@"online"] == NSOrderedSame) [lines addObject:[NSString stringWithFormat:@"IP Address: %@", [self getValueFrom:selectedDevice withKey:@"ip_address"]]];

	[lines addObject:[NSString stringWithFormat:@"State: %@", string]];

	boolean = [self getValueFrom:selectedDevice withKey:@"agent_running"];
	string = (boolean.boolValue) ? @"online" : @"offline";
	[lines addObject:[NSString stringWithFormat:@"Agent state: %@", string]];

	if (boolean.boolValue)
	{
		[lines addObject:[NSString stringWithFormat:@"Agent URL: https://agent.electricimp.com/%@", [self getValueFrom:selectedDevice withKey:@"agent_id"]]];
	}

	NSDictionary *dg = [self getValueFrom:selectedDevice withKey:@"devicegroup"];
	NSString *dgid = [self getValueFrom:dg withKey:@"id"];

	if (dgid != nil)
	{
		Devicegroup *adg = nil;
		Project *apr = nil;

		if (projectArray.count > 0)
		{
			for (Project *pr in projectArray)
			{
				if (pr.devicegroups.count > 0)
				{
					for (Devicegroup *dg in pr.devicegroups)
					{
						if ([dgid compare:dg.did] == NSOrderedSame)
						{
							adg = dg;
							apr = pr;
							break;
						}
					}
				}

				if (adg != nil) break;
			}
		}

		if (adg != nil)
		{
			[lines addObject:[NSString stringWithFormat:@"Device assigned to device group \"%@\" of project \"%@\".", adg.name, apr.name]];
		}
		else
		{
			[lines addObject:[NSString stringWithFormat:@"Device assigned to a device group of ID \"%@\".", dgid]];
		}
	}
	else
	{
		[lines addObject:@"Device is not assigned to a device group."];
	}


	// Add the assembled lines to the log view and re-check for URLs

	[self printInfoInLog:lines];
	[self parseLog];
}



- (IBAction)logDeviceCode:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (currentDevicegroup.models.count == 0)
	{
		[self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no device code.", currentDevicegroup.name] :YES];
		return;
	}

	BOOL done = NO;

	for (Model *model in currentDevicegroup.models)
	{
		if ([model.type compare:@"device"] == NSOrderedSame)
		{
			if ((currentDevicegroup.squinted & kDeviceCodeSquinted) == 0) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" has not been compiled using the latest device code.", currentDevicegroup.name] :YES];

			done = YES;
			[self writeStringToLog:@"Device Code:" :NO];
			[self writeStringToLog:@" " :NO];
			[extraOpQueue addOperationWithBlock:^{[self listCode:model.code :-1 :-1 :-1 :-1];}];
			break;
		}
	}

	if (!done) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no device code.", currentDevicegroup.name] :YES];
}



- (IBAction)logAgentCode:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (currentDevicegroup.models.count == 0)
	{
		[self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no agent code.", currentDevicegroup.name] :YES];
		return;
	}

	BOOL done = NO;

	for (Model *model in currentDevicegroup.models)
	{
		if ([model.type compare:@"agent"] == NSOrderedSame)
		{
			if ((currentDevicegroup.squinted & kAgentCodeSquinted) == 0) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" has not been compiled using the latest agent code.", currentDevicegroup.name] :YES];

			done = YES;
			[self writeStringToLog:@"Agent Code:" :NO];
			[self writeStringToLog:@" " :NO];
			[extraOpQueue addOperationWithBlock:^{[self listCode:model.code :-1 :-1 :-1 :-1];}];
			break;
		}
	}

	if (!done) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no agent code.", currentDevicegroup.name] :YES];
}



- (IBAction)clearLog:(id)sender
{
	[logTextView setString:@""];
}



- (void)printInfoInLog:(NSMutableArray *)lines
{
	// Determine the number of characters in the longest line...

	NSInteger dashCount = 0;

	for (NSString *string in lines)
	{
		if (string.length > dashCount) dashCount = string.length;
	}

	// ...then build a string of dashes that long

	NSString *dashes = @"";

	for (NSUInteger i = 0 ; i < dashCount ; ++i)
	{
		dashes = [dashes stringByAppendingString:@"-"];
	}

	// Write out the dashes

	[self writeStringToLog:dashes :NO];

	// Write out the lines themselves

	for (NSString *string in lines)
	{
		[self writeStringToLog:string :NO];
	}

	// Write out the dashes

	[self writeStringToLog:dashes :NO];
}



- (void)writeStringToLog:(NSString *)string :(BOOL)addTimestamp
{
	logTextView.editable = YES;

	//NSTextStorage *ts = [logTextView textStorage];

	// Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

	// [logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];

	if (addTimestamp)
	{
		NSString *date = [def stringFromDate:[NSDate date]];
		date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
		[logTextView insertText:date replacementRange:NSMakeRange(logTextView.string.length, 0)];
		[logTextView insertText:@" " replacementRange:NSMakeRange(logTextView.string.length, 0)];

		//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withString:date];
		//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withString:@" "];
	}

	if (string != nil) {
		[logTextView insertText:string replacementRange:NSMakeRange(logTextView.string.length, 0)];
		//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withString:string];
	}

	[logTextView insertText:@"\n" replacementRange:NSMakeRange(logTextView.string.length, 0)];
	//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withString:@"\n"];

	logTextView.editable = NO;
}



- (void)writeErrorToLog:(NSString *)string :(BOOL)addTimestamp
{
	[self writeNoteToLog:string :[NSColor redColor] :addTimestamp];
}



- (void)writeWarningToLog:(NSString *)string :(BOOL)addTimestamp
{
	[self writeNoteToLog:string :[NSColor orangeColor] :addTimestamp];
}



- (void)writeNoteToLog:(NSString *)string :(NSColor *)colour :(BOOL)addTimestamp
{
	NSArray *values = [NSArray arrayWithObjects:colour, nil];
	NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, nil];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
	NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	[self writeStyledStringToLog:attrString :addTimestamp];
}



- (void)writeStyledStringToLog:(NSAttributedString *)string :(BOOL)addTimestamp
{
	logTextView.editable = YES;

	// Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

	//[logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];

	NSDictionary *attributes = [string fontAttributesInRange:NSMakeRange(0, string.length)];

	if (addTimestamp)
	{
		NSString *date = [def stringFromDate:[NSDate date]];
		date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

		[logTextView insertText:[[NSAttributedString alloc] initWithString:date attributes:attributes] replacementRange:NSMakeRange(logTextView.string.length, 0)];
		//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withAttributedString:[[NSAttributedString alloc] initWithString:date attributes:attributes]];
		
		[logTextView insertText:@" " replacementRange:NSMakeRange(logTextView.string.length, 0)];
		//[ts replaceCharactersInRange:NSMakeRange(ts.length, 0) withString:@" "];
	}

	if (string != nil) [logTextView insertText:string replacementRange:NSMakeRange(logTextView.string.length, 0)];

	[logTextView insertText:@"\n" replacementRange:NSMakeRange(logTextView.string.length, 0)];

	logTextView.editable = NO;
}



- (NSString *)getDisplayPath:(NSString *)path
{
	NSInteger index = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];

	if (index == 0) path = [self getAbsolutePath:currentProject.path :path];

	if (index == 2)
	{
		path = [self getAbsolutePath:currentProject.path :path];
		path = [self getRelativeFilePath:[@"~/" stringByStandardizingPath] :[path stringByDeletingLastPathComponent]];
	}

	return path;
}



- (void)showCodeErrors:(NSNotification *)note
{
	NSDictionary *data = (NSDictionary *)note.object;
	NSDictionary *object = [data objectForKey:@"object"];
	Devicegroup *devicegroup = [object objectForKey:@"devicegroup"];
	NSMutableArray *errors = [data objectForKey:@"data"];

	if (errors.count > 0)
	{
		[self writeErrorToLog:@"Server-reported syntax-check code errors listed below." :YES];
		[self writeErrorToLog:@" " :NO];

		for (NSArray *error in errors)
		{
			NSDictionary *err = [error objectAtIndex:0];
			NSUInteger row = [[err objectForKey:@"row"] integerValue];
			NSUInteger col = [[err objectForKey:@"column"] integerValue];
			NSString *filename = [err objectForKey:@"file"];
			NSArray *parts = [filename componentsSeparatedByString:@"_"];
			filename = [parts objectAtIndex:0];

			[self writeErrorToLog:[NSString stringWithFormat:@"Error in %@ code: %@ (line %lu, column %lu)", filename, [err objectForKey:@"text"], (unsigned long)row, (unsigned long)col] :NO];

			for (Model *model in devicegroup.models)
			{
				if ([model.type compare:filename] == NSOrderedSame)
				{
					[self listCode:model.code :row - 5 :row + 5 :row :col];
				}
			}
		}
	}
}



- (void)listCode:(NSString *)code :(NSUInteger)from :(NSUInteger)to :(NSUInteger)at :(NSUInteger)col
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

	lineStart = (from < 1) ? 1 : from;
	lineEnd = (to > lineTotal || to < 1) ? lineTotal : to;

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

	lineHighlight = (at > lineEnd || at < lineStart) ? -1 : at;

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
	[self writeStringToLog:listString :NO];
	[self writeStringToLog:@" " :NO];
}



- (void)writeStreamToLog:(NSAttributedString *)string
{
	logTextView.editable = YES;

	// Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

	[logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];

	if (string != nil && string.length > 0)
	{
		[logTextView insertText:string replacementRange:NSMakeRange(logTextView.string.length, 0)];
	}

	[logTextView insertText:@"\n" replacementRange:NSMakeRange(logTextView.string.length, 0)];

	logTextView.editable = NO;
}



- (void)displayError:(NSNotification *)note;
{
	// Relay a BuildAPIAccess error

	NSDictionary *error = (NSDictionary *)note.object;
	NSString *errorMessage = [error objectForKey:@"message"];
	NSNumber *code = [error objectForKey:@"code"];
	NSInteger errorCode = [code integerValue];

	if (loginFlag)
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

		loginFlag = NO;
	}
	else
	{
		// The error was not specifically related to log in

		NSString *errString = (errorCode == kErrorNetworkError) ? @"[NETWORK ERROR] " : @"";

		[self writeErrorToLog:[errString stringByAppendingString:errorMessage] :YES];
	}
}



#pragma mark - External Editor Methods


- (IBAction)externalOpen:(id)sender
{
    // Open the original source code files an external editor

	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (sender == externalOpenDeviceItem || sender == externalOpenBothItem || sender == externalOpenMenuItem || sender == viewDeviceCode)
    {
		for (Model *model in currentDevicegroup.models)
		{
			if ([model.type compare:@"device"] == NSOrderedSame)
			{
				[self switchToEditor:model];
				break;
			}
		}
    }
    
    if (sender == externalOpenAgentItem || sender == externalOpenBothItem || sender == externalOpenMenuItem || sender == viewAgentCode)
    {
		for (Model *model in currentDevicegroup.models)
		{
			if ([model.type compare:@"agent"] == NSOrderedSame)
			{
				[self switchToEditor:model];
				break;
			}
		}
    }
}



- (void)switchToEditor:(Model *)model
{
	if (model.hasMoved)
	{
		// We've previously recorded that the model file or its parent project file have moved, so warn the user and bail

		[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Source file \"%@\" can't be found it is known location.", model.filename] :YES];
		return;
	}

	NSString *path = [NSString stringWithFormat:@"%@/%@", model.path, model.filename];
	path = [self getAbsolutePath:currentProject.path :path];
	[nswsw openFile:path];
}



- (IBAction)externalLibOpen:(id)sender
{
    // Open class libraries in an external editor

	if (sender == externalOpenLibsItem)
    {
		for (Model *model in currentDevicegroup.models)
		{
			if (model.libraries.count > 0)
			{
				for (File *lib in model.libraries)
				{
					if (lib.hasMoved)
					{
						[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Library \"%@\" can't be found it is known location.", model.filename] :YES];
					}
					else
					{
						NSString *path = [self getAbsolutePath:currentProject.path :lib.path];
						path = [path stringByAppendingFormat:@"/%@", lib.filename];
						[nswsw openFile:path];

						// Yosemite seems to require a delay between NSWorkspace accesses, or not all files will be loaded

						[NSThread sleepForTimeInterval:0.2];
					}
				}
			}
		}
    }
    else
    {
        NSMenuItem *item = (NSMenuItem *)sender;
        NSString *name = item.representedObject;

		for (Model *model in currentDevicegroup.models)
		{
			if (model.libraries.count > 0)
			{
				for (File *lib in model.libraries)
				{
					if ([lib.filename compare:name] == NSOrderedSame)
					{
						if (lib.hasMoved)
						{
							[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Library \"%@\" can't be found it is known location.", model.filename] :YES];
							return;
						}
						else
						{
							NSString *path = [self getAbsolutePath:currentProject.path :lib.path];
							path = [path stringByAppendingFormat:@"/%@", lib.filename];
							[nswsw openFile:path];
						}

						break;
					}
				}
			}
		}
	}
}



- (IBAction)externalFileOpen:(id)sender
{
	// Open included files in an external editor

	if (sender == externalOpenFileItem)
	{
		for (Model *model in currentDevicegroup.models)
		{
			if (model.files.count > 0)
			{
				for (File *file in model.files)
				{
					if (file.hasMoved)
					{
						[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] File \"%@\" can't be found it is known location.", model.filename] :YES];
					}
					else
					{
						NSString *path = [self getAbsolutePath:currentProject.path :file.path];
						path = [path stringByAppendingFormat:@"/%@", file.filename];
						[nswsw openFile:path];

						// Yosemite seems to require a delay between NSWorkspace accesses, or not all files will be loaded

						[NSThread sleepForTimeInterval:0.2];
					}
				}
			}
		}
	}
	else
	{
		NSMenuItem *item = (NSMenuItem *)sender;

		for (Model *model in currentDevicegroup.models)
		{
			if (model.files.count > 0)
			{
				for (File *file in model.files)
				{
					if ([file.filename compare:item.title] == NSOrderedSame)
					{
						if (file.hasMoved)
						{
							[self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] File \"%@\" can't be found it is known location.", model.filename] :YES];

						}
						else
						{
							NSString *path = [self getAbsolutePath:currentProject.path :file.path];
							path = [path stringByAppendingFormat:@"/%@", file.filename];
							[nswsw openFile:path];
						}

						break;
					}
				}
			}
		}
	}
}



- (IBAction)externalOpenAll:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	[self externalOpen:externalOpenBothItem];

	// Add a delay, or the second open is somehow missed out

	[NSThread sleepForTimeInterval:0.2];

	if (sender != externalOpenBothItem)
	{
		[self externalLibOpen:externalOpenLibsItem];
		[NSThread sleepForTimeInterval:0.2];
		[self externalFileOpen:externalOpenFileItem];
	}
}



- (IBAction)openAgentURL:(id)sender
{
	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSString *urlstring = [NSString stringWithFormat:@"https://agent.electricimp.com/%@", [self getValueFrom:selectedDevice withKey:@"agent_id"]];

	[nswsw openURL:[NSURL URLWithString:urlstring]];
}



- (IBAction)showProjectInFinder:(id)sender
{
	if (currentProject == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
		return;
	}

	[nswsw selectFile:[NSString stringWithFormat:@"%@/%@", currentProject.path, currentProject.filename] inFileViewerRootedAtPath:currentProject.path];
}



- (IBAction)showModelFilesInFinder:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	if (currentDevicegroup.models.count > 0)
	{
		Model *md = [currentDevicegroup.models objectAtIndex:0];
		NSString *mPath = [self getAbsolutePath:currentProject.path :md.path];

		if (mPath.length > 0) [nswsw selectFile:[NSString stringWithFormat:@"%@/%@", mPath, md.filename] inFileViewerRootedAtPath:mPath];

		if (currentDevicegroup.models.count > 1)
		{
			md = [currentDevicegroup.models objectAtIndex:1];
			NSString *mPath2 = [self getAbsolutePath:currentProject.path :md.path];

			if ([mPath compare:mPath2] != NSOrderedSame) [nswsw selectFile:[NSString stringWithFormat:@"%@/%@", mPath2, md.filename] inFileViewerRootedAtPath:mPath2];
		}
	}
}



- (void)launchLibsPage
{
	[nswsw openURL:[NSURL URLWithString:@"https://electricimp.com/docs/libraries/"]];
}



#pragma mark - UI Update Methods


- (void)refreshProjectsMenu
{
	// Manages the Projects menu's state,
	// except for the Open Projects submenu ('refreshOpenProjectsMenu')
	// and the Current Products submenu ('refreshProductsmenu')

	if (currentProject != nil)
	{
		// A project is selected

		showProjectInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", currentProject.name];
		showProjectFinderMenuItem.title = [NSString stringWithFormat:@"Show “%@” in Finder", currentProject.name];
		renameProjectMenuItem.title = [NSString stringWithFormat:@"Edit “%@”...", currentProject.name];
		syncProjectMenuItem.title = currentProject.pid.length > 0 ? [NSString stringWithFormat:@"Sync “%@”", currentProject.name] : [NSString stringWithFormat:@"Upload “%@”", currentProject.name];

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
		syncProjectMenuItem.title = @"Upload Project";

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

	showProjectInfoMenuItem.enabled = (currentProject != nil) ? YES : NO;
	showProjectFinderMenuItem.enabled = (currentProject != nil) ? YES : NO;
	renameProjectMenuItem.enabled = (currentProject != nil) ? YES : NO;
	downloadProductMenuItem.enabled = (selectedProduct != nil) ? YES : NO;
	linkProductMenuItem.enabled = (currentProject != nil && selectedProduct != nil) ? YES : NO;
	deleteProductMenuItem.enabled = (selectedProduct != nil) ? YES : NO;
	renameProductMenuItem.enabled = (selectedProduct != nil) ? YES : NO;
	syncProjectMenuItem.enabled = (currentProject != nil && currentProject.pid.length == 0) ? YES : NO;

	// Update the File menu's one changeable item

	fileAddFilesMenuItem.enabled = (currentProject != nil) ? YES : NO;
}



- (void)refreshOpenProjectsMenu
{
	// This method manages the Open projects submenu of the Projects menu
	// It also handles the Projects Popup

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
			subitem.tag = [openProjectsMenu indexOfItem:item];
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
					projectsPopUp.selectedItem.title = [NSString stringWithFormat:@"%@/%@", currentProject.name, currentDevicegroup.name];
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



- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle :(Project *)aProject
{
	// Create a new menu entry to the 'Projects' menu’s 'Open Projects' submenu and to the Current Project popup
	// For the Open Projects submenu, each menu item's representedObject points to the named project
	// For the Current Project popup, each menu item's tag is set to the index of the project in the submenu
	// This allows us to choose projects irrespective of the name used in the menu, for example letting us
	// distinguish between 'explorer' and 'explorer 2'

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
			if ([item.title compare:menuItemTitle] == NSOrderedSame)
			{
				// The title is there already - but does the menu item reference the same project?

				if (aProject == item.representedObject)
				{
					// Yes it does, so signal failure to add

					return NO;
				}
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

	NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:menuItemTitle action:@selector(chooseProject:) keyEquivalent:@""];
	item.representedObject = aProject;
	item.state = NSOnState;
	[openProjectsMenu addItem:item];

	// ...and add it to the popup and select it

	[projectsPopUp addItemWithTitle:menuItemTitle];
	NSMenuItem *pitem = [projectsPopUp itemWithTitle:menuItemTitle];
	pitem.tag = [openProjectsMenu indexOfItem:item];
	projectsPopUp.enabled = YES;
	[projectsPopUp selectItem:pitem];

	// Return success
	
	return YES;
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
		// No products in the list, so warn the user and bail

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
		// No products in the list, so warn the user and bail

		item = [[NSMenuItem alloc] initWithTitle:@"None"
										  action:nil
								   keyEquivalent:@""];
		item.enabled = NO;
		item.state = NSOffState;
		[productsMenu addItem:item];
		return;
	}

	for (NSMutableDictionary *aProduct in productsArray)
	{
		// Run through the list of products and add a menu item for each

		NSString *name = [self getValueFrom:aProduct withKey:@"name"];
		item = [[NSMenuItem alloc] initWithTitle:name
										  action:@selector(chooseProduct:)
								   keyEquivalent:@""];
		item.representedObject = aProduct;
		item.state = NSOffState;
		[productsMenu addItem:item];
	}

	// Add the update command

	item = [NSMenuItem separatorItem];
	[productsMenu addItem:item];

	item = [[NSMenuItem alloc] initWithTitle:@"Update Products List"
									  action:@selector(getProductsFromServer:)
							   keyEquivalent:@""];
	item.enabled = YES;
	item.state = NSOffState;
	item.representedObject = nil;
	[productsMenu addItem:item];

	// Re-select the existing item or select the first on the list
	// NOTE we do this by comparing IDs because the selected product's
	// reference will have changed if the list was updated

	if (selectedProduct != nil)
	{
		for (item in productsMenu.itemArray)
		{
			if (item.representedObject == selectedProduct)
			{
				item.state = NSOnState;
				break;
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



- (void)refreshDevicegroupMenu
{
	// Rebuild the Device Groups menu's submenu of current project device groups
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
		for (Devicegroup *dg in currentProject.devicegroups)
		{
			item = [[NSMenuItem alloc] initWithTitle:dg.name
											  action:@selector(chooseDevicegroup:)
									   keyEquivalent:@""];
			item.representedObject = dg;
			item.state = (dg == currentDevicegroup) ? NSOnState : NSOffState;
			[deviceGroupsMenu addItem:item];
		}

		// Add the 'fixed' menu entries

		item = [NSMenuItem separatorItem];
		[deviceGroupsMenu addItem:item];

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
		Project *pr = [projectArray objectAtIndex:item.tag];
		item.title = [NSString stringWithFormat:@"%@/%@", pr.name, currentDevicegroup.name];
	}

	// Now go and build the assigned devices submenus
	// This SHOULD be only place we call this but may not be

	[self refreshDevicesMenus];
}




- (void)refreshMainDevicegroupsMenu
{
	// This method updates the main Device Groups menu, ie. all but the list of
	// the current Project's Device Groups, which is handled by 'refreshDevicegroupMenu:'
	// This menu controls the View menu

	NSMenuItem *item;
	BOOL compiled = YES;
	BOOL gotFiles = YES;

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

	showDeviceGroupInfoMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
	showModelFilesFinderMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
	restartDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
	listCommitsMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
	deleteDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
	renameDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
	compileMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
	uploadMenuItem.enabled = (currentDevicegroup != nil && compiled == YES) ? YES : NO;
	uploadExtraMenuItem.enabled = (currentDevicegroup != nil && compiled == YES) ? YES : NO;
	checkImpLibrariesMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
	removeFilesMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;

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



- (void)refreshDevicesMenus
{
	// Rebuild the various sub-menus of devices assigned to the
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
		// Remove existing device sub-menus

		for (menuItem in deviceGroupsMenu.itemArray)
		{
			if (menuItem.submenu != nil)
			{
				[menuItem.submenu removeAllItems];
				menuItem.submenu = nil;
			}
		}
	}

	// Rebuild the sub-menus

	for (NSMutableDictionary *device in devicesArray)
	{
		NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
		NSString *dgid = (NSString *)[dg objectForKey:@"id"];

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
							// If there's no devices submenu, add one

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

			for (NSMenuItem	*ditem in items)
			{
				[item.submenu addItem:ditem];
				if (ditem.isHidden) ditem.hidden = NO;
			}
		}
	}

	// Re-select the selected device, if there is one
	// NOTE the selected device may not be represented here becuase
	// it's assigned to another device group or is assigned
	// NOTE A new device group will have no devices, so this won't
	// select any part of the menu

	if (selectedDevice != nil)
	{
		BOOL flag = NO;
		NSString *devid = [selectedDevice objectForKey:@"id"];

		// For 'deviceGroupsMenu' we have to iterate through any submenus
		// and compare the IDs of the represented device and the selectedDevice
		// as the objects may be identical by value but not by reference

		for (NSMenuItem *item in deviceGroupsMenu.itemArray)
		{
			if (item.submenu != nil)
			{
				for (NSMenuItem *sitem in item.submenu.itemArray)
				{
					NSMutableDictionary *sdict = (NSMutableDictionary *)sitem.representedObject;
					NSString *sid = [sdict objectForKey:@"id"];

					if ([devid compare:sid] == NSOrderedSame)
					{
						// Set 'selectedDevice' to point at the right object

						selectedDevice = sdict;
						sitem.state = NSOnState;
						flag = YES;
						break;
					}
				}
			}

			if (flag) break;
		}
	}
}



- (void)refreshDeviceMenu
{
	if (selectedDevice != nil)
	{
		NSString *dName = [self getValueFrom:selectedDevice withKey:@"name"];

		showDeviceInfoMenuItem.title = [NSString stringWithFormat:@"Show “%@” Info", dName];
		restartDeviceMenuItem.title = [NSString stringWithFormat:@"Restart “%@”", dName];
		copyAgentURLMenuItem.title = [NSString stringWithFormat:@"Copy “%@” Agent URL", dName];
		openAgentURLMenuItem.title = [NSString stringWithFormat:@"Open “%@” Agent URL", dName];
		unassignDeviceMenuItem.title = [NSString stringWithFormat:@"Unassign “%@”", dName];
		getLogsMenuItem.title = [NSString stringWithFormat:@"Get Logs from “%@”", dName];
		getHistoryMenuItem.title = [NSString stringWithFormat:@"Get History of “%@”", dName];
		deleteDeviceMenuItem.title = [NSString stringWithFormat:@"Delete “%@”", dName];

		BOOL flag = [ide isDeviceLogging:[selectedDevice objectForKey:@"id"]];
		streamLogsMenuItem.title = (flag) ? @"Stop Log Streaming" : @"Start Log Streaming";
	}
	else
	{
		showDeviceInfoMenuItem.title = @"Show Device Info";
		restartDeviceMenuItem.title = @"Restart Device";
		copyAgentURLMenuItem.title = @"Copy Device’s Agent URL";
		openAgentURLMenuItem.title = @"Open Device’s Agent URL";
		unassignDeviceMenuItem.title = @"Unassign Device";
		getLogsMenuItem.title = @"Get Logs from Device";
		getHistoryMenuItem.title = @"Get History of Device";
		deleteDeviceMenuItem.title = @"Delete Device";
		streamLogsMenuItem.title = @"Start Log Streaming";
	}

	showDeviceInfoMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	restartDeviceMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	copyAgentURLMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	openAgentURLMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	unassignDeviceMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	getLogsMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	getHistoryMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	streamLogsMenuItem.enabled = (selectedDevice != nil) ? YES : NO;
	deleteDeviceMenuItem.enabled = (selectedDevice != nil) ? YES : NO;

	unassignDeviceMenuItem.enabled = (devicesArray.count > 0) ? YES : NO;
	renameDeviceMenuItem.enabled = (devicesArray.count > 0) ? YES : NO;
	assignDeviceMenuItem.enabled = (devicesArray.count > 0 && projectArray.count > 0) ? YES : NO;
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
			NSMutableDictionary *device = [devicesArray objectAtIndex:i];
			NSString *dvName = [self getValueFrom:device withKey:@"name"];
			[devicesPopUp addItemWithTitle:dvName];

			NSMenuItem *item = [devicesPopUp itemWithTitle:dvName];
			item.tag = i;
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
	
	if (selectedDevice != nil)
	{
		// Select the correct pop-up item

		NSString *dvName = [self getValueFrom:selectedDevice withKey:@"name"];
		[devicesPopUp selectItemWithTitle:dvName];
	}
	else
	{
		// Selecte the first device on the list

		[devicesPopUp selectItemAtIndex:0];
		selectedDevice = [devicesArray objectAtIndex:0];
	}

	// Update the list of unassigned devices - this only happens here
	
	[self refreshUnassignedDevicesMenu];
}



- (void)refreshUnassignedDevicesMenu
{
	// Rebuild the various sub-menus of development devices assigned to the
	// listed device groups, ie. those belonging to the current project

	// NOTE 'refreshDevicesPopup:' handles the 'no devices' warning

	// NOTE #2 This should ALWAYS be called after 'refreshDevicesPopup:'

	[unassignedDevicesMenu removeAllItems];

	NSMutableArray *items = nil;
	NSMutableArray *repos = nil;

	for (NSMutableDictionary *device in devicesArray)
	{
		NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
		NSString *dgid = [dg objectForKey:@"id"];
		NSString *dvName = [self getValueFrom:device withKey:@"name"];

		if (dgid == nil || ((NSNull *)dgid == [NSNull null]))
		{
			// If there is no device group ID, so the device must be unassigned

			if (items == nil) items = [[NSMutableArray alloc] init];
			if (repos == nil) repos = [[NSMutableArray alloc] init];

			[items addObject:dvName];
			[repos addObject:device];
		}
	}

	if (items.count > 0)
	{
		// Populate the menu

		for (NSUInteger i = 0 ; i < items.count ; ++i)
		{
			NSString *device = [items objectAtIndex:i];
			NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:device action:@selector(chooseDevice:) keyEquivalent:@""];

			NSMutableDictionary *rep = [repos objectAtIndex:i];
			item.representedObject = rep;
			item.state = (selectedDevice == rep) ? NSOnState : NSOffState;
			item.image = [self menuImage:rep];
			[unassignedDevicesMenu addItem:item];
		}
	}
	else
	{
		// No unassigned devices, so add 'None'

		NSMenuItem *item = [[NSMenuItem alloc] initWithTitle:@"None" action:nil keyEquivalent:@""];
		item.enabled = NO;
		[unassignedDevicesMenu addItem:item];
	}
}



- (void)refreshViewMenu
{
	// The View menu has two items. These are only actionable if there is a selected device group
	// and that device group's code has has been compiled

	logDeviceCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kDeviceCodeSquinted) ? YES : NO;
	logAgentCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kAgentCodeSquinted) ? YES : NO;
}



- (void)refreshRecentFilesMenu
{
	NSMenuItem *item;

	[openRecentMenu removeAllItems];

	// 'recentFiles' is set by 'addRecentFileToMenu:' and initialised at startup by reading in from the defaults

	if (recentFiles == nil || recentFiles.count == 0)
	{
		item = [[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(clearRecent:) keyEquivalent:@""];
		item.enabled = NO;
		[openRecentMenu addItem:item];
	}
	else
	{
		for (NSDictionary *file in recentFiles)
		{
			item = [[NSMenuItem alloc] initWithTitle:[file objectForKey:@"name"] action:@selector(openRecent:) keyEquivalent:@""];
			item.enabled = YES;
			item.representedObject = file;
			[openRecentMenu addItem:item];
		}

		[openRecentMenu addItem:[NSMenuItem separatorItem]];

		item = [[NSMenuItem alloc] initWithTitle:@"Open All" action:@selector(openRecentAll) keyEquivalent:@""];
		item.enabled = YES;
		[openRecentMenu addItem:item];

		[openRecentMenu addItem:[NSMenuItem separatorItem]];

		item = [[NSMenuItem alloc] initWithTitle:@"Clear Menu" action:@selector(clearRecent:) keyEquivalent:@""];
		item.enabled = YES;
		[openRecentMenu addItem:item];
	}
}



- (IBAction)showHideToolbar:(id)sender
{
	// Flip the menu item in the View menu

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



#pragma mark Imported Library and File List Methods


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
		m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Agent Code";
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

		m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Device Code";
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
			if ([model.type compare:@"agent"] == NSOrderedSame)
			{
				[self libAdder:model.impLibraries :YES];
			}
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
			if ([model.type compare:@"device"] == NSOrderedSame)
			{
				[self libAdder:model.impLibraries :YES];
			}
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
	for (File *lib in libs)
	{
		[self addLibraryToMenu:lib :isEILib :YES];
	}
}



- (void)addLibraryToMenu:(File *)lib :(BOOL)isEILib :(BOOL)isActive
{
	// Create a new menu entry for the libraries menus

	NSMenuItem *item;

	if (isEILib)
	{
		item = [[NSMenuItem alloc] initWithTitle:[lib.filename stringByAppendingFormat:@" (%@)", lib.version] action:@selector(launchLibsPage) keyEquivalent:@""];
		[impLibrariesMenu addItem:item];
	}
	else
	{
		if (isActive)
		{
			item = [[NSMenuItem alloc] initWithTitle:[lib.filename stringByAppendingFormat:@" (%@)", ((lib.version.length == 0) ? @"unknown" : lib.version)]  action:@selector(externalLibOpen:) keyEquivalent:@""];
			item.representedObject = lib.filename;
		}
		else
		{
			item = [[NSMenuItem alloc] initWithTitle:lib.filename action:nil keyEquivalent:@""];
		}

		item.enabled = isActive;
		[externalLibsMenu addItem:item];
	}
}


- (NSImage *)menuImage:(NSMutableDictionary *)device
{
	// Sets a device menu's icon according to the device's connection status

	NSImage *returnImage = nil;
	NSString *nameString = @"";

	NSNumber *boolean = [self getValueFrom:device withKey:@"device_online"];
	NSString *dvid = [self getValueFrom:device withKey:@"id"];

	nameString = boolean.boolValue ? @"online" : @"offline";
	if ([ide isDeviceLogging:dvid]) nameString = [nameString stringByAppendingString:@"_logging"];

	returnImage = [NSImage imageNamed:nameString];
	return returnImage;
}


- (NSString *)menuString:(NSMutableDictionary *)device
{
	// Creates the status readout that will be added to the device's name in menus
	// eg. "Action (logging)"

	NSString *statusString = @"";
	NSString *loggingString = @"";
	NSString *returnString = @"";

	NSString *dvid = [self getValueFrom:device withKey:@"id"];
	NSNumber *boolean = [self getValueFrom:device withKey:@"device_online"];

	if (!boolean.boolValue) statusString = @"offline";
	if ([ide isDeviceLogging:dvid]) loggingString = @"logging";

	// Assemble the menuString, eg.
	// "(offline)", "(offline, logging)", "(logging)"

	if (loggingString.length > 0 || statusString.length > 0)
	{
		// Start with a space and an open bracket

		returnString = @" (";

		// Add in the offline status indicator if there is one

		if (statusString.length > 0) returnString = [returnString stringByAppendingString:statusString];

		// If we are logging too, add that in too, prefixing with a comma and space
		// if we have already added offline status

		if (loggingString.length > 0)
		{
			if (statusString.length > 0) returnString = [returnString stringByAppendingString:@", "];
			returnString = @" (logging)";
		}

		// Finish with a close bracket

		returnString = [returnString stringByAppendingString:@")"];
	}

	return returnString;
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
			aFileCount = aFileCount + model.files.count;
		}
		else
		{
			dFileCount = dFileCount + model.files.count;
		}
	}

	// Add agent files, if any

	if (aFileCount > 0)
	{
		m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Agent Code";

		[self addFileToMenu:m :NO];

		for (Model *model in currentDevicegroup.models)
		{
			if ([model.type compare:@"agent"] == NSOrderedSame)
			{
				[self fileAdder:model.files];
			}
		}
	}

	// Add device files, if any

	if (dFileCount > 0)
	{
		// Drop in a spacer if we have any files above

		if (aFileCount > 0) [externalFilesMenu addItem:[NSMenuItem separatorItem]];

		//m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Device Code";

		[self addFileToMenu:@"Device Code" :NO];

		for (Model *model in currentDevicegroup.models)
		{
			if ([model.type compare:@"device"] == NSOrderedSame)
			{
				[self fileAdder:model.files];
			}
		}
	}

	if (dFileCount == 0 && aFileCount == 0)
	{
		[self addFileToMenu:@"None" :NO];
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
	for (File *file in models)
	{
		[self addFileToMenu:file.filename :YES];
	}
}



- (void)addFileToMenu:(NSString *)filename :(BOOL)isActive
{
	// Adds a model's imported file to the menu list

	NSMenuItem *item;

	if (isActive)
	{
		item = [[NSMenuItem alloc] initWithTitle:filename action:@selector(externalFileOpen:) keyEquivalent:@""];
	}
	else
	{
		item = [[NSMenuItem alloc] initWithTitle:filename action:nil keyEquivalent:@""];

	}

	item.enabled = isActive;
	[externalFilesMenu addItem:item];
}



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

	// Enable or disable device-specific toolbar items

	BOOL flag = [ide isDeviceLogging:[selectedDevice objectForKey:@"id"]];
	streamLogsItem.enabled = (selectedDevice != nil) ? YES : NO;
	streamLogsItem.state = flag ? kStreamToolbarItemStateOn : kStreamToolbarItemStateOff;

	// Enabled or disable the login item

	loginAndOutItem.isLocked = !ide.isLoggedIn;

	// Validate items

	[squinterToolbar validateVisibleItems];
}



#pragma mark Logging Area Methods


- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold
{
	// Set the log window's basic text settings based on preferences

	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font;

	font = isBold
	? [fontManager fontWithFamily:fontName traits:NSBoldFontMask weight:0 size:fontSize]
	: [NSFont fontWithName:fontName size:fontSize];

	return font;
}



- (void)setColours
{
	// Populate the 'colors' array with a set of colours for logging different devices

	[colors addObject:[NSColor yellowColor]];
	[colors addObject:[NSColor cyanColor]];
	[colors addObject:[NSColor magentaColor]];
	[colors addObject:[NSColor purpleColor]];
	[colors addObject:[NSColor blueColor]];
	[colors addObject:[NSColor colorWithSRGBRed:0.4 green:0.9 blue:0.5 alpha:1.0]]; // Flora (green)
	[colors addObject:[NSColor colorWithSRGBRed:1.0 green:0.2 blue:0.6 alpha:1.0]]; // Strawberry
	[colors addObject:[NSColor colorWithSRGBRed:1.0 green:0.8 blue:0.5 alpha:1.0]]; // Tangerine
	[colors addObject:[NSColor colorWithSRGBRed:0.4 green:0.9 blue:0.5 alpha:1.0]]; // Flora (green)
	[colors addObject:[NSColor colorWithSRGBRed:1.0 green:1.0 blue:1.0 alpha:1.0]]; // White
	[colors addObject:[NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:1.0]]; // Black
	[colors addObject:[NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.5 alpha:1.0]]; // Mid-grey
	[colors addObject:[NSColor colorWithSRGBRed:0.8 green:0.8 blue:0.8 alpha:1.0]]; // Light-grey
	[colors addObject:[NSColor colorWithSRGBRed:0.3 green:0.3 blue:0.3 alpha:1.0]]; // Dark-grey
	[colors addObject:[NSColor brownColor]];
}



- (void)setLoggingColours
{
	// Pick colours from the 'colours' array that are darker/lighter than the log background
	// as approrpriate

	[logColors removeAllObjects];

	NSInteger back = [self perceivedBrightness:backColour];
	// NSInteger fore = [self perceivedBrightness:textColour];

	if (back > 200)
	{
		// Background is light

		for (NSColor *colour in colors)
		{
			NSInteger stock = [self perceivedBrightness:colour];

			if (back - stock > 40)
			{
				// Colour is dark enough to use against this background
				// But is it too close to the text colour ?
				
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

			if (stock - back > 40) [logColors addObject:colour];
		}
	}
}



- (NSInteger)perceivedBrightness:(NSColor *)colour
{
	// Returns the perceived brightness of the specified colour
	// Used to pick colours that will stand out against the log's background color

	CGFloat red, blue, green, alpha;
	[colour colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
	[colour getRed:&red green:&green blue:&blue alpha:&alpha];
	red = red * 255;
	blue = blue * 255;
	green = green * 255;
	return (NSInteger)sqrt((red * red * .241) + (green * green * .691) + (blue * blue * .068));
}



#pragma mark Progress Methods


- (void)startProgress
{
    [connectionIndicator startAnimation:self];
	connectionIndicator.hidden = NO;
}



- (void)stopProgress
{
    [connectionIndicator stopAnimation:self];
    connectionIndicator.hidden = YES;
}



#pragma mark About Sheet Methods


- (IBAction)showAboutSheet:(id)sender
{
	[aboutVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@.%@",
									   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
									   [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
	[_window beginSheet:aboutSheet completionHandler:nil];
}



- (IBAction)viewSquinterSite:(id)sender
{
	[_window endSheet:aboutSheet];
	[[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/version2/"]];
}



- (IBAction)closeAboutSheet:(id)sender
{
	[_window endSheet:aboutSheet];
}



#pragma mark Help Menu Methods


- (IBAction)showAuthor:(id)sender
{
	if (sender == author01) [nswsw openURL:[NSURL URLWithString:@"https://github.com/carlbrown/PDKeychainBindingsController"]];
	if (sender == author02) [nswsw openURL:[NSURL URLWithString:@"https://github.com/bdkjones/VDKQueue"]];
	if (sender == author03) [nswsw openURL:[NSURL URLWithString:@"https://github.com/uliwitness/UliKit"]];
	if (sender == author04) [nswsw openURL:[NSURL URLWithString:@"https://electricimp.com/docs/"]];
	if (sender == author05) [nswsw openURL:[NSURL URLWithString:@"https://github.com/adobe-fonts/source-code-pro"]];
	if (sender == author06) [nswsw openURL:[NSURL URLWithString:@"https://github.com/sparkle-project/Sparkle/blob/master/LICENSE"]];
}



#pragma mark Preferences Sheet Methods


- (IBAction)showPrefs:(id)sender
{
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

	preserveCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.preservews"]) ? NSOnState : NSOffState;
	autoCompileCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autocompile"]) ? NSOnState : NSOffState;
	loadModelsCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autoload"]) ? NSOnState : NSOffState;
	autoLoadListsCheckbox.state =  ([defaults boolForKey:@"com.bps.squinter.autoloadlists"]) ? NSOnState : NSOffState;
	autoUpdateCheckCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autocheckupdates"]) ? NSOnState : NSOffState;
	boldTestCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.showboldtext"]) ? NSOnState : NSOffState;
	loadDevicesCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autoloaddevlists"]) ? NSOnState : NSOffState;

	// Set location menu

	[locationMenu selectItemAtIndex:[[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue]];

	// Set recent files count menu

	NSInteger count = ([[defaults objectForKey:@"com.bps.squinter.recentFilesCount"] integerValue] / 5) - 1;

	[recentFilesCountMenu selectItemAtIndex:count];

	count = [defaults stringForKey:@"com.bps.squinter.logListCount"].integerValue;

	[maxLogCountMenu selectItemWithTag:count];

	// Show the sheet

	[_window beginSheet:preferencesSheet completionHandler:nil];
}



- (IBAction)cancelPrefs:(id)sender
{
	[_window endSheet:preferencesSheet];
}



- (IBAction)setPrefs:(id)sender
{
	workingDirectory = workingDirectoryField.stringValue;

	if (autoLoadListsCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autoloadlists"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autoloadlists"];
	}

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

	if (loadDevicesCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autoloaddevlists"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autoloaddevlists"];
	}

	if (autoUpdateCheckCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.autocheckupdates"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.autocheckupdates"];
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

	if (azureCheckbox.state == NSOnState)
	{
		[defaults setBool:YES forKey:@"com.bps.squinter.useazure"];
	}
	else
	{
		[defaults setBool:NO forKey:@"com.bps.squinter.useazure"];
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

	[logScrollView setScrollerKnobStyle:(a < 30 ? NSScrollerKnobStyleLight : NSScrollerKnobStyleDark)];

	NSString *fontName = [self getFontName:fontsMenu.indexOfSelectedItem];
	NSInteger fontSize = kInitialFontSize + sizeMenu.indexOfSelectedItem;
	if (fontSize == 15) fontSize = 18;

	logTextView.font = [self setLogViewFont:fontName :fontSize :(boldTestCheckbox.state == NSOnState)];
	[logTextView setTextColor:textColour];
	[logClipView setBackgroundColor:backColour];

	[defaults setObject:[NSNumber numberWithInteger:fontsMenu.indexOfSelectedItem] forKey:@"com.bps.squinter.fontNameIndex"];
	[defaults setObject:[NSNumber numberWithInteger:fontSize] forKey:@"com.bps.squinter.fontSizeIndex"];

	[defaults setObject:[NSNumber numberWithInteger:locationMenu.indexOfSelectedItem] forKey:@"com.bps.squinter.displaypath"];

	// Set recent files count

	NSInteger count = (recentFilesCountMenu.indexOfSelectedItem + 1) * 5;

	[defaults setObject:[NSNumber numberWithInteger:count] forKey:@"com.bps.squinter.recentFilesCount"];

	// Set max list items count

	count = maxLogCountMenu.selectedTag;
	ide.maxListCount = count;
	
	[defaults setObject:[NSNumber numberWithInteger:count] forKey:@"com.bps.squinter.logListCount"];

	// If the max is now lower than the current list total, we should prune the list

	if (recentFiles.count > count)
	{
		while (recentFiles.count > count) [recentFiles removeLastObject];
		[self refreshRecentFilesMenu];
	}

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



#pragma mark - File Watching Methods


- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath
{
    // A file has changed so notify the user
	// IMPORTANT: fpath is the MONITORED location. VDKQueue will continue watching this file wherever it is moved
	// or whatever it is renamed
	// TODO Review for new archtecture

#ifdef DEBUG
	NSLog(@"File change: %@", fpath);
#endif

	if ([noteName compare:VDKQueueRenameNotification] == NSOrderedSame)
    {
        // Called when the file is MOVED or RENAMED

        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been renamed or moved. You will need to re-add it to this device group.", [fpath lastPathComponent]] :YES];
    }
	
	if ([noteName compare:VDKQueueDeleteNotification] == NSOrderedSame)
	{
		// Only called when Trash is emptied/GitHub desktop deletes a file before saving a new version
		
		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been deleted.", [fpath lastPathComponent]] :YES];
	}
	
	if ([noteName compare:VDKQueueWriteNotification] == NSOrderedSame)
	{
		[self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] File \"%@\" has been edited - you may wish to recompile this device group's code.", [fpath lastPathComponent]] :YES];
	}
}



#pragma mark - File Path Methods


- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath
{
	// This method takes an absolute location ('filePath') and returns a location relative
	// to another location ('basePath'). Typically, this is the path to the host
	// project

	basePath = [basePath stringByStandardizingPath];
	filePath = [filePath stringByStandardizingPath];

	NSString *theFilePath = filePath;

	NSInteger nf = [self numberOfFoldersInPath:theFilePath];
	NSInteger nb = [self numberOfFoldersInPath:basePath];

	if (nf > nb) // theFilePath.length > basePath.length
	{
		// The file path is longer than the base path
		NSRange r = [theFilePath rangeOfString:basePath];

		if (r.location != NSNotFound)
		{
			// The file path contains the base path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// contains
			// '/Users/smitty/documents/github/squinter'

			theFilePath = [theFilePath substringFromIndex:r.length];
			//theFilePath = [theFilePath stringByAppendingFormat:@"/%@", theFileName];
		}
		else
		{
			// The file path does not contain the base path, eg.
			// '/Users/smitty/downloads'
			// doesn't contain
			// '/Users/smitty/documents/github/squinter'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}
	else if (nf < nb) // theFilePath.length < basePath.length
	{
		NSRange r = [basePath rangeOfString:theFilePath];

		if (r.location != NSNotFound)
		{
			// The base path contains the file path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// contains
			// '/Users/smitty/documents'

			theFilePath = [basePath substringFromIndex:r.length];
			NSArray *filePathParts = [theFilePath componentsSeparatedByString:@"/"];
			//theFilePath = theFileName;

			// Add in '../' for each directory in the base path but not in the file path

			for (NSInteger i = 0 ; i < filePathParts.count - 1 ; ++i)
			{
				theFilePath = [@"../" stringByAppendingString:theFilePath];
			}
		}
		else
		{
			// The base path doesn't contains the file path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// doesn't contain
			// '/Users/smitty/downloads'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}
	else
	{
		// The two paths are the same length

		if ([theFilePath compare:basePath] == NSOrderedSame)
		{
			// The file path and the base patch are the same, eg.
			// '/Users/smitty/documents/github/squinter'
			// matches
			// '/Users/smitty/documents/github/squinter'

			theFilePath = @"";
		}
		else
		{
			// The file path and the base patch are not the same, eg.
			// '/Users/smitty/documents/github/squinter'
			// matches
			// '/Users/smitty/downloads/archive/nofiles'

			theFilePath = [self getPathDelta:basePath :theFilePath];
			//theFilePath = [theFilePath stringByAppendingString:theFileName];
		}
	}

	return theFilePath;
}



- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath
{
	NSInteger location = -1;
	NSArray *fileParts = [filePath componentsSeparatedByString:@"/"];
	NSArray *baseParts = [basePath componentsSeparatedByString:@"/"];

	for (NSUInteger i = 0 ; i < fileParts.count ; ++i)
	{
		// Compare the two paths, directory by directory, starting at the left
		// then break when they no longer match

		NSString *filePart = [fileParts objectAtIndex:i];
		NSString *basePart = [baseParts objectAtIndex:i];

		if ([filePart compare:basePart] != NSOrderedSame)
		{
			location = i;
			break;
		}
	}

	NSString *path = @"";

	for (NSUInteger i = location ; i < baseParts.count ; ++i)
	{
		// Add a '../' for every non-matching base path directory

		path = [path stringByAppendingString:@"../"];
	}

	for (NSUInteger i = location ; i < fileParts.count ; ++i)
	{
		// Then add the actual file path directries from the no matching part

		path = [path stringByAppendingFormat:@"%@/", [fileParts objectAtIndex:i]];
	}

	// Remove the final /

	path = [path substringToIndex:(path.length - 1)];

	return path;
}



- (NSInteger)numberOfFoldersInPath:(NSString *)path
{
	NSArray *parts = [path componentsSeparatedByString:@"/"];
	return (parts.count - 1);
}



- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath
{
	// Expand a relative path that is relative to the base path to an absolute path

	NSString *absolutePath = [basePath stringByAppendingFormat:@"/%@", relativePath];
	absolutePath = [absolutePath stringByStandardizingPath];
	return absolutePath;
}



- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath
{
	// Takes an absolute path to a project and a file path relative to that same project,
	// and returns the user's preferred style of path for printing

	NSInteger pathType = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];

	switch (pathType)
	{
		case 0:
			// Absolute Path
			return [self getAbsolutePath:projectPath :filePath];
		case 1:
			// Path relative to project DEFAULT
			return filePath;
			break;

		default:
			// Path relative to home
			return [@"~" stringByAppendingString:[self getRelativeFilePath:@"~" :[self getAbsolutePath:projectPath :filePath]]];
			break;
	}
}



- (NSData *)bookmarkForURL:(NSURL *)url
{
	NSError *error = nil;
	NSData *bookmark = [url bookmarkDataWithOptions: NSURLBookmarkCreationSuitableForBookmarkFile
					 includingResourceValuesForKeys: nil
									  relativeToURL: nil
											  error: &error];

	if (error != nil) return nil;
	return bookmark;
}



- (NSURL *)urlForBookmark:(NSData *)bookmark
{
	NSError *error = nil;
	BOOL isStale = NO;
	NSURL *url = [NSURL URLByResolvingBookmarkData: bookmark
										   options: NSURLBookmarkResolutionWithoutUI
									 relativeToURL: nil
							   bookmarkDataIsStale: &isStale
											 error: &error];

	// There was an error, so return 'nil' as a warning

	if (error != nil) return nil;
	stale = isStale;
	return url;
}



#pragma mark - Check Electric Imp Libraries Methods


- (IBAction)checkElectricImpLibraries:(id)sender
{
	[self checkElectricImpLibs];
}



- (void)checkElectricImpLibs
{
	// Initiate a read of the current Electric Imp library versions
	// Only do this if the project contains EI libraries and 1 hour has
	// passed since the last look-up

	BOOL performCheck = NO;

	if (currentDevicegroup.models.count > 0)
	{
		if (eiLibListTime != nil)
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

				if (eiLibListData != nil)
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
	NSHTTPURLResponse *rps = (NSHTTPURLResponse *)response;

	if (rps.statusCode != 200)
	{
		NSString *errString =[NSString stringWithFormat:@"[ERROR] Could not get list of Electric Imp libraries (Code: %ld)", (long)rps.statusCode];
		[self writeErrorToLog:errString :YES];
		completionHandler(NSURLSessionResponseCancel);
		return;
	}

	completionHandler(NSURLSessionResponseAllow);
}



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data
{
	[eiLibListData appendData:data];
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
	if (task == eiLibListTask)
	{
		if (ide.numberOfConnections < 1)
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
		[self writeErrorToLog:@"[ERROR] Could not parse list of Electric Imp libraries" :YES];
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

				if (libParts.count == 2)
				{
					// Watch out for single-line entries in .csv file

					NSString *libName = [[libParts objectAtIndex:0] lowercaseString];
					NSString *libVer = [libParts objectAtIndex:1];

					for (Model *model in currentDevicegroup.models)
					{
						if (model.impLibraries.count > 0)
						{
							for (File *eiLib in model.impLibraries)
							{
								NSString *name = [eiLib.filename lowercaseString];

								if ([name compare:libName] == NSOrderedSame)
								{
									// Local EI lib record and download lib record match
									// First check for deprecation

									if ([libVer compare:@"dep"] == NSOrderedSame)
									{
										// Library is marked as deprecated

										NSString *mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is deprecated. Please replace it with \"%@\".", libName, [libParts objectAtIndex:2]];
										[self writeWarningToLog:mString :YES];
										allOKFlag = NO;
									}
									else if ([eiLib.version	compare:libVer] != NSOrderedSame)
									{
										// Library versions are not the same, so report the discrepancy

										NSString *mString;

										if ([eiLib.version compare:@"not set"] == NSOrderedSame)
										{
											mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is at version %@ - your code doesn't specify a version.", libName, libVer];

										}
										else
										{
											mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is at version %@ - you have version %@.", libName, libVer, eiLib.version];
											[self writeWarningToLog:mString :YES];
										}

										[self writeWarningToLog:mString :YES];
										allOKFlag = NO;
									}
								}
							}
						}
					}
				}
			}
		}

		if (allOKFlag)
		{
			[self writeStringToLog:[NSString stringWithFormat:@"All the Electric Imp libraries used in device group \"%@\" are up to date.", currentDevicegroup.name] :YES];
		}
	}
}



#pragma mark - NSTextFieldDelegate Methods

- (void)controlTextDidChange:(NSNotification *)obj
{
	id sender = obj.object;

	// New Project sheet

	if (sender == newProjectNameTextField)
	{
		if (newProjectNameTextField.stringValue.length > 80)
		{
			newProjectNameTextField.stringValue = [newProjectNameTextField.stringValue substringToIndex:80];
			NSBeep();
		}

		newProjectNameCountField.stringValue = [NSString stringWithFormat:@"%li/80", (long)newProjectNameTextField.stringValue.length];
	}

	if (sender == newProjectDescTextField)
	{
		if (newProjectDescTextField.stringValue.length > 255)
		{
			newProjectDescTextField.stringValue = [newProjectDescTextField.stringValue substringToIndex:255];
			NSBeep();
		}

		newProjectDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)newProjectDescTextField.stringValue.length];
	}

	// Rename Project Sheet

	if (sender == renameProjectTextField)
	{
		if (renameProjectTextField.stringValue.length > 80)
		{
			renameProjectTextField.stringValue = [renameProjectTextField.stringValue substringToIndex:80];
			NSBeep();
		}

		renameProjectCountField.stringValue = [NSString stringWithFormat:@"%li/80", (long)renameProjectTextField.stringValue.length];
	}

	if (sender == renameProjectDescTextField)
	{
		if (renameProjectDescTextField.stringValue.length > 255)
		{
			renameProjectDescTextField.stringValue = [renameProjectDescTextField.stringValue substringToIndex:255];
			NSBeep();
		}

		renameProjectDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)renameProjectDescTextField.stringValue.length];
	}

	// New Device Group Sheet

	if (sender == newDevicegroupNameTextField)
	{
		if (newDevicegroupNameTextField.stringValue.length > 80)
		{
			newDevicegroupNameTextField.stringValue = [newDevicegroupNameTextField.stringValue substringToIndex:80];
			NSBeep();
		}

		newDevicegroupNameCountField.stringValue = [NSString stringWithFormat:@"%li/80", (long)newDevicegroupNameTextField.stringValue.length];
	}

	if (sender == newDevicegroupDescTextField)
	{
		if (newDevicegroupDescTextField.stringValue.length > 255)
		{
			newDevicegroupDescTextField.stringValue = [newDevicegroupDescTextField.stringValue substringToIndex:255];
			NSBeep();
		}

		newDevicegroupDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)newDevicegroupDescTextField.stringValue.length];
	}

	// Rename Device Group Sheet

	// Upload Code Extra Sheet

	if (sender == uploadCommitTextField)
	{
		if (uploadCommitTextField.stringValue.length > 255)
		{
			uploadCommitTextField.stringValue = [uploadCommitTextField.stringValue substringToIndex:255];
			NSBeep();
		}

		uploadCommitCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)uploadCommitTextField.stringValue.length];
	}

	if (sender == uploadOriginTextField)
	{
		if (uploadOriginTextField.stringValue.length > 255)
		{
			uploadOriginTextField.stringValue = [uploadOriginTextField.stringValue substringToIndex:255];
			NSBeep();
		}

		uploadOriginCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)uploadOriginTextField.stringValue.length];
	}

	if (sender == uploadTagsTextField)
	{
		if (uploadTagsTextField.stringValue.length > 500)
		{
			uploadTagsTextField.stringValue = [uploadTagsTextField.stringValue substringToIndex:500];
			NSBeep();
		}

		uploadTagsCountField.stringValue = [NSString stringWithFormat:@"%li/500", (long)uploadTagsTextField.stringValue.length];
	}

	// Rename Device Sheet

	if (sender == renameName)
	{
		if (renameName.stringValue.length > 140)
		{
			renameName.stringValue = [renameName.stringValue substringToIndex:140];
			NSBeep();
		}

		renameNameLength.stringValue = [NSString stringWithFormat:@"%li/140", (long)renameName.stringValue.length];
	}
}



#pragma mark - Pasteboard Methods


- (IBAction)copyDeviceCodeToPasteboard:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	BOOL flag = NO;

	for (Model *model in currentDevicegroup.models)
	{
		if ([model.type compare:@"device"] == NSOrderedSame)
		{
			if (model.squinted && model.code.length > 0)
			{
				NSPasteboard *pb = [NSPasteboard generalPasteboard];
				NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
				[pb declareTypes:types owner:self];
				[pb setString:model.code forType:NSStringPboardType];
				[self writeStringToLog:@"Compiled device code copied to clipboard." :YES];
				flag = YES;
			}

			break;
		}
	}

	if (!flag) [self writeWarningToLog:@"[WARNING] This device group has no compiled device code to copy." :YES];
}



- (IBAction)copyAgentCodeToPasteboard:(id)sender
{
	if (currentDevicegroup == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
		return;
	}

	BOOL flag = NO;

	for (Model *model in currentDevicegroup.models)
	{
		if ([model.type compare:@"agent"] == NSOrderedSame)
		{
			if (model.squinted && model.code.length > 0)
			{
				NSPasteboard *pb = [NSPasteboard generalPasteboard];
				NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
				[pb declareTypes:types owner:self];
				[pb setString:model.code forType:NSStringPboardType];
				[self writeStringToLog:@"Compiled agent code copied to clipboard." :YES];
				flag = YES;
			}

			break;
		}
	}

	if (!flag) [self writeWarningToLog:@"[WARNING] This device group has no compiled agent code to copy." :YES];
}



- (IBAction)copyAgentURL:(id)sender
{
	if (selectedDevice == nil)
	{
		[self writeStringToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
		return;
	}

	NSString *agentid = [self getValueFrom:selectedDevice withKey:@"agent_id"];
	NSString *ustring = [NSString stringWithFormat:@"https://agent.electricimp.com/%@", agentid];
	NSPasteboard *pb = [NSPasteboard generalPasteboard];
	NSArray *ptypes = [NSArray arrayWithObjects:NSStringPboardType, nil];

	[pb declareTypes:ptypes owner:self];
	[pb setString:ustring forType:NSStringPboardType];

	[self writeStringToLog:[NSString stringWithFormat:@"The agent URL of device \"%@\" has been copied to the clipboard.", [self getValueFrom:selectedDevice withKey:@"name"]] :YES];
}



#pragma mark - Utilty Methods


- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key
{
	NSDictionary *rd = nil;

	// This extracts the required key, wherever it is in the source (API) data

	if ([key compare:@"id"] == NSOrderedSame) return [apiDict objectForKey:@"id"];
	if ([key compare:@"type"] == NSOrderedSame) return [apiDict objectForKey:@"type"];

	// Attributes General properties

	if ([key compare:@"created_at"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.created_at"];
	if ([key compare:@"updated_at"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.updated_at"];

	if ([key compare:@"name"] == NSOrderedSame)
	{
		NSString *name = [apiDict valueForKeyPath:@"attributes.name"];
		if ((NSNull *)name == [NSNull null]) return nil;
		return name;
	}

	if ([key compare:@"description"] == NSOrderedSame)
	{
		NSString *desc = [apiDict valueForKeyPath:@"attributes.description"];
		if ((NSNull *)desc == [NSNull null]) return nil;
		return desc;
	}

	// Attributes Device properties

	if ([key compare:@"device_online"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.device_online"];
	if ([key compare:@"mac_address"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.mac_address"];
	if ([key compare:@"ip_address"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.ip_address"];
	if ([key compare:@"imp_type"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.imp_type"];
	if ([key compare:@"agent_id"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.agent_id"];
	if ([key compare:@"agent_running"] == NSOrderedSame) return [NSNumber numberWithBool:[[apiDict valueForKeyPath:@"attributes.agent_running"] boolValue]];
	if ([key compare:@"swversion"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.swversion"];

	// if ([key compare:@"free_memory"] == NSOrderedSame) return (NSNumber *)[NSNumber numberWithInteger:[[apiDict valueForKeyPath:@"attributes.free_memory"] integerValue]];

	if ([key compare:@"device_state_changed_at"] == NSOrderedSame) return [self convertTimestring:[apiDict valueForKeyPath:@"attributes.device_state_changed_at"]];
	if ([key compare:@"last_blinkup_at"] == NSOrderedSame) return [self convertTimestring:[apiDict valueForKeyPath:@"attributes.last_blinkup_at"]];

	// Attributes Deployment properties - non-nullable

	if ([key compare:@"flagged"] == NSOrderedSame) return [NSNumber numberWithBool:[[apiDict valueForKeyPath:@"attributes.flagged"] boolValue]];
	if ([key compare:@"sha"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.sha"];

	// Attributes Deployment properties - nullable

	if ([key compare:@"agent_code"] == NSOrderedSame)
	{
		NSString *ac = [apiDict valueForKeyPath:@"attributes.agent_code"];
		if ((NSNull *)ac == [NSNull null]) return nil;
		return ac;
	}

	if ([key compare:@"device_code"] == NSOrderedSame)
	{
		NSString *dc = [apiDict valueForKeyPath:@"attributes.device_code"];
		if ((NSNull *)dc == [NSNull null]) return nil;
		return dc;
	}

	if ([key compare:@"origin"] == NSOrderedSame)
	{
		NSString *or = [apiDict valueForKeyPath:@"attributes.origin"];
		if ((NSNull *)or == [NSNull null]) return nil;
		return or;
	}

	if ([key compare:@"tags"] == NSOrderedSame)
	{
		NSArray *tags = [apiDict valueForKeyPath:@"attributes.tags"];
		if ((NSNull *)tags == [NSNull null]) return nil;
		return tags;
	}

	// Relationships properties

	if ([key compare:@"product"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.product"];
	if ([key compare:@"devicegroup"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.devicegroup"];
	if ([key compare:@"current_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.current_deployment"];

	if ((NSNull *)rd == [NSNull null]) return nil;
	return rd;
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
	NSArray *dgtypes = @[ @"production_devicegroup", @"factoryfixture_devicegroup", @"development_devicegroup",
						  @"pre_factoryfixture_devicegroup", @"pre_production_devicegroup"];
	NSArray *dgnames = @[ @"Production", @"Factory Fixture", @"Development", @"Factory Test", @"Production Test"];

	for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
	{
		NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];

		if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
	}

	if (!back) return @"Unknown";
	return @"development_devicegroup";
}



- (Project *)getParentProject:(Devicegroup *)devicegroup
{
	for (Project *ap in projectArray)
	{
		if (ap.devicegroups.count > 0)
		{
			for (Devicegroup *adg in ap.devicegroups)
			{
				if (adg == devicegroup) return ap;
			}
		}
	}

	return nil;
}



- (NSDate *)convertTimestring:(NSString *)dateString
{
	NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
	[dateFormatter setDateFormat:@"yyyy-mm-DD'T'hh:mm:ss.sZ"];
	NSLog(@"convertTimestring: %@", dateString);
	return [logDef dateFromString:dateString];
}



- (NSString *)getErrorMessage:(NSUInteger)index
{
	switch (index)
	{
		case kErrorMessageNoSelectedDevice:
			return @"[ERROR] You have not selected a device. Choose one from the 'Current Device' pop-up below.";

		case kErrorMessageNoSelectedDevicegroup:
			return @"[ERROR] You have not selected a device group. Go to 'Device Groups'  > 'Project's Device Groups' to select one.";

		case kErrorMessageNoSelectedProject:
			return @"[ERROR] You have not selected a project. Go to 'Projects' > 'Open Projects' to select one.";

		case kErrorMessageNoSelectedProduct:
			return @"[ERROR] You have not selected a product. Go to 'Projects' > 'Current Products' to select one.";

		case kErrorMessageMalformedOperation:
			return @"[ERROR] Malformed action request - no action specified.";
	}

	return @"No Error";
}



- (NSArray *)displayDescription:(NSString *)description :(NSInteger)maxWidth :(NSString *)spaces
{
	// Takes a device group or project description, adds a caption, and formats it as a series
	// of lines up to the specified length 'maxWidth', breaking at spaces not mid-word
	// Used by the 'showProjectInfo:' and 'showDevicegroupInfo:' methods

	description = [NSString stringWithFormat:@"Description: %@", description];

	NSInteger count = 0;
	NSMutableArray *lines = [[NSMutableArray alloc] init];

	while (count < description.length)
	{
		NSRange range = NSMakeRange(count, maxWidth);

		if (count + maxWidth > description.length) range = NSMakeRange(count, description.length - count);

		NSString *line = [description substringWithRange:range];
		NSInteger back = 1;
		BOOL done = NO;

		if (line.length == maxWidth)
		{
			// Only process a line if it's the full width

			do
			{
				// Work back from the list line character

				range = NSMakeRange(line.length - back, 1);
				NSString *last = [line substringWithRange:range];

				if ([last compare:@" "] == NSOrderedSame)
				{
					// Found a space

					done = YES;
					line = [line substringToIndex:line.length - back];
				}
				else
				{
					back++;
				}

			}
			while (!done);
		}

		[lines addObject:[spaces stringByAppendingString:line]];

		count = count + line.length + 1;
	}

	return lines;
}



- (void)setDevicegroupDevices:(Devicegroup *)devicegroup
{
	if (devicesArray.count > 0)
	{
		for (NSMutableDictionary *device in devicesArray)
		{
			NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
			NSString *dgid = [self getValueFrom:dg withKey:@"id"];

			if (devicegroup.did != nil && devicegroup.did.length > 0 && ([devicegroup.did compare:dgid] == NSOrderedSame))
			{
				if (devicegroup.devices == nil) devicegroup.devices = [[NSMutableArray alloc] init];

				BOOL flag = NO;

				NSString *dvn = [self getValueFrom:device withKey:@"name"];

				if (dvn == nil) dvn = [self getValueFrom:device withKey:@"id"];

				for (NSString *dgdevice in devicegroup.devices)
				{
					if ([dvn compare:dgdevice] == NSOrderedSame)
					{
						// Device is already on the list

						flag = YES;
						break;
					}
				}

				// Add the name to the list of device group devices as it's not already present

				if (!flag && dvn != nil) [devicegroup.devices addObject:dvn];
			}
		}
	}
}


@end
