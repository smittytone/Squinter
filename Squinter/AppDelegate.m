

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateFileHandlers.h"
#import "AppDelegateAPIHandlers.h"
#import "AppDelegateSquinting.h"
#import "AppDelegateUI.h"
#import "AppDelegateUtilities.h"



@implementation AppDelegate

@synthesize touchBar;



#pragma mark - Application Initialization Methods


- (void)applicationWillFinishLaunching:(NSNotification *)notification
{
    // Set up stock date formatters
    // The first, 'def', is used to format app-issued timestamps in the log.
    // The second, 'inLogDef', sets the format for incoming timestamps from impCentral.
    // The third, 'outLogDef', is used to present timestamps from impCentral;
    // It is the same as 'def' but adds three decimals to the seconds count

    touchBar = appBar;
    mainWindow = _window;

    def = [[NSDateFormatter alloc] init];
    def.dateFormat = @"yyyy-MM-dd HH:mm:ss ZZZZZ";
    def.timeZone = [NSTimeZone localTimeZone];

    inLogDef = [[NSDateFormatter alloc] init];
    inLogDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ";
    inLogDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];

    outLogDef = [[NSDateFormatter alloc] init];
    outLogDef.dateFormat = @"yyyy-MM-dd HH:mm:ss.SSS ZZZZZ";
    outLogDef.timeZone = [NSTimeZone localTimeZone];

    // Initialize app properties
    // NOTE 'currentXXX' indicates a selected Squinter object
    //      'selectedXXX' indicates a selected API object

    currentProject = nil;
    currentDevicegroup = nil;
    eiDeviceGroup = nil;
    selectedProduct = nil;
    selectedDevice = nil;
    projectArray = nil;
    devicesArray = nil;
    productsArray = nil;
    loggedDevices = nil;
    fixtureTargets = nil;
    //downloads = nil;
    ide = nil;
    dockMenu = nil;
    refreshTimer = nil;

    eiLibListData = nil;
    eiLibListTask = nil;
    eiLibListTime = nil;

    newDevicegroupName = nil;

    newTargetsFlag = NO;
    newDevicegroupFlag = NO;
    deviceSelectFlag = NO;
    renameProjectFlag = NO;
    saveAsFlag = YES;
    isBookmarkStale = NO;
    credsFlag = NO;
    switchingAccount = NO;
    doubleSaveFlag = NO;
    reconnectAfterSleepFlag = NO;
    
    lastAPIError = 0;
    syncItemCount = 0;
    logPaddingLength = 0;
    deviceCheckCount = -1;
    updateDevicePeriod = 300.0;
    loginMode = kLoginModeNone;
    accountType = kElectricImpAccountTypeNone;

    nswsw = NSWorkspace.sharedWorkspace;
    nsfm = NSFileManager.defaultManager;
    nsncdc = NSNotificationCenter.defaultCenter;
    defaults = NSUserDefaults.standardUserDefaults;

    // Initialize colours

    textColour = NSColor.blackColor;
    backColour = NSColor.whiteColor;

    colors = [[NSMutableArray alloc] init];
    logColors = [[NSMutableArray alloc] init];

    logFont = [self setLogViewFont:@"Monaco" :12.0 :NO];

    // Initialize the UI

    logDeviceCodeMenuItem.menu.autoenablesItems = NO;
    logAgentCodeMenuItem.menu.autoenablesItems = NO;
    externalOpenMenuItem.menu.autoenablesItems = NO;
    deviceGroupsMenu.autoenablesItems = NO;
    accountMenu.autoenablesItems = NO;

    // Hide the Dictation and Emoji items in the Edit menu

    [defaults setBool:YES forKey:@"NSDisabledDictationMenuItem"];
    [defaults setBool:YES forKey:@"NSDisabledCharacterPaletteMenuItem"];

    // File Menu

    fileMenu.autoenablesItems = NO;
    openRecentMenu.autoenablesItems = NO;

    [self refreshRecentFilesMenu];

    // Projects Menu

    projectsMenu.autoenablesItems = NO;

    [self refreshOpenProjectsSubmenu];
    [self refreshProjectsMenu];
    [self refreshProductsMenu];

    // Device Groups Menu

    externalSourceMenu.autoenablesItems = NO;

    [self refreshDeviceGroupsSubmenu];
    [self refreshDeviceGroupsMenu];
    [self refreshLibraryMenus];
    [self refreshFilesMenu];

    // Device Menu

    deviceMenu.autoenablesItems = NO;

    [self refreshDeviceMenu];
    [self refreshDevicesPopup];

    // NOTE refreshDevicegroupMenu: calls refreshDevicesMenus:
    // NOTE refreshDevicesPopup: calls refreshUnassignedDevices:

    // Account Menu

    // switchAccountMenuItem.enabled = NO;
    accountMenuItem.enabled = NO;

    // View Menu

    showHideToolbarMenuItem.title = @"Hide Toolbar";
    // NOTE refreshDeviceGroupsMenu: calls refreshViewMenu:

    // Toolbar

    squintItem.activeImageName = @"black_compile";
    squintItem.inactiveImageName = @"black_compile_grey";
    squintItem.toolTip = @"Compile libraries and files into agent and device code for uploading";

    newProjectItem.activeImageName = @"plus";
    newProjectItem.inactiveImageName = @"plus_grey";
    newProjectItem.toolTip = @"Create a new Squinter project";

    infoItem.activeImageName = @"info";
    infoItem.inactiveImageName = @"info_grey";
    infoItem.toolTip = @"Display detailed project information";

    openAllItem.activeImageName = @"open";
    openAllItem.inactiveImageName = @"open_grey";
    openAllItem.toolTip = @"View the device group's code and library files in your external editor";

    openDeviceCode.activeImageName = @"open";
    openDeviceCode.inactiveImageName = @"open_grey";
    openDeviceCode.toolTip = @"Display the device group's compiled device code";

    openAgentCode.activeImageName = @"open";
    openAgentCode.inactiveImageName = @"open_grey";
    openAgentCode.toolTip = @"Display the device group's compiled agent code";

    uploadCodeItem.activeImageName = @"upload2";
    uploadCodeItem.inactiveImageName = @"upload2_grey";
    uploadCodeItem.toolTip = @"Upload the device group's compiled code to the impCloud";

    uploadCodeExtraItem.activeImageName = @"uploadplus";
    uploadCodeExtraItem.inactiveImageName = @"uploadplus_grey";
    uploadCodeExtraItem.toolTip = @"Upload the device group's compiled code and commit information to the impCloud";

    restartDevicesItem.activeImageName = @"restart";
    restartDevicesItem.inactiveImageName = @"restart_grey";
    restartDevicesItem.toolTip = @"Force all devices running the device group's code to reboot";

    clearItem.activeImageName = @"clear";
    clearItem.inactiveImageName = @"clear_grey";
    clearItem.toolTip = @"Clear the log window";

    copyAgentItem.activeImageName = @"copy";
    copyAgentItem.inactiveImageName = @"copy_grey";
    copyAgentItem.toolTip = @"Copy the device group's compiled agent code to the clipboard";

    copyDeviceItem.activeImageName = @"copy";
    copyDeviceItem.inactiveImageName = @"copy_grey";
    copyDeviceItem.toolTip = @"Copy the device group's compiled device code to the clipboard";

    printItem.activeImageName = @"print";
    printItem.inactiveImageName = @"print_grey";
    printItem.toolTip = @"Print the contents of the log window";

    refreshModelsItem.activeImageName = @"refresh";
    refreshModelsItem.inactiveImageName = @"refresh_grey";
    refreshModelsItem.toolTip = @"Refresh the list of devices from the impCloud";

    newDevicegroupItem.activeImageName = @"newdg";
    newDevicegroupItem.inactiveImageName = @"newdg_grey";
    newDevicegroupItem.toolTip = @"Create a new device group for your selected project";

    devicegroupInfoItem.activeImageName = @"info";
    devicegroupInfoItem.inactiveImageName = @"info_grey";
    devicegroupInfoItem.toolTip = @"Display detailed device group information";

    streamLogsItem.toolTip = @"Enable or disable live log streaming for the current device";
    streamLogsItem.state = kStreamToolbarItemStateOff;

    loginAndOutItem.activeLogoutImageName = @"logout";
    loginAndOutItem.activeLoginImageName = @"login";
    loginAndOutItem.inactiveLogoutImageName = @"logout_grey";
    loginAndOutItem.inactiveLoginImageName = @"login_grey";
    loginAndOutItem.toolTip = @"Login or logout of your Electric Imp account";
    loginAndOutItem.isLoggedIn = NO;

    listCommitsItem.activeImageName = @"commits2";
    listCommitsItem.inactiveImageName = @"commits2_grey";
    listCommitsItem.toolTip = @"List the commits made to the current device group";

    downloadProductItem.activeImageName = @"download";
    downloadProductItem.inactiveImageName = @"download_grey";
    downloadProductItem.toolTip = @"Download the selected product as a project";

    inspectorItem.activeImageName = @"inspect";
    inspectorItem.inactiveImageName = @"inspect_grey";
    inspectorItem.toolTip = @"Show or hide the project and device inspector";

    syncItem.activeImageName = @"sync";
    syncItem.inactiveImageName = @"sync_grey";
    syncItem.toolTip = @"Sync the project to the impCloud, uploading if necessary";
    
    projectsPopUp.toolTip = @"Select an open project";
    devicesPopUp.toolTip = @"Select a development device";
    saveLight.toolTip = @"Indicates whether the project has changes to be saved (outline) or not (filled)";
    

    // Other UI Items

    connectionIndicator.hidden = YES;

    [saveLight hide];
    [saveLight needSave:NO];

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

    NSArray *keyArray = [NSArray arrayWithObjects:
                         @"com.bps.squinter.workingdirectory",
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
                         @"com.bps.squinter.logListCount",
                         @"com.bps.squinter.dev1.red",          // Redundant from 2.0.123
                         @"com.bps.squinter.dev1.blue",         // Redundant from 2.0.123
                         @"com.bps.squinter.dev1.green",        // Redundant from 2.0.123
                         @"com.bps.squinter.dev2.red",          // Redundant from 2.0.123
                         @"com.bps.squinter.dev2.blue",         // Redundant from 2.0.123
                         @"com.bps.squinter.dev2.green",        // Redundant from 2.0.123
                         @"com.bps.squinter.dev3.red",          // Redundant from 2.0.123
                         @"com.bps.squinter.dev3.blue",         // Redundant from 2.0.123
                         @"com.bps.squinter.dev3.green",        // Redundant from 2.0.123
                         @"com.bps.squinter.dev4.red",          // Redundant from 2.0.123
                         @"com.bps.squinter.dev4.blue",         // Redundant from 2.0.123
                         @"com.bps.squinter.dev4.green",        // Redundant from 2.0.123
                         @"com.bps.squinter.dev5.red",          // Redundant from 2.0.123
                         @"com.bps.squinter.dev5.blue",         // Redundant from 2.0.123
                         @"com.bps.squinter.dev5.green",        // Redundant from 2.0.123
                         @"com.bps.squinter.show.inspector",
                         @"com.bps.squinter.inspectorsize",
                         @"com.bps.squinter.updatedevs",        // New in 2.0.122
                         @"com.bps.squinter.devicecolours",     // New in 2.0.123
                         @"com.bps.squinter.inspectorshow",     // New in 2.2.126
                         nil];

    NSArray *objectArray = [NSArray arrayWithObjects:
                            workingDirectory,
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
                            [NSNumber numberWithFloat:1.0],
                            [NSNumber numberWithFloat:0.0],
                            [NSNumber numberWithFloat:0.0],
                            [NSNumber numberWithFloat:0.0],
                            [NSNumber numberWithBool:YES],
                            [NSNumber numberWithBool:NO],
                            [NSNumber numberWithBool:NO],
                            [NSNumber numberWithBool:NO],
                            [NSNumber numberWithInteger:1],
                            [NSNumber numberWithBool:NO],
                            [NSNumber numberWithBool:NO],
                            [[NSArray alloc] init],
                            [NSNumber numberWithInteger:5],
                            [NSNumber numberWithInteger:200],
                            [NSNumber numberWithFloat:0.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.6],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.6],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.6],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:1.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.2],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.3],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.6],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.5],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:1.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.8],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:1.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.0],         // Redundant from 2.0.123
                            [NSNumber numberWithFloat:0.6],         // Redundant from 2.0.123
                            [NSNumber numberWithBool:NO],
                            [NSString stringWithString:NSStringFromRect(NSMakeRect(0.0, 20.0, 340.0, 520.0))],
                            [NSNumber numberWithBool:NO],           // New in 2.0.123
                            [[NSArray alloc] init],                 // New in 2.0.123
                            [NSNumber numberWithBool:NO],           // New in 2.2.126
                            nil];

    // Drop the arrays into the Defauts

    NSDictionary *appDefaults = [NSDictionary dictionaryWithObjects:objectArray forKeys:keyArray];
    [defaults registerDefaults:appDefaults];

    // Prepare the main window

    wantsToHide = 0;
    isInspectorHidden = NO;

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

        // **** TO 2.1.125 ****

        // NSString *frameString = [defaults stringForKey:@"com.bps.squinter.inspectorsize"];
        // nuRect = NSRectFromString(frameString);
        // [iwvc.view.window setFrame:nuRect display:NO];

        // **** FROM 2.2.126 ****

        NSNumber *num = [defaults objectForKey:@"com.bps.squinter.inspectorshow"];
        isInspectorHidden = num.boolValue;

        if (isInspectorHidden)
        {
            // Fake a click on the show/hide inspector button to hide it

            wantsToHide = -1;
            [splitView setPosition:splitView.frame.size.width ofDividerAtIndex:0];
        }
        else
        {
            // It's already being shown; just adjust the width

            wantsToHide = 1;
            [splitView setPosition:(splitView.frame.size.width - 340.0 - splitView.dividerThickness) ofDividerAtIndex:0];
        }
    }
    else
    {
        [_window center];

        // **** To 2.1.125 ****

        // iwvc.mainWindowFrame = _window.frame;
        // [iwvc positionWindow];

        // **** FROM 2.2.126 ****

        // Set up the Split View to show the Inspector by default

        CGFloat proposed = splitView.frame.size.width - 340.0 - splitView.dividerThickness;
        [splitView setPosition:proposed ofDividerAtIndex:0];
    }

    // Set the Log TextView's font

    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.fontNameIndex"] integerValue];
    NSString *fontName = [self getFontName:index];
    NSInteger fontSize = [[defaults objectForKey:@"com.bps.squinter.fontSizeIndex"] integerValue];
    BOOL isBold = [[defaults objectForKey:@"com.bps.squinter.showboldtext"] boolValue];
    logTextView.font = [self setLogViewFont:fontName :fontSize :isBold];
    logFont = logTextView.font;

    float r = [[defaults objectForKey:@"com.bps.squinter.text.red"] floatValue];
    float b = [[defaults objectForKey:@"com.bps.squinter.text.blue"] floatValue];
    float g = [[defaults objectForKey:@"com.bps.squinter.text.green"] floatValue];
    textColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    r = [[defaults objectForKey:@"com.bps.squinter.back.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.back.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.back.green"] floatValue];
    backColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

    NSUInteger a = [self perceivedBrightness:backColour];

    [logScrollView setScrollerKnobStyle:(a < 30 ? NSScrollerKnobStyleLight : NSScrollerKnobStyleDark)];
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
    
    [self configureNotifications];
    
    [nsncdc addObserver:self
           selector:@selector(startProgress)
               name:@"BuildAPIProgressStart"
             object:ide];

    [nsncdc addObserver:self
           selector:@selector(stopProgress)
               name:@"BuildAPIProgressStop"
             object:ide];

    [nsncdc addObserver:self
               selector:@selector(handleLoginKey:)
                   name:@"BuildAPILoginKey"
                 object:ide];

    [nsncdc addObserver:self
               selector:@selector(getOtp:)
                   name:@"BuildAPINeedOTP"
                 object:ide];

    [nsncdc addObserver:self
               selector:@selector(gotLibraries:)
                   name:@"BuildAPIGotLibrariesList"
                 object:ide];



    // Set up sleep/wake notification

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveSleepNote:)
                                                               name: NSWorkspaceWillSleepNotification
                                                             object: nil];

    [[[NSWorkspace sharedWorkspace] notificationCenter] addObserver: self
                                                           selector: @selector(receiveWakeNote:)
                                                               name: NSWorkspaceDidWakeNotification
                                                             object: nil];

    // Get macOS version

    sysVer = [[NSProcessInfo processInfo] operatingSystemVersion];


    // Load in working directory, reading in the location from the defaults in case it has been changed by a previous launch

    workingDirectory = [defaults stringForKey:@"com.bps.squinter.workingdirectory"];

    // Set up parallel operation queue and limit it to serial operation

    extraOpQueue = [[NSOperationQueue alloc] init];
    extraOpQueue.maxConcurrentOperationCount = 1;

    // Set up the project array, so it's ready for files being opened by double-click,
    // or from the Dock Tile's menu

    if (projectArray == nil) projectArray = [[NSMutableArray alloc] init];
    iwvc.projectArray = projectArray;

    // FROM 2.3.128
    // Pass the path display mode to the Inspector

    NSNumber *num = [defaults objectForKey:@"com.bps.squinter.displaypath"];
    iwvc.pathType = num.integerValue;
}



- (BOOL)application:(NSApplication *)theApplication openFile:(NSString *)filename
{
    // If the user launched Squinter by double-clicking a .squirrelproj file, this method will be called
    // *before* applicationDidFinishLoading

    // Turn the opened file’s path into an NSURL an add to the array that openFileHandler: expects

    NSArray *array = [NSArray arrayWithObjects:[NSURL fileURLWithPath:filename], nil];
    NSLog(@"Squinter loading %@", filename);
    [self openFileHandler:array :kActionOpenSquirrelProject];
    return YES;
}



- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Set up the Preferences panel's colour wells' on-click functions

    [dev1ColorWell setAction:@selector(showPanelForDev1)];
    [dev2ColorWell setAction:@selector(showPanelForDev2)];
    [dev3ColorWell setAction:@selector(showPanelForDev3)];
    [dev4ColorWell setAction:@selector(showPanelForDev4)];
    [dev5ColorWell setAction:@selector(showPanelForDev5)];
    [dev6ColorWell setAction:@selector(showPanelForDev6)];
    [dev7ColorWell setAction:@selector(showPanelForDev7)];
    [dev8ColorWell setAction:@selector(showPanelForDev8)];

    // Organize the Preferences panel's colour wells into an array
    // See 'setPrefs:' for usage

    deviceColourWells = [[NSMutableArray alloc] init];

    [deviceColourWells addObject:dev1ColorWell];
    [deviceColourWells addObject:dev2ColorWell];
    [deviceColourWells addObject:dev3ColorWell];
    [deviceColourWells addObject:dev4ColorWell];
    [deviceColourWells addObject:dev5ColorWell];
    [deviceColourWells addObject:dev6ColorWell];
    [deviceColourWells addObject:dev7ColorWell];
    [deviceColourWells addObject:dev8ColorWell];

    // Popular the logging colours array

    [self setColours];

    // Instantiate an IDE-access object

    ide = [[BuildAPIAccess alloc] init];
    ide.maxListCount = [defaults stringForKey:@"com.bps.squinter.logListCount"].integerValue;
    ide.pageSize = 50;

    // Update UI

	[self setToolbar];
    [_window makeKeyAndOrderFront:self];

    // if ([defaults boolForKey:@"com.bps.squinter.show.inspector"]) [iwvc.view.window makeKeyAndOrderFront:self];

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

        // [self showLoginWindow];

        // switchAccountMenuItem.enabled = YES;
        [self writeStringToLog:@"To make full use of Squinter, please log in to your Electric Imp account via the Account menu." :YES];
    }
}



- (void)applicationWillBecomeActive:(NSNotification *)notification
{
    if (!_window.isKeyWindow) [_window makeKeyAndOrderFront:self];
}



#pragma mark - Application Quit Methods


- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApp
{
    // Return YES to quit app when user clicks on the close button

    return YES;
}



