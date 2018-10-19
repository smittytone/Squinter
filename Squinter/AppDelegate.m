

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"
#import "AppDelegateSquinting.h"

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
    downloads = nil;
    ide = nil;
    dockMenu = nil;
    refreshTimer = nil;

    eiLibListData = nil;
    eiLibListTask = nil;
    eiLibListTime = nil;

    newDevicegroupName = nil;

    resetTargetFlag = NO;
    newDevicegroupFlag = NO;
    deviceSelectFlag = NO;
    renameProjectFlag = NO;
    saveAsFlag = YES;
    isBookmarkStale = NO;
    credsFlag = NO;
    switchAccountFlag = NO;
    doubleSaveFlag = NO;
    reconnectAfterSleepFlag = NO;

    syncItemCount = 0;
    logPaddingLength = 0;
    deviceCheckCount = -1;
    updateDevicePeriod = 300.0;
    loginMode = kLoginModeNone;

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

    // Account Menu

    // switchAccountMenuItem.enabled = NO;
    accountMenuItem.enabled = NO;

    // View Menu

    showHideToolbarMenuItem.title = @"Hide Toolbar";
    // NOTE refreshMainDevicegroupsMenu: calls refreshViewMenu:

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

    viewDeviceCode.activeImageName = @"open";
    viewDeviceCode.inactiveImageName = @"open_grey";
    viewDeviceCode.toolTip = @"Display the device group's compiled device code";

    viewAgentCode.activeImageName = @"open";
    viewAgentCode.inactiveImageName = @"open_grey";
    viewAgentCode.toolTip = @"Display the device group's compiled agent code";

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

    newDevicegroupItem.activeImageName = @"plus";
    newDevicegroupItem.inactiveImageName = @"plus_grey";
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

    listCommitsItem.activeImageName = @"commits";
    listCommitsItem.inactiveImageName = @"commits_grey";
    listCommitsItem.toolTip = @"List the commits made to the current device group";

    downloadProductItem.activeImageName = @"download";
    downloadProductItem.inactiveImageName = @"download_grey";
    downloadProductItem.toolTip = @"Download the selected product as a project";

    inspectorItem.activeImageName = @"inspect";
    inspectorItem.inactiveImageName = @"inspect_grey";
    inspectorItem.toolTip = @"Show the project and device inspector";

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
                         nil];

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
                            [NSString stringWithString:NSStringFromRect(iwvc.view.window.frame)],
                            [NSNumber numberWithBool:NO],           // New in 2.0.123
                            [[NSArray alloc] init],                 // New in 2.0.123
                            nil];

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

    // Position Inspector

    if ([defaults boolForKey:@"com.bps.squinter.preservews"])
    {
        NSString *frameString = [defaults stringForKey:@"com.bps.squinter.inspectorsize"];
        NSRect nuRect = NSRectFromString(frameString);
        [iwvc.view.window setFrame:nuRect display:NO];
    }
    else
    {
        iwvc.mainWindowFrame = _window.frame;
        [iwvc positionWindow];
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
           selector:@selector(startProgress)
               name:@"BuildAPIProgressStart"
             object:ide];

    [nsncdc addObserver:self
           selector:@selector(stopProgress)
               name:@"BuildAPIProgressStop"
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
               selector:@selector(handleLoginKey:)
                   name:@"BuildAPILoginKey"
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
               selector:@selector(getOtp:)
                   name:@"BuildAPINeedOTP"
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

    if ([defaults boolForKey:@"com.bps.squinter.show.inspector"]) [iwvc.view.window makeKeyAndOrderFront:self];

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

    // Kill any timers

    if (refreshTimer != nil) [refreshTimer invalidate];

    // Record settings that are not set by the Prefs dialog

    [defaults setValue:workingDirectory forKey:@"com.bps.squinter.workingdirectory"];
    [defaults setValue:NSStringFromRect(_window.frame) forKey:@"com.bps.squinter.windowsize"];
    if (iwvc.view.window.isVisible) [defaults setValue:NSStringFromRect(iwvc.view.window.frame) forKey:@"com.bps.squinter.inspectorsize"];
    [defaults setObject:[NSArray arrayWithArray:recentFiles] forKey:@"com.bps.squinter.recentFiles"];

    // Stop watching for notifications

    [nsncdc removeObserver:self];
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
                [nswsw openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html"]];
                break;

            case 2:
                [nswsw openURL:[NSURL URLWithString:@"https://developer.electricimp.com/"]];
                break;

            case 3:
                [nswsw openURL:[NSURL URLWithString:@"https://forums.electricimp.com/"]];
                break;

            default:
                [nswsw openFile:workingDirectory withApplication:nil andDeactivate:YES];
        }
    }
}



#pragma mark - Inspector Methods


- (IBAction)showInspector:(id)sender
{
    // Show the Inspector if it's closed
    // If the Inspector is obscured by the main window, or not key, bring it forward

    [iwvc.view.window makeKeyAndOrderFront:self];
}



- (IBAction)showProjectInspector:(id)sender
{
    if (currentProject != nil) iwvc.project = currentProject;

    [iwvc setTab:kInspectorTabProject];
    [iwvc.view.window makeKeyAndOrderFront:self];
}



- (IBAction)showDeviceInspector:(id)sender
{
    if (selectedDevice != nil) iwvc.device = selectedDevice;

    [iwvc setTab:kInspectorTabDevice];
    [iwvc.view.window makeKeyAndOrderFront:self];
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

        [self logout];

        // Update the UI and report to the user

        accountMenuItem.title = @"Not Signed in to any Account";
        loginMenuItem.title = @"Log in to your Main Account";
        // switchAccountMenuItem.enabled = YES;
        switchAccountMenuItem.title = @"Log in to a Different Account...";
        loginMode = kLoginModeNone;

        NSString *cloudName = [self getCloudName:cloudCode];
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
    [self refreshDevicesMenus];
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
        // We don't have a password or a username, so we'll need to show the login window

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
        ic = @"AWS";
        [impCloudPopup selectItemAtIndex:0];
    }
    else if ([ic compare:@"Azure"] == NSOrderedSame)
    {
        [impCloudPopup selectItemAtIndex:1];
    }
    else
    {
        // Error!

        credsFlag = NO;
        usernameTextField.stringValue = @"";
        passwordTextField.stringValue = @"";
    }
}



- (IBAction)cancelLogin:(id)sender
{
    // Just hide the login sheet

    [_window endSheet:loginSheet];

    if (switchAccountFlag) switchAccountFlag = NO;
}



- (IBAction)hitSaveCheckbox:(id)sender
{
    // If the user hits 'save' while going to another account, warn them that
    // they will overwrite their currently saved credentials

    NSButton *checkbox = (NSButton *)sender;

    if (checkbox.state == NSOnState && switchAccountFlag)
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

    if (switchAccountFlag)
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

        switchAccountFlag = YES;

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
    [nswsw openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html#account"]];
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

    if (switchAccountFlag) switchAccountFlag = NO;

    [_window endSheet:otpSheet];
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
            // User wants to make a new product or doesn't want to associate with an exitsting one
            // so compare the new product's name against existing product names

            if (productsArray.count > 0)
            {
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

    // Go on to the next phase

    [self newProjectSheetCreateStageTwo:pName :pDesc :makeNewProduct :associateProduct];
}



- (void)newProjectSheetCreateStageTwo:(NSString *)projectName :(NSString *)projectDesc :(BOOL)make :(BOOL)associate
{
    // Second phase of project creation
    // This needs to be a separate method because of the async nature of the first phase,
    // embodied in 'newProjectSheetCreate:', which may pop up an alert whose effect may be
    // to take the user away from here

    // Make the new project

    currentProject = [[Project alloc] init];
    currentProject.name = projectName;
    currentProject.description = projectDesc;
    currentProject.path = workingDirectory;
    currentProject.filename = [projectName stringByAppendingString:@".squirrelproj"];
    currentProject.haschanged = YES;
    currentProject.devicegroupIndex = -1;
    currentDevicegroup = nil;

    // Add the account ID if we are logged in

    if (ide.isLoggedIn) currentProject.aid = ide.currentAccount;

    [projectArray addObject:currentProject];

    if (make)
    {
        // User wants to create a new product for this project. We will pick up saving
        // this project AFTER the product has been created (to make sure it is created)
        // NOTE 'make' can only be YES if we are logged in

        [self writeStringToLog:@"Creating Project's Product on the server..." :YES];

        NSDictionary *dict = @{ @"action"  : @"newproject",
                                @"project" : currentProject };

        [ide createProduct:projectName :projectDesc :dict];
        return;

        // Pick up the action at 'createProductStageTwo:'
    }

    // Check whether we're connecting this project to a product (new or selected)

    if (associate)
    {
        // User wants to associate the new project with the selected product, so set 'pid'
        // NOTE user can't have made this choice if 'selectedProduct' is nil

        currentProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
    }

    // Add the new project to the project menu. We've already checked for a name clash,
    // so we needn't care about the return value

    [self addProjectMenuItem:projectName :currentProject];

    // Enable project-related UI items for the new project
    // NOTE 'addProjectMenuItem:' will have updated the sub-menus already

    [self refreshProjectsMenu];
    [self setToolbar];

    iwvc.project = currentProject;
    [iwvc setTab:0];

    // Mark the status light as empty, ie. in need of saving

    [saveLight show];
    [saveLight needSave:YES];

    // Save the new project - this gives the user the chance to re-locate it

    savingProject = currentProject;
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

    // Switch in the newly chosen project and select its known selected device group

    currentProject = chosenProject;
    currentDevicegroup = (currentProject.devicegroupIndex != -1) ? [currentProject.devicegroups objectAtIndex:currentProject.devicegroupIndex] : nil;

    // If we have a current device group, select its device if it has one

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

    // Update the save? indicator if the newly selected project needs it

    [saveLight needSave:currentProject.haschanged];

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
    [self refreshOpenProjectsMenu];
    [self refreshMainDevicegroupsMenu];
    [self refreshDevicegroupMenu];
    [self setToolbar];

    // Set the inspector

    iwvc.project = currentProject;
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
    if (projectArray.count == 0 || currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
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
        currentDevicegroup = nil;

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
    }

    // Update the UI whether we've closed one of x projects, or the last one

    [self refreshProjectsMenu];
    [self refreshOpenProjectsMenu];
    [self refreshMainDevicegroupsMenu];
    [self refreshDevicegroupMenu];
    [self setToolbar];

    iwvc.project = currentProject;
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
                iwvc.project = currentProject;
            }

            // Report if no changes were made

            if (!currentProject.haschanged) [self writeStringToLog:[NSString stringWithFormat:@"No changes made to Project \"%@\".", currentProject.name] :YES];

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
        }
    }
}