- (void)windowWillClose:(NSNotification *)notification
{
    // ADDED 2.3.130
    // This is an NSWindowDelegate method, tripped whenn the user clicks the red close button
    // It's used here to make sure the Help window, if open, doesn't block the app from being
    // shut down becuase it's open and the last window visible (see 'applicationShouldTerminateAfterLastWindowClosed:')

    if (hwvc.isOnScreen)
    {
        hwvc.isOnScreen = NO;
        [hwvc.view.window close];
    }
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



- (void)applicationWillTerminate:(NSNotification *)notification
{
    // Stop watching for file-changes

    [fileWatchQueue removeAllPaths];

    // Kill any connections to the API

    [ide killAllConnections];

    // Kill any timers

    if (refreshTimer != nil) [refreshTimer invalidate];

    // Record settings that are not set by the Prefs dialog

    [defaults setValue:workingDirectory forKey:@"com.bps.squinter.workingdirectory"];
    [defaults setValue:NSStringFromRect(_window.frame) forKey:@"com.bps.squinter.windowsize"];

    // **** TO 2.1.125 ****

    // if (iwvc.view.window.isVisible) [defaults setValue:NSStringFromRect(iwvc.view.window.frame) forKey:@"com.bps.squinter.inspectorsize"];

    // **** FROM 2.2.126 ****

    [defaults setValue:[NSNumber numberWithBool:isInspectorHidden] forKey:@"com.bps.squinter.inspectorshow"];
    [defaults setValue:NSStringFromRect(NSMakeRect(0.0, 20.0, 340.0, 520.0)) forKey:@"com.bps.squinter.inspectorsize"];

    [defaults setObject:[NSArray arrayWithArray:recentFiles] forKey:@"com.bps.squinter.recentFiles"];

    // Stop watching for notifications

    [nsncdc removeObserver:self];

    // FROM 2.3.130
    // Make sure we close the Help window, if it's open, first

    if (hwvc.isOnScreen)
    {
        hwvc.isOnScreen = NO;
        [hwvc.view.window close];
    }
}



#pragma mark - Full Screen Methods


- (void)windowWillEnterFullScreen:(NSNotification *)notification
{
    [_window setStyleMask:NSWindowStyleMaskBorderless];
}



- (void)windowWillExitFullScreen:(NSNotification *)notification
{
    [_window setStyleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskMiniaturizable | NSWindowStyleMaskClosable)];
    [_window setTitle:@"Squinter"];
}



#pragma mark - Inspector Methods


- (IBAction)showInspector:(id)sender
{
    // Show the Inspector if it's closed
    // If the Inspector is obscured by the main window, or not key, bring it forward

    if (isInspectorHidden)
    {
        // Inspector panel is hidden, so prepare to show it

        CGFloat proposed = splitView.frame.size.width - 340.0;
        wantsToHide = 1;
        [splitView setPosition:proposed ofDividerAtIndex:0];
    }
    else
    {
        // Inspector panel is visible, so prepare to hide it

        CGFloat proposed = splitView.frame.size.width;
        wantsToHide = -1;
        [splitView setPosition:proposed ofDividerAtIndex:0];
    }
}



- (IBAction)showProjectInspector:(id)sender
{
    if (currentProject != nil) iwvc.project = currentProject;

    [iwvc setTab:kInspectorTabProject];

    if (isInspectorHidden) [self showInspector:nil];
}



- (IBAction)showDeviceInspector:(id)sender
{
    if (selectedDevice != nil) iwvc.device = selectedDevice;

    [iwvc setTab:kInspectorTabDevice];

    if (isInspectorHidden) [self showInspector:nil];
}



#pragma mark - Login Methods


- (IBAction)loginOrOut:(id)sender
{
    // We come here when the log in/out menu option is selected

    if (!ide.isLoggedIn)
    {
        // We are not logged in, so we may need to show the log in sheet,
        // but only if we're not already trying to log in ('isLoggingIn' is true)

        if (!isLoggingIn)
        {
            if (!credsFlag)
            {
                // No creds set? Show the sheet to get them...

                [self showLoginWindow];
            }
            else
            {
                // ...or login in automatically

                [self autoLogin];
            }
        }
    }
    else
    {
        // We are logged in, so log the user out

        NSInteger cloudCode = ide.impCloudCode;
        NSString *cloudName = [self getCloudName:cloudCode];

        [self logout];

        // Update the UI and report to the user

        accountMenuItem.title = @"Not Signed in to any Account";
        loginMenuItem.title = @"Log in to your Main Account";
        switchAccountMenuItem.title = @"Log in to a Different Account...";
        loginMode = kLoginModeNone;

        [self writeStringToLog:[NSString stringWithFormat:@"You are now logged out of the %@impCloud.", cloudName] :YES];
    }
}



- (void)logout
{
    // Log out of the current account
    // NOTE Account menu clean-up is handled by the calling method, 'logInOrOut:'

    [ide logout];

    // Clear all account-related items: Products and Devices

    [productsArray removeAllObjects];
    [devicesArray removeAllObjects];

    productsArray = nil;
    devicesArray = nil;
    selectedProduct = nil;
    selectedDevice = nil;
    iwvc.device = nil;
    loginKey = nil;
    otpLoginToken = nil;

    // Stop auto-updating account devices' status

    [self keepDevicesStatusUpdated:nil];

    // Update the UI elements relating to these items

    [self refreshProductsMenu];
    [self refreshProjectsMenu];
    [self refreshDeviceGroupSubmenuDevices];
    [self refreshDeviceMenu];
    [self refreshDevicesPopup];
    [self setToolbar];
}



- (void)autoLogin
{
    // Set the credentials for reading

    [self setLoginCreds];

    if (usernameTextField.stringValue.length == 0 || passwordTextField.stringValue.length == 0)
    {
        // We don't have a password or a username, so we'll need to show the login window anyway

        saveDetailsCheckbox.state = NSOnState;

        [_window beginSheet:loginSheet completionHandler:nil];
    }
    else
    {
        // We've got the credentials so bypass the sheet and log straight in

        saveDetailsCheckbox.state = NSOffState;

        [self writeStringToLog:@"Logging you into the impCloud. Automatic login can be disabled in Preferences." :YES];
        [self login:nil];
    }
}



- (void)showLoginWindow
{
    // Present the login sheet

    saveDetailsCheckbox.state = NSOnState;

    // Set the credentials for reading

    [self setLoginCreds];

    [_window beginSheet:loginSheet completionHandler:nil];
}



- (void)setLoginCreds
{
    // Pull the login credentials from the keychain

    PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
    NSString *un = [pc stringForKey:@"com.bps.Squinter.ak.notional.tully"];
    NSString *pw = [pc stringForKey:@"com.bps.Squinter.ak.notional.tilly"];
    NSString *lk = [pc stringForKey:@"com.bps.Squinter.ak.notional.telly"];
    NSString *ic = [pc stringForKey:@"com.bps.Squinter.ak.notional.toolly"];

    // Set the login window fields with the data

    usernameTextField.stringValue = (un == nil) ? @"" : [ide decodeBase64String:un];
    passwordTextField.stringValue = (pw == nil) ? @"" : [ide decodeBase64String:pw];

    if (lk != nil) loginKey = lk;

    if (ic == nil || [ic compare:@"AWS"] == NSOrderedSame)
    {
        [impCloudPopup selectItemAtIndex:0];
    }
    else if ([ic compare:@"Azure"] == NSOrderedSame)
    {
        [impCloudPopup selectItemAtIndex:1];
    }
    else
    {
        // Error! No selected impCloud

        credsFlag = NO;
        usernameTextField.stringValue = @"";
        passwordTextField.stringValue = @"";
    }
}



- (IBAction)cancelLogin:(id)sender
{
    // Just hide the login sheet

    [_window endSheet:loginSheet];

    if (switchingAccount) switchingAccount = NO;
}



- (IBAction)hitSaveCheckbox:(id)sender
{
    // If the user hits 'save' while going to another account, warn them that
    // they will overwrite their currently saved credentials

    NSButton *checkbox = (NSButton *)sender;

    if (checkbox.state == NSOnState && switchingAccount)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Caution";
        alert.informativeText = @"If you already have account credentials saved in your keychain, checking this box will overwrite them. Are you sure?";
        [alert addButtonWithTitle:@"Yes"];
        [alert addButtonWithTitle:@"No"];

        [alert beginSheetModalForWindow:loginSheet completionHandler:^(NSModalResponse returnCode) {
            if (returnCode != NSAlertFirstButtonReturn) checkbox.state = NSOffState;
        }];
    }
}



- (IBAction)login:(id)sender
{
    // If we pass in nil to 'sender' we have called this method manually
    // so we don't need to remove the sheet from the window

    if (sender != nil) [_window endSheet:loginSheet];

    // If we're switching accounts, log out first

    if (switchingAccount)
    {
        [self logout];

        credsFlag = NO;
    }

    // Register that we're attempting a login

    isLoggingIn = YES;

    // Attempt to login with the current credentials

    if (!credsFlag && loginKey != nil)
    {
        [ide loginWithKey:loginKey];
        return;
    }

    // NOTE the following will bork autologin if the user changes the popup (eg. to Azure)
    //      and the account we're autoloading is AWS

    NSInteger code = [impCloudPopup indexOfSelectedItem];

    [ide login:usernameTextField.stringValue
              :passwordTextField.stringValue
              :code];

    // Pick up the action in **loggedIn:** or **displayError:**, depending on success or failure
}



- (void)loginAlert:(NSString *)extra
{
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"You are not logged in to the impCloud";
    alert.informativeText = [NSString stringWithFormat:@"You must be logged in to %@. Do you wish to log in now?", extra];
    [alert addButtonWithTitle:@"Yes"];
    [alert addButtonWithTitle:@"No"];

    [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertFirstButtonReturn) [self autoLogin];
    }];
}



- (IBAction)setSecureEntry:(id)sender
{
    // EXPERIMENTAL — switches the password entry field between secure and non-secure mode

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



- (IBAction)switchAccount:(id)sender
{
    // We're switching account - presumably temporarily - by holding the the option key
    // when clicking the Account menu option. This allows the user to log into a different
    // account ('loginMode' is 2) or switch to the primary

    if (loginMode != kLoginModeAlt)
    {
        // The user wants to log into a different account

        switchingAccount = YES;

        // Show the login sheet empty and with 'save credentials' switched off

        saveDetailsCheckbox.state = NSOffState;
        usernameTextField.stringValue = @"";
        passwordTextField.stringValue = @"";

        [_window beginSheet:loginSheet completionHandler:nil];
    }
    else
    {
        // We a logging into the primary account

        [self logout];
        [self autoLogin];
    }
}



- (IBAction)signup:(id)sender
{
    // Show EI account sign-up help information
    
    [self launchOwnSite:@"#electric-imp-accounts"];
}



- (void)handleLoginKey:(NSNotification *)note
{
    NSDictionary *data = (NSDictionary *)note.object;
    NSString *key = [data objectForKey:@"id"];

    // Pull the login credentials from the keychain

    PDKeychainBindings *pc = [PDKeychainBindings sharedKeychainBindings];
    NSString *lk = [pc stringForKey:@"com.bps.Squinter.ak.notional.telly"];

    if (lk == nil)
    {
        [pc setString:key forKey:@"com.bps.Squinter.ak.notional.telly"];
    }
    else
    {
        // Warn user and ask if they want to replace key

        [pc setString:key forKey:@"com.bps.Squinter.ak.notional.telly"];
    }

    loginKey = key;
}



- (void)getOtp:(NSNotification *)note
{
    // The server has signalled BuildAPIAcces that it needs an OTP, and BuildAPIAccess
    // has signalled the host app to get an OTP

    NSDictionary *data = (NSDictionary *)note.object;
    otpLoginToken = [data objectForKey:@"token"];

    // Show OTP request box

    [_window beginSheet:otpSheet completionHandler:nil];
}



- (IBAction)setOtp:(id)sender
{
    [_window endSheet:otpSheet];

    // Clear the entered OTP value, if any

    NSString *otp = otpTextField.stringValue;
    otpTextField.stringValue = @"";

    [ide twoFactorLogin:otpLoginToken :otp];
}



- (IBAction)cancelOtpSheet:(id)sender
{
    // Cancel the OTP Sheet - and therefore the login

    otpTextField.stringValue = @"";
    otpLoginToken = nil;
    isLoggingIn = NO;

    if (switchingAccount) switchingAccount = NO;

    [_window endSheet:otpSheet];
}



#pragma mark - New Project Methods


- (IBAction)newProject:(id)sender
{
    // Create a new product from scratch

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

        // Get the list of products if we don't have it already
        // This will be later used to check the new project's name

        // if (productsArray == nil || productsArray.count == 0) [self getProductsFromServer:nil];
    }
    else
    {
        // ...otherwise we can't

        newProjectNewProductCheckbox.enabled = NO;
        newProjectNewProductCheckbox.state = NSOffState;

        // TODO - Add warning here and suggest the user log in
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

    if (makeNewProduct)
    {
        // NOTE 'makeNewProduct' is not selectable (ie. always NO) if the user is not logged in
        
        if (productsArray != nil)
        {
            // Compare the new product's name against existing product names

            if (productsArray.count > 0)
            {
                for (NSDictionary *product in productsArray)
                {
                    NSString *aName = [self getValueFrom:product withKey:@"name"];

                    if ([aName compare:pName] == NSOrderedSame)
                    {
                        NSAlert *alert = [[NSAlert alloc] init];
                        alert.messageText = @"A product with that name already exists";
                        alert.informativeText = @"Please click ‘Continue’ to choose another project name, or ‘Cancel’ to end the project creation process.";
                        [alert addButtonWithTitle:@"Cancel"];
                        [alert addButtonWithTitle:@"Continue"];
                        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
                            if (returnCode == NSAlertSecondButtonReturn)
                            {
                                // Clear the project name text field and re-show the panel
                                
                                newProjectNameTextField.stringValue = @"";
                                [_window beginSheet:newProjectSheet completionHandler:nil];
                            }
                        }];
                        
                        return;
                    }
                }
            }
        }
        else
        {
            // 'productsArray' is nil so we have not downloaded the product list
            // Warn the user about this and give them a way out of the create process

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"You haven‘t yet retrieved this account’s products";
            alert.informativeText = @"If a product with the same name as your new project already exists, creating a new product for this project will fail.";
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Continue"];
            [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn) [self newProjectSheetCreateStageTwo:pName :pDesc :YES :NO];
            }];

            return;
        }
    }

    // Go on to the next stage

    [self newProjectSheetCreateStageTwo:pName :pDesc :makeNewProduct :associateProduct];
}



- (void)newProjectSheetCreateStageTwo:(NSString *)projectName :(NSString *)projectDesc :(BOOL)make :(BOOL)associate
{
    // Second phase of project creation
    // This needs to be a separate method because of the async nature of the first phase
    // (see 'newProjectSheetCreate:'), which may pop up an alert whose effect may be
    // to take the user away from here

    // Make the new project, and make it the current project

    Project *newProject = [[Project alloc] init];
    newProject.name = projectName;
    newProject.description = projectDesc;
    newProject.path = workingDirectory;
    newProject.filename = [projectName stringByAppendingString:@".squirrelproj"];
    newProject.haschanged = YES;
    newProject.devicegroupIndex = -1;
    
    // Add the account ID if we are logged in

    if (ide.isLoggedIn) newProject.aid = ide.currentAccount;
    
    // Set the new project as the current project
    
    currentProject = newProject;
    currentDevicegroup = nil;
    iwvc.project = currentProject;
    
    [projectArray addObject:newProject];
    
    // Add the new project to the project menu.
    // We've already checked for a name clash, so we needn't care about the return value
    
    [self addOpenProjectsMenuItem:newProject.name :newProject];
    
    if (make)
    {
        // User wants to create a new product for this project. We will pick up saving
        // this project AFTER the product has been created (to make sure it is created)
        // NOTE 'make' can only be YES if we are logged in

        [self writeStringToLog:@"Creating the project's product on the server..." :YES];

        NSDictionary *dict = @{ @"action"  : @"newproject",
                                @"project" : newProject };

        [ide createProduct:projectName :projectDesc :dict];
        
        return;

        // Pick up the action at 'createProductStageTwo:'
    }

    // Check whether we're connecting this project to a product (new or selected)

    if (associate)
    {
        // User wants to associate the new project with the selected product, so set 'pid'
        // NOTE user can't have made this choice if 'selectedProduct' is nil

        newProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
    }

    // Go on to the next stage
    
    [self newProjectSheetCreateStageThree:newProject];
}



- (void)newProjectSheetCreateStageThree:(Project *)newProject
{
    // This is a separate method to allow its access from multiple locations:
    // 'newProjectSheetCreateStageTwo:' and 'createProductStageTwo:'
    
    // Enable project-related UI items for the new project:
    // The 'Projects' menu
    // The 'Device Groups' menu and 'Projects's Device Groups' submenu
    // The Toolbar
    
    [self refreshProjectsMenu];
    [self refreshDeviceGroupsMenu];
    [self refreshDeviceGroupsSubmenu];
    [self setToolbar];
    
    // Status light
    // NOTE We show this here as this may be the first project displayed
    
    [saveLight show];
    [saveLight needSave:YES];
    
    // Save the new project - this gives the user the chance to re-locate it
    
    savingProject = newProject;
    [self saveProjectAs:nil];
}



- (IBAction)newProjectCheckboxStateHandler:(id)sender
{
    // This method responds to attempts to select a new project dialog checkbox
    // to make sure contradictory responses are not permitted

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
    // This is called by any click on 'projectsPopup'
    // Selecting a project from the 'openProjectsMenu' calls 'chooseProject:' indirectly via the menu item's target

    [self chooseProject:projectsPopUp];
}



- (void)chooseProject:(id)sender
{
    // Select one of the open projects from the Projects sub-menu or the Project menu

    NSMenuItem *item;

    // 'item' will become the open projects menu item that has been selected, either
    // directly (via 'sender') or by the projects popup's tag value

    if (sender != projectsPopUp)
    {
        // The user has selected a projects from the 'openProjectsMenu' submenu

        item = (NSMenuItem *)sender;
    }
    else
    {
        // 'sender' is 'projectsPopUp', so use the item's represented object to
        // get the 'openProjectsMenu' item that references the same project

        for (NSMenuItem *anItem in openProjectsMenu.itemArray)
        {
            if (anItem.representedObject == projectsPopUp.selectedItem.representedObject)
            {
                item = anItem;
                break;
            }
        }
    }
    
    if (item != nil)
    {
        Project *chosenProject = nil;

        if (item.representedObject != nil)
        {
            chosenProject = item.representedObject;
        }
        else
        {
            // Just in case we didn't set the represented object for some reason

            for (NSUInteger i = 0 ; i < projectArray.count ; ++i)
            {
                chosenProject = [projectArray objectAtIndex:i];

                if ([chosenProject.name compare:item.title] == NSOrderedSame) break;
            }
        }
        
        // Have we chosen the already selected project? Bail

        if (chosenProject == currentProject) return;

        // Switch in the newly chosen project and select its known selected device group

        currentProject = chosenProject;
        currentDevicegroup = currentProject.devicegroupIndex != -1 ? [currentProject.devicegroups objectAtIndex:currentProject.devicegroupIndex] : nil;

        // If we have a current device group, select its first device if it has one

        if (currentDevicegroup != nil)
        {
            [self selectFirstDevice];
        }
        else
        {
            // If we don't have a selected device group but we do have device groups in
            // this project, select the first one on the list (if there is one)

            if (currentProject.devicegroups.count > 0)
            {
                currentDevicegroup = [currentProject.devicegroups objectAtIndex:0];
                currentProject.devicegroupIndex = 0;

                [self selectFirstDevice];
            }
        }
    }
    
    // Is the project associated with a product? If so, select it

    if (currentProject.pid.length > 0)
    {
        if (productsArray.count > 0)
        {
            BOOL done = NO;

            for (NSMenuItem *item in productsMenu.itemArray)
            {
                if (item.representedObject != nil)
                {
                    NSDictionary *product = (NSDictionary *)item.representedObject;
                    NSString *pid = [self getValueFrom:product withKey:@"id"];

                    if (pid != nil && [pid compare:currentProject.pid] == NSOrderedSame)
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
                            NSDictionary *product = (NSDictionary *)sitem.representedObject;
                            NSString *pid = [self getValueFrom:product withKey:@"id"];

                            if (pid != nil && [pid compare:currentProject.pid] == NSOrderedSame)
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
        }
    }

    // Update the Menus and the Toolbar (left until now in case models etc are selected)
    // NOTE previous calls to chooseProduct: will cause the products sub-menu to be updated

    [self refreshProjectsMenu];
    [self refreshOpenProjectsSubmenu];
    [self refreshDeviceGroupsMenu];
    [self refreshDeviceGroupsSubmenu];
    [self setToolbar];

    // Set the inspector

    iwvc.project = currentProject;
    
    // Update the save? indicator if the newly selected project needs it
    
    [saveLight needSave:currentProject.haschanged];
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
    // The UI entry point for 'close project' operations

    if (projectArray.count == 0 || currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    if (sender == closeAllMenuItem)
    {
        // We need to close multiple projects at once, so iterate through
        // all of them, recursively calling closeProject:, sending nil as
        // the sender so this block is not re-run.
        // NOTE this should exit with just one remaining project,
        //      which the rest of the method will deal with

        if (projectArray.count > 1)
        {
            do
            {
                // Close the current project
                // NOTE 'closeProject:' sets the current project

                [self closeProject:nil];
            }
            while (projectArray.count > 1);
        }
    }

    // Close the current project

    if (currentProject.haschanged)
    {
        // The project has unsaved changes, so warn the user before closing

        saveChangesSheetLabel.stringValue = @"Project has unsaved changes.";
        closeProjectFlag = YES;

        [_window beginSheet:saveChangesSheet completionHandler:nil];

        return;
    }

    // Stop watching all of the current project's files: each device group's models,
    // and then each model's various local libraries and files

    if (currentProject.devicegroups.count > 0)
    {
        for (Devicegroup *devicegroup in currentProject.devicegroups)
        {
            [self closeDevicegroupFiles:devicegroup :currentProject];
        }
    }

    NSString *closedName = currentProject.name;

    if (projectArray.count == 1)
    {
        // If there is only one open project, which we're about to close,
        // we can clear everything project-related in the UI

        [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" closed. There are no open projects.", closedName] :YES];
        [projectArray removeAllObjects];
        [fileWatchQueue kill];

        fileWatchQueue = nil;
        currentProject = nil;
        currentDevicegroup = nil;
        iwvc.project = nil;

        // Fade the status light

        [saveLight hide];
        [saveLight needSave:NO];
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
            confirmMessage = [confirmMessage stringByAppendingFormat:@" %@ is now the current project.", currentProject.name];

            if (projectArray.count == 1)
            {
                confirmMessage = [confirmMessage stringByAppendingString:@" There are no other open projects."];
            }
            else
            {
                confirmMessage = [confirmMessage stringByAppendingFormat:@" There are %li open projects.", projectArray.count];
            }

            [self writeStringToLog:confirmMessage :YES];
        }

        [saveLight needSave:currentProject.haschanged];

        iwvc.project = currentProject;
    }

    // Update the UI whether we've closed one of x projects, or the last one

    [self refreshProjectsMenu];
    [self refreshOpenProjectsSubmenu];
    [self refreshDeviceGroupsMenu];
    [self refreshDeviceGroupsSubmenu];
    [self refreshDeviceMenu];
    [self setToolbar];
}



- (void)closeDevicegroupFiles:(Devicegroup *)devicegroup :(Project *)parent
{
    // FROM 2.3.128
    // This method ensure all the files relating to the specified devicegroup, ie.
    // models, their files and their librares, are removed from the file watch list

    if (devicegroup.models.count > 0)
    {
        for (Model *model in devicegroup.models)
        {
            NSString *path = [model.path stringByAppendingFormat:@"/%@", model.filename];

            if (path.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:parent.path :path]];

            if (model.libraries.count > 0)
            {
                for (File *file in model.libraries)
                {
                    NSString *fpath = [file.path stringByAppendingFormat:@"/%@", file.filename];

                    if (fpath.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:parent.path :fpath]];
                }
            }

            if (model.files.count > 0)
            {
                for (File *file in model.files)
                {
                    NSString *fpath = [file.path stringByAppendingFormat:@"/%@", file.filename];

                    if (fpath.length > 0) [fileWatchQueue removePath:[self getAbsolutePath:parent.path :fpath]];
                }
            }
        }
    }
}



- (IBAction)renameCurrentProject:(id)sender
{
    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    [self renameProject:sender];
}



- (void)renameProject:(id)sender
{
    // Present the sheet, adapting it according to sender ('rename Peroject' or 'rename Device Group')

    renameProjectFlag = (sender == renameProjectMenuItem) ? YES : NO;

    if (!renameProjectFlag && !ide.isLoggedIn)
    {
        // We now disallow editing device group information when Squinter is not logged in

        [self loginAlert:@"edit device group information"];
        return;
    }

    if (renameProjectFlag && !ide.isLoggedIn && currentProject.pid.length > 0)
    {
        // We now disallow editing project information when Squinter is not logged in,
        // but only if the project points to a product, ie. it has a PID

        [self loginAlert:@"update information for a project linked to a product"];
        return;
    }

    NSString *desc = (renameProjectFlag) ? currentProject.description : currentDevicegroup.description;
    NSString *name = (renameProjectFlag) ? currentProject.name : currentDevicegroup.name;

    renameProjectLabel.stringValue = (renameProjectFlag) ? @"Enter a new project name or update the description:" : @"Enter a new device group name or update the description:";
    renameProjectLinkCheckbox.title = (renameProjectFlag) ? @"Also update the product linked to this project" : @"Also update the device group in the impCloud";

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
        renameProjectLabel.stringValue = @"That description is too long. Please enter another description, or cancel.";
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

            if (![self isCorrectAccount:currentProject])
            {
                // We're logged in, but to the wrong account

                [self projectAccountAlert:currentProject :@"update the product linked to" :_window];
                return;
            }

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
                [self writeStringToLog:[NSString stringWithFormat:@"No changes made to project \"%@\".", currentProject.name] :YES];
            }
        }
        else
        {
            // Do all the work here because we're not making an async operation

            if ([currentProject.name compare:newName] != NSOrderedSame)
            {
                currentProject.name = newName;
                currentProject.haschanged = YES;
                iwvc.project = currentProject;

                // Update the UI only if the name has changed

                [self refreshOpenProjectsSubmenu];
                [self refreshProjectsMenu];
                [self refreshDeviceGroupsSubmenu];
                [self refreshDeviceGroupsMenu];
            }

            if ([currentProject.description compare:newDesc] != NSOrderedSame)
            {
                currentProject.description = newDesc;
                currentProject.haschanged = YES;
                iwvc.project = currentProject;
            }

            // Report if no changes were made

            if (!currentProject.haschanged) [self writeStringToLog:[NSString stringWithFormat:@"No changes made to project \"%@\".", currentProject.name] :YES];

            // Update the save indicator if anything has changed

            [saveLight needSave:currentProject.haschanged];
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

            if (![self isCorrectAccount:currentProject])
            {
                // We're logged in, but to the wrong account

                [self devicegroupAccountAlert:currentDevicegroup :@"update" :_window];
                return;
            }

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
                // Add the device group's type to the keys - values arrays. It will not be changed,
                // but it hacks around an issue with BuildAPIAccess

                [keys addObject:@"type"];
                [values addObject:currentDevicegroup.type];

                NSDictionary *dict = @{ @"action" : @"devicegroupchanged",
                                        @"devicegroup" : currentDevicegroup };

                [ide updateDevicegroup:currentDevicegroup.did :(NSArray *)keys :(NSArray *)values :dict];

                // Pick up the action at 'updateDevicegroupStageTwo:'
            }
            else
            {
                [self writeStringToLog:[NSString stringWithFormat:@"No changes made to device group \"%@\".", currentDevicegroup.name] :YES];
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
                iwvc.project = currentProject;

                // Update the UI; in the above code the UI will be updated
                // in response to notification from the server

                [self refreshOpenProjectsSubmenu];
                [self refreshDeviceGroupsSubmenu];
                [self refreshDeviceGroupsMenu];
            }

            if ([currentDevicegroup.description compare:newDesc] != NSOrderedSame)
            {
                currentDevicegroup.description = newDesc;
                currentProject.haschanged = YES;
                iwvc.project = currentProject;

                [self refreshOpenProjectsSubmenu];
            }

            if (!currentProject.haschanged) [self writeStringToLog:[NSString stringWithFormat:@"No changes made to device group \"%@\".", currentDevicegroup.name] :YES];

            // Update the save indicator if anything has changed

            [saveLight needSave:currentProject.haschanged];
        }
    }
}



#pragma mark Upload Project


- (IBAction)doUpload:(id)sender
{
    // Entry point for the UI upload project operation

    // We can't upload this project to a product if we're not logged in

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"upload this project"];
        return;
    }

    // Must have a selected project to sync (this should be prevented by the UI)

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    // Start the upload operation

    [self uploadProject:currentProject];
}



- (void)uploadProject:(Project *)project
{
    // Uploading a project is the act of creating a new product out of a pre-existing project,
    // ie. a new product wasn't created when the project was created

    BOOL correctAccount = [ide.currentAccount compare:project.aid] == NSOrderedSame ? YES : NO;

    if (project.pid == nil || project.pid.length == 0)
    {
        // TODO Complete account check

        if (correctAccount)
        {
            // Project has no PID so just create a new product

            if (productsArray != nil)
            {
                // Compare the project's name against existing product names

                if (productsArray.count > 0)
                {
                    for (NSDictionary *product in productsArray)
                    {
                        NSString *name = [self getValueFrom:product withKey:@"name"];

                        if ([name compare:project.name] == NSOrderedSame)
                        {
                            // The project's name matches an existing product name
                            // TODO Fix an action for this rather than bailing

                            return;
                        }
                    }
                }
            }
            else
            {
                // Get the list of products from the server

                NSDictionary *dict = @{ @"action" : @"uploadproject",
                                        @"project" : project };

                [ide getProducts:dict];

                // Pick up in 'listProducts:'
            }

            [self writeStringToLog:[NSString stringWithFormat:@"Uploading project \"%@\" to impCloud: making a product...", project.name] :YES];

            // Start by creating the product

            NSDictionary *dict = @{ @"action" : @"uploadproject",
                                    @"project" : project };

            [ide createProduct:project.name :project.description :dict];

            // Pick up in 'createProductStageTwo:'
        }
        else
        {
            // The project is associated with an account other than the one we're signed in to

            [self reassociateProject:project];
        }
    }
    else
    {
        // Project has a PID, but has it been orphaned?

        if (!correctAccount)
        {
            // The project is associated with an account other than the one we're signed in to

            [self reassociateProject:project];
            return;
        }

        if (productsArray == nil)
        {
            // We don't have the products list populated yet, so we need to get it first

            [self writeStringToLog:@"Retrieving a list of your products" :YES];

            NSDictionary *dict = @{ @"action" : @"uploadproject",
                                    @"project" : project };

            [ide getProducts:dict];

            // Pick up the action at 'listProducts:'
        }
        else if (productsArray.count > 0)
        {
            BOOL deadpid = YES;

            for (NSDictionary *product in productsArray)
            {
                NSString *pid = [product objectForKey:@"id"];

                if ([project.pid compare:pid] == NSOrderedSame)
                {
                    [self writeErrorToLog:@"This project already exists as a product in the impCloud." :YES];
                    deadpid = NO;
                    break;
                }
            }

            if (deadpid)
            {
                // We have an orphan project - its product has been deleted and its PID is dead
                // so clear the pid and proceed with the upload.

                [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Project \"%@\" is linked to a deleted product. Deleting the link.", project.name] :YES];

                project.pid = @"";

                NSDictionary *dict = @{ @"action" : @"uploadproject",
                                        @"project" : project };

                [ide createProduct:project.name :project.description :dict];

                // Pick up in 'createProductStageTwo:'

                return;
            }
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



- (void)reassociateProject:(Project *)project
{
    // This method re-binds the specified project to a different product under a different account
    // EXPERIMENTAL

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"Project “%@” is not associated with the logged in account.", project.name];

    if (project.pid == nil || project.pid.length == 0)
    {
        alert.informativeText = [NSString stringWithFormat:@"Do you wish to re-associate it with the current account (this will break its link with account %@), or cancel the upload?", project.aid];
    }
    else
    {
        alert.informativeText = [NSString stringWithFormat:@"Do you wish to re-associate it with the current account (this will break its link with product %@ and account %@), or cancel the upload?", project.pid, project.aid];
    }

    [alert addButtonWithTitle:@"Cancel"];
    [alert addButtonWithTitle:@"Associate"];
    [alert setAlertStyle:NSAlertStyleWarning];
    [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
        if (returnCode == NSAlertSecondButtonReturn)
        {
            // Proceed with the upload to this account

            project.aid = ide.currentAccount;
            project.pid = @"";
            project.haschanged = YES;

            if (project == currentProject)
            {
                // Update the Inspector manually

                iwvc.project = currentProject;
                [saveLight needSave:YES];
            }

            // Re-call 'uploadProject:' now that we have changed the Account ID and Product ID

            [self uploadProject:project];
        }
    }];
}



#pragma mark Project Synchronisation


- (IBAction)doSync:(id)sender
{
    // This is the start point for the UI to trigger a project sync

    // We can't sync if we're not logged in

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"upload or sync this project"];
        return;
    }

    // Must have a selected project to sync (this should be prevented by the UI)

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    // Does the current project have a product ID?

    if (currentProject.pid == nil || currentProject.pid.length == 0)
    {
        // No, so warn the user and request they associate the project with a product
        // or upload the project (ie. create a product for it)

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Project “%@” is not linked to a product", currentProject.name];
        alert.informativeText = @"You can associate the project it with a product (use the 'Projects' > 'Link Product' menu item) and then synchronise again. You may need to refresh the list of products in the impCloud first. Or you can upload the project to a new product.";

        [alert addButtonWithTitle:@"Upload"];
        [alert addButtonWithTitle:@"Associate"];
        [alert addButtonWithTitle:@"Cancel"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertFirstButtonReturn)
            {
                // Proceed to upload the project

                [self uploadProject:currentProject];
            }
        }];

        return;
    }

    // Now go and perform the sync

    [self syncProject:currentProject];
}



- (void)syncProject:(Project *)project
{
    // Retrieve the device groups for this specific product ID. We will later
    // compare this list with the local list in order to see what needs to be
    // uploaded or downloaded

    NSDictionary *dict = @{ @"action" : @"syncproject",
                            @"project" : currentProject };

    [ide getDevicegroupsWithFilter:@"product.id" :currentProject.pid :dict];

    // At this point the we have to wait for the async call to 'productToProjectStageTwo:'
}



- (IBAction)cancelSyncChoiceSheet:(id)sender
{
    // Close the unsynced device groups sheet and end the operation

    [_window endSheet:syncChoiceSheet];
}



- (IBAction)closeSyncChoiceSheet:(id)sender
{
    // Close the unsynced device groups sheet and prepare to download
    // the selected missing device groups, if any

    [_window endSheet:syncChoiceSheet];

    // If no device groups are selected, treat this as a cancel

    if (sywvc.selectedGroups.count == 0) return;

    // Assemble a list of device groups to download into the project

    NSMutableArray *groupsToSync = [[NSMutableArray alloc] init];

    for (NSUInteger i = 0 ; i < sywvc.selectedGroups.count ; ++i)
    {
        NSNumber *num = [sywvc.selectedGroups objectAtIndex:i];
        [groupsToSync addObject:[sywvc.syncGroups objectAtIndex:num.integerValue]];
    }

    // NOTE The following test should always be true

    if (groupsToSync.count > 0)
    {
        BOOL noDeployments = YES;

        // Record the number of devicegroups to download/upload

        sywvc.project.count = groupsToSync.count;

        if (sywvc.presentingRemotes)
        {
            // Handle the device groups for downloading

            for (NSDictionary *dg in groupsToSync)
            {
                // Convert each of the downloadable device group dictionaries
                // into local objects for inclusion in the project

                Devicegroup *newdg = [[Devicegroup alloc] init];
                newdg.did = [dg objectForKey:@"id"];
                newdg.name = [self getValueFrom:dg withKey:@"name"];

                bool got = YES;
                NSUInteger count = 0;
                NSString *newName = newdg.name;

                do
                {
                    got = [self checkDevicegroupName:newName];

                    if (got) {
                        count++;
                        newName = [newName stringByAppendingFormat:@" %00li", (long)count];
                    }
                }
                while (got);

                newdg.type = [self getValueFrom:dg withKey:@"type"];
                newdg.description = [self getValueFrom:dg withKey:@"description"];
                newdg.data = [NSMutableDictionary dictionaryWithDictionary:dg];

                if (sywvc.project.devicegroups == nil) sywvc.project.devicegroups = [[NSMutableArray alloc] init];
                [sywvc.project.devicegroups addObject:newdg];

                // Does the device group have a current deployment

                NSDictionary *cd = [self getValueFrom:dg withKey:@"current_deployment"];

                if (cd != nil)
                {
                    // The dictionary has a current deployment, so go and get it

                    NSDictionary *dict = @{ @"action" : @"syncmodelcode",
                                            @"devicegroup" : newdg,
                                            @"project": sywvc.project };

                    [ide getDeployment:[cd objectForKey:@"id"] :dict];

                    // At this point we have to dela with multiple async calls to 'productToProjectStageThree:'

                    noDeployments = NO;
                }
            }

            // Mark the project as requiring a save (we've added at least one new device group

            sywvc.project.haschanged = YES;

            if (noDeployments)
            {
                // None of the device groups have code, so we need to update the UI here

                // [self postSync:sywvc.project];
            }

            // Re-call the project sync to trap un-uploaded device groups
            // NOTE These were detected but not actioned becuase we handled downloads
            //      in preference to them. Going back means there are now no groups
            //      to download, so the uploads will be handled. if there are no
            //      groups to upload, the project is in sync and the post-sync
            //      alert will appear

            [self syncProject:sywvc.project];
        }
        else
        {
            // Handle uploads

            [self syncLocalDevicegroups:groupsToSync];
        }
    }
}



- (void)postSync:(Project *)project
{
    // NOTE May renove this before release (see 'closeSyncChoiceSheet:')

    // Update the UI immediately after a sync

    [saveLight needSave:project.haschanged];
    [self refreshDeviceGroupsMenu];
    [self refreshDeviceGroupsSubmenu];
    [self refreshDeviceMenu];
    [self setToolbar];

    if (project == currentProject) iwvc.project = project;

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"Project “%@” synchronised", project.name];
    alert.informativeText = @"All of the device groups listed on the server are now accessible via the project. Please save the project to write any downloaded code to disk.";

    [alert beginSheetModalForWindow:_window completionHandler:nil];
}



- (void)syncLocalDevicegroups:(NSMutableArray *)devicegroups
{
    // NOTE All of the devicegroups in the array will have the same
    //      parent. We've already checked (in doSync:) that the
    //      project is associated with a product

    Project *parent = [self getParentProject:[devicegroups firstObject]];
    parent.count = devicegroups.count;

    // Run through the list of local-only devicegroups and create a new group
    // on the server for each.

    for (Devicegroup *dg in devicegroups) {

        NSDictionary *dict = @{ @"action" : @"syncdevicegroup",
                                @"project" : parent,
                                @"devicegroup" : dg };

        NSString *altName = [dg.data objectForKey:@"dgname"];
        if (altName == nil) altName = dg.name;

        NSDictionary *newdg = @{ @"name" : altName,
                                 @"description" : dg.description,
                                 @"productid" : parent.pid,
                                 @"type" : dg.type };

        [ide createDevicegroup:newdg :dict];

        // Pick up the action in 'createDevicegroupStageTwo:'

        // NOTE Creation may fail because the DG is a (pre_)fixture and requires targets
        // TODO Fix this by calling 'newDevicegroupSheetCreateStageTwo:'
    }
}