- (IBAction)doSync:(id)sender
{
    // This is an start point for the UI to trigger a project sync
    // NOTE this may yet be merged with 'syncProject:'

    if (currentProject == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedProject] :YES];
        return;
    }

    [self uploadProject:currentProject];
}



- (void)uploadProject:(Project *)project
{
    // Uploading a project is the act of creating a new product out of a pre-existing project,
    // ie. a new product wasn't created when the project was created

    if (!ide.isLoggedIn)
    {
        // We can't upload this project to a product if we're not logged in

        [self loginAlert:@"upload this Project"];
        return;
    }

    BOOL correctAccount = (project.aid == nil || project.aid.length == 0 || [ide.currentAccount compare:project.aid] == NSOrderedSame) ? YES : NO;

    if (project.pid == nil || project.pid.length == 0)
    {
        // TODO - Complete account check

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
                            return;
                        }
                    }
                }
            }

            [self writeStringToLog:[NSString stringWithFormat:@"Uploading Project \"%@\" to impCloud: making a Product...", project.name] :YES];

            // Start by creating the product

            NSDictionary *dict = @{ @"action" : @"uploadproject",
                                    @"project" : project };

            [ide createProduct:project.name :project.description :dict];

            // Pick up in 'createProductStageTwo:'
        }
        else
        {
            // The project is associated with an account other than the one we're signed in to

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"Project “%@” is not associated with the logged in Account.", project.name];
            alert.informativeText = [NSString stringWithFormat:@"Do you wish to re-associate it with the current Account (this will break its link with Account %@), or cancel the upload?", project.aid];
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Continue"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn)
                {
                    // Proceed with the upload to this account

                    project.aid = ide.currentAccount;
                    project.haschanged = YES;
                    if (project == currentProject) [saveLight needSave:YES];

                    // Re-call this method now we have changed the Account ID

                    [self uploadProject:project];
                }
            }];
        }

        return;
    }
    else
    {
        // Project has a PID, but has it been orphaned?

        if (!correctAccount)
        {
            // The project is associated with an account other than the one we're signed in to

            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"Project “%@” is not associated with the logged in Account.", project.name];
            alert.informativeText = [NSString stringWithFormat:@"Do you wish to re-associate it with the current Account (this will break its link with Product %@ and Account %@), or cancel the upload?", project.pid, project.aid];
            [alert addButtonWithTitle:@"Cancel"];
            [alert addButtonWithTitle:@"Continue"];
            [alert setAlertStyle:NSWarningAlertStyle];
            [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
                if (returnCode == NSAlertSecondButtonReturn)
                {
                    // Proceed with the upload to this account

                    project.aid = ide.currentAccount;
                    project.pid = @"";
                    project.haschanged = YES;
                    if (project == currentProject) [saveLight needSave:YES];

                    // Re-call this method now we have changed the Account ID and Product ID

                    [self uploadProject:project];
                }
            }];

            return;
        }

        if (productsArray == nil)
        {
            // We don't have the products list populated yet, so we need to get it first

            [self writeStringToLog:@"Retrieving a list of your Products" :YES];

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

        // Pick up the action in **listProducts:**
        // NOTE This will trigger updates to:
        //      The Project Inspector (sets 'products' array)
        //      Projects menu
        //      Projects > Products sub-menu
        //      Toolbar
    }
    else
    {
        [ide getMyAccount:dict];
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
        [alert setAlertStyle:NSWarningAlertStyle];
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

                [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - checking for device droups...", [self getValueFrom:selectedProduct withKey:@"name"]] :YES];

                [ide getDevicegroupsWithFilter:@"product.id" :[selectedProduct objectForKey:@"id"] :dict];

                // Pick up the action in **productToProjectStageTwo:**
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

    if (selectedProduct == nil)
    {
        [self writeErrorToLog:@"[ERROR] You have not selected a product as the new project's source." :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"download products"];
        return;
    }

    NSString *name = [self getValueFrom:selectedProduct withKey:@"name"];
    [self writeStringToLog:[NSString stringWithFormat:@"Downloading product \"%@\" - retrieving device groups and source code...", name] :YES];
    [self writeStringToLog:@"Please be patient as this may take some time if the product has many components." :YES];

    Project *newProject = [[Project alloc] init];

    // Set new project's name, id and desc to match that of the source product

    newProject.pid = [self getValueFrom:selectedProduct withKey:@"id"];
    newProject.description = [self getValueFrom:selectedProduct withKey:@"description"];
    newProject.path = workingDirectory;
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

        [self refreshOpenProjectsMenu];
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
        [ays setAlertStyle:NSWarningAlertStyle];
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
    newdg.type = @"development_devicegroup";

    switch (newType)
    {
        default:
        case 0:
            newdg.type = @"development_devicegroup";
            break;
        case 1:
            newdg.type = @"pre_factoryfixture_devicegroup";
            break;
        case 2:
            newdg.type = @"pre_production_devicegroup";
            break;
        case 3:
            newdg.type = @"factoryfixture_devicegroup";
            break;
        case 4:
            newdg.type = @"production_devicegroup";
            break;
    }

    if (newType == 1 || newType == 3)
    {
        // On choosing a fixture device group, we need to eastablish a target or creation will fail

        NSUInteger count = 0;

        for (Devicegroup *dg in currentProject.devicegroups)
        {
            if (newType == 1 && [dg.type compare:@"pre_production_devicegroup"] == NSOrderedSame) ++count;
            if (newType == 3 && [dg.type compare:@"production_devicegroup"] == NSOrderedSame) ++count;
        }

        if (count == 0)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            alert.messageText = [NSString stringWithFormat:@"You cannot create a factory %@ device group", (newType == 1 ? @"test" : @"")];
            alert.informativeText = [NSString stringWithFormat:@"To create this type of device group, you need to specify a production %@ device group as its target, and you have no such device group in this project.", (newType == 1 ? @"test" : @"")];

            [alert beginSheetModalForWindow:_window completionHandler:nil];

            return;
        }

        [self showSelectTarget:newdg :makeNewFiles];
    }
    else
    {
        [self newDevicegroupSheetCreateStageTwo:newdg :makeNewFiles :nil];
    }
}



- (void)newDevicegroupSheetCreateStageTwo:(Devicegroup *)devicegroup :(BOOL)makeNewFiles :(Devicegroup *)theTarget
{
    if (currentProject.pid != nil && currentProject.pid.length > 0)
    {
        // The current project is associated with a product so we can create the device group on the server

        NSDictionary *dict = @{ @"action" : @"newdevicegroup",
                                @"devicegroup" : devicegroup,
                                @"project" : currentProject,
                                @"files" : [NSNumber numberWithBool:makeNewFiles] };

        [self writeStringToLog:[NSString stringWithFormat:@"Uploading Device Group \"%@\" to the impCloud.", devicegroup.name] :YES];

        NSDictionary *details;

        if (![devicegroup.type containsString:@"factoryfixture"])
        {
            details = @{ @"name" : devicegroup.name,
                         @"description" : devicegroup.description,
                         @"productid" : currentProject.pid,
                         @"type" : devicegroup.type };
        }
        else
        {
            details = @{ @"name" : devicegroup.name,
                         @"description" : devicegroup.description,
                         @"productid" : currentProject.pid,
                         @"type" : devicegroup.type,
                         @"targetid" : theTarget.did };
        }

        [ide createDevicegroup:details :dict];

        // We will handle the addition of the device group and UI updates later - it will call
        // the following code separately in **createDevicegroupStageTwo:**
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

        if (currentDevicegroup != devicegroup)
        {
            [currentProject.devicegroups addObject:devicegroup];
            currentDevicegroup = devicegroup;
            currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];
        }

        // Update the UI

        [self refreshDevicegroupMenu];
        [self refreshMainDevicegroupsMenu];
        [self setToolbar];

        currentProject.haschanged = YES;
        [saveLight needSave:YES];
        [self refreshOpenProjectsMenu];

        // Update the inspector, if required

        if (iwvc.tabIndex == kInspectorTabProject) iwvc.project = currentProject;

        // Create the new device group's files as requested

        if (makeNewFiles) [self createFilesForDevicegroup:devicegroup.name :@"agent"];
    }
}



- (void)showSelectTarget:(Devicegroup *)devicegroup :(BOOL)andMakeNewFiles
{
    // Show a sheet listing suitable fixture device group targets

    swvc.theNewDevicegroup = devicegroup;
    swvc.makeNewFiles = andMakeNewFiles;
    swvc.project = currentProject;

    [_window beginSheet:selectTargetSheet completionHandler:nil];
}



- (IBAction)cancelSelectTarget:(id)sender
{
    [_window endSheet:selectTargetSheet];

    resetTargetFlag = NO;
}



- (IBAction)selectTarget:(id)sender
{
    [_window endSheet:selectTargetSheet];

    // If no target was selected, bail

    if (swvc.theTarget == nil) return;

    // If we are not (re)setting a target for an existing device,
    // continue with the creation of a new devicegroup

    if (!resetTargetFlag)
    {
        [self newDevicegroupSheetCreateStageTwo:swvc.theNewDevicegroup :swvc.makeNewFiles :swvc.theTarget];
        return;
    }

    resetTargetFlag = NO;

    // Check that the selected device group is not the current one

    if (currentDevicegroup.data != nil)
    {
        NSDictionary *tgt = [self getValueFrom:currentDevicegroup.data withKey:@"production_target"];

        if (tgt != nil)
        {
            NSString *tid = [tgt objectForKey:@"id"];

            if ([tid compare:swvc.theTarget.did] == NSOrderedSame)
            {
                [self writeWarningToLog:[NSString stringWithFormat:@"The device group you selected is already \"%@\"'s production target.", currentDevicegroup.name]  :YES];
                return;
            }
        }
    }

    NSDictionary *dict = @{ @"action" : @"resetprodtarget",
                           @"devicegroup" : currentDevicegroup,
                           @"target" : swvc.theTarget };

    NSDictionary *targ = @{ @"type" : swvc.theTarget.type,
                            @"id" : swvc.theTarget.did };

    [ide updateDevicegroup:currentDevicegroup.did :@[@"production_target", @"type"] :@[targ, currentDevicegroup.type] :dict];

    // Pick up the action at ... updateDevicegroupStageTwo:
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

            [self refreshMainDevicegroupsMenu];
        }

        if (!added) NSLog(@"Some files couldn't be added");
    }
    else
    {
        [self writeErrorToLog:@"[ERROR] The file could not be saved." :YES];
    }
}



#pragma mark - Existing Device Group Methods

- (void)chooseDevicegroup:(id)sender
{
    // User has selected a device group
    // So we need to set 'currentDevicegroup' to the chosen device group
    // And, depending on prefs, select the first device, if there is one
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

                NSMenuItem *sitem = [dgitem.submenu.itemArray objectAtIndex:0];

                // Select the device using 'chooseDevice:' as this manages 'selectedDevice'

                [self chooseDevice:sitem];
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
        [self writeErrorToLog:@"[ERROR] Cannot upload: the selected device group is not associated with a device group in the impCloud." :YES];
        return;
    }

    if (currentDevicegroup.models.count == 0)
    {
        [self writeErrorToLog:@"[ERROR] The selected device group contains no code to upload." :YES];
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
            [self writeErrorToLog:@"[ERROR] The selected device group contains uncompiled code. Please compile before uploading." :YES];
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
             if (currentDevicegroup.models.count > 0) [currentDevicegroup.models removeAllObjects];
             currentProject.haschanged = YES;
             [saveLight needSave:YES];
             // [self refreshOpenProjectsMenu];
             [self refreshLibraryMenus];
             [self refreshMainDevicegroupsMenu];
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

    // Pick up the action in listCommits:
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

    // Pick up the action in updateCodeStageTwo:
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

    // Pick up the action in listCommits:
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

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
        return;
    }

    if (![currentDevicegroup.type containsString:@"factoryfixture"])
    {
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" is not a factory fixture group so has no production target.", currentDevicegroup.name] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"set production device groups as targets"];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"set a production device group as a target for" :_window];
        return;
    }

    resetTargetFlag = YES;

    [self showSelectTarget:currentDevicegroup :NO];
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
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" is not a pre-production group so has no test blessed devices.", currentDevicegroup.name] :YES];
        return;
    }

    if (!ide.isLoggedIn)
    {
        [self loginAlert:@"list test blessed devices"];
        return;
    }

    if (![self isCorrectAccount:currentProject])
    {
        // We are working on a project that is NOT tied to the current account

        [self devicegroupAccountAlert:currentDevicegroup :@"show test blessed devices in" :_window];
        return;
    }

    NSDictionary *dict = @{ @"action" : @"gettestblesseddevices",
                            @"devicegroup" : currentDevicegroup };

    [ide getDevicesWithFilter:@"devicegroup.id" :currentDevicegroup.did :dict];

    // Pick up the action at **listDevices:**
}



#pragma mark - Existing Device Methods


- (void)selectDevice
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
                        list = [list substringToIndex:list.length - 2];
                        list = [list stringByAppendingFormat:@" and %@", item];
                    }
                    else
                    {
                        list = [list stringByAppendingFormat:@"%@, ", item];
                    }
                }

                selectedDevice = [selectedDevices firstObject];
                iwvc.device = selectedDevice;

                [self setDevicesPopupTick];
                [self setUnassignedDevicesMenuTick];
                [self setDevicesMenusTicks];
                [self refreshDeviceMenu];

                NSAlert *alert = [[NSAlert alloc] init];
                alert.messageText = [NSString stringWithFormat:@"This device group has mulitple assigned devices: %@. The first device, %@, will be selected initially.", list, first];
                [alert addButtonWithTitle:@"OK"];
                [alert beginSheetModalForWindow:_window
                              completionHandler:nil];
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
    [connectionIndicator startAnimation:self];

    // Get all the devices from development device groups and unassigned devices

    NSDictionary *dict = @{ @"action" : @"getdevices" };

    [ide getDevices:dict];

    // Pick up the action at listDevices:
}



- (IBAction)keepDevicesStatusUpdated:(id)sender
{
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

            // Pick up the action at updateDevice:
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

        [self writeErrorToLog:@"[ERROR] You have no projects open. You will need to open or create a project and add a device group to assign a device." :YES];
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
                if (![dg.type containsString:@"production"])
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

        [self writeErrorToLog:@"[ERROR] None of your open Projects have any Device Groups. You will need to create a Device Group to assign a device." :YES];
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

    NSDictionary *dict = @{ @"action" : @"assign",
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

        [self writeErrorToLog:@"[ERROR] You have no devices listed. You need to retrieve the list from the impCloud." :YES];
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
    //   The Device PopUp
    //   The 'Device' menu's 'Unassigned Devices' submenu
    //   The 'Device Groups' menu's 'Project's Device Groups' submenu

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
        // We may be here from eiter the 'Unassigned Devices' or the 'Project's Device Groups' submenu

        item = (NSMenuItem *)sender;
        isUnassigned = item.menu == unassignedDevicesMenu ? YES : NO;
    }

    // Set the currently selected device to the object the menu item is bound to

    selectedDevice = item.representedObject;

    if (!isPopup && !isUnassigned)
    {
        // Run through the Device Groups submenus to see if the selected device is not assigned to the
        // currently selected device group (because we'll now need to select that group)
        // NOTE But only if we DIDN'T select from the popup or an unassgined device, ie. these controls
        //      do not force a devicegroup switch

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

    [self refreshDevicegroupMenu];
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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSDictionary *dict;

    if (sender == getLogsMenuItem)
    {
        dict = @{ @"action" : @"getlogs" ,
                  @"device" : selectedDevice };

        [ide getDeviceLogs:[self getValueFrom:selectedDevice withKey:@"id"] :dict];

        // Pick up the action at **listLogs:**
    }
    else
    {
        dict = @{ @"action" : @"gethistory" ,
                  @"device" : selectedDevice };

        [ide getDeviceHistory:[self getValueFrom:selectedDevice withKey:@"id"] :dict];

        // Pick up the action at **listLogs:**
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

            [self writeStringToLog:[NSString stringWithFormat:@"Loading Project \"%@\" from file \"%@\".", currentProject.name, filePath] :YES];

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
                        alert.informativeText = [NSString stringWithFormat:@"You can upload project \"%@\" as a new product, or you may prefer to associate it with an existing product or upload it later. If you see processing errors in the log, you should not upload this project.", currentProject.name];
                        [alert addButtonWithTitle:@"Upload Now"];
                        [alert addButtonWithTitle:@"Later"];
                        [alert setAlertStyle:NSWarningAlertStyle];
                        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
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
                        alert.informativeText = [NSString stringWithFormat:@"You will need to upload project \"%@\" manually later, after you have logged in.", currentProject.name];
                        [alert addButtonWithTitle:@"OK"];
                        [alert setAlertStyle:NSWarningAlertStyle];
                        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) { }];
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

                                        [self projectAccountAlert:currentProject :@"**apply changes to this project" :_window];

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

                            if (currentProject.aid != nil && currentProject.aid.length > 0 && ide.isLoggedIn)
                            {
                                if ([currentProject.aid compare:ide.currentAccount] != NSOrderedSame)
                                {
                                    // Whoops - they don't match so warn the use that they can't work with this project

                                    [self projectAccountAlert:currentProject :@"*apply changes to this project" :_window];
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

                        if (ide.isLoggedIn && currentProject.aid != nil &&
                            currentProject.aid.length > 0 &&
                            [ide.currentAccount compare:currentProject.aid] != NSOrderedSame)
                        {
                            // If the account IDs don't match, then the product ID won't no matter what

                            [self projectAccountAlert:currentProject :@"***apply changes to this project" :_window];
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

                        [self projectAccountAlert:currentProject :@"*apply changes to this project" :_window];
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

                        [alert beginSheetModalForWindow:_window completionHandler:^(NSModalResponse returnCode) {
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

            [self addProjectMenuItem:(newName != nil ? newName : currentProject.name) :currentProject];

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
                                                @"devicegroup" : devicegroup };

                        [ide getDevicegroup:devicegroup.did :dict];

                        // Action continues asynchronously at **updateCodeStageTwo:**

                        // Set the devicegroup's device list

                        [self setDevicegroupDevices:devicegroup];
                    }
                }

                // Auto-compile all of the project's device groups, if required by the user

                if ([defaults boolForKey:@"com.bps.squinter.autocompile"])
                {
                    [self writeStringToLog:@"Auto-compiling the Project's Device Groups. This can be disabled in Preferences." :YES];

                    for (Devicegroup *dg in currentProject.devicegroups)
                    {
                        if (dg.models.count > 0) [self compile:dg :NO];
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

                                    [self writeStringToLog:[NSString stringWithFormat:@"Device Group \"%@\" cannot be compiled until this is resolved.", devicegroup.name] :YES];

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

            [self selectDevice];

            // Update the Menus and the Toolbar

            [self refreshOpenProjectsMenu];    // Need this or we crash in refreshDevicegroupMenu: TODO - check why
            [self refreshProjectsMenu];
            [self refreshDevicegroupMenu];
            [self refreshMainDevicegroupsMenu];
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

        [self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] Could not load project file \"%@\".", fileName] :YES];
    }

    // Call the method again in case there are any URLs left to deal with

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

        [self writeStringToLog:[NSString stringWithFormat:@"Device Group \"%@\" cannot be compiled until this is resolved.", devicegroup.name] :YES];

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



#pragma mark Add files to Device Groups


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
                                             // Remove the current file from the watch queue

                                             [fileWatchQueue removePath:[self getAbsolutePath:currentProject.path :[model.path stringByAppendingPathComponent:model.filename]]];

                                             // Add the new file to the model
                                             
                                             model.filename = [filePath lastPathComponent];
                                             model.path = [self getRelativeFilePath:currentProject.path :[filePath stringByDeletingLastPathComponent]];

                                            currentProject.haschanged = YES;

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

            // Add the project to the list
            // Don't need to do this is just saving, only save as...

            if (saveAsFlag) [self addToRecentMenu:savingProject.filename :savingProject.path];

            saveAsFlag = NO;
        }

        if (!doubleSaveFlag) [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" saved at %@.", savingProject.name, [savePath stringByDeletingLastPathComponent]] :YES];
    }
    else
    {
        [self writeErrorToLog:@"[ERROR] The Project could not be saved." :YES];
    }

    // Saved the project, but are there models to save, from a 'download product' operation?

    Project *sp = nil;

    if (downloads.count > 0)
    {
        for (Project *ap in downloads)
        {
            if (ap == savingProject) sp = ap;
        }
    }

    // Done saving so clear 'savingProject'

    savingProject = nil;
    doubleSaveFlag = NO;

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

    // Configure the NSSavePanel

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

        savingProject = currentProject;
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

    NSMutableArray *filesToSave = [[NSMutableArray alloc] init];

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

                    [filesToSave addObject:model];
                }
            }
        }
    }

    if (filesToSave.count > 0) [self saveFiles:filesToSave];

    [projectArray addObject:project];

    iwvc.project = project;
    currentProject = project;

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
    [saveLight needSave:NO];

    [self refreshOpenProjectsMenu];
    [self refreshProjectsMenu];
    [self refreshDevicegroupMenu];
    [self refreshMainDevicegroupsMenu];

    // We now need to re-save the project file, which now contains the locations
    // of the various model files. We do this programmatically rather than indicate
    // to the user that they need to (re)save the project

    currentProject.haschanged = YES;
    savingProject = currentProject;
    doubleSaveFlag = YES;

    [self saveProject:nil];
}



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