#pragma mark Recent Project List Management


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
        if (isBookmarkStale)
        {
            // The project's bookmark is stale, ie. it has changed location.
            // 'url' contains the new location

            isBookmarkStale = NO;

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
        BOOL changed = NO;

        for (NSDictionary *recent in recentFiles)
        {
            isBookmarkStale = NO;
            NSURL *url = [self urlForBookmark:[recent valueForKey:@"bookmark"]];

            if (isBookmarkStale)
            {
                changed = YES;
                if (url != nil)
                {
                    [self writeStringToLog:[NSString stringWithFormat:@"Updating location of project file \"%@\".", [recent valueForKey:@"name"]] :YES];

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
        // We removed one or more files from recentFiles, so re-process this menu

        if (changed) [self refreshRecentFilesMenu];

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

    // Set the selected product to the chosen menu item's represented object
    // NOTE all products menu items reference their source this way

    NSMenuItem *item = (NSMenuItem *)sender;

    if (item.representedObject != nil && item.representedObject != selectedProduct)
    {
        selectedProduct = item.representedObject;

        // Update the UI:
        //   The product list sub-menu's selection
        //   The main Projects menu
        //   The toobar

        [self setProductsMenuTick];
        [self refreshProjectsMenu];
        [self setToolbar];
    }
}



- (IBAction)getProductsFromServer:(id)sender
{
    // Get a list of the current account's products to populate the Projects menu's products sub-menu,
    // but only if we are logged in

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"get a list of products from the impCloud"];
        return;
    }

    [self writeStringToLog:@"Getting a list of this account's products from the impCloud..." :YES];

    NSDictionary *dict = @{ @"action" : @"getproducts" };

    if (ide.currentAccount != nil && ide.currentAccount.length > 0)
    {
        [ide getProducts:dict];

        // Pick up the action in 'listProducts:'
        // NOTE This will trigger updates to:
        //      The Project Inspector (sets 'products' array)
        //      Projects menu
        //      Projects > Products sub-menu
        //      Toolbar
    }
    else
    {
        [ide getMyAccount:dict];

        // Pick up the action in 'gotMyAccount:'
    }
}



- (IBAction)deleteProduct:(id)sender
{
    // Delete the selected product, if there is one, and provided we are logged in

    if (selectedProduct == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProduct] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"delete products"];
        return;
    }

    // NOTE we shouldn't need to check the account at this point as we are dealing with server-only
    // entities, ie. only the products from the current account are presented for possible deletion

    BOOL flag = NO;

    // If the product is linked to a project, pre-flight the deletion
    // by checking the product's device groups (if it has any) for assigned devices
    // We can only do this with open projects, and when we have retrieved a list
    // of devices, but it saves checking with the server

    if (projectArray.count > 0)
    {
        NSString *pid = [self getValueFrom:selectedProduct withKey:@"id"];

        for (Project *project in projectArray)
        {
            if ([project.pid compare:pid] == NSOrderedSame)
            {
                // This product has a matching project (referenced by ID)
                // Check if any of the project's device groups know about devices

                if (devicesArray.count > 0 && project.devicegroups.count > 0)
                {
                    for (Devicegroup *devicegroup in project.devicegroups)
                    {
                        if (devicegroup.devices.count > 0)
                        {
                            // The device group thinks it has assigned devices so
                            // flag this up so we don't attempt to delete the product

                            flag = YES;
                            break;
                        }
                    }
                }
            }

            // Break out here because we know we have a match

            if (flag) break;
        }
    }

    if (!flag)
    {
        // The selected product is not associated with an open project or,
        // if it is, its device groups are all BELIEVED to be empty - we will check this later

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"You are about to delete product “%@”. Are you sure you want to proceed?", [self getValueFrom:selectedProduct withKey:@"name"]];
        alert.informativeText = @"Selecting ‘Yes’ will permanently delete the product, but only if its device groups have no devices assigned to any of them.";
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        [alert setAlertStyle:NSAlertStyleWarning];
        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn)
            {
                // Proceed with the deletion: create a dictionary holding the product itself
                // and a count variable which we'll use to tick of devicegroups as they are
                // also deleted

                NSMutableDictionary *productToDelete = [[NSMutableDictionary alloc] init];
                [productToDelete setObject:selectedProduct forKey:@"product"];
                [productToDelete setObject:[NSNumber numberWithInteger:0] forKey:@"count"];

                // First, get a list of the product's device groups

                NSDictionary *dict = @{ @"action" : @"deleteproduct",
                                        @"product" : productToDelete };

                [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - checking for device groups...", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];

                [ide getDevicegroupsWithFilter:@"product.id" :[selectedProduct objectForKey:@"id"] :dict];

                // Pick up the action in 'productToProjectStageTwo:'
            }
        }];
    }
    else
    {
        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Cannot delete product \"%@\" as it appears to have device groups with assigned devices", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];
    }
}



- (IBAction)downloadProduct:(id)sender
{
    // This is the process by which a product on the server is downloaded as a project
    // The project is created with the requisite number of device groups, each of which
    // has its current deployment downloaded and saved as source code files.
    // This is only possible if the user is logged in (and has a list of products)

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"download products"];
        return;
    }

    if (selectedProduct == nil)
    {
        [self writeErrorToLog:@"You have not selected a product as the new project's source." :YES];
        return;
    }

    NSString *name = [self getValueFrom:selectedProduct withKey:@"name"];
    [self writeStringToLog:[NSString stringWithFormat:@"Downloading product \"%@\" - retrieving device groups and source code...", name] :YES];
    [self writeStringToLog:@"Please be patient as this may take some time if the product has many components." :YES];

    Project *newProject = [[Project alloc] init];

    // Set new project's name, id and desc to match that of the source product

    newProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
    newProject.description = [self getValueFrom:selectedProduct withKey:@"description"];
    // newProject.path = workingDirectory;
    newProject.aid = ide.currentAccount;

    NSString *cid = [selectedProduct valueForKeyPath:@"relationships.creator.id"];

    if ([cid compare:newProject.aid] != NSOrderedSame) newProject.cid = cid;

    NSInteger count = 1;
    BOOL done = YES;

    // Update the name if it matches a loaded project - the user can change this at the saving stage

    if (projectArray.count > 0)
    {
        // Repetitively run through the project list checking the current name
        // against existing names, until we are safe to proceed. This deals with
        // the case where we have multiple uses of the same name, each with a
        // number to differentiate them, eg. 'project', 'project 1', 'project 2', etc.

        do
        {
            for (Project *project in projectArray)
            {
                if ([name compare:project.name] == NSOrderedSame)
                {
                    // We've got a matching name, so add a number to the end of the
                    // new project's name, 'project' -> 'project x'
                    // Make sure we restart the loop to check the new current name
                    // against ALL existing names as it may still match
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
    }

    newProject.name = name;

    NSDictionary *dict = @{ @"action" : @"downloadproduct",
                            @"project" : newProject };

    // Add the project to the list of current downloading products
    // TODO Do we need this? Probably not (we can refresh list at the end)

    //if (downloads == nil) downloads = [[NSMutableArray alloc] init];

    //[downloads addObject:newProject];

    // Now retrieve the device groups for this specific product id

    [ide getDevicegroupsWithFilter:@"product.id" :newProject.pid :dict];

    // At this point the we have to wait for the async call to 'productToProjectStageTwo:'
}



- (IBAction)linkProjectToProduct:(id)sender
{
    if (selectedProduct == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProduct] :YES];
        return;
    }

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We have selected a project that is NOT tied to the current account, so we can't link them

        [self projectAccountAlert:currentProject :[NSString stringWithFormat:@"link product “%@” with", [self getValueFrom:selectedProduct withKey:@"name"]] :_window];
        return;
    }

    NSString *pid = [selectedProduct objectForKey:@"id"];

    if (currentProject.pid != nil && [currentProject.pid compare:pid] == NSOrderedSame)
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" is already linked to product \"%@\".", currentProject.name, [self getValueFrom:selectedProduct withKey:@"name"]] :YES];

        // TODO - give the user the choice to change
    }
    else
    {
        // Link the project to the new product by ID, and set the project's
        // account association — by linking to a product, the project MUST be
        // also linked to the product's parent account

        currentProject.pid = pid;
        currentProject.aid = ide.currentAccount;
        currentProject.haschanged = YES;
        iwvc.project = currentProject;

        [self refreshOpenProjectsSubmenu];
        [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" is now linked to product \"%@\".", currentProject.name, [self getValueFrom:selectedProduct withKey:@"name"]] :YES];

        // TODO This has to have an implicit sync eg. if the project has device groups
        //      not in the product, and vice versa. What about matching device groups?
    }

    // Update UI

    [saveLight needSave:YES];
}



#pragma mark - New Device Group Methods


- (IBAction)newDevicegroup:(id)sender
{
    // Add a device group to the current project
    // Because this also adds a device group to the linked product,
    // this can only be done when we are logged in UNLESS the project
    // has no linked product

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    if (currentProject.pid.length > 0)
    {
        if (!ide.isLoggedIn)
        {
            [self loginAlert:@"create device groups"];
            return;
        }

        if (![self isCorrectAccount:currentProject])
        {
            // We are working on a project that is NOT tied to the current account

            [self projectAccountAlert:currentProject :@"add a device group to" :_window];
            return;
        }
    }

    if (sender != nil)
    {
        newDevicegroupLabel.stringValue = @"What would you like to call the new device group?";
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
    
    newDevicegroupTypePopup.menu.autoenablesItems = NO;
    
    if (accountType != kElectricImpAccountTypePaid)
    {
        for (NSUInteger i = 0 ; i < newDevicegroupTypePopup.itemArray.count ; ++i)
        {
            if (i > 0)
            {
                NSMenuItem *item = [newDevicegroupTypePopup.itemArray objectAtIndex:i];
                item.enabled = NO;
            }
        }
    }
    else
    {
        for (NSMenuItem *item in newDevicegroupTypePopup.itemArray)
        {
            if (!item.enabled) item.enabled = YES;
        }
    }
    
    [newDevicegroupTypePopup selectItemAtIndex:0];

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
        [ays setAlertStyle:NSAlertStyleWarning];
        [ays beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
            if (returnCode == NSAlertSecondButtonReturn)
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

                [self refreshDeviceGroupsMenu];
                [self refreshDeviceGroupsSubmenu];

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
    NSInteger newType = newDevicegroupTypePopup.indexOfSelectedItem;

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

        newDevicegroupLabel.stringValue = @"The description you chose is too long. Please enter another one, or cancel.";
        [NSThread sleepForTimeInterval:2.0];
        [self newDevicegroup:nil];
        return;
    }

    if (dgname.length == 0)
    {
        // Device Group name is too short

        newDevicegroupLabel.stringValue = @"You must choose a device group name. Please choose a name, or cancel.";
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
                newDevicegroupLabel.stringValue = @"The current project already has a device group with that name. Please choose another, or cancel.";
                [NSThread sleepForTimeInterval:2.0];
                [self newDevicegroup:nil];
                return;
            }
        }
    }

    newdg.name = dgname;
    newdg.description = dgdesc;
    newdg.type = @"development_devicegroup";

    // FROM 2.3.128: support new DUT device groups
    // NOTE the missing case values are for the menu separators
    //      between Dev, Test and Prod categories

    switch (newType)
    {
            // Development groups
        default:
        case 0:
            newdg.type = @"development_devicegroup";
            break;
            // Test groups
        case 2:
            newdg.type = @"pre_factoryfixture_devicegroup";
            break;
        case 3:
            newdg.type = @"pre_dut_devicegroup";
            break;
        case 4:
            newdg.type = @"pre_production_devicegroup";
            break;
            // Production groups
        case 6:
            newdg.type = @"factoryfixture_devicegroup";
            break;
        case 7:
            newdg.type = @"dut_devicegroup";
            break;
        case 8:
            newdg.type = @"production_devicegroup";
            break;
    }

    if (newType == 2 || newType == 6)
    {
        // On choosing a Fixture device group, we need to eastablish a target or creation will fail
        // FROM 2.3.128: support new DUT device groups; Fixture device groups now have two targets:
        //               one DUT group and one Production group

        NSUInteger dutCount = [self checkDUTTargets:newType];
        NSUInteger prodCount = [self checkProdTargets:newType];
        NSString *typeString = newType == 2 ? @"Test " : @"";

        if (prodCount == 0 && dutCount == 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"You cannot create a %@Fixture device group", typeString];
            alert.informativeText = [NSString stringWithFormat:@"To create this type of device group, you need to specify %@Production and DUT device groups as its targets, and you have no such device groups in this project.", typeString];

            [alert beginSheetModalForWindow:_window completionHandler:nil];

            return;
        }

        if (prodCount == 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"You cannot create a %@Fixture device group", typeString];
            alert.informativeText = [NSString stringWithFormat:@"To create this type of device group, you need to specify a %@Production device group as its target, and you have no such device group in this project.", typeString];

            [alert beginSheetModalForWindow:_window completionHandler:nil];

            return;
        }

        if (dutCount == 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"You cannot create a %@Fixture device group", typeString];
            alert.informativeText = [NSString stringWithFormat:@"To create this type of device group, you need to specify a %@DUT device group as its target, and you have no such device group in this project.", typeString];

            [alert beginSheetModalForWindow:_window completionHandler:nil];

            return;
        }

        // Go to the next stage: choose the target production device group

        newTargetsFlag = YES;

        [self showSelectTarget:newdg :makeNewFiles :kTargetDeviceGroupTypeProd];
    }
    else
    {
        // For all device groups other than (test) factory device groups,
        // go an create the device group

        [self newDevicegroupSheetCreateStageTwo:newdg :currentProject :makeNewFiles :nil];
    }
}



- (NSUInteger)checkDUTTargets:(NSUInteger)groupType
{
    return [self checkTargets:(groupType == 2 ? @"pre_d" : @"dut")];
}



- (NSUInteger)checkProdTargets:(NSUInteger)groupType
{
    return [self checkTargets:(groupType == 2 ? @"pre_p" : @"prod")];
}



- (NSUInteger)checkTargets:(NSString *)groupPrefix
{
    NSUInteger count = 0;

    for (Devicegroup *dg in currentProject.devicegroups)
    {
        if ([dg.type hasPrefix:groupPrefix]) ++count;
    }

    return count;
}



- (void)newDevicegroupSheetCreateStageTwo:(Devicegroup *)devicegroup :(Project *)project :(BOOL)makeNewFiles :(NSMutableArray *)anyTargets
{
    if (project.pid != nil && project.pid.length > 0)
    {
        // The current project is associated with a product so we can create the device group on the server

        NSDictionary *dict = @{ @"action" : @"newdevicegroup",
                                @"devicegroup" : devicegroup,
                                @"project" : project,
                                @"files" : [NSNumber numberWithBool:makeNewFiles] };

        [self writeStringToLog:[NSString stringWithFormat:@"Uploading device group \"%@\" to the impCloud.", devicegroup.name] :YES];

        NSDictionary *details;

        if (![devicegroup.type containsString:@"factoryfixture"])
        {
            details = @{ @"name" : devicegroup.name,
                         @"description" : devicegroup.description,
                         @"productid" : project.pid,
                         @"type" : devicegroup.type };
        }
        else
        {
            if ([devicegroup.type containsString:@"fixture"] && anyTargets != nil)
            {
                // Assume the device group's two targets are actually Devicegroups for now
                // and that they are in the correct order - Production then DUT - which
                // SHOULD be the case

                Devicegroup *dg1 = [anyTargets firstObject];
                Devicegroup *dg2 = [anyTargets lastObject];

                if (dg1 == dg2)
                {
                    // ERROR
                    
                    NSLog(@"Target device groups match");
                    [self writeErrorToLog:[NSString stringWithFormat:@"New device group \"%@\" has been set with the same target twice. Cannot proceed.", devicegroup.name] :YES];
                    return;
                }

                details = @{ @"name" : devicegroup.name,
                             @"description" : devicegroup.description,
                             @"productid" : project.pid,
                             @"type" : devicegroup.type,
                             @"targetid" : dg1.did,
                             @"dutid": dg2.did };
            }
            else
            {
                details = @{ @"name" : devicegroup.name,
                             @"description" : devicegroup.description,
                             @"productid" : project.pid,
                             @"type" : devicegroup.type };
            }
        }

        [ide createDevicegroup:details :dict];

        // We will handle the addition of the device group and UI updates later - it will call
        // the following code separately in 'createDevicegroupStageTwo:'
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

        [project.devicegroups addObject:devicegroup];

        if (project == currentProject)
        {
            if (devicegroup != currentDevicegroup)
            {
                currentDevicegroup = devicegroup;
                project.devicegroupIndex = [project.devicegroups indexOfObject:currentDevicegroup];
            }

            iwvc.project = project;
            project.haschanged = YES;

            [saveLight needSave:YES];
            [self refreshOpenProjectsSubmenu];
        }

        // Update the UI

        [self refreshDeviceGroupsSubmenu];
        [self refreshDeviceGroupsMenu];
        [self setToolbar];

        // Create the new device group's files as requested

        if (makeNewFiles) [self createFilesForDevicegroup:devicegroup.name :@"agent"];
    }
}



- (void)showSelectTarget:(Devicegroup *)devicegroup :(BOOL)andMakeNewFiles :(NSInteger)targetType
{
    // Show a sheet listing suitable fixture device group targets

    // ADDED IN 2.3.128
    // Pass across the type of device group that needs to be chosen as a target

    swvc.targetType = targetType;
    swvc.theNewDevicegroup = devicegroup;
    swvc.makeNewFiles = andMakeNewFiles;
    swvc.project = currentProject;

    [swvc prepSheet];
    [_window beginSheet:selectTargetSheet completionHandler:nil];
}



- (IBAction)cancelSelectTarget:(id)sender
{
    // Close the sheet...

    [_window endSheet:selectTargetSheet];

    // ... and reset any progress variables

    newTargetsFlag = NO;
}



- (IBAction)selectTarget:(id)sender
{
    // If no target was selected, bail

    if (swvc.theSelectedTarget == nil)
    {
        // No target was selected in the dialog so treat this as a cancel

        [self cancelSelectTarget:nil];

        return;
    }

    // Close the sheet

    [_window endSheet:selectTargetSheet];

    // If we are not changing a target for an existing device, continue with the creation of a new devicegroup
    // ie. if 'newTargetsFlag' is true

    if (newTargetsFlag)
    {
        // ADDED IN 2.3.128 Branch back to re-show the select group for the subsequent targets

        if (swvc.targetType == kTargetDeviceGroupTypeProd)
        {
            // We have just got the (Test) Production Device Group target,
            // so go back and get the (Test) DUT Device Group

            if (fixtureTargets == nil)
            {
                fixtureTargets = [[NSMutableArray alloc] init];
            }
            else
            {
                [fixtureTargets removeAllObjects];
            }

            [fixtureTargets addObject:swvc.theSelectedTarget];

            [self showSelectTarget:swvc.theNewDevicegroup :swvc.makeNewFiles :kTargetDeviceGroupTypeDUT];
        }
        else if (swvc.targetType == kTargetDeviceGroupTypeDUT)
        {
            // We now have the (Test) DUT Device Group, so we're ready to create the new group

            newTargetsFlag = NO;

            swvc.targetType = kTargetDeviceGroupTypeNone;

            [fixtureTargets addObject:swvc.theSelectedTarget];

            [self newDevicegroupSheetCreateStageTwo:swvc.theNewDevicegroup :swvc.project :swvc.makeNewFiles :fixtureTargets];
        }

        return;
    }

    // Check that the selected device group is not the current one

    // ADDED 2.3.128 Allow the use of various '_target' attributes

    NSString *key = @"";

    if (currentDevicegroup.data != nil)
    {
        if (swvc.targetType == kTargetDeviceGroupTypeProd) key = @"production_target";
        if (swvc.targetType == kTargetDeviceGroupTypeDUT)  key = @"dut_target";

        NSDictionary *tgt = [self getValueFrom:currentDevicegroup.data withKey:key];

        if (tgt != nil)
        {
            NSString *tid = [tgt objectForKey:@"id"];

            if ([tid compare:swvc.theSelectedTarget.did] == NSOrderedSame)
            {
                [self writeWarningToLog:[NSString stringWithFormat:@"The device group you selected is already one of device group \"%@\"'s targets.", currentDevicegroup.name]  :YES];
                return;
            }
        }
        else
        {
            // The device group were working with has no targets

            NSLog(@"ERROR: attempting to set a target on a non-targetable device group in selectTarget:");
            return;
        }
    }

    NSDictionary *dict = @{ @"action" : @"resetprodtarget",
                            @"devicegroup" : currentDevicegroup,
                            @"target" : swvc.theSelectedTarget };

    NSDictionary *targ = @{ @"type" : swvc.theSelectedTarget.type,
                            @"id" : swvc.theSelectedTarget.did };

    [ide updateDevicegroup:currentDevicegroup.did :@[key, @"type"] :@[targ, currentDevicegroup.type] :dict];

    // Pick up the action at 'updateDevicegroupStageTwo:'
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

        // Watch the new file

        BOOL added = [self checkAndWatchFile:savePath];

        if (action == kActionNewDGBothFiles)
        {
            // We have just written the agent code file, so now go and write the device file in the same place

            newModel.type = @"agent";
            [currentDevicegroup.models addObject:newModel];

            NSRange dot = [newFileName rangeOfString:@"."];
            if (dot.location != NSNotFound) newFileName = [newFileName substringToIndex:dot.location];
            newFileName = [newFileName stringByAppendingString:@".device.nut"];
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

            [self refreshDeviceGroupsMenu];

            Project *parent = [self getParentProject:currentDevicegroup];

            if (parent == currentProject) iwvc.project = currentProject;
        }

        if (!added) NSLog(@"Some files couldn't be added");
    }
    else
    {
        [self writeErrorToLog:@"The file could not be saved." :YES];
    }
}



#pragma mark - Existing Device Group Methods

- (void)chooseDevicegroup:(id)sender
{
    // User has selected a device group
    // So we need to set 'currentDevicegroup' to the chosen device group
    // And select the first device, if there is one
    // then update the UI

    BOOL devicegroupChanged = NO;
    NSMenuItem *item = (NSMenuItem *)sender;
    Devicegroup *dg = item.representedObject;

    if (dg != currentDevicegroup)
    {
        devicegroupChanged = YES;
        currentDevicegroup = dg;
        currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
    }

    // Switch off unselected menus - and submenus

    for (NSMenuItem *dgitem in deviceGroupsMenu.itemArray)
    {
        if (dgitem != item)
        {
            dgitem.state = NSOffState;

            if (dgitem.submenu != nil)
            {
                // Turn off any submenu items (ie. devices) too

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

            if (!deviceSelectFlag && dgitem.submenu != nil && devicegroupChanged)
            {
                // Only change the device if it's in a different devicegroup than before

                // TO 2.1.125 - The following lines select the device group's first
                //              device manually

                // NSMenuItem *sitem = [dgitem.submenu.itemArray objectAtIndex:0];
                // [self chooseDevice:sitem];

                // FROM 2.2.126 - Use the dedicated first-device selection function
                //                as this pops up the multi-device dialog if required
                [self selectFirstDevice];
            }
        }
    }

    deviceSelectFlag = NO;

    // Update the UI: the Device Groups menu and the View menu (in case
    // the selected device group has compiled code)

    [self refreshLibraryMenus];
    [self refreshDeviceGroupsSubmenu];
    [self refreshDeviceGroupsMenu];
    [self setToolbar];
}



- (IBAction)incrementCurrentDevicegroup:(id)sender
{
    // Move to the next device group in the list by determining which
    // one that is from the device group submenu, and sending that item
    // to chooseDevicegroup:

    if (currentProject.devicegroups.count > 1)
    {
        NSInteger next = currentProject.devicegroupIndex + 1;
        if (next >= currentProject.devicegroups.count) next = 0;
        Devicegroup *target = [currentProject.devicegroups objectAtIndex:next];

        for (NSInteger i = 1 ; i < deviceGroupsMenu.itemArray.count - 1 ; ++i)
        {
            NSMenuItem *item = [deviceGroupsMenu.itemArray objectAtIndex:i];
            Devicegroup *dg = item.representedObject;

            if (dg == target) {
                [self chooseDevicegroup:item];
                return;
            }
        }
    }
}


- (IBAction)decrementCurrentDevicegroup:(id)sender
{
    // Move to the previous device group in the list by determining which
    // one that is from the device group submenu, and sending that item
    // to chooseDevicegroup:

    if (currentProject.devicegroups.count > 1)
    {
        NSInteger previous = currentProject.devicegroupIndex - 1;
        if (previous < 0) previous = currentProject.devicegroups.count - 1;
        Devicegroup *target = [currentProject.devicegroups objectAtIndex:previous];

        for (NSInteger i = 1 ; i < deviceGroupsMenu.itemArray.count - 1 ; ++i)
        {
            NSMenuItem *item = [deviceGroupsMenu.itemArray objectAtIndex:i];
            Devicegroup *dg = item.representedObject;

            if (dg == target) {
                [self chooseDevicegroup:item];
                return;
            }
        }
    }
}



- (IBAction)deleteDevicegroup:(id)sender
{
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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

        if (![self isCorrectAccount:currentProject])
        {
            // We are working on a project that is NOT tied to the current account

            [self devicegroupAccountAlert:currentDevicegroup :@"delete" :_window];
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

                    [self accountAlert:[NSString stringWithFormat:@"Device group \"%@\" can’t be deleted.", currentDevicegroup.name]
                                      :[NSString stringWithFormat:@"Device group \"%@\" has devices assigned to it. A device group can’t be deleted until all of its devices have been re-assigned.", currentDevicegroup.name]
                                      :_window];
                    return;
                }
            }
        }

        // If we are here, the device group has no devices assigned, or we can't check at this time.
        // So just try to delete it anyway - the server will warn if the group can't be deleted

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"Are you sure you wish to delete device group “%@”?", currentDevicegroup.name];
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
        alert.messageText = [NSString stringWithFormat:@"Are you sure you wish to delete device group “%@”?", currentDevicegroup.name];
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
                 iwvc.project = currentProject;

                 [saveLight needSave:YES];
                 [self refreshOpenProjectsSubmenu];
                 [self refreshDeviceGroupsMenu];
                 [self refreshDeviceGroupsSubmenu];
             }
         }
         ];
    }
}



- (IBAction)renameDevicegroup:(id)sender
{
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        // The user is not logged in, but the device group is associated with a device group on the server.

        [self loginAlert:[NSString stringWithFormat:@"edit device group \"%@\"", currentDevicegroup.name]];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"edit" :_window];
        return;
    }

    [self renameProject:sender];
}



- (IBAction)uploadCode:(id)sender
{
    // This is a general method for both direct uploads and uploads with extra information

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
        [self writeErrorToLog:@"Cannot upload: the selected device group is not associated with a device group in the impCloud." :YES];
        return;
    }

    if (currentDevicegroup.models.count == 0)
    {
        [self writeErrorToLog:@"The selected device group contains no code to upload." :YES];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"upload code to" :_window];
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
            if (returnCode == NSAlertFirstButtonReturn)
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
            [self writeErrorToLog:@"The selected device group contains uncompiled code. Please compile before uploading." :YES];
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
    dt = [dt stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

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

    // Pick up the action at 'uploadCodeStageTwo:'
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

    // Pick up the action at 'uploadCodeStageTwo:'
}



- (IBAction)removeSource:(id)sender
{
    // This method removes a device group's links to its source code files
    // As this does not change the device group on the server, it can be done at any time

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"Are you sure you wish to remove the source code files from device group “%@”?", currentDevicegroup.name];
    alert.informativeText = @"This will remove all source code files from the device group but not delete them. You can re-add source code files to the device group at any time.";
    [alert addButtonWithTitle:@"No"];
    [alert addButtonWithTitle:@"Yes"];
    [alert beginSheetModalForWindow:_window
                  completionHandler:^(NSModalResponse response)
     {
         if (response != NSAlertFirstButtonReturn)
         {
             if (currentDevicegroup.models.count > 0)
             {
                 // FROM 2.3.128 - Unwatch the device group's files

                 [self closeDevicegroupFiles:currentDevicegroup :currentProject];

                 // Remove the model and file records from the device group

                 [currentDevicegroup.models removeAllObjects];
             }
             currentProject.haschanged = YES;
             iwvc.project = currentProject;

             [saveLight needSave:YES];
             // [self refreshOpenProjectsSubmenu];
             [self refreshLibraryMenus];
             [self refreshDeviceGroupsMenu];
         }
     }
     ];
}



- (IBAction)getCommits:(id)sender
{
    // Download a list of the commits made to the current device group
    // This requires the user to be logged in

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"download the list of commits"];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"list commits to" :_window];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"listcommits",
                            @"devicegroup" : currentDevicegroup };

    [ide getDeploymentsWithFilter:@"devicegroup.id" :currentDevicegroup.did :dict];

    // Pick up the action in 'listCommits:'
}



- (IBAction)updateCode:(id)sender
{
    // NOTE This method is not currently connected to a UI element, or called from within this file or
    // any other AppDelegate file. Keep for now, but may remove

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"updatecode",
                            @"devicegroup" : currentDevicegroup };

    [ide getDevicegroup:currentDevicegroup.did :dict];

    // Pick up the action in 'updateCodeStageTwo:'
}



- (IBAction)showMinimumDeploymentSheet:(id)sender
{
    // Pops up a sheet which displays all the commits made to the device group
    // The current set minimum deployment is checked - all those commits which are
    // older than the minimum are unavailablel; any newer one can be selected as
    // the minimum supported deployment
    // NOTE The table contained within the sheet is handled by a separate
    // CommitWindowViewController instance, 'cwvc'

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"set the minimum supported deployment"];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"set the minimum deployment for" :_window];
        return;
    }

    cwvc.devicegroup = currentDevicegroup;

    [cwvc prepSheet];
    [_window beginSheet:commitSheet completionHandler:nil];

    NSDictionary *dict = @{ @"action" : @"getcommits",
                            @"devicegroup" : currentDevicegroup };

    [ide getDeploymentsWithFilter:@"devicegroup.id" :currentDevicegroup.did :dict];

    // Pick up the action in 'listCommits:'
}



- (IBAction)cancelMinimumDeploymentSheet:(id)sender
{
    [_window endSheet:commitSheet];
}



- (IBAction)setMinimumDeployment:(id)sender
{
    NSDictionary *newMinimum = cwvc.minimumDeployment;

    [_window endSheet:commitSheet];

    NSDictionary *dg = [self getValueFrom:newMinimum withKey:@"devicegroup"];
    NSString *did = [dg objectForKey:@"id"];
    Devicegroup *devicegroup = nil;

    for (Project *project in projectArray)
    {
        if (project.devicegroups.count > 0)
        {
            for (Devicegroup *adg in project.devicegroups)
            {
                if ([adg.did compare:did] == NSOrderedSame)
                {
                    devicegroup = adg;
                    break;
                }
            }
        }
    }

    if (devicegroup == nil)
    {
        [self writeErrorToLog:[NSString stringWithFormat:@"Device group \"%@\" cannot be found", did] :YES];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"setmindeploy",
                            @"devicegroup" : devicegroup };

    [ide setMinimumDeployment:devicegroup.did :newMinimum :dict];

    // Pick up the action at ?????
}



- (IBAction)chooseProductionTarget:(id)sender
{
    // This method allows the user with ops access to select a factory device group's target
    // The sheet presents a list of suitable device groups in a table
    // NOTE The table contained within the sheet is handled by a separate
    // SelectWindowViewController instance, 'swvc'

    [self chooseTarget:kTargetDeviceGroupTypeProd];
}



- (IBAction)chooseDUTTarget:(id)sender
{
    // FROM 2.3.128
    // This method allows the user with ops access to select a factory device group's DUT target
    // The sheet presents a list of suitable device groups in a table
    // NOTE The table contained within the sheet is handled by a separate
    // SelectWindowViewController instance, 'swvc'

    [self chooseTarget:kTargetDeviceGroupTypeDUT];
}



- (void)chooseTarget:(NSInteger)type
{
    // FROM 2.3.128
    // This method allows the user with ops access to select a factory device group's DUT target
    // The sheet presents a list of suitable device groups in a table
    // NOTE The table contained within the sheet is handled by a separate
    // SelectWindowViewController instance, 'swvc'

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    NSString *groupType = type == kTargetDeviceGroupTypeDUT ? @"DUT" : @"production";

    if (!ide.isLoggedIn)
    {
        [self loginAlert:[NSString stringWithFormat:@"set %@ device groups as targets", groupType]];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :[NSString stringWithFormat:@"set a %@ device group as a target for", groupType] :_window];
        return;
    }

    if (![currentDevicegroup.type containsString:@"factoryfixture"])
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" is not a Fixture group so has no %@ target.", currentDevicegroup.name, groupType] :YES];
        return;
    }

    // NOTE see 'newDevicegroupSheetCreate:' for why we have 2 (pre-fixture) or 6 (fixture) here

    NSUInteger code = [currentDevicegroup.type hasPrefix:@"pre"] ? 2 : 6;
    NSString *groupPrefix = [currentDevicegroup.type hasPrefix:@"pre"] ? @"Test " : @"";
    NSUInteger count = type == kTargetDeviceGroupTypeDUT ? [self checkDUTTargets:code] : [self checkProdTargets:code];

    if (count == 0)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = [NSString stringWithFormat:@"You have no %@ %@ device groups in this project", groupPrefix, groupType];
        alert.informativeText = [NSString stringWithFormat:@"You will need to create a %@%@ device group in order to set it as one of the targets of %@Fixture device group \"%@\".", groupPrefix, groupType, groupPrefix, currentDevicegroup.name];

        [alert beginSheetModalForWindow:_window completionHandler:nil];

        return;
    }

    [self showSelectTarget:currentDevicegroup :NO :type];
}



- (IBAction)showTestBlessedDevices:(id)sender
{
    // Get and list a pre_production device group's devices

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (![currentDevicegroup.type containsString:@"pre_production"])
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" is not a Test Production group so has no test production devices.", currentDevicegroup.name] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"list test production devices"];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"show test production devices in" :_window];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"gettestblesseddevices",
                            @"devicegroup" : currentDevicegroup };

    [ide getDevicesWithFilter:@"devicegroup.id" :currentDevicegroup.did :dict];

    // Pick up the action at 'listDevices:'
}



- (IBAction)logAllDevices:(id)sender
{
    // ADDED IN 2.3.130
    // Add all of the devices in the devicegroup, if any, to the log stream
    
    // Make sure we have a device group selected - this should always be the case because we disable the menu item otherwise
    
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }
    
    // Are there any devices in the group to log from?
    
    if (currentDevicegroup.devices.count > 0)
    {
        // Run through all the devices. If any are not logging already, prep them for logging

        if (currentDevicegroup.devices.count <= kMaxLogStreamDevices - ide.numberOfLogStreams)
        {
            NSMutableArray *devicesToAdd = [[NSMutableArray alloc] init];
            NSString *devID;
            NSDictionary *device;

            // Run through all the devices and make a list of devices not currently logging
            
            for (NSUInteger i = 0 ; i < currentDevicegroup.devices.count ; i++)
            {
                devID = [currentDevicegroup.devices objectAtIndex:i];
                if (![ide isDeviceLogging:devID]) [devicesToAdd addObject:[self deviceWithID:devID]];
            }

            // If we need to start logging any devices, process them now

            if (devicesToAdd.count > 0)
            {
                // Get the first item on the list, and remove it from the list

                device = [devicesToAdd firstObject];
                devID = [device valueForKey:@"id"];
                [devicesToAdd removeObjectAtIndex:0];

                // Only try to start logging on the last device in the group, otherwise
                // add the device to an array. This array will be processed when (a) a log stream
                // has been started and then (b) the last device has been added to it successfully.
                // We can't just call 'startLogging:' for all the devices at once because of the
                // async nature of the op: starting logging a device can only begin when a stream is
                // up and running, and when don't know when that will be

                if (devicesToAdd.count > 0)
                {
                    // Log the first device and add the rest for pick-up later

                    [ide startLogging:devID :@{ @"device" : device, @"devices" : devicesToAdd }];
                }
                else
                {
                    // Just log the only device on the list

                    [ide startLogging:devID :@{ @"device" : device }];
                }

                // Set the Toolbar Item's state if the device is the currently selected one

                if (devID == (NSString *)[selectedDevice valueForKey:@"id"]) streamLogsItem.state = 1;

                // Set the spacing for the log output so that log messages align after the device name

                NSString *devname = [self getValueFrom:device withKey:@"name"];
                if (devname.length > logPaddingLength) logPaddingLength = devname.length;
            }
        }
        else
        {
            // There aren't enough logging slots for the
            
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = @"There are insufficient logging slots";
            alert.informativeText = [NSString stringWithFormat:@"You are currently logging %li devices. Devicegroup “%@” has %li devices assigned to it. Please select devices individually, or stop logging from some devices.", (long)ide.numberOfLogStreams, currentDevicegroup.name, (long)currentDevicegroup.devices.count];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:_window completionHandler:nil];
        }
    }
    else
    {
        // The device group has no devices, so inform the user
        
        [self writeWarningToLog:[NSString stringWithFormat:@"Devicegroup “%@” has no devices assigned to it.", currentDevicegroup.name] :YES];
    }
}



- (IBAction)closeAllDeviceLogs:(id)sender
{
    // ADDED 2.3.130
    // Stop logging any devices that are currently streaming
    // NOTE The UI is updated at the async pick-up: 'loggingStopped:' in 'AppDelegateAPIHandlers.m'

    if (loggedDevices.count > 0)
    {
        for (NSString *devID in loggedDevices)
        {
            // Empty-string entries are freed slots in the list, so
            // make sure we ignore them here

            if (devID.length > 0) [ide stopLogging:devID];
        }
    }
}



#pragma mark - Existing Device Methods


- (void)selectFirstDevice
{
    // Select the first device in the current device group, if we have a list of devices
    // and we actualy have a current device group. Called to select a device after a
    // project has been opened, selected or downloaded from a product
    //
    // Called from: openSquirrelProject:
    //              productToProjectStage2:
    //              chooseProject:

    if (devicesArray.count > 0)
    {
        // The current device group should have a list of devices - get the ID of the first one

        if (currentDevicegroup.devices.count > 0)
        {
            if (currentDevicegroup.devices.count == 1)
            {
                // 'currentDevicegroup.devices' only stores device IDs, so we need to find the
                // referenced device first

                NSString *devId = [currentDevicegroup.devices firstObject];

                for (NSMutableDictionary *device in devicesArray)
                {
                    NSString *aDevId = [self getValueFrom:device withKey:@"id"];

                    if ([aDevId compare:devId] == NSOrderedSame)
                    {
                        selectedDevice = device;
                        iwvc.device = selectedDevice;

                        [self setDevicesPopupTick];
                        [self setUnassignedDevicesMenuTick];
                        [self setDevicesMenusTicks];
                        [self refreshDeviceMenu];

                        return;
                    }
                }
            }
            else
            {
                NSMutableArray *selectedDevices = [[NSMutableArray alloc] init];

                for (NSString *devId in currentDevicegroup.devices)
                {
                    for (NSMutableDictionary *device in devicesArray)
                    {
                        NSString *aDevId = [self getValueFrom:device withKey:@"id"];

                        if ([aDevId compare:devId] == NSOrderedSame)
                        {
                            [selectedDevices addObject:device];
                        }
                    }
                }

                NSMutableDictionary *device = [selectedDevices firstObject];
                NSString *first = [self getValueFrom:device withKey:@"name"];
                if (first == nil) first = [self getValueFrom:device withKey:@"id"];

                NSString *list = @"";
                NSUInteger count = 0;

                for (NSMutableDictionary *device in selectedDevices)
                {
                    NSString *item = [self getValueFrom:device withKey:@"name"];
                    if (item == nil) item = [self getValueFrom:device withKey:@"id"];

                    ++count;

                    if (count == selectedDevices.count)
                    {
                        //if (list.length > 2) list = [list substringToIndex:list.length - 2];
                        //list = [list stringByAppendingFormat:@" and %@", item];
                        list = [list stringByAppendingFormat:@"  • %@\n", item];
                    }
                    else
                    {
                        list = [list stringByAppendingFormat:@"  • %@\n", item];
                    }
                }

                selectedDevice = [selectedDevices firstObject];
                iwvc.device = selectedDevice;

                [self setDevicesPopupTick];
                [self setUnassignedDevicesMenuTick];
                [self setDevicesMenusTicks];
                [self refreshDeviceMenu];

                // NOTE TO 2.1.125, 'com.bps.squinter.autoselectdevice' is not exposed, so
                //      we can add this here without breaking anything (fingers crossed...)
                //      We use it to block the multi-device warning sheet

                BOOL doShow = [defaults boolForKey:@"com.bps.squinter.autoselectdevice"];
                if (!doShow) return;

                // TODO Have to add a 'reset warnings' item to Prefs/somewhere too

                multiDeviceLabel.stringValue = [NSString stringWithFormat:@"This device group has mulitple assigned devices:\n\n%@\nThe first device, %@, will be selected initially.\nThis warning can be disabled in Preferences.", list, first];

                [_window beginSheet:multiDeviceSheet completionHandler:nil];
            }
        }
    }
}


- (IBAction)endMultiDeviceSheet:(id)sender
{
    [_window endSheet:multiDeviceSheet];
}



- (IBAction)updateDevicesStatus:(id)sender
{
    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"update devices' status information"];
        return;
    }

    [self writeStringToLog:@"Updating devices’ status information - this may take a moment..." :YES];
    [connectionIndicator startAnimation:self];

    // Get all the devices from development device groups and unassigned devices

    NSDictionary *dict = @{ @"action" : @"getdevices" };

    [ide getDevices:dict];

    // Pick up the action at 'listDevices:'
}