#pragma mark - API Response Handler Methods

- (void)gotMyAccount:(NSNotification *)note
{
    // This method should ONLY be called by BuildAPIAccess instance AFTER loading the account info

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];

    if (so != nil)
    {
        // Because the BuildAPIAccess instance's own attempt to get the account info will come here, we
        // (uniquely) need to make sure that we have a passed object ('so') to work with before processing

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
                
                [self loggedInStageTwo];
            }
        }
        else
        {
            [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (gotAccount:)"] :YES];
        }
    }
}



- (void)gotAnAccount:(NSNotification *)note
{
    // This method should ONLY be called by BuildAPIAccess instance AFTER loading the account info

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *account = [data objectForKey:@"account"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSMutableDictionary *product = [so objectForKey:@"product"];
    NSString *action = [so objectForKey:@"action"];

    if (action != nil)
    {
        if ([action compare:@"getaccountid"] == NSOrderedSame)
        {
            NSString *productName = [account valueForKeyPath:@"attributes.name"];

            if ([product objectForKey:@"shared"])
            {
                [product setValue:productName forKeyPath:@"shared.name"];
                [self refreshProductsMenu];
            }
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (gotAccount:)"] :YES];
    }
}



- (void)listProducts:(NSNotification *)note
{
    // This method should ONLY be called by BuildAPIAccess instance AFTER loading a list of products
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
                for (NSDictionary *product in products)
                {
                    // Convert incoming dictionary into a mutable one and copy the data

                    NSMutableDictionary *aProduct = [[NSMutableDictionary alloc] init];

                    [aProduct setObject:[product objectForKey:@"id"] forKey:@"id"];
                    [aProduct setObject:[product objectForKey:@"type"] forKey:@"type"];
                    [aProduct setObject:[product objectForKey:@"relationships"] forKey:@"relationships"];
                    [aProduct setObject:[NSMutableDictionary dictionaryWithDictionary:[product objectForKey:@"attributes"]] forKey:@"attributes"];

                    NSString *cid = [aProduct valueForKeyPath:@"relationships.creator.id"];
                    NSString *oid = ide.currentAccount;

                    if ([cid compare:oid] != NSOrderedSame)
                    {
                        // The Product is being shared with a collaborator

                        NSMutableDictionary *shared = [[NSMutableDictionary alloc] init];
                        [shared setObject:@"" forKey:@"name"];
                        [shared setObject:cid forKey:@"id"];
                        [aProduct setObject:shared forKey:@"shared"];

                        // Get the account name

                        NSDictionary *dict = @{ @"product" : aProduct,
                                                @"action" : @"getaccountid" };

                        [ide getAccount:cid :dict];

                        // Pick up the asynchronous action at **gotAnAccount:**
                        
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

                    if (selectedProduct == nil && [action compare:@"newproduct"] == NSOrderedSame)
                    {
                        NSString *pid = [so objectForKey:@"productid"];
                        NSString *apid = [product objectForKey:@"id"];

                        if ([pid compare:apid] == NSOrderedSame) selectedProduct = aProduct;
                    }
                }

                // Inform the user

                [self writeStringToLog:@"List of products loaded: see 'Projects' > 'Current Products'." :YES];

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
    // It may be in response to calling 'downloadProduct:' or to 'deleteProduct:', with the
    // actions "downloadproduct" and "deleteproduct", respectively

    NSDictionary *data = (NSDictionary *)note.object;
    NSMutableArray *devicegroups = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];

    if (action != nil)
    {
        if ([action compare:@"downloadproduct"] == NSOrderedSame)
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

                            // At this point we have to wait for multiple async calls to **productToProjectStageThree:**
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

                    // Pick up the action in **listDevices:**
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
    // This method is called by the BuildAPIAccess instance in response to
    // multiple requests to retrieve the current deployment for a given device group

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *deployment = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];

    NSString *action = [so objectForKey:@"action"];
    Project *newProject = [so objectForKey:@"project"];
    Devicegroup *newDevicegroup = [so objectForKey:@"devicegroup"];

    if (deployment != nil)
    {
        if ([action compare:@"updatecode"] == NSOrderedSame)
        {
            // Compare the deployment we have with the one just downloaded

            if (newDevicegroup.models.count == 0)
            {
                // BORKED? The target has no models, so create them using the code below

                return;
            }

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
                    [saveLight needSave:YES];
                }
            }
        }
        else
        {
            // We presume the 'action' is 'downloadproduct'
            // Create two models - one device, one agent - based on the deployment

            if (newDevicegroup.models == nil) newDevicegroup.models = [[NSMutableArray alloc] init];

            Model *model;
            NSString *code = [self getValueFrom:deployment withKey:@"device_code"];

            if (code != nil)
            {
                model = [[Model alloc] init];
                model.type = @"device";
                model.squinted = YES;
                model.code = code;
                model.path = newProject.path;
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
                model.path = newProject.path;
                model.sha = [self getValueFrom:deployment withKey:@"sha"];
                model.updated = [self getValueFrom:deployment withKey:@"updated_at"];
                if (model.updated == nil) model.updated = [self getValueFrom:deployment withKey:@"created_at"];
                [newDevicegroup.models addObject:model];
            }
        }
    }

    // Decrement the tally of downloadable device groups to see if we've got them all yet

    --newProject.count;

    if (newProject.count <= 0)
    {
        // We have now acquired all the device groups models, so we can process everything

        newProject.aid = ide.isLoggedIn ? ide.currentAccount : @"";

        if (newProject.devicegroups.count > 0)
        {
            if (devicesArray.count > 0)
            {
                // If we have a device list, run through it and see which devices, if any,
                // have been assigned to the current device group

                for (NSDictionary *device in devicesArray)
                {
                    NSDictionary *relationships = [device objectForKey:@"relationships"];
                    NSDictionary *devgrp = [relationships objectForKey:@"devicegroup"];
                    NSString *deviceid = [devgrp objectForKey:@"id"];

                    // Just check for a nil device group ID - to avoid unassigned devices - and
                    // then record the device ID in the device group record if it belongs there

                    if (deviceid != nil && [deviceid compare:currentDevicegroup.did] == NSOrderedSame) [currentDevicegroup.devices addObject:deviceid];
                }

                // See if the current device group has any devices, and select one

                [self selectDevice];
            }
        }

        // Save the project

        [self productToProjectStageFour:newProject];
        [self setToolbar];
    }
}



- (void)productToProjectStageFour:(Project *)project
{
    // This method is called by productToProjectStageThree: in order to
    // save the downloaded project

    project.haschanged = YES;

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
}



- (void)createProductStageTwo:(NSNotification *)note
{
    // This is called by the BuildAPIAccess instance in response to a new product being created
    // This is a result of the user creating a new project and asking for a product to be made too.

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];
    Project *project = [so objectForKey:@"project"];
    data = [data objectForKey:@"data"];

    // Perform appropriate action flows

    if (action != nil)
    {
        // Link the project to the new product

        project.pid = [data objectForKey:@"id"];
        project.cid = [data valueForKeyPath:@"relationships.creator.id"];

        if ([action compare:@"newproject"] == NSOrderedSame)
        {
            // This is the action flow for a new project, new product

            selectedProduct = nil;

            [self writeStringToLog:[NSString stringWithFormat:@"Created product for project \"%@\".", project.name] :YES];
            [self writeStringToLog:@"Refreshing your list of products..." :YES];

            NSDictionary *dict = @{ @"action" : @"newproduct",
                                    @"productid" : project.pid };

            [ide getProducts:dict];

            // -> Pick up the async outcomce in 'listProducts:'

            // Add the new project to the project menu. We've already checked for a name clash,
            // so we needn't care about the return value.

            //BOOL result = [self addProjectMenuItem:project.name :project];

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

            if (project.devicegroups.count > 0)
            {
                project.count = project.devicegroups.count;

                for (Devicegroup *devicegroup in project.devicegroups)
                {
                    [self writeStringToLog:[NSString stringWithFormat:@"Uploading device group \"%@\"...", devicegroup.name] :YES];

                    NSDictionary *dict = @{ @"action" : @"uploadproject",
                                            @"project" : project,
                                            @"devicegroup" : devicegroup };

                    NSDictionary *details = @{ @"name" : devicegroup.name,
                                               @"description" : devicegroup.description,
                                               @"productid" : project.pid,
                                               @"type" : devicegroup.type };

                    [ide createDevicegroup:details :dict];
                }
            }

            // Pick up the action at **createDevicegroupStageTwo:**
        }
    }
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createProductStageTwo:)"] :YES];
    }
}