- (IBAction)keepDevicesStatusUpdated:(id)sender
{
    // Entry point for UI to enable or disable periodic device status checks
    // If 'sender' is nil, we've arrived from elsewhere in the code (eg. 'loggedin:')
    // in order that this is set in response to a prefs check

    if (refreshTimer != nil)
    {
        // If 'refreshTimer' is not nil, we are already auto-refreshing, so it's
        // clear that the the user wants to turn auto-updates off. Turn off the
        // timer, update the menu item and nil the refreshTimer reference, so we
        // don't come back here next time the menu is selected

        [refreshTimer invalidate];

        checkDeviceStatusMenuItem.state = NSOffState;
        refreshTimer = nil;
        return;
    }

    if (ide.isLoggedIn)
    {
        // If we are logged in to the impCloud, we can start to auto-refresh device info

        checkDeviceStatusMenuItem.state = NSOnState;

        // If there are no known devices yet, go and get the list

        if (devicesArray == nil || devicesArray.count == 0) [self updateDevicesStatus:nil];

        // Now set the refresh timer to call repeatedly

        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:updateDevicePeriod
                                                        target:self
                                                      selector:@selector(deviceStatusCheck)
                                                      userInfo:nil
                                                       repeats:YES];
    }
    else
    {
        // Only issue a warning if we come here via the menu (ie. 'sender' not nil)

        if (sender != nil) [self loginAlert:@"keep devices' status information updated"];
    }
}



- (void)deviceStatusCheck
{
    // If we're in the process of checking already when the timer fires, don't proceed any further

    if (deviceCheckCount != -1) return;

    if (devicesArray != nil && devicesArray.count > 0)
    {
        // We have a list of devices in place and there is at least one device in the list
        // so go through each device in the list and update its details individually

        // [self writeStringToLog:@"Auto-updating devices' status. This can be disabled in the Device menu." :YES];

        deviceCheckCount = 0;

        for (NSUInteger i = 0 ; i < devicesArray.count ; ++i)
        {
            // Re-acquire a single device's data

            NSMutableDictionary *device = [devicesArray objectAtIndex:i];
            NSDictionary *dict = @{ @"action" : @"refreshdevice",
                                    @"device" : device };

            [ide getDevice:[device objectForKey:@"id"] :dict];

            // Pick up the action at 'updateDevice:'
        }
    }
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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    // Is the device unassigned? If so, it can't be restarted

    NSString *did = [selectedDevice valueForKeyPath:@"relationships.devicegroup.id"];

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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"restart all the devices assigned to" :_window];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"restartdevices",
                            @"devicegroup" : currentDevicegroup };

    [ide restartDevices:currentDevicegroup.did :dict];

    // Pick up the action at 'restarted:'
}



- (IBAction)conditionalRestartDevices:(id)sender
{
    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"conditionally restart devices"];
        return;
    }

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"conditionally restart all the devices assigned to" :_window];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"conrestartdevices",
                            @"devicegroup" : currentDevicegroup };

    [ide conditionalRestartDevices:currentDevicegroup.did :dict];

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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSMutableDictionary *devicegroup = [self getValueFrom:selectedDevice withKey:@"devicegroup"];

    if (devicegroup == nil)
    {
        [self writeErrorToLog:[NSString stringWithFormat:@"Device \"%@\" is already unassigned.", [self getValueFrom:selectedDevice withKey:@"name"]]:YES];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"unassigndevice",
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

        [self writeErrorToLog:@"You have no devices listed. You may need to retrieve the list from the impCloud." :YES];
        return;
    }

    if (projectArray == nil || projectArray.count == 0)
    {
        // We have no projects open - so we can't assign a device to an open device group

        [self writeErrorToLog:@"You have no projects open. You will need to open or create a project and add a device group to assign a device." :YES];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self accountAlert:[NSString stringWithFormat:@"Project “%@” is not associated with the current account", currentProject.name]
                          :[NSString stringWithFormat:@"To assign devices to any of this project’s device groups, you need to log out of your current account and log into the account it is associated with (ID %@)", currentProject.aid]
                          :_window];
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
    BOOL firstDone = NO;

    for (Project *project in projectArray)
    {
        if (project.devicegroups.count > 0)
        {
            // Add all the device groups' names

            for (Devicegroup *dg in project.devicegroups)
            {
                if (![dg.type hasPrefix:@"prod"] && ![dg.type containsString:@"dut"])
                {
                    if (firstDone)
                    {
                        [assignDeviceMenuModels.menu addItem:NSMenuItem.separatorItem];
                        firstDone = NO;
                    }

                    [assignDeviceMenuModels addItemWithTitle:[NSString stringWithFormat:@"%@/%@", project.name, dg.name]];
                    item = [assignDeviceMenuModels.itemArray lastObject];
                    item.representedObject = dg;
                }
            }

            firstDone = YES;
        }
    }

    if (assignDeviceMenuModels.itemArray.count == 0)
    {
        // We have no device groups to assign

        [self writeErrorToLog:@"None of your open projects include any device groups. You will need to create a device group to assign a device." :YES];
        return;
    }

    if (currentDevicegroup != nil)
    {
        // Select the current device group on the list

        [assignDeviceMenuModels selectItemAtIndex:[assignDeviceMenuModels indexOfItemWithRepresentedObject:currentDevicegroup]];
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

        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] Device \"%@\" not assigned because the chosen device group, \"%@\" is not yet associated with a device group in the impCloud.", [self getValueFrom:device withKey:@"name"], dg.name] :YES];
        return;
    }

    // Assign the device to the device group

    NSDictionary *dict = @{ @"action" : @"assigndevice",
                            @"device" : device,
                            @"devicegroup" : dg };

    [ide assignDevice:device :dg.did :dict];

    // Pick up the action at 'reassigned:'
}



- (IBAction)renameDevice:(id)sender
{
    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"rename a device"];
        return;
    }

    if (devicesArray == nil || devicesArray.count == 0)
    {
        // We have no device to rename

        [self writeErrorToLog:@"You have no devices listed. You need to retrieve the list from the impCloud." :YES];
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

    NSDictionary *dict = @{ @"action" : @"renamedevice",
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
        alert.messageText = [NSString stringWithFormat:@"The device name “%@” is already in use. Having multiple devices with the same name may cause confusion. Are you sure you want to rename this device?", newName];
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
    // - The Device PopUp
    // - The 'Device' menu's 'Unassigned Devices' submenu
    // - The 'Device Groups' menu's 'Project's Device Groups' submenu

    NSMenuItem *item;
    BOOL isUnassigned = NO;
    BOOL isPopup = NO;

    if (sender == devicesPopUp)
    {
        // Device has been selected from the popup rather than the menu

        isPopup = YES;
        item = devicesPopUp.selectedItem;

        // Ignore the selection if it's 'None'

        if ([item.title compare:@"None"] == NSOrderedSame)
        {
            item.enabled = NO;
            return;
        }
    }
    else
    {
        // We may be here from either the 'Unassigned Devices' menu or a 'Project's Device Groups' submenu

        item = (NSMenuItem *)sender;
        isUnassigned = item.menu == unassignedDevicesMenu ? YES : NO;
    }

    // Set the currently selected device to the object the menu item is bound to

    selectedDevice = item.representedObject;

    if (!isPopup && !isUnassigned)
    {
        // Run through the Device Groups submenus to see if the selected device is not assigned to the
        // currently selected device group (because we'll now need to select that group)
        // NOTE But only if we DIDN'T select from the popup or an unassgined device,
        //      ie. these controls do NOT force a devicegroup switch

        for (NSMenuItem *menuitem in deviceGroupsMenu.itemArray)
        {
            if (menuitem.submenu != nil)
            {
                // The referenced device group has a submenu, ie. it has some assigned devices

                for (NSMenuItem *subMenuItem in menuitem.submenu.itemArray)
                {
                    subMenuItem.state = NSOffState;

                    if (subMenuItem.representedObject == selectedDevice)
                    {
                        if (menuitem.representedObject != currentDevicegroup)
                        {
                            // We are selecting a new device group by selecting an assigned device
                            // NOTE This doesn't force a project change because we are only selecting from
                            //      among one project's device groups and devices

                            deviceSelectFlag = YES;

                            [self chooseDevicegroup:menuitem];
                        }
                    }
                }
            }
        }
    }

    // Update the UI: First, the device menus tick marks:

    if (!isPopup) [self setDevicesPopupTick];
    if (!isUnassigned) [self setUnassignedDevicesMenuTick];
    if (isPopup || isUnassigned) [self setDevicesMenusTicks];

    // Update the menus and toolbar

    [self refreshDeviceGroupsSubmenu];
    [self refreshDeviceMenu];
    [self setToolbar];

    iwvc.device = selectedDevice;
}



- (IBAction)deleteDevice:(id)sender
{
    if (selectedDevice == nil)
    {
        return;
    }

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = [NSString stringWithFormat:@"You are about to remove device “%@” from your account. Are you sure?", [self getValueFrom:selectedDevice withKey:@"name"]];
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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSDictionary *dict;

    if (sender == getLogsMenuItem)
    {
        dict = @{ @"action" : @"getlogs" ,
                  @"device" : selectedDevice };

        [ide getDeviceLogs:[self getValueFrom:selectedDevice withKey:@"id"] :dict];

        // Pick up the action at 'listLogs:'
    }
    else
    {
        dict = @{ @"action" : @"gethistory" ,
                  @"device" : selectedDevice };

        [ide getDeviceHistory:[self getValueFrom:selectedDevice withKey:@"id"] :dict];

        // Pick up the action at 'listLogs:'
    }
}



- (IBAction)streamLogs:(id)sender
{
    // Called by the UI in response to user control, to begin streaming logs from the current device

    // Is there a currently selected device? If not, bail

    if (selectedDevice == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }
    
    // We have a selected device

    NSString *devid = [self getValueFrom:selectedDevice withKey:@"id"];
    NSString *devname = [self getValueFrom:selectedDevice withKey:@"name"];

    // Is the selected device already being streamed?

    if (![ide isDeviceLogging:devid])
    {
        // No, the device is not in the log stream, so add it

        if (ide.numberOfLogStreams == kMaxLogStreamDevices)
        {
            // We have reached the maximum number of logs per stream, so warn the user
            // TODO Support multiple streams as one

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"You are already logging %@ devices", kMaxLogStreamDevicesText];
            alert.informativeText = [NSString stringWithFormat:@"The impCentral API only supports logging for up to %@ devices simultaneously. To stream logs from another device, you will need to stop logging from one of the current streaming devices.", kMaxLogStreamDevicesText];
            [alert addButtonWithTitle:@"OK"];
            [alert beginSheetModalForWindow:_window
                          completionHandler:nil];

            return;
        }

        // Set the Toolbar Item's state

        streamLogsItem.state = 1;

        // Start logging

        [ide startLogging:devid :@{ @"device" : selectedDevice }];

        // Set the spacing for the log output so that log messages align after the device name

        if (devname.length > logPaddingLength) logPaddingLength = devname.length;
    }
    else
    {
        // Yes, the device is in the log stream, so remove it

        [ide stopLogging:devid];

        // FROM 2.3.130
        // Handle the UI update in the async pick-up: 'loggingStopped:' in 'AppDelegateAPIHandlers.m'

        /*

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

        // Set the Toolbar Item's state

        streamLogsItem.state = 1;
        */
    }

    // Update the UI elements showing device names

    //[squinterToolbar validateVisibleItems];
    //[self refreshDeviceMenu];
    //[self refreshDevicesPopup];
    //[self refreshDeviceGroupsSubmenu];
}



// ADDED IN 2.2.127
- (IBAction)findDevice:(id)sender
{
    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"find a device using its ID"];
        return;
    }

    if (devicesArray == nil || devicesArray.count == 0)
    {
        // We have no device(s) to assign

        [self writeErrorToLog:@"You have no devices listed. You may need to retrieve the list from the impCloud." :YES];
        return;
    }

    dlvc.deviceArray = devicesArray;

    [dlvc prepSheet];
    [_window beginSheet:findDeviceSheet completionHandler:nil];
}



// ADDED IN 2.2.127
- (IBAction)cancelFindDeviceSheet:(id)sender
{
    [_window endSheet:findDeviceSheet];
}



// ADDED IN 2.2.127
- (IBAction)useFindDeviceSheet:(id)sender
{
    [_window endSheet:findDeviceSheet];

    if (dlvc.selectedDeviceID.length != 0)
    {
        for (NSMenuItem *item in devicesPopUp.itemArray)
        {
            NSDictionary *device = item.representedObject;
            NSString *did = [device objectForKey:@"id"];

            if ([did compare:dlvc.selectedDeviceID] == NSOrderedSame)
            {
                if (item != devicesPopUp.selectedItem)
                {
                    [devicesPopUp selectItem:item];
                    [self chooseDevice:devicesPopUp];
                }

                break;
            }
        }
    }
}



#pragma mark - Log and Logging Methods


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



- (IBAction)showProjectInfo:(id)sender
{
    // Output details of the current project, if there is one, to the log

    // If there is no currently selected project, bail

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
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

    if (currentProject.aid != nil && currentProject.aid.length > 0)
    {
        if (currentProject.cid != nil && currentProject.cid.length > 0)
        {
            if ([currentProject.cid compare:currentProject.aid] != NSOrderedSame)
            {
                [lines addObject:[NSString stringWithFormat:@"Project was created by account %@", currentProject.cid]];

                if (ide.isLoggedIn && [ide.currentAccount compare:currentProject.aid] == NSOrderedSame)
                {
                    [lines addObject:@"Project is accessible via the account you are currently logged in to."];
                }
                else
                {
                    [lines addObject:[NSString stringWithFormat:@"Project is not accessible via the account you are currently logged (requires account ID %@).", currentProject.aid]];
                }
            }
            else
            {
                [lines addObject:@"Project was created by you"];
            }
        }
    }
    else
    {
        [lines addObject:@"Project is not associated with an account"];
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

    [self writeLinesToLog:lines];
}



- (IBAction)showDeviceGroupInfo:(id)sender
{
    // Output details of the current device group, if there is one, to the log

    // If there is no current project, or no current device group, warn then bail

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    // Gather the deviece group data and display it

    [self compileDevicegroupInfo:currentDevicegroup :0 :nil];
}



- (IBAction)showDeviceInfo:(id)sender
{
    // Runs through the current device's record in 'deviceArray' and displays
    // key information in the main window log view

    if (selectedDevice == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSMutableArray *lines = [[NSMutableArray alloc] init];

    [lines addObject:@"Device Information"];

    NSString *item = [selectedDevice valueForKeyPath:@"attributes.name"];
    if ((NSNull *)item == [NSNull null]) item = [selectedDevice objectForKey:@"id"];
    [lines addObject:[NSString stringWithFormat:@"     Name: %@", item]];

    [lines addObject:[NSString stringWithFormat:@"       ID: %@", [selectedDevice objectForKey:@"id"]]];

    item = [selectedDevice valueForKeyPath:@"attributes.imp_type"];
    if ((NSNull *)item == [NSNull null]) item = @"Unknown";
    [lines addObject:[NSString stringWithFormat:@"     Type: %@", item]];

    NSString *version = [selectedDevice valueForKeyPath:@"attributes.swversion"];
    if ((NSNull *)version == [NSNull null]) version = nil;
    if (version != nil)
    {
        NSArray *parts = [version componentsSeparatedByString:@" - "];
        parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"-"];
        [lines addObject:[NSString stringWithFormat:@"    impOS: %@", [parts objectAtIndex:1]]];
    }

    NSNumber *number = [selectedDevice valueForKeyPath:@"attributes.free_memory"];
    if ((NSNull *)number == [NSNull null]) number = nil;
    if (number != nil) [lines addObject:[NSString stringWithFormat:@" Free RAM: %@KB", number]];

    [lines addObject:@"\nNetwork Information"];
    NSString *mac = [selectedDevice valueForKeyPath:@"attributes.mac_address"];
    if ((NSNull *)mac == [NSNull null]) mac = nil;
    if (mac != nil) mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    [lines addObject:[NSString stringWithFormat:@"      MAC: %@", (mac != nil ? mac : @"Unknown")]];

    NSNumber *boolean = [selectedDevice valueForKeyPath:@"attributes.device_online"];
    if ((NSNull *)boolean == [NSNull null]) boolean = [NSNumber numberWithBool:NO];
    NSString *string = boolean.boolValue ? @"Online" : @"Offline";

    if ([string compare:@"Online"] == NSOrderedSame)
    {
        NSNumber *ip = [selectedDevice valueForKeyPath:@"attributes.ip_address"];
        if ((NSNull *)ip == [NSNull null]) ip = nil;
        NSString *sip = ip != nil ? [NSString stringWithFormat:@"%@", ip] : @"Unknown";
        [lines addObject:[NSString stringWithFormat:@"       IP: %@", sip]];
    }
    else
    {
        [lines addObject:@"       IP: Unknown"];
    }

    [lines addObject:[NSString stringWithFormat:@"    State: %@", string]];

    [lines addObject:@"\nAgent Information"];

    boolean = [selectedDevice valueForKeyPath:@"attributes.agent_running"];
    if ((NSNull *)boolean == [NSNull null]) boolean = [NSNumber numberWithBool:NO];
    string = boolean.boolValue ? @"Online" : @"Offline";
    [lines addObject:[NSString stringWithFormat:@"    State: %@", string]];

    if (boolean.boolValue)
    {
        string = [selectedDevice valueForKeyPath:@"attributes.agent_id"];
        if ((NSNull *)string == [NSNull null]) string = nil;
        [lines addObject:(string != nil ? [NSString stringWithFormat:@"      URL: https://agent.electricimp.com/%@", string] : @"Unknown")];
    }

    [lines addObject:@"\nBlinkUp Information"];
    NSString *date = [selectedDevice valueForKeyPath:@"attributes.last_enrolled_at"];
    if ((NSNull *)date == [NSNull null]) date = nil;
    [lines addObject:[NSString stringWithFormat:@" Enrolled: %@", (date != nil ? date : @"Unknown")]];

    NSString *plan = [selectedDevice valueForKeyPath:@"attributes.plan_id"];
    if ((NSNull *)plan == [NSNull null]) plan = nil;
    if (plan != nil) [lines addObject:[NSString stringWithFormat:@"  Plan ID: %@", plan]];

    [lines addObject:@"\nDevice Group Information"];
    NSString *dgid = [selectedDevice valueForKeyPath:@"relationships.devicegroup.id"];
    if ((NSNull *)dgid == [NSNull null]) dgid = nil;

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
            [lines addObject:[NSString stringWithFormat:@"  Project: %@", apr.name]];
            [lines addObject:[NSString stringWithFormat:@"    Group: %@", adg.name]];
            [lines addObject:[NSString stringWithFormat:@"       ID: %@", dgid]];
        }
        else
        {
            [lines addObject:[NSString stringWithFormat:@"       ID: %@", dgid]];
        }
    }
    else
    {
        [lines addObject:@"   Group: Device is not assigned to a device group"];
    }

    // Add the assembled lines to the log and re-check for URLs

    [self writeLinesToLog:lines];
    [self parseLog];
}



- (IBAction)logDeviceCode:(id)sender
{
    // Dumps compiled device source code to the log

    [self logModelCode:@"device"];
}



- (IBAction)logAgentCode:(id)sender
{
    // Dumps compiled agent source code to the log

    [self logModelCode:@"agent"];
}



- (IBAction)clearLog:(id)sender
{
    // Clear the log of all text

    NSTextStorage *textStorage = logTextView.textStorage;
    NSArray *values = [NSArray arrayWithObjects:textColour, logFont, nil];
    NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSAttributedString *emptyString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];

    [textStorage beginEditing];
    [textStorage setAttributedString:emptyString];
    [textStorage endEditing];
}



- (void)printDone:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo
{
    // Show a post-print message
    
    if (success) [self writeStringToLog:@"Log contents sent to print system." :YES];
}