- (void)deleteProductStageTwo:(NSMutableDictionary *)productToDelete
{
    // We come here diretctly after checking all of a product's device groups to see if they can be deleted
    // It's here that we action the deletion of each device group

    NSArray *devicegroups = [productToDelete objectForKey:@"devicegroups"];
    NSDictionary *product = [productToDelete objectForKey:@"product"];

    // At this point we can be pretty sure we can delete the product and any device groups it has,
    // so we can break its link with any current projects. Run through the open projects and clear
    // their PID.

    // TODO should we also clear the account ID, since the link to the account is the product, and
    //      that has now gone? With no account ID, the project is free to be uploaded to a new acct

    if (projectArray.count > 0)
    {
        for (Project *project in projectArray)
        {
            NSString *pid = [self getValueFrom:product withKey:@"id"];

            if ([pid compare:project.pid] == NSOrderedSame)
            {
                project.pid = @"";
                project.haschanged = YES;
                if (project == currentProject) [saveLight needSave:YES];

                // NOTE Project Inspector will be updated later, in 'deleteProductStageThree:'
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
            NSDictionary *source = @{ @"action" : @"deleteproduct",
                                      @"devicegroup" : devicegroup,
                                      @"product" : productToDelete };

            [ide deleteDevicegroup:[devicegroup objectForKey:@"id"] :source];
        }

        // Pick up the action in **deleteDevicegroupStageTwo:**
    }
    else
    {
        // There are no device groups to delete so just delete the product itself

        [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\"...", [self getValueFrom:product withKey:@"name"]] :YES];

        NSDictionary *source = @{ @"action" : @"deleteproduct",
                                  @"product" : productToDelete };

        [ide deleteProduct:[product objectForKey:@"id"] :source];

        // Pick this up at **deleteProductStageThree:**
    }
}



- (void)deleteProductStageThree:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess instance AFTER deleting a product

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSDictionary *productToDelete = [source objectForKey:@"product"];
    NSDictionary *product = [productToDelete objectForKey:@"product"];

    // Clear the current product if it's still the one we're deleting

    if (selectedProduct == product) selectedProduct = nil;

    // Inform the user

    [self writeStringToLog:[NSString stringWithFormat:@"Deleted product \"%@\".", [self getValueFrom:product withKey:@"name"]] :YES];
    [self writeStringToLog:@"Refreshing your list of products..." :YES];

    // Go and get an updated list of products

    NSDictionary *dict = @{ @"action" : @"getproducts" };

    [ide getProducts:dict];

    // Pick up the action at **listProducts:**
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

                    // Action continues in parallel at updateCodeStageTwo:
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
        else if ([action compare:@"resetprodtarget"] == NSOrderedSame)
        {
            // Target changed, so report it

            [self updateDevicegroup:devicegroup];

            Devicegroup *tdg = [source objectForKey:@"target"];

            [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" now has a new target device group: \"%@\".", devicegroup.name, tdg.name] :YES];
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

        [self updateDevicegroup:devicegroup];

        Project *project = [self getParentProject:devicegroup];

        if (project != nil)
        {
            project.haschanged = YES;

            [saveLight needSave:YES];
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
            NSMutableDictionary *productToDelete = [source objectForKey:@"product"];
            NSNumber *number = [productToDelete objectForKey:@"count"];
            NSArray *devicegroups = [productToDelete objectForKey:@"devicegroups"];
            NSDictionary *product = [productToDelete objectForKey:@"product"];
            NSInteger count = number.integerValue - 1;

            [self writeStringToLog:[NSString stringWithFormat:@"Deleting product \"%@\" - device group \"%@\" deleted (%li of %li).", [self getValueFrom:product withKey:@"name"], [self getValueFrom:devicegroup withKey:@"name"], (long)(devicegroups.count - count), (long)devicegroups.count] :YES];

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



- (void)updateCodeStageTwo:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER uploading code

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *devicegroup = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];

    if (action != nil)
    {
        if ([action compare:@"updatedevicegroup"] == NSOrderedSame)
        {
            // We're updating the devicegroup with info from the server

            Devicegroup *dg = [source objectForKey:@"devicegroup"];
            dg.data = [NSMutableDictionary dictionaryWithDictionary:devicegroup];

            NSDictionary *dict = [self getValueFrom:dg.data withKey:@"min_supported_deployment"];
            dg.mdid = [dict objectForKey:@"id"];
            dict = [self getValueFrom:dg.data withKey:@"current_deployment"];
            dg.cdid = [dict objectForKey:@"id"];
        }
        else if ([action compare:@"updatecode"] == NSOrderedSame)
        {
            // We're updating the devicegroup's code

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
    else
    {
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (updateCodeStageTwo:)"] :YES];
    }
}



- (void)listDevices:(NSNotification *)note
{
    // This method should ONLY be called by the BuildAPIAccess object instance AFTER loading a list of devices
    // This list may have been request by many methods — check the source object's 'action' key to find out
    // which flow we need to run here

    NSDictionary *data = (NSDictionary *)note.object;
    NSArray *devices = [data objectForKey:@"data"];
    NSDictionary *so = [data objectForKey:@"object"];
    NSString *action = [so objectForKey:@"action"];

    if (action != nil)
    {
        if ([action compare:@"deleteproduct"] == NSOrderedSame)
        {
            // Perform the delete product flow. All we are doing here is checking the
            // number devices being provided for one of a product's device groups so we
            // can decide whether we need to halt the deletion process, ie. the presence
            // of assigned devices means the devicegroup deletion will fail

            NSMutableDictionary *productToDelete = [so objectForKey:@"product"];
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

                NSDictionary *devicegroup = [so objectForKey:@"devicegroup"];

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
            [self listBlessedDevices:devices :[so objectForKey:@"devicegroup"]];
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

                [devicesArray addObject:newDevice];

                NSDictionary *dict = @{ @"action" : @"getdevice",
                                        @"device" : newDevice };

                [ide getDevice:[newDevice objectForKey:@"id"] :dict];

                // Pick up the action at updateDevice:
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
        // NOTE Because we have just updated the device list, we need to refresh it with refreshDevicesPopup and refreshDeviceMenu
        //      rather than just change the popup's selection

        [self refreshDevicesPopup];
        [self refreshDeviceMenu];
        [self refreshDevicegroupMenu];
        [self setToolbar];

        // Update the Inspector

        // iwvc.devices = devicesArray;
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
        [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" contains no test blessed devices.", devicegroup.name] :YES];
        return;
    }

    __block NSString *titleString = [NSString stringWithFormat:@"Device group \"%@\" test blessed devices:", devicegroup.name];
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
                if (projectArray.count > 0) [self refreshDevicesMenus];

                if (ide.numberOfConnections < 1)
                {
                    // Only hide the connection indicator if 'ide' has no live connections

                    [connectionIndicator stopAnimation:self];
                    connectionIndicator.hidden = YES;
                }

            }

            return;
        }

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
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
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

                // And select the device group

                currentDevicegroup = devicegroup;
                currentProject.devicegroupIndex = [currentProject.devicegroups indexOfObject:currentDevicegroup];

                // Update the UI

                [self setToolbar];
                [self refreshDevicegroupMenu];
                [self refreshMainDevicegroupsMenu];

                // Update the inspector, if required

                if (iwvc.tabIndex == kInspectorTabProject) iwvc.project = currentProject;
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
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (createDevicegroupStageTwo:)"] :YES];
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
        [self writeErrorToLog:[[self getErrorMessage:kErrorMessageMalformedOperation] stringByAppendingString:@" (reassigned:)"] :YES];
    }
}



- (void)renameDeviceStageTwo:(NSNotification *)note
{
    // Called ONLY in response to a notification from BuildAPIAccess that a device has been renamed

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];

    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" renamed \"%@\".", [source objectForKey:@"old"], [source objectForKey:@"new"]] :YES];

    selectedDevice = nil;
    iwvc.device = nil;

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

    if (selectedDevice == device)
    {
        selectedDevice = nil;
        iwvc.device = nil;
    }

    // Now refresh the devices list

    [self updateDevicesStatus:nil];
}



- (void)uploadCodeStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a deployment has been created

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *response = [data objectForKey:@"data"];
    NSDictionary *source = [data objectForKey:@"object"];
    Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
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

    if (action != nil)
    {
        if ([action compare:@"uploadproject"] == NSOrderedSame)
        {
            // Decrement the count of uploaded deployments

            --project.count;

            if (project.count == 0)
            {
                // All done!

                NSDictionary *dict = @{ @"action" : @"getproducts" };

                [ide getProducts:dict];
                [self writeStringToLog:[NSString stringWithFormat:@"Project \"%@\" uploaded to impCloud. Please save your project file.", project.name] :YES];
                [self writeStringToLog:@"Refreshing product list." :YES];
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



- (void)setMinimumDeploymentStageTwo:(NSNotification *)note
{
    // Called in response to a notification from BuildAPIAccess that a minimum deployment has been set

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



- (void)loggedIn:(NSNotification *)note
{
    // BuildAPIAccess has signalled login success

    // First, get the user's account ID
    
    NSDictionary *dict = @{ @"action" : @"loggedin" };
    
    [ide getMyAccount:dict];

    // Action continues asynchronously at **gotMyAccount:**
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

    if (switchAccountFlag)
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
    switchAccountFlag = NO;
    otpLoginToken = nil;

    // Inform the user he or she is logged in - and to which cloud

    [self writeStringToLog:[NSString stringWithFormat:@"You now are logged in to the %@impCloud.", cloudName] :YES];

    // Check for any post-login actions that need to be performed

    // User may want the Product lists loaded on login

    // NOTE From 125, this check takes place in 'inloggedInStageTwo:' which indirectly requires a correct account ID

    // User wants to update devices' status periodically, or the Device lists loaded on login

    if ([defaults boolForKey:@"com.bps.squinter.updatedevs"])
    {
        [self keepDevicesStatusUpdated:nil];
    }
    else if ([defaults boolForKey:@"com.bps.squinter.autoloaddevlists"])
    {
        [self updateDevicesStatus:nil];
    }
}



- (void)loggedInStageTwo
{
    // User wants the Product lists loaded on login
    
    if ([defaults boolForKey:@"com.bps.squinter.autoloadlists"]) [self getProductsFromServer:nil];
}



- (void)loginRejected:(NSNotification *)note
{
    // BuildAPIAccess has notified the host that a login attempt has been rejected

    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = @"Sorry, your impCentral credentials have been rejected";
    alert.informativeText = @"Please check your account details and then try to log in again.";
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:_window completionHandler:nil];

    // Register we are no longer trying to log in

    isLoggingIn = NO;
    credsFlag = YES;
    switchAccountFlag = NO;
    otpLoginToken = nil;
    loginMode = kLoginModeNone;
}



- (void)loggedOut:(NSNotification *)note
{
    // BuildAPIAccess has notified us that we have been logged out

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
    //switchAccountMenuItem.enabled = YES;
    switchAccountMenuItem.title = @"Log in to a Different Account...";
    loginMode = kLoginModeNone;
}



#pragma mark - Log and Logging Methods


- (void)listCommits:(NSNotification *)note
{
    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *source = [data objectForKey:@"object"];
    NSString *action = [source objectForKey:@"action"];

    __block Devicegroup *devicegroup = [source objectForKey:@"devicegroup"];
    __block NSMutableArray *deployments = [data objectForKey:@"data"];

    if (action != nil && [action compare:@"getcommits"] == NSOrderedSame)
    {
        cwvc.commits = deployments;
        return;
    }

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

            [self performSelectorOnMainThread:@selector(printInfoInLog:) withObject:lines waitUntilDone:YES];

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



- (void)logLogs:(NSString *)logLine
{
    // Write a line of a list of log entries to the main window's log view

    [self writeStringToLog:logLine :NO];
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
    // Show a post-print message

    if (success) [self writeStringToLog:@"Log contents sent to print system." :YES];
}



- (void)loggingStarted:(NSNotification *)note
{
    // We come here via a notification from BuildAPIAccess that a device has been added to the log stream

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
    
    // Add the device to the list of logging devices
    
    if (loggedDevices == nil) loggedDevices = [[NSMutableArray alloc] init];
    
    if (loggedDevices.count < kMaxLogStreamDevices)
    {
        [loggedDevices addObject:dvid];
    }
    else
    {
        NSInteger index = -1;
        
        for (NSInteger i = 0 ; i < loggedDevices.count ; i++)
        {
            NSString *advid = [loggedDevices objectAtIndex:i];
            
            if ([advid compare:@"FREE"] == NSOrderedSame)
            {
                index = i;
                break;
            }
        }
        
        if (index != -1)
        {
            [loggedDevices replaceObjectAtIndex:index withObject:dvid];
        }
        else
        {
            NSLog(@"loggedDevices index error in loggingStarted:");
        }
    }
    
    // Inform the user

    [self writeStringToLog:[NSString stringWithFormat:@"Device \"%@\" added to log stream", [self getValueFrom:device withKey:@"name"]] :YES];

    // Update the UI: add logging marks to menus, colour to the toolbar item,
    // and set the menu item's text and state

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
    // and set the menu item's text and state

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
        
        /*
        // Calculate colour table index

        BOOL done = NO;

        while (done == NO)
        {
            if (index > colors.count - 1)
            {
                index = index - colors.count;
            }
            else
            {
                done = YES;
            }
        }
         */
        
        NSRange range = [logItem rangeOfString:type];
        NSString *message = [logItem substringFromIndex:(range.location + type.length + 1)];

        if (ide.numberOfLogStreams > 1)
        {
            NSString *subspacer = [@"                                      " substringToIndex:logPaddingLength - device.length];
            log = [NSString stringWithFormat:@"\"%@\"%@: %@ %@%@", device, subspacer, stype, spacer, message];
            //values = [NSArray arrayWithObjects:[colors objectAtIndex:index], logFont, nil];
        }
        else
        {
            log = [NSString stringWithFormat:@"\"%@\": %@ %@%@", device, stype, spacer, message];
            //values = [NSArray arrayWithObjects:[colors objectAtIndex:index], logFont, nil];
        }

        log = [timestamp stringByAppendingFormat:@" %@", log];
        logColour = [colors objectAtIndex:index];

        //NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
        //NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        //NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:log attributes:attributes];

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



- (IBAction)showProjectInfo:(id)sender
{
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

    [self printInfoInLog:lines];
}



- (IBAction)showDeviceGroupInfo:(id)sender
{
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
        [lines addObject:[NSString stringWithFormat:@"%@Minimum Supported Deployment Set (ID: %@)", spaces, devicegroup.mdid]];
    }

    [lines addObject:[NSString stringWithFormat:@"%@Device group type: %@", spaces, [self convertDevicegroupType:devicegroup.type :NO]]];

    if (devicegroup.data != nil)
    {
        NSDictionary *aTarget = [self getValueFrom:devicegroup.data withKey:@"production_target"];

        if (aTarget != nil)
        {
            NSString *tid = [aTarget objectForKey:@"id"];

            for (Devicegroup *dg in currentProject.devicegroups)
            {
                if ([dg.did compare:tid] == NSOrderedSame)
                {
                    [lines addObject:[NSString stringWithFormat:@"%@Target Device Group: %@", spaces, dg.name]];
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
    // Runs through the device's record in 'deviceArray' and displays
    // key information in the main window log view

    if (selectedDevice == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevice] :YES];
        return;
    }

    NSMutableArray *lines = [[NSMutableArray alloc] init];

    [lines addObject:@"Device Information"];
    [lines addObject:[NSString stringWithFormat:@"     Name: %@", [self getValueFrom:selectedDevice withKey:@"name"]]];
    [lines addObject:[NSString stringWithFormat:@"       ID: %@", [selectedDevice objectForKey:@"id"]]];
    [lines addObject:[NSString stringWithFormat:@"     Type: %@", [self getValueFrom:selectedDevice withKey:@"imp_type"]]];

    NSString *version = [self getValueFrom:selectedDevice withKey:@"swversion"];
    NSArray *parts = [version componentsSeparatedByString:@" - "];
    parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"-"];
    if (version != nil ) [lines addObject:[NSString stringWithFormat:@"    impOS: %@", [parts objectAtIndex:1]]];

    NSNumber *number = [self getValueFrom:selectedDevice withKey:@"free_memory"];
    if (number != nil) [lines addObject:[NSString stringWithFormat:@" Free RAM: %@KB", number]];

    [lines addObject:@"\nNetwork Information"];
    NSString *mac = [self getValueFrom:selectedDevice withKey:@"mac_address"];
    mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
    [lines addObject:[NSString stringWithFormat:@"      MAC: %@", mac]];

    NSNumber *boolean = [self getValueFrom:selectedDevice withKey:@"device_online"];
    NSString *string = (boolean.boolValue) ? @"online" : @"offline";

    if ([string compare:@"online"] == NSOrderedSame) [lines addObject:[NSString stringWithFormat:@"       IP: %@", [self getValueFrom:selectedDevice withKey:@"ip_address"]]];

    [lines addObject:[NSString stringWithFormat:@"    State: %@", string]];

    [lines addObject:@"\nAgent Information"];

    boolean = [self getValueFrom:selectedDevice withKey:@"agent_running"];
    string = (boolean.boolValue) ? @"online" : @"offline";
    [lines addObject:[NSString stringWithFormat:@"    State: %@", string]];

    if (boolean.boolValue)
    {
        [lines addObject:[NSString stringWithFormat:@"      URL: https://agent.electricimp.com/%@", [self getValueFrom:selectedDevice withKey:@"agent_id"]]];
    }

    [lines addObject:@"\nBlinkUp Information"];
    NSString *date = [self getValueFrom:selectedDevice withKey:@"last_enrolled_at"];
    [lines addObject:[NSString stringWithFormat:@" Enrolled: %@", (date != nil ? date : @"Unknown")]];
    NSString *plan = [self getValueFrom:selectedDevice withKey:@"plan_id"];
    if (plan != nil) [lines addObject:[NSString stringWithFormat:@"  Plan ID: %@", plan]];

    [lines addObject:@"\nDevice Group Information"];
    NSString *dgid = [selectedDevice valueForKeyPath:@"relationships.devicegroup.id"];

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

    // Add the assembled lines to the log view and re-check for URLs

    [self printInfoInLog:lines];
    [self parseLog];
}



- (IBAction)logDeviceCode:(id)sender
{
    // Dumps compiled device source code to the main window log view

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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
            //[self writeStringToLog:@" " :NO];
            [extraOpQueue addOperationWithBlock:^{[self listCode:model.code :-1 :-1 :-1 :-1];}];
            break;
        }
    }

    if (!done) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no device code.", currentDevicegroup.name] :YES];
}



- (IBAction)logAgentCode:(id)sender
{
    // Dumps compiled agent source code to the main window log view

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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
            //[self writeStringToLog:@" " :NO];
            [extraOpQueue addOperationWithBlock:^{[self listCode:model.code :-1 :-1 :-1 :-1];}];
            break;
        }
    }

    if (!done) [self writeStringToLog:[NSString stringWithFormat:@"Device group \"%@\" currently has no agent code.", currentDevicegroup.name] :YES];
}



- (IBAction)clearLog:(id)sender
{
    // Clear the main window log view of all text

    /*
    NSNumber *index = [defaults objectForKey:@"com.bps.squinter.fontNameIndex"];
    NSString *fontName = [self getFontName:index.integerValue];
    index = [defaults objectForKey:@"com.bps.squinter.fontSizeIndex"];

    NSArray *values = [NSArray arrayWithObjects:textColour, nil];
    NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];

    [logTextView setTypingAttributes:attributes];
    logTextView.font = [self setLogViewFont:fontName :index.integerValue :false];

    [logTextView setString:@""];
    */

    NSTextStorage *textStorage = logTextView.textStorage;
    NSArray *values = [NSArray arrayWithObjects:textColour, logFont, nil];
    NSArray *keys = [NSArray arrayWithObjects:NSForegroundColorAttributeName, NSFontAttributeName, nil];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    NSAttributedString *emptyString = [[NSAttributedString alloc] initWithString:@"" attributes:attributes];

    [textStorage beginEditing];
    [textStorage setAttributedString:emptyString];
    [textStorage endEditing];
}



- (void)printInfoInLog:(NSMutableArray *)lines
{
    // This method is used to present a series of lines by prefixing and suffixing
    // them with a line of dashes that is caclulated to be as long as the longest
    // line in the list passed into 'lines'

    // Determine the number of characters in the longest line...

    // NSInteger dashCount = 0;

    // for (NSString *string in lines) dashCount = string.length > dashCount ? string.length : dashCount;

    // ...then build a string of dashes that long

    // NSString *dashes = [@"" stringByPaddingToLength:dashCount withString:@"-" startingAtIndex:0];

    // Write out the dashes

    // [self writeNoteToLog:dashes :textColour :NO];

    // Write out the lines themselves

    for (NSString *string in lines) [self writeNoteToLog:string :textColour :NO];

    // Write out the dashes

    // [self writeNoteToLog:dashes :textColour :NO];
}



- (void)writeStringToLog:(NSString *)string :(BOOL)addTimestamp
{
    // Write 'string' to the main window log view as a normal line (ie. of colour 'textColour')

    [self writeNoteToLog:[self recodeLogTags:string] :textColour :addTimestamp];
}



- (void)writeErrorToLog:(NSString *)string :(BOOL)addTimestamp
{
    // Write 'string' to the main window log view as an error (ie. in red)

    [self writeNoteToLog:string :[NSColor redColor] :addTimestamp];
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
        /*
        logTextView.editable = YES;

        // Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

        [logTextView setSelectedRange:NSMakeRange(logTextView.string.length,0)];

        if (addTimestamp)
        {
            NSDictionary *attributes = [string fontAttributesInRange:NSMakeRange(0, string.length)];
            NSString *date = [def stringFromDate:[NSDate date]];
            date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];

            [logTextView insertText:[[NSAttributedString alloc] initWithString:date attributes:attributes]
                   replacementRange:NSMakeRange(logTextView.string.length, 0)];

            [logTextView insertText:@" "
                   replacementRange:NSMakeRange(logTextView.string.length, 0)];
        }

        [logTextView insertText:string
               replacementRange:NSMakeRange(logTextView.string.length, 0)];

        [logTextView insertText:@"\n"
               replacementRange:NSMakeRange(logTextView.string.length, 0)];

		logTextView.editable = NO;
		*/

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



- (void)showCodeErrors:(NSNotification *)note
{
    // This method is triggered by a notification from BuildAPIAccess signalling
    // that there are errors in uploaded code - which this method displays

    NSDictionary *data = (NSDictionary *)note.object;
    NSDictionary *object = [data objectForKey:@"object"];
    Devicegroup *devicegroup = [object objectForKey:@"devicegroup"];
    NSMutableArray *errors = [data objectForKey:@"data"];

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
    // Write the string assembled in listCode: to the main window log view
    // Use 'writeNoteToLog:' to avoid the message status parsing that 'writeStringToLog:' does

    [self writeNoteToLog:listString :textColour :NO];
    [self writeNoteToLog:@" " :textColour :NO];
}


/*
- (void)writeStreamToLog:(NSAttributedString *)string
{
    // Write a decoded log stream event to the main window log view

    logTextView.editable = YES;

    // Make sure the insertion point is at the end of the text (it may not be if the user has clicked on the log)

    [logTextView setSelectedRange:NSMakeRange(logTextView.string.length, 0)];

    if (string != nil && string.length > 0)
    {
        [logTextView insertText:string
               replacementRange:NSMakeRange(logTextView.string.length, 0)];

        [logTextView insertText:@"\n"
               replacementRange:NSMakeRange(logTextView.string.length, 0)];
    }

    logTextView.editable = NO;
}
*/


- (void)displayError:(NSNotification *)note;
{
    // Relay a BuildAPIAccess error

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

        NSString *errString = (errorCode == kErrorNetworkError) ? @"[NETWORK ERROR] " : @"[ERROR] ";

        [self writeErrorToLog:[errString stringByAppendingString:errorMessage] :YES];

        // Just in case we are attemmpting to log stream from the current device

        streamLogsItem.state = 0;
        [squinterToolbar validateVisibleItems];
    }
}



#pragma mark - Squint Methods


- (IBAction)squint:(id)sender
{
    // This method is a hangover from a previous version.
    // Now it simply calls the version which replaces it.

    [self compile:currentDevicegroup :NO];
}



#pragma mark - External Editor Methods


- (IBAction)externalOpen:(id)sender
{
    // Open the original source code files an external editor

    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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
    // Open the supplied model's source code in the user's preferred text editor

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



- (void)externalOpenItem:(id)sender :(BOOL)isLibrary
{
    // Opens a file or library from the relevant 'Device Groups' menu submenu

    NSMenuItem *item = (NSMenuItem *)sender;
    File *file = item.representedObject;

    if (file.hasMoved)
    {
        [self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] %@ \"%@\" can't be found it is known location.", (isLibrary ? @"Library" : @"File"), file.filename] :YES];

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
    // Opens all the files or libraries from the relevant 'Device Groups' menu submenu

    for (Model *model in currentDevicegroup.models)
    {
        if (model.files.count > 0)
        {
            NSMutableArray *list = areLibraries ? model.libraries : model.files;

            for (File *file in list)
            {
                if (file.hasMoved)
                {
                    [self writeErrorToLog:[NSString stringWithFormat:@"[ERROR] %@ \"%@\" can't be found it is known location.", (areLibraries ? @"Library" : @"File"), model.filename] :YES];
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



- (IBAction)externalOpenAll:(id)sender
{
    // Open all of the source code files associated with the current device group:
    // agent and device code, and all of their included libraries and files

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



- (void)launchLibsPage
{
    // Open the Electric Imp libraries page on the Dev Center in the default Web browser

    [nswsw openURL:[NSURL URLWithString:@"https://developer.electricimp.com/codelibraries/"]];
}



- (IBAction)launchReleaseNotesPage:(id)sender
{
    // Open the Squinter home page as the Release Notes section

    [nswsw openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html#rn"]];
}



#pragma mark - UI Update Methods
#pragma mark Projects Menu

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
            if (name.length == 0) name = [sharer objectForKey:@"id"];

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



#pragma mark Device Groups Menu


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
        [self refreshDevicegroupByType:@"development_devicegroup"];
        [self refreshDevicegroupByType:@"pre_production_devicegroup"];
        [self refreshDevicegroupByType:@"pre_factoryfixture_devicegroup"];
        [self refreshDevicegroupByType:@"production_devicegroup"];
        [self refreshDevicegroupByType:@"factoryfixture_devicegroup"];

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
        Project *pr = [projectArray objectAtIndex:item.tag];
        item.title = [NSString stringWithFormat:@"%@/%@", pr.name, currentDevicegroup.name];
    }

    // Now go and build the assigned devices submenus
    // This SHOULD be only place we call this but may not be
    // (other than updateDevice:)

    [self refreshDevicesMenus];

    iwvc.project = currentProject;
}



- (void)refreshDevicegroupByType:(NSString *)type
{
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



- (void)refreshMainDevicegroupsMenu
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

    showDeviceGroupInfoMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    showModelFilesFinderMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
    restartDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    conRestartDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    setMinimumMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    setProductionTargetMenuItem.enabled = (currentDevicegroup != nil && [currentDevicegroup.type containsString:@"factoryfixture"]) ? YES : NO;
    listCommitsMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    deleteDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    renameDeviceGroupMenuItem.enabled = (currentDevicegroup != nil) ? YES : NO;
    compileMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
    uploadMenuItem.enabled = (currentDevicegroup != nil && compiled == YES) ? YES : NO;
    uploadExtraMenuItem.enabled = (currentDevicegroup != nil && compiled == YES) ? YES : NO;
    checkImpLibrariesMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
    removeFilesMenuItem.enabled = (currentDevicegroup != nil && gotFiles == YES) ? YES : NO;
    listTestBlessedDevicesMenuItem.enabled = (currentDevicegroup != nil && [currentDevicegroup.type containsString:@"pre_production"]) ? YES : NO;

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



- (NSImage *)menuImage:(NSMutableDictionary *)device
{
    // Sets a device's menu and/or popup icon according to the device's connection status

    NSString *imageNameString = @"";
    NSNumber *boolean = [self getValueFrom:device withKey:@"device_online"];
    NSString *dvid = [self getValueFrom:device withKey:@"id"];

    imageNameString = boolean.boolValue ? @"online" : @"offline";
    if ([ide isDeviceLogging:dvid]) imageNameString = [imageNameString stringByAppendingString:@"_logging"];

    return [NSImage imageNamed:imageNameString];
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
        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Agent Code" : @"Compiled Agent Code";

        [self addItemToFileMenu:m :NO];

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

        m = (currentDevicegroup.squinted == 0) ? @"Uncompiled Device Code" : @"Compiled Device Code";

        [self addItemToFileMenu:m :NO];

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
    for (File *file in models)
    {
        [self addFileToMenu:file :YES];
    }
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
    // Called to set the state of the main Device Menu
    // The sub-menu 'Unassigned Devices' is set by refreshDevicesPopup:

    // Title menus according to whether there is a currently selected device or not

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
        streamLogsMenuItem.title = flag ? @"Stop Log Streaming" : @"Start Log Streaming";
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



#pragma mark View Menu


- (void)refreshViewMenu
{
    // The View menu has two items. These are only actionable if there is a selected device group
    // and that device group's code has been compiled

    logDeviceCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kDeviceCodeSquinted) ? YES : NO;
    logAgentCodeMenuItem.enabled = (currentDevicegroup != nil && currentDevicegroup.squinted & kAgentCodeSquinted) ? YES : NO;
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



#pragma mark Files Menu


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

    // Enable or disable device-specific toolbar items

    BOOL flag = [ide isDeviceLogging:[selectedDevice objectForKey:@"id"]];
    streamLogsItem.enabled = (selectedDevice != nil) ? YES : NO;
    streamLogsItem.state = flag ? kStreamToolbarItemStateOn : kStreamToolbarItemStateOff;

    // Enabled or disable the login item

    loginAndOutItem.isLoggedIn = ide.isLoggedIn;

    // Validate items

    [squinterToolbar validateVisibleItems];
}



#pragma mark - About Sheet Methods


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
    [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html"]];
}



- (IBAction)closeAboutSheet:(id)sender
{
    [_window endSheet:aboutSheet];
}



#pragma mark - Help Menu Methods


- (IBAction)showAuthor:(id)sender
{
    if (sender == author01) [nswsw openURL:[NSURL URLWithString:@"https://github.com/carlbrown/PDKeychainBindingsController"]];
    if (sender == author02) [nswsw openURL:[NSURL URLWithString:@"https://github.com/bdkjones/VDKQueue"]];
    if (sender == author03) [nswsw openURL:[NSURL URLWithString:@"https://github.com/uliwitness/UliKit"]];
    if (sender == author04) [nswsw openURL:[NSURL URLWithString:@"https://developer.electricimp.com/"]];
    if (sender == author05) [nswsw openURL:[NSURL URLWithString:@"https://github.com/adobe-fonts/source-code-pro"]];
    if (sender == author06) [nswsw openURL:[NSURL URLWithString:@"https://github.com/sparkle-project/Sparkle/blob/master/LICENSE"]];
}



#pragma mark - Preferences Sheet Methods


- (IBAction)showPrefs:(id)sender
{
    // The user has invoked the Preferences panel, so populate the panel's settings
    // with the current saved defaults

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

/*
    r = [[defaults objectForKey:@"com.bps.squinter.dev1.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.dev1.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.dev1.green"] floatValue];
    dev1ColorWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];;
    [dev1ColorWell setAction:@selector(showPanelForDev1)];

    r = [[defaults objectForKey:@"com.bps.squinter.dev2.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.dev2.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.dev2.green"] floatValue];
    dev2ColorWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];;
    [dev2ColorWell setAction:@selector(showPanelForDev2)];

    r = [[defaults objectForKey:@"com.bps.squinter.dev3.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.dev3.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.dev3.green"] floatValue];
    dev3ColorWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];;
    [dev3ColorWell setAction:@selector(showPanelForDev3)];

    r = [[defaults objectForKey:@"com.bps.squinter.dev4.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.dev4.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.dev4.green"] floatValue];
    dev4ColorWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];;
    [dev4ColorWell setAction:@selector(showPanelForDev4)];

    r = [[defaults objectForKey:@"com.bps.squinter.dev5.red"] floatValue];
    b = [[defaults objectForKey:@"com.bps.squinter.dev5.blue"] floatValue];
    g = [[defaults objectForKey:@"com.bps.squinter.dev5.green"] floatValue];
    dev5ColorWell.color = [NSColor colorWithRed:r green:g blue:b alpha:1.0];;
    [dev5ColorWell setAction:@selector(showPanelForDev5)];
*/

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
    showInspectorCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.show.inspector"]) ? NSOnState : NSOffState;
    updateDevicesCheckbox.state = ([defaults boolForKey:@"com.bps.squinter.updatedevs"]) ? NSOnState : NSOffState;

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



- (IBAction)selectFontName:(id)sender
{
    // Disable the 'show bold' checkbox for fonts not available in bold

    NSPopUpButton *list = (NSPopUpButton *)sender;
    NSInteger index = list.indexOfSelectedItem;
    boldTestCheckbox.enabled = index < 3 ? YES : NO;
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
    [defaults setBool:(showInspectorCheckbox.state == NSOnState) forKey:@"com.bps.squinter.show.inspector"];

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

/*
    r = (float)dev1ColorWell.color.redComponent;
    b = (float)dev1ColorWell.color.blueComponent;
    g = (float)dev1ColorWell.color.greenComponent;

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.dev1.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.dev1.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.dev1.blue"];

    r = (float)dev2ColorWell.color.redComponent;
    b = (float)dev2ColorWell.color.blueComponent;
    g = (float)dev2ColorWell.color.greenComponent;

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.dev2.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.dev2.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.dev2.blue"];

    r = (float)dev3ColorWell.color.redComponent;
    b = (float)dev3ColorWell.color.blueComponent;
    g = (float)dev3ColorWell.color.greenComponent;

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.dev3.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.dev3.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.dev3.blue"];

    r = (float)dev4ColorWell.color.redComponent;
    b = (float)dev4ColorWell.color.blueComponent;
    g = (float)dev4ColorWell.color.greenComponent;

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.dev4.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.dev4.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.dev4.blue"];

    r = (float)dev5ColorWell.color.redComponent;
    b = (float)dev5ColorWell.color.blueComponent;
    g = (float)dev5ColorWell.color.greenComponent;

    [defaults setObject:[NSNumber numberWithFloat:r] forKey:@"com.bps.squinter.dev5.red"];
    [defaults setObject:[NSNumber numberWithFloat:g] forKey:@"com.bps.squinter.dev5.green"];
    [defaults setObject:[NSNumber numberWithFloat:b] forKey:@"com.bps.squinter.dev5.blue"];
*/

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

    // Start or stop auto-updating the device list
    if ([defaults boolForKey:@"com.bps.squinter.updatedevs"] != updateDevicesCheckbox.state == NSOnState)
    {
        [defaults setBool:(updateDevicesCheckbox.state == NSOnState) forKey:@"com.bps.squinter.updatedevs"];
        [self keepDevicesStatusUpdated:nil];
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



- (IBAction)getHelpPrefs:(id)sender
{
    [nswsw openURL:[NSURL URLWithString:@"https://smittytone.github.io/squinter/index.html#configuring"]];
}



#pragma mark - Report a Problem Sheet Methods

- (IBAction)showFeedbackSheet:(id)sender
{
    // Show the sheet

    feedbackField.stringValue = @"";

    if (sender == feedbackButton)
    {
        [self closeAboutSheet:sender];
    }

    [_window beginSheet:feedbackSheet completionHandler:nil];
}



- (IBAction)cancelFeedbackSheet:(id)sender
{
    [_window endSheet:feedbackSheet];
}



- (IBAction)sendFeedback:(id)sender
{
    NSString *feedback = feedbackField.stringValue;

    [_window endSheet:feedbackSheet];

    if (feedback.length == 0) return;

    // Send the string etc.

    NSError *error = nil;

    NSOperatingSystemVersion sysVer = [[NSProcessInfo processInfo] operatingSystemVersion];
    NSString *userAgent = [NSString stringWithFormat:@"%@/%@.%@ (macOS %li.%li.%li)", [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleExecutable"], [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"],
                 [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"], (long)sysVer.majorVersion, (long)sysVer.minorVersion, (long)sysVer.patchVersion];

    NSDictionary *dict = @{ @"comment" : feedback,
                            @"useragent" : userAgent };


    if (connectionIndicator.hidden == YES)
    {
        // Start the connection indicator

        connectionIndicator.hidden = NO;
        [connectionIndicator startAnimation:self];
    }

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:kSquinterFeedbackAddress]];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];

    [request setValue:userAgent forHTTPHeaderField:@"User-Agent"];
    [request setValue:kSquinterFeedbackUUID forHTTPHeaderField:@"X-Squinter-ID"];

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
    [self checkElectricImpLibs:currentDevicegroup];
}



- (void)checkElectricImpLibs:(Devicegroup *)devicegroup
{
    // Initiate a read of the current Electric Imp library versions
    // Only do this if the project contains EI libraries and 1 hour has
    // passed since the last look-up

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
        [ide getLibraries];
        return;
        
        /*
         if (eiLibListTime != nil)
        {
            NSDate *now = [NSDate date];
            NSTimeInterval interval = [eiLibListTime timeIntervalSinceDate:now];

            if (interval >= kEILibCheckInterval && eiLibListData != nil && eiLibListData.length > 0)
            {
                // Last check was less than 1 hour earlier, so use existing list if it exists

                [self compareElectricImpLibs:devicegroup];
                return;
            }
        }

        // Set/reset the time of the most recent check

        eiLibListTime = [NSDate date];
        
         if (connectionIndicator.hidden == YES)
        {
            // Start the connection indicator

            connectionIndicator.hidden = NO;
            [connectionIndicator startAnimation:self];
        }

        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"https://smittytone.github.io/files/liblist.csv"]];
        request.HTTPMethod = @"GET";

        eiDeviceGroup = devicegroup;
        eiLibListData = [NSMutableData dataWithCapacity:0];

        NSURLSessionConfiguration *config = [NSURLSessionConfiguration ephemeralSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration: config
                                                              delegate: self
                                                         delegateQueue: nil];
        eiLibListTask = [session dataTaskWithRequest:request];
        [eiLibListTask resume];
         */
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
            NSString *errString =[NSString stringWithFormat:@"[ERROR] Could not get list of Electric Imp libraries (Code: %ld)", (long)rps.statusCode];
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
        // The connection has come to a conclusion without error

        [self compareElectricImpLibs:eiDeviceGroup];
    }
    else if (task == feedbackTask)
    {
        // The user just successfully posted feedback

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


#pragma mark - Pasteboard Methods


- (IBAction)copyDeviceCodeToPasteboard:(id)sender
{
    if (currentDevicegroup == nil)
    {
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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
        [self writeErrorToLog:[self getErrorMessage:kErrorMessageNoSelectedDevicegroup] :YES];
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



@end