- (void)compileDevicegroupInfo:(Devicegroup *)devicegroup :(NSUInteger)inset :(NSMutableArray *)otherLines
{
    // Gathers and displays info for the specified device group
    // It's separate from 'showDeviceGroupInfo:' because it needs to be called by 'showProjectInfo:' too
    
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    
    // Prepare the indent: should be 0 or 2 spaces
    
    NSString *spaces = @"";
    NSString *liner = @"";
    
    if (inset > 0)
    {
        for (NSUInteger i = 0 ; i < inset ; ++i) spaces = [spaces stringByAppendingString:@" "];
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
    
    if (devicegroup.mdid != nil || devicegroup.mdid.length > 0)
    {
        [lines addObject:[NSString stringWithFormat:@"%@Minimum supported deployment set (ID: %@)", spaces, devicegroup.mdid]];
    }
    
    [lines addObject:[NSString stringWithFormat:@"%@Device group type: %@", spaces, [self convertDevicegroupType:devicegroup.type :NO]]];
    
    if (devicegroup.data != nil && [devicegroup.type containsString:@"fixture"])
    {
        NSString *prefix = [devicegroup.type hasPrefix:@"pre"] ? @"Test " : @"";
        NSDictionary *aTarget = [self getValueFrom:devicegroup.data withKey:@"production_target"];
        
        if (aTarget != nil)
        {
            NSString *tid = [aTarget objectForKey:@"id"];
            
            for (Devicegroup *dg in currentProject.devicegroups)
            {
                if ([dg.did compare:tid] == NSOrderedSame)
                {
                    [lines addObject:[NSString stringWithFormat:@"%@Target %@Production device group: %@", spaces, prefix, dg.name]];
                    break;
                }
            }
        }
        
        aTarget = [self getValueFrom:devicegroup.data withKey:@"dut_target"];
        
        if (aTarget != nil)
        {
            NSString *tid = [aTarget objectForKey:@"id"];
            
            for (Devicegroup *dg in currentProject.devicegroups)
            {
                if ([dg.did compare:tid] == NSOrderedSame)
                {
                    [lines addObject:[NSString stringWithFormat:@"%@Target %@DUT device group: %@", spaces, prefix, dg.name]];
                    break;
                }
            }
        }
    }
    
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
        [self writeLinesToLog:lines];
    }
    else
    {
        [otherLines addObjectsFromArray:lines];
    }
}



- (void)compileModelInfo:(Model *)model :(NSUInteger)inset :(NSMutableArray *)otherLines
{
    // Gathers and displays info for the specified model
    
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
        [self writeLinesToLog:lines];
    }
    else
    {
        [otherLines addObjectsFromArray:lines];
    }
}



- (void)writeLinesToLog:(NSMutableArray *)lines
{
    // Write each of lines of test in the list passed into 'lines' to the log

    for (NSString *string in lines) [self writeNoteToLog:string :textColour :NO];
}



- (void)writeStringToLog:(NSString *)string :(BOOL)addTimestamp
{
    // Write 'string' to the main window log view as a normal line (ie. of colour 'textColour')

    [self writeNoteToLog:[self recodeLogTags:string] :textColour :addTimestamp];
}



- (void)writeErrorToLog:(NSString *)string :(BOOL)addTimestamp
{
    // Write 'string' to the main window log view as an error (ie. in red)

    [self writeNoteToLog:[@"[ERROR] " stringByAppendingString:string] :[NSColor redColor] :addTimestamp];
}



- (void)writeWarningToLog:(NSString *)string :(BOOL)addTimestamp
{
    // Write 'string' to the main window log view as a warning (ie. in amber)

    [self writeNoteToLog:string :[NSColor orangeColor] :addTimestamp];
}



- (void)writeNoteToLog:(NSString *)string :(NSColor *)colour :(BOOL)addTimestamp
{
    // Build an NSAttributedString from 'string' and coloured 'colour'

    NSArray *values = [NSArray arrayWithObjects:colour, logFont, nil];
    NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:string attributes:attributes];

    // Make sure the actual writing is done on the main thread

    dispatch_async(dispatch_get_main_queue(), ^{
        [self writeStyledStringToLog:attrString :addTimestamp];
    });
}



- (void)writeStyledStringToLog:(NSAttributedString *)string :(BOOL)addTimestamp
{
    // This method writes the specified NSAttributedString, 'string' to the log adding a timestamp if required

    // Only display non-zero length strings

    if (string.length > 0)
    {
        NSDictionary *attributes = [string attributesAtIndex:0 effectiveRange:nil];
		NSTextStorage *textStorage = logTextView.textStorage;

        if (addTimestamp)
		{
            NSString *date = [def stringFromDate:[NSDate date]];
            date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
            date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
            date = [date stringByAppendingString:@" "];

            [textStorage beginEditing];
            [textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:date attributes:attributes]];
        }
		else
		{
			[textStorage beginEditing];
		}

        [textStorage appendAttributedString:string];
        [textStorage appendAttributedString:[[NSAttributedString alloc] initWithString:@"\n" attributes:attributes]];
        [textStorage endEditing];

		// Scroll to the end of the window

        [logTextView scrollToEndOfDocument:nil];
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

    numberLength = [NSString stringWithFormat:@"%li", lineTotal].length;

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
    // Write the string assembled in 'listCode:' to the main window log view
    // Use 'writeNoteToLog:' to avoid the message status parsing that 'writeStringToLog:' does

    [self writeNoteToLog:listString :textColour :NO];
    [self writeNoteToLog:@" " :textColour :NO];
}



- (void)logModelCode:(NSString *)codeType
{
    // Processes the display of the specified type of source code from the current device group, if there is one
    
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }
    
    if (currentDevicegroup.models.count == 0)
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no %@ code.", currentDevicegroup.name, codeType] :YES];
        return;
    }
    
    BOOL done = NO;
    
    for (Model *model in currentDevicegroup.models)
    {
        if ([model.type compare:codeType] == NSOrderedSame)
        {
            NSUInteger squintedTest = [codeType hasPrefix:@"a"] ? kAgentCodeSquinted : kDeviceCodeSquinted;
            
            if ((currentDevicegroup.squinted & squintedTest) == 0) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" has not been compiled using the latest %@ code.", currentDevicegroup.name, codeType] :YES];
            
            done = YES;
            NSString *firstChar = [[codeType substringToIndex:1] capitalizedString];
            codeType = [codeType stringByReplacingCharactersInRange:NSMakeRange(0,1) withString:firstChar];
            [self writeStringToLog:[NSString stringWithFormat:@"%@ Code:", codeType] :NO];
            [extraOpQueue addOperationWithBlock:^{[self listCode:model.code :-1 :-1 :-1 :-1];}];
            break;
        }
    }
    
    if (!done) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no %@ code.", currentDevicegroup.name, codeType] :YES];
}



- (void)logLogs:(NSString *)logLine
{
    // Write a line of a list of log entries to the main window's log view
    
    [self writeStringToLog:logLine :NO];
}



#pragma mark - Squint Methods


- (IBAction)squint:(id)sender
{
    // This method is a hangover from a previous version.
    // Now it simply calls the version which replaces it.
    // NOTE 'compile:' is in AppDelegateSquinting.m

    // FROM 2.3.128
    // Make sure we have a path for the current project. If not, ask the user to save the project first
    if (currentProject.path == nil || currentProject.path.length == 0)
    {
        [self unsavedAlert:currentProject.name :@"compiling device groups’ source code" :_window];
        return;
    }

    [self compile:currentDevicegroup :NO];
}



#pragma mark - External Editor Methods


- (IBAction)externalOpen:(id)sender
{
    // Open the original source code files an external editor - whatever the user has set to opne text files (or .nut files)
    // Called by selecting: 'Both' from the 'Device Group' menu's 'View Device Group Source' submenu
    //                      'Agent Code' from the 'Device Group' menu's 'View Device Group Source' submenu
    //                      'Device Code' from the 'Device Group' menu's 'View Device Group Source' submenu
    //                      'View Device Group Source in Editor' from the 'Device Group' menu
    //                      The Edit Agent Code toolbar item
    //                      The Edit Device Code toolbar item
    // Or from 'externalOpenAll:'
    
    // Only continue if a device group is selected

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    // Open the device code, if requested

    if (sender == externalOpenDeviceItem || sender == externalOpenBothItem || sender == externalOpenMenuItem || sender == openDeviceCode)
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

    // Open the agent code, if requested

    if (sender == externalOpenAgentItem || sender == externalOpenBothItem || sender == externalOpenMenuItem || sender == openAgentCode)
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



- (IBAction)externalLibOpen:(id)sender
{
    // Open class libraries in an external editor

    if (sender == externalOpenLibsItem)
    {
        [self externalOpenItems:YES];
    }
    else
    {
        [self externalOpenItem:sender :YES];
    }
}



- (IBAction)externalFileOpen:(id)sender
{
    // Open included files in an external editor

    if (sender == externalOpenFileItem)
    {
        [self externalOpenItems:NO];
    }
    else
    {
        [self externalOpenItem:sender :NO];
    }
}



- (IBAction)externalOpenAll:(id)sender
{
    // Open all of the source code files associated with the current device group:
    // agent and device code, and all of their included libraries and files
    // Called by clicking on the 'Edit' toolbar item

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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
    // Open the selected device's agent URL in the default web browser

    if (selectedDevice == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSString *urlstring = [NSString stringWithFormat:@"https://agent.electricimp.com/%@", [self getValueFrom:selectedDevice withKey:@"agent_id"]];

    [nswsw openURL:[NSURL URLWithString:urlstring]];
}



- (IBAction)showProjectInFinder:(id)sender
{
    // Switch to finder and present the project file's enclosing folder

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    [nswsw selectFile:[NSString stringWithFormat:@"%@/%@", currentProject.path, currentProject.filename] inFileViewerRootedAtPath:currentProject.path];
}



- (IBAction)showModelFilesInFinder:(id)sender
{
    // Switch to finder and present the current device groups source files' enclosing folder(s)
    // NOTE They may be in different folders, so we check and open both if necessary

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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



- (void)externalOpenItem:(id)sender :(BOOL)isLibrary
{
    // Opens a single file or libaray from the current Device Group
    // Called by 'externalFileOpen:' or 'externalLibOpen:'
    // 'isLibrary' should be: YES for a library, or
    //                        NO for a regular file
    
    NSMenuItem *item = (NSMenuItem *)sender;
    File *file = item.representedObject;
    
    if (file.hasMoved)
    {
        [self writeErrorToLog:[NSString stringWithFormat:@"%@ \"%@\" can't be found it is known location.", (isLibrary ? @"Library" : @"File"), file.filename] :YES];
    }
    else
    {
        NSString *path = [self getAbsolutePath:currentProject.path :file.path];
        path = [path stringByAppendingFormat:@"/%@", file.filename];
        [nswsw openFile:path];
    }
}



- (void)externalOpenItems:(BOOL)areLibraries
{
    // Opens all of the current Device Group's files or libraries
    // Called by 'externalFileOpen:' or 'externalLibOpen:'
    // 'areLibraries' is: YES for libraries ('externalLibOpen:'), or
    //                    NO for files ('externalFileOpen:')
    
    for (Model *model in currentDevicegroup.models)
    {
        if (model.files.count > 0)
        {
            NSMutableArray *list = areLibraries ? model.libraries : model.files;
            
            for (File *file in list)
            {
                if (file.hasMoved)
                {
                    [self writeErrorToLog:[NSString stringWithFormat:@"%@ \"%@\" can't be found it is known location.", (areLibraries ? @"Library" : @"File"), model.filename] :YES];
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



- (void)switchToEditor:(Model *)model
{
    // Open the supplied model's source code in the user's preferred text editor
    
    if (model.hasMoved)
    {
        // We've previously recorded that the model file or its parent project file have moved, so warn the user and bail
        
        [self writeErrorToLog:[NSString stringWithFormat:@"Source file \"%@\" can't be found it is known location.", model.filename] :YES];
        return;
    }
    
    NSString *path = [NSString stringWithFormat:@"%@/%@", model.path, model.filename];
    path = [self getAbsolutePath:currentProject.path :path];
    [nswsw openFile:path];
}



#pragma mark - Web Access Methods


- (IBAction)showReleaseNotesPage:(id)sender
{
    // Open the Squinter Release Notes page from 'Help > Show Squinter Release Notes'

    [self launchWebSite:@"https://smittytone.github.io/squinter/releases.html"];
}



- (IBAction)showAuthor:(id)sender
{
    // Open the relevant third-party source code web page from 'Help > Acknowledgements'
    
    if (sender == author01) [self launchWebSite:@"https://github.com/carlbrown/PDKeychainBindingsController"];
    if (sender == author02) [self launchWebSite:@"https://github.com/bdkjones/VDKQueue"];
    if (sender == author03) [self launchWebSite:@"https://github.com/uliwitness/UliKit"];
    if (sender == author04) [self launchWebSite:@"https://developer.electricimp.com/"];
    if (sender == author05) [self launchWebSite:@"https://github.com/adobe-fonts/source-code-pro"];
    if (sender == author06) [self launchWebSite:@"https://github.com/sparkle-project/Sparkle/blob/master/LICENSE"];
}



- (IBAction)showOfflineHelp:(id)sender
{
    // Open the Squinter web page from 'Help > Show Squinter Help'
    // NOTE Jumps to the 'How to Use Squinter' section
    
    if (!hwvc.isOnScreen)
    {
        // Size the window to fit neatly alongside the main Squinter window, either immediately
        // to its right, or overlapping if the gap between the Squinter window and the edge of
        // the screen is too narrow
        
        NSRect rect = _window.frame;
        NSInteger w = [[NSScreen mainScreen] frame].size.width - rect.size.width;
        rect.origin.x = (w < 800) ? ([[NSScreen mainScreen] frame].size.width - 800) : (rect.size.width + rect.origin.x);
        rect.size.width = 800;
        rect.size.height = [[NSScreen mainScreen] frame].size.height;
        
        // Save the new frame specification...
        
        hwvc.initialFrame = rect;
        
        // ...and apply it
        
        [hwvc.view.window setFrame:rect display:NO];
        
        // Call 'prepSheet' to load the contents; this will trigger the window's
        // appearance when the content has loaded
        
        [hwvc prepSheet];
    }
    else
    {
        // Call this in case the window is hidden
        
        [hwvc.view.window makeKeyAndOrderFront:self];
    }
}



- (IBAction)showWebHelp:(id)sender
{
    // Open the Squinter web page from 'Help > Show Squinter Help'
    // NOTE Jumps to the 'How to Use Squinter' section
    
    [self launchOwnSite:@"#account"];
}



- (IBAction)showPrefsHelp:(id)sender
{
    // Open the Squinter web page from either of the 'Preferences' sheet's tabs
    // NOTE Jumps to the 'Configuring Squinter' section
    
    [self launchOwnSite:@"#configuring-squinter"];
}



- (void)showEILibsPage
{
    // Open the Electric Imp libraries page on the Dev Center in the default Web browser
    
    [self launchWebSite:@"https://developer.electricimp.com/codelibraries/"];
}



- (void)launchOwnSite:(NSString *)anchor
{
    // Open the Squinter web site and jump to the specified anchor
    // NOTE Pass in an empty string to just view the page
    
    [self launchWebSite:[@"https://smittytone.github.io/squinter/index.html" stringByAppendingString:anchor]];
}



- (void)launchWebSite:(NSString *)url
{
    // Open the specified URL in the machine's defauls web browser
    
    [nswsw openURL:[NSURL URLWithString:url]];
}



#pragma mark - About Sheet Methods


- (IBAction)showAboutSheet:(id)sender
{
    // Set the current version string and show the 'About' sheet
    
    [aboutVersionLabel setStringValue:[NSString stringWithFormat:@"Version %@.%@ (%@)",
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                                        [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SQBuildVersion"]]];
    [_window beginSheet:aboutSheet completionHandler:nil];
}



- (IBAction)viewSquinterSite:(id)sender
{
    // The user has clicked on the 'About' sheet's Squinter icon, so open the web site
    
    [_window endSheet:aboutSheet];
    [self launchOwnSite:@"#about"];
}



- (IBAction)closeAboutSheet:(id)sender
{
    // The user has clicked on the 'About' sheet's 'OK" button, so just close the sheet
    
    [_window endSheet:aboutSheet];
}



#pragma mark - Preferences Sheet Methods


- (IBAction)showPrefs:(id)sender
{
    // The user has invoked the Preferences panel, so populate the panel's settings with the current saved defaults

    // Set working directory

    workingDirectoryField.stringValue = @"";
    workingDirectoryField.stringValue = workingDirectory;

    // Set the panel's text colour well

    float r = [[defaults objectForKey:@"com.bps.squinter.text.red"] floatValue];
    float b = [[defaults objectForKey:@"com.bps.squinter.text.blue"] floatValue];
    float g = [[defaults objectForKey:@"com.bps.squinter.text.green"] floatValue];
    textColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
    textColorWell.color = textColour;
    [textColorWell setAction:@selector(showPanelForText)];

    // Set the panel's background colour well

    r = [[defaults objectForKey:@"com.bps.squinter.back.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.back.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.back.green"] floatValue];
    backColour = [NSColor colorWithRed:r green:g blue:b alpha:1.0];
    backColorWell.color = backColour;
    [backColorWell setAction:@selector(showPanelForBack)];

    // Set the panel's various device log colour wells
    // NOTE currently there are 8 wells, but there were 5, so we have migrated
    //      from fixed defaults to an array containing RGB arrays for each colour

    NSArray *savedColours = [defaults objectForKey:@"com.bps.squinter.devicecolours"];

    if (savedColours.count != 0)
    {
        NSUInteger colourIndex = 0;

        for (NSColorWell *colourWell in deviceColourWells)
        {
            // Only load in saved colours if we have any (at first launch we won't).
            // Otherwise the colour wells will take the default colours

            NSArray *colour = [savedColours objectAtIndex:colourIndex];

            r = [[colour objectAtIndex:0] floatValue];
            g = [[colour objectAtIndex:1] floatValue];
            b = [[colour objectAtIndex:2] floatValue];

            colourWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];

            // Walk the saved colours array separately, just in case there are
            // suddenly more wells than colours (in which case, cycle through
            // the colours)

            ++colourIndex;
            if (colourIndex > savedColours.count) colourIndex = 0;
        }
    }

    // Set font name and size menus

    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.fontSizeIndex"] integerValue] - 9;
    if (index == 9) index = 6;
    [sizeMenu selectItemAtIndex:index];

    index = [[defaults objectForKey:@"com.bps.squinter.fontNameIndex"] integerValue];
    [fontsMenu selectItemAtIndex:index];
    boldTestCheckbox.enabled = index < 3 ? YES : NO;

    // Set checkboxes

    preserveCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.preservews"]) ? NSOnState : NSOffState;
    autoCompileCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autocompile"]) ? NSOnState : NSOffState;
    loadModelsCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autoload"]) ? NSOnState : NSOffState;
    autoLoadListsCheckbox.state =  ([defaults boolForKey:@"com.bps.squinter.autoloadlists"]) ? NSOnState : NSOffState;
    autoUpdateCheckCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autocheckupdates"]) ? NSOnState : NSOffState;
    boldTestCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.showboldtext"]) ? NSOnState : NSOffState;
    loadDevicesCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autoloaddevlists"]) ? NSOnState : NSOffState;
    updateDevicesCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.updatedevs"]) ? NSOnState : NSOffState;
    showDeviceWarnigCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.autoselectdevice"]) ? NSOnState : NSOffState;
    //showInspectorCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.show.inspector"]) ? NSOnState : NSOffState;
    
    // Set file location display mode menu

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
    // The user clicks the Preferences panel's Save button, so apply all the changes
    // and write values out to the defaults

    workingDirectory = workingDirectoryField.stringValue;
    BOOL textChange = NO;

    [defaults setBool:(autoLoadListsCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autoloadlists"];
    [defaults setBool:(preserveCheckbox.state == NSOnState) forKey:@"com.bps.squinter.preservews"];
    [defaults setBool:(autoCompileCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autocompile"];
    [defaults setBool:(loadDevicesCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autoloaddevlists"];
    [defaults setBool:(autoUpdateCheckCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autocheckupdates"];
    [defaults setBool:(loadModelsCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autoload"];
    //[defaults setBool:(showInspectorCheckbox.state == NSOnState) forKey:@"com.bps.squinter.show.inspector"];

    float r = (float)textColour.redComponent;
    float b = (float)textColour.blueComponent;
    float g = (float)textColour.greenComponent;

    textColour = textColorWell.color;

    float r2 = (float)textColour.redComponent;
    float b2 = (float)textColour.blueComponent;
    float g2 = (float)textColour.greenComponent;

    if (r != r2 || b != b2 || g != g2)
    {
        textChange = YES;

        [defaults setObject:[NSNumber numberWithFloat:r2] forKey:@"com.bps.squinter.text.red"];
        [defaults setObject:[NSNumber numberWithFloat:g2] forKey:@"com.bps.squinter.text.green"];
        [defaults setObject:[NSNumber numberWithFloat:b2] forKey:@"com.bps.squinter.text.blue"];
    }

    r = (float)backColour.redComponent;
    b = (float)backColour.blueComponent;
    g = (float)backColour.greenComponent;

    backColour = backColorWell.color;

    r2 = (float)backColour.redComponent;
    b2 = (float)backColour.blueComponent;
    g2 = (float)backColour.greenComponent;

    if (r != r2 || b != b2 || g != g2)
    {
        textChange = YES;

        [defaults setObject:[NSNumber numberWithFloat:r2] forKey:@"com.bps.squinter.back.red"];
        [defaults setObject:[NSNumber numberWithFloat:g2] forKey:@"com.bps.squinter.back.green"];
        [defaults setObject:[NSNumber numberWithFloat:b2] forKey:@"com.bps.squinter.back.blue"];
    }

    if (r == 0) r = 0.1;
    if (b == 0) b = 0.1;
    if (g == 0) g = 0.1;

    NSUInteger a = 100 * r * b * g;

    [logScrollView setScrollerKnobStyle:(a < 30 ? NSScrollerKnobStyleLight : NSScrollerKnobStyleDark)];

    // Populate the colour wells on the Logs tab

    NSMutableArray *savedColours = [[NSMutableArray alloc] init];

    for (NSColorWell *colourWell in deviceColourWells)
    {
        // Get the current colour well's colours...

        r = (float)colourWell.color.redComponent;
        g = (float)colourWell.color.greenComponent;
        b = (float)colourWell.color.blueComponent;

        // ...and convert to an array of NSNumbers for saving to defaults...

        NSArray *colour = @[ [NSNumber numberWithFloat:r], [NSNumber numberWithFloat:g], [NSNumber numberWithFloat:b] ];

        // ...and add the colour to the new default array

        [savedColours addObject:colour];
    }

    // Write out the array of saved colours as a default

    [defaults setObject:[NSArray arrayWithArray:savedColours] forKey:@"com.bps.squinter.devicecolours"];
    [self setColours];

    NSString *fontName = [self getFontName:fontsMenu.indexOfSelectedItem];
    NSNumber *num = [defaults objectForKey:@"com.bps.squinter.fontNameIndex"];
    if (fontsMenu.indexOfSelectedItem != num.integerValue) textChange = YES;

    NSInteger fontSize = kInitialFontSize + sizeMenu.indexOfSelectedItem;
    if (fontSize == 15) fontSize = 18;
    num = [defaults objectForKey:@"com.bps.squinter.fontSizeIndex"];
    if (fontSize != num.integerValue) textChange = YES;

    BOOL isBold = [defaults boolForKey:@"com.bps.squinter.showboldtext"];
    BOOL shouldBeBold = boldTestCheckbox.state == NSOnState ? YES : NO;

    if (isBold != shouldBeBold) textChange = YES;

    if (textChange)
    {
        logFont = [self setLogViewFont:fontName :fontSize :shouldBeBold];
        logTextView.font = logFont;
        [logTextView setTextColor:textColour];
        [logClipView setBackgroundColor:backColour];
    }

    [defaults setObject:[NSNumber numberWithInteger:fontsMenu.indexOfSelectedItem] forKey:@"com.bps.squinter.fontNameIndex"];
    [defaults setObject:[NSNumber numberWithInteger:fontSize] forKey:@"com.bps.squinter.fontSizeIndex"];
    [defaults setObject:[NSNumber numberWithInteger:locationMenu.indexOfSelectedItem] forKey:@"com.bps.squinter.displaypath"];
    [defaults setBool:(boldTestCheckbox.state == NSOnState) forKey:@"com.bps.squinter.showboldtext"];
    [defaults setBool:(showDeviceWarnigCheckbox.state == NSOnState) forKey:@"com.bps.squinter.autoselectdevice"];

    // FROM 2.3.128

    iwvc.pathType = locationMenu.indexOfSelectedItem;
    if (currentProject != nil) iwvc.project = currentProject;

    // Set recent files count

    NSInteger count = (recentFilesCountMenu.indexOfSelectedItem + 1) * 5;

    [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"com.bps.squinter.recentFilesCount"];
    
    // If the max is now lower than the current list total, we should prune the list
    
    if (recentFiles.count > count)
    {
        while (recentFiles.count > count) [recentFiles removeLastObject];
        [self refreshRecentFilesMenu];
    }
    
    // Set max list items count

    count = maxLogCountMenu.selectedTag;
    ide.maxListCount = count;

    [defaults setObject:[NSNumber numberWithInteger:count] forKey:@"com.bps.squinter.logListCount"];

    // Start or stop auto-updating the device list
    if ([defaults boolForKey:@"com.bps.squinter.updatedevs"] != updateDevicesCheckbox.state == NSOnState)
    {
        [defaults setBool:(updateDevicesCheckbox.state == NSOnState) forKey:@"com.bps.squinter.updatedevs"];
        [self keepDevicesStatusUpdated:nil];
    }

    // Close the sheet

    [_window endSheet:preferencesSheet];
}



- (IBAction)selectFontName:(id)sender
{
    // Disable the 'show bold' checkbox for fonts not available in bold
    
    NSPopUpButton *list = (NSPopUpButton *)sender;
    NSInteger index = list.indexOfSelectedItem;
    boldTestCheckbox.enabled = index < 3 ? YES : NO;
}



- (IBAction)chooseWorkingDirectory:(id)sender
{
    // Present a subsidiary sheet on the Preferences sheet to allow the user
    // to select the current working directory
    
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



#pragma mark - Report a Problem Sheet Methods


- (IBAction)showFeedbackSheet:(id)sender
{
    // Show the Feedback sheet
    
    // Clear the text field from the last usage
    
    feedbackField.stringValue = @"";
    
    // If we've come from the 'About Squinter' sheet, close it first
    
    if (sender == feedbackButton) [self closeAboutSheet:sender];
    
    // Present the window
    // TODO make sure this is the top sheet
    
    [_window beginSheet:feedbackSheet completionHandler:nil];
}



- (IBAction)cancelFeedbackSheet:(id)sender
{
    // User clicked 'Cancel' so just close the sheet
    
    [_window endSheet:feedbackSheet];
}



- (IBAction)sendFeedback:(id)sender
{
    // User clicked 'Send' so get the message (if there is one) from the text field and send it
    
    NSString *feedback = feedbackField.stringValue;

    [_window endSheet:feedbackSheet];

    if (feedback.length == 0) return;

    // Start the connection indicator if it's not already visible
    
    if (connectionIndicator.hidden == YES)
    {
        connectionIndicator.hidden = NO;
        [connectionIndicator startAnimation:self];
    }

    // Send the string etc.

    NSError *error = nil;
    NSOperatingSystemVersion sysVer = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString *userAgent = [NSString stringWithFormat:@"%@ %@.%@.%@ (macOS %li.%li.%li)",
                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"],
                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
                           [[NSBundle mainBundle] objectForInfoDictionaryKey:@"SQBuildVersion"],
                           (long)sysVer.majorVersion, (long)sysVer.minorVersion, (long)sysVer.patchVersion];

    // UP TO 2.2.126
    // NSDictionary *dict = @{ @"comment" : feedback, @"useragent" : userAgent };

    // FROM 2.2.127
    NSDate *date = [NSDate date];
    NSDictionary *dict = @{ @"text" : [NSString stringWithFormat:@"*FEEDBACK REPORT*\n*DATE* %@\n*USER AGENT* %@\n*FEEDBACK* %@", [def stringFromDate:date], userAgent, feedback],
              @"mrkdwn" : @YES };

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[kSquinterFeedbackAddressA stringByAppendingString:kSquinterFeedbackAddressB]]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    //[request setValue:kSquinterFeedbackUUID forHTTPHeaderField:@"X-Squinter-ID"];
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];

    if (error != nil || request == nil)
    {
        // Something went wrong during the creation of the request, so tell the user and bail

        [self sendFeedbackError];
        return;
    }

    NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration: config
                                                          delegate: self
                                                     delegateQueue: [NSOperationQueue mainQueue]];
    feedbackTask = [session dataTaskWithRequest:request];
    [feedbackTask resume];
}



- (void)sendFeedbackError
{
    // Present an error message specific to sending feedback
    // This is called from multiple locations: if the initial request can't be created,
    // there was a send failure, or a server error

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Could Not Send Your Feedback";
    alert.informativeText = @"Unfortunately, your comments could not be send at this time. Please try again later.";

    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:_window completionHandler:nil];
}



#pragma mark - Check Electric Imp Libraries Methods


- (IBAction)checkElectricImpLibraries:(id)sender
{
    // FROM 2.3.129
    // Check we can access the impCloud before proceeding
    
    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"get Electric Imp libraries"];
        return;
    }
    
    [self checkElectricImpLibs:currentDevicegroup];
}



- (void)checkElectricImpLibs:(Devicegroup *)devicegroup
{
    // Initiate a read of the current Electric Imp library versions
    // Only do this if the project contains EI libraries and 1 hour has
    // passed since the last look-up

    // FROM 2.3.129
    // Check we can access the impCloud before proceeding
    // NOTE We don't post an error here because this call is sometimes made on behalf
    //      of the user, not by the user. So we check in 'checkElectricImpLibraries:'
    //      instead
    
    if (!ide.isLoggedIn) return;
        
    if (devicegroup.models.count > 0)
    {
        if (eiLibListTime != nil)
        {
            // NOTE 'eiLibListTime' is a proxy flag for 'have I asked for the library list'

            if (eiLibListData == nil || eiLibListData.length == 0)
            {
                // We haven't acquired the library list yet, so just cache the specified device group.
                // We'll process the cached devicegroups when we have the list

                [eiDeviceGroupCache addObject:devicegroup];
                return;
            }

            // Is the library list still valid? We assume it is for the hour after it was
            // acquired - after that we need to get a new list

            NSDate *now = [NSDate date];
            NSTimeInterval interval = [eiLibListTime timeIntervalSinceDate:now];

            if (interval >= kEILibCheckInterval)
            {
                // Last check was less than 1 hour earlier, so use existing list if it exists
                // NOTE 'interval' is negative

                [self compareElectricImpLibs:devicegroup];
                return;
            }
        }

        // Set the library list acquisition time

        eiLibListTime = [NSDate date];

        // Initalize or clear the devicegroup cache

        if (eiDeviceGroupCache == nil)
        {
            eiDeviceGroupCache = [[NSMutableArray alloc] init];
        }
        else
        {
            [eiDeviceGroupCache removeAllObjects];
        }

        // Cache the specified device group and get the library list

        [eiDeviceGroupCache addObject:devicegroup];
        [self writeStringToLog:@"Loading a list of supported Electric Imp libraries from the Electric Imp impCloud..." :YES];
        [ide getLibraries];
    }
}



- (void)compareElectricImpLibs:(Devicegroup *)devicegroup
{
    // This is where we actually compare a devicegroup's EI libraries

    NSString *parsedData;

    if (devicegroup != nil && devicegroup.models.count == 0) return;

    if (eiLibListData != nil && eiLibListData.length > 0)
    {
        // If we have data, attempt to decode it assuming that it is JSON (if it's not, 'error' will not equal nil

        parsedData = [[NSString alloc] initWithData:eiLibListData encoding:NSASCIIStringEncoding];
    }
    else
    {
        [self writeErrorToLog:@"Could not parse list of Electric Imp libraries" :YES];
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

                if (libParts.count >= 2)
                {
                    // Watch out for single-line entries in .csv file

                    NSString *libName = [[libParts objectAtIndex:0] lowercaseString];
                    NSString *libVer = [libParts objectAtIndex:1];

                    for (Model *model in devicegroup.models)
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

                                        NSString *mString;

                                        if (libParts.count > 2)
                                        {
                                            // Is there no replacement for the deprecated library?

                                            NSString *rep = [libParts objectAtIndex:2];

                                            if ([rep compare:@"none"] == NSOrderedSame)
                                            {
                                                mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is deprecated. There is no replacement library.", libName];
                                            }
                                            else
                                            {
                                                mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is deprecated. Please replace it with \"%@\".", libName, [libParts objectAtIndex:2]];
                                            }
                                        }
                                        else
                                        {
                                            mString = [NSString stringWithFormat:@"[WARNING] Electric Imp reports library \"%@\" is deprecated.", libName];
                                        }


                                        [self writeWarningToLog:mString :YES];
                                        allOKFlag = NO;
                                    }
                                    else if ([eiLib.version compare:libVer] != NSOrderedSame)
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
            [self writeStringToLog:[NSString stringWithFormat:@"All the Electric Imp libraries used in device group \"%@\" are up to date.", devicegroup.name] :YES];
        }

        eiDeviceGroup = nil;
    }
}



#pragma mark - Pasteboard Methods


- (IBAction)copyAgentURL:(id)sender
{
    if (selectedDevice == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
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



- (IBAction)copyDeviceCodeToPasteboard:(id)sender
{
    // Put the current device code onto the pasteboard
    
    [self copyCodeToPasteboard:@"device"];
}



- (IBAction)copyAgentCodeToPasteboard:(id)sender
{
    // Put the current agent code onto the pasteboard
    
    [self copyCodeToPasteboard:@"agent"];
}



- (void)copyCodeToPasteboard:(NSString *)type
{
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }
    
    BOOL flag = NO;
    NSString *code;
    
    for (Model *model in currentDevicegroup.models)
    {
        if ([model.type compare:type] == NSOrderedSame)
        {
            if (model.squinted && model.code.length > 0)
            {
                code = model.code;
                flag = YES;
            }
            
            break;
        }
    }
    
    if (flag)
    {
        NSPasteboard *pb = [NSPasteboard generalPasteboard];
        NSArray *types = [NSArray arrayWithObjects:NSStringPboardType, nil];
        
        [pb declareTypes:types owner:self];
        [pb setString:code forType:NSStringPboardType];
        [self writeStringToLog:[NSString stringWithFormat:@"Compiled %@ code copied to clipboard.", type] :YES];
    }
    else
    {
        [self writeWarningToLog:[NSString stringWithFormat:@"[WARNING] This device group has no compiled %@ code to copy.", type] :YES];
    }
}



#pragma mark - NSURLSession Delegate Methods


- (void)URLSession:(NSURLSession *)session
          dataTask:(NSURLSessionDataTask *)task
didReceiveResponse:(NSURLResponse *)response
 completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler
{
    NSHTTPURLResponse *rps = (NSHTTPURLResponse *)response;

    if (rps.statusCode != 200)
    {
        // Were we sending feedback?

        if (task == feedbackTask)
        {
            [self sendFeedbackError];
        }
        else
        {
            NSString *errString =[NSString stringWithFormat:@"Could not get list of Electric Imp libraries (Code: %ld)", (long)rps.statusCode];
            [self writeErrorToLog:errString :YES];
        }

        completionHandler(NSURLSessionResponseCancel);
        return;
    }

    completionHandler(NSURLSessionResponseAllow);
}



- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)task didReceiveData:(NSData *)data
{
    // Make sure we are recording data from the correct task
    // We are only interested in the EI library list data

    if (task == eiLibListTask) [eiLibListData appendData:data];
}



- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
    // Was there an error?

    if (error)
    {
        // React to a passed client-side error - most likely a timeout or inability to resolve the URL
        // ie. the client is not connected to the Internet

        if (error.code == NSURLErrorCancelled) return;

        [task cancel];

        // NOTE We will already have reported other errors, eg. connection errors,
        // so we can just bail here

        return;
    }

    // Make sure we are recording data from the correct task

    if (task == eiLibListTask)
    {
        // Successfully retrieved the current EI library list

        [self compareElectricImpLibs:eiDeviceGroup];
    }
    else if (task == feedbackTask)
    {
        // Successfully posted Squinter feedback

        NSAlert *alert = [[NSAlert alloc] init];
        alert.messageText = @"Thanks For Your Feedback!";
        alert.informativeText = @"Your comments have been received and we’ll take a look at them shortly.";

        [alert addButtonWithTitle:@"OK"];
        [alert beginSheetModalForWindow:_window completionHandler:nil];
    }

    if (ide.numberOfConnections < 1)
    {
        // Only hide the connection indicator if 'ide' has no live connections
        // Make sure it's on the main thread

        dispatch_async(dispatch_get_main_queue(), ^{
            [connectionIndicator stopAnimation:self];
            connectionIndicator.hidden = YES;
        });

    }

    [task cancel];
}



#pragma mark - NSTextFieldDelegate Methods


- (void)controlTextDidChange:(NSNotification *)obj
{
    // Generic handler for all changes made to text field that register the app delegate as their own delegate
    // Primarily used to warn the user that they have reached the limit on the number of characters
    // that can be entered, but it also checks the OTP entry field for numeric and hex characters
    
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
        return;
    }

    if (sender == newProjectDescTextField)
    {
        if (newProjectDescTextField.stringValue.length > 255)
        {
            newProjectDescTextField.stringValue = [newProjectDescTextField.stringValue substringToIndex:255];
            NSBeep();
        }

        newProjectDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)newProjectDescTextField.stringValue.length];
        return;
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
        return;
    }

    if (sender == renameProjectDescTextField)
    {
        if (renameProjectDescTextField.stringValue.length > 255)
        {
            renameProjectDescTextField.stringValue = [renameProjectDescTextField.stringValue substringToIndex:255];
            NSBeep();
        }

        renameProjectDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)renameProjectDescTextField.stringValue.length];
        return;
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
        return;
    }

    if (sender == newDevicegroupDescTextField)
    {
        if (newDevicegroupDescTextField.stringValue.length > 255)
        {
            newDevicegroupDescTextField.stringValue = [newDevicegroupDescTextField.stringValue substringToIndex:255];
            NSBeep();
        }

        newDevicegroupDescCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)newDevicegroupDescTextField.stringValue.length];
        return;
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
        return;
    }

    if (sender == uploadOriginTextField)
    {
        if (uploadOriginTextField.stringValue.length > 255)
        {
            uploadOriginTextField.stringValue = [uploadOriginTextField.stringValue substringToIndex:255];
            NSBeep();
        }

        uploadOriginCountField.stringValue = [NSString stringWithFormat:@"%li/255", (long)uploadOriginTextField.stringValue.length];
        return;
    }

    if (sender == uploadTagsTextField)
    {
        if (uploadTagsTextField.stringValue.length > 500)
        {
            uploadTagsTextField.stringValue = [uploadTagsTextField.stringValue substringToIndex:500];
            NSBeep();
        }

        uploadTagsCountField.stringValue = [NSString stringWithFormat:@"%li/500", (long)uploadTagsTextField.stringValue.length];
        return;
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
        return;
    }

    // OTP Sheet

    if (sender == otpTextField)
    {
        // Makes sure the string isn't longer than six characters

        if (otpTextField.stringValue.length > 6)
        {
            otpTextField.stringValue = [otpTextField.stringValue substringToIndex:6];
            NSBeep();
        }

        // Make sure the string doesn't contain non-numeral characters

        NSCharacterSet *set = [NSCharacterSet decimalDigitCharacterSet];

        for (NSInteger i = 0 ; i < otpTextField.stringValue.length ; ++i)
        {
            unichar chara = [otpTextField.stringValue characterAtIndex:i];

            if (![set characterIsMember:chara])
            {
                NSBeep();
                NSString *new = i > 0 ? [otpTextField.stringValue substringToIndex:i] : @"";
                new = i < otpTextField.stringValue.length - 1 ? [new stringByAppendingString:[otpTextField.stringValue substringFromIndex: i + 1]] : new;
                otpTextField.stringValue = new;
            }
        }
    }

    // Report a Problem sheet

    if (sender == feedbackField)
    {
        // Make sure the content isn't longerr than 512 characters

        if (feedbackField.stringValue.length > 512)
        {
            feedbackField.stringValue = [feedbackField.stringValue substringToIndex:512];
            NSBeep();
        }
    }
}



# pragma mark - VDKQueueDelegate Methods


- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString *)noteName forPath:(NSString *)fpath
{
    // A file has changed so notify the user
    // IMPORTANT: fpath is the MONITORED location. VDKQueue will continue watching this file wherever it is moved
    // or whatever it is renamed
    // TODO Review for new archtecture
    
#ifdef DEBUG
    NSLog(@"File change: %@ (%@)", fpath, noteName);
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



@end
