

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2020 Tony Smith. All rights reserved.


#import  <Cocoa/Cocoa.h>
#include <CoreServices/CoreServices.h>
#include <Security/Security.h>
#include <Foundation/Foundation.h>
#include <Sparkle/Sparkle.h>
#include <math.h>
#import  "ConstantsPrivate.h"
#import  "Constants.h"
#import  "StatusLight.h"
#import  "Project.h"
#import  "Devicegroup.h"
#import  "Model.h"
#import  "File.h"
#import  "BuildAPIAccess.h"
#import  "VDKQueue.h"
#import  "SquinterToolbarItem.h"
#import  "StreamToolbarItem.h"
#import  "LoginToolbarItem.h"
#import  "PDKeychainBindings.h"
#import  "CommitWindowViewController.h"
#import  "SelectWindowViewController.h"
#import  "InspectorViewController.h"
#import  "LogView.h"
#import  "DeviceLookupWindowViewController.h"
#import  "SyncWindowViewController.h"
#import  "HelpWindowViewController.h"
#import  "EnvVarWindowController.h"
#import  "InspectorToolbarItem.h"


@interface AppDelegate : NSObject <NSApplicationDelegate,
                                   NSOpenSavePanelDelegate,
                                   NSFileManagerDelegate,
                                   VDKQueueDelegate,
                                   NSToolbarDelegate,
                                   NSURLSessionDataDelegate,
                                   NSURLSessionTaskDelegate,
                                   NSTextFieldDelegate,
                                   NSTouchBarProvider,
                                   NSSplitViewDelegate,
                                   NSWindowDelegate>
{
    #pragma mark - Main UI element outlets

    IBOutlet LogView               *logTextView;
    IBOutlet NSClipView            *logClipView;
    IBOutlet NSScrollView          *logScrollView;
    IBOutlet StatusLight           *saveLight;
    IBOutlet NSProgressIndicator   *connectionIndicator;
    IBOutlet NSPopUpButton         *projectsPopUp;
    IBOutlet NSPopUpButton         *devicesPopUp;
    IBOutlet NSSplitView           *splitView;

    #pragma mark File Menu outlets

    IBOutlet NSMenu     *fileMenu;
    IBOutlet NSMenuItem *fileSaveMenuItem;
    IBOutlet NSMenuItem *fileSaveAsMenuItem;
    IBOutlet NSMenuItem *fileAddFilesMenuItem;
    IBOutlet NSMenu     *openRecentMenu;

    #pragma mark Project Menu outlets

    IBOutlet NSMenu     *projectsMenu;
    IBOutlet NSMenu     *openProjectsMenu;
    IBOutlet NSMenuItem *renameProjectMenuItem;
    IBOutlet NSMenuItem *syncProjectMenuItem;
    IBOutlet NSMenuItem *showProjectInfoMenuItem;
    IBOutlet NSMenuItem *showProjectFinderMenuItem;
    IBOutlet NSMenu     *productsMenu;
    IBOutlet NSMenuItem *downloadProductMenuItem;
    IBOutlet NSMenuItem *linkProductMenuItem;
    IBOutlet NSMenuItem *deleteProductMenuItem;
    IBOutlet NSMenuItem *renameProductMenuItem;

    #pragma mark Device Groups Menu outlets

    IBOutlet NSMenu     *deviceGroupsMainMenu;
    IBOutlet NSMenu     *deviceGroupsMenu;
    IBOutlet NSMenuItem *showDeviceGroupInfoMenuItem;
    IBOutlet NSMenuItem *listCommitsMenuItem;
    IBOutlet NSMenuItem *showModelFilesFinderMenuItem;
    IBOutlet NSMenuItem *restartDeviceGroupMenuItem;
    IBOutlet NSMenuItem *conRestartDeviceGroupMenuItem;
    IBOutlet NSMenuItem *deleteDeviceGroupMenuItem;
    IBOutlet NSMenuItem *renameDeviceGroupMenuItem;
    IBOutlet NSMenuItem *compileMenuItem;
    IBOutlet NSMenuItem *uploadMenuItem;
    IBOutlet NSMenuItem *uploadExtraMenuItem;
    IBOutlet NSMenuItem *setMinimumMenuItem;
    IBOutlet NSMenuItem *setProductionTargetMenuItem;
    IBOutlet NSMenuItem *setDUTTargetMenuItem;
    IBOutlet NSMenuItem *removeFilesMenuItem;
    IBOutlet NSMenuItem *externalOpenMenuItem;
    IBOutlet NSMenu     *externalSourceMenu;
    IBOutlet NSMenuItem *externalOpenDeviceItem;
    IBOutlet NSMenuItem *externalOpenAgentItem;
    IBOutlet NSMenuItem *externalOpenBothItem;
    IBOutlet NSMenuItem *externalOpenLibsItem;
    IBOutlet NSMenu     *externalLibsMenu;
    IBOutlet NSMenuItem *externalOpenFileItem;
    IBOutlet NSMenu     *externalFilesMenu;
    IBOutlet NSMenu     *impLibrariesMenu;
    IBOutlet NSMenuItem *checkImpLibrariesMenuItem;
    IBOutlet NSMenuItem *listTestBlessedDevicesMenuItem;
    IBOutlet NSMenuItem *logAllDevicegroupDevices;
    IBOutlet NSMenuItem *nextDevicegroupMenuItem;
    IBOutlet NSMenuItem *previousDevicegroupMenuItem;
    IBOutlet NSMenuItem *envVarsMenuItem;

    #pragma mark Device Menu outlets

    IBOutlet NSMenu     *deviceMenu;
    IBOutlet NSMenuItem *showDeviceInfoMenuItem;
    IBOutlet NSMenuItem *restartDeviceMenuItem;
    IBOutlet NSMenuItem *copyAgentURLMenuItem;
    IBOutlet NSMenuItem *openAgentURLMenuItem;
    IBOutlet NSMenuItem *unassignDeviceMenuItem;
    IBOutlet NSMenuItem *assignDeviceMenuItem;
    IBOutlet NSMenuItem *getLogsMenuItem;
    IBOutlet NSMenuItem *getHistoryMenuItem;
    IBOutlet NSMenuItem *streamLogsMenuItem;
    IBOutlet NSMenuItem *renameDeviceMenuItem;
    IBOutlet NSMenuItem *updateDeviceStatusMenuItem;
    IBOutlet NSMenuItem *checkDeviceStatusMenuItem;
    IBOutlet NSMenuItem *deleteDeviceMenuItem;
    IBOutlet NSMenu     *unassignedDevicesMenu;
    IBOutlet NSMenuItem *findDeviceMenuItem;
    IBOutlet NSMenuItem *closeAllDeviceLogsMenuItem;

    #pragma mark Account Menu Outlets

    IBOutlet NSMenu     *accountMenu;
    IBOutlet NSMenuItem *loginMenuItem;
    IBOutlet NSMenuItem *accountMenuItem;
    IBOutlet NSMenuItem *switchAccountMenuItem;

    #pragma mark View Menu outlets

    IBOutlet NSMenuItem *logDeviceCodeMenuItem;
    IBOutlet NSMenuItem *logAgentCodeMenuItem;
    IBOutlet NSMenuItem *showHideToolbarMenuItem;
    // FROM 2.3.133
    IBOutlet NSMenuItem *showHideInspectorMenuItem;

    #pragma mark File Menu outlets

    IBOutlet NSMenuItem *closeAllMenuItem;

    #pragma mark Help Menu

    IBOutlet NSMenuItem *author01;
    IBOutlet NSMenuItem *author02;
    IBOutlet NSMenuItem *author03;
    IBOutlet NSMenuItem *author04;
    IBOutlet NSMenuItem *author05;
    IBOutlet NSMenuItem *author06;

    #pragma mark Toolbar outlets

    IBOutlet NSToolbar              *squinterToolbar;
    IBOutlet SquinterToolbarItem    *squintItem;
    IBOutlet SquinterToolbarItem    *newProjectItem;
    IBOutlet SquinterToolbarItem    *infoItem;
    IBOutlet SquinterToolbarItem    *openAllItem;
    IBOutlet SquinterToolbarItem    *uploadCodeItem;
    IBOutlet SquinterToolbarItem    *restartDevicesItem;
    IBOutlet SquinterToolbarItem    *clearItem;
    IBOutlet SquinterToolbarItem    *copyDeviceItem;
    IBOutlet SquinterToolbarItem    *copyAgentItem;
    IBOutlet SquinterToolbarItem    *printItem;
    IBOutlet SquinterToolbarItem    *openDeviceCode;
    IBOutlet SquinterToolbarItem    *openAgentCode;
    IBOutlet StreamToolbarItem      *streamLogsItem;
    IBOutlet SquinterToolbarItem    *refreshModelsItem;
    IBOutlet SquinterToolbarItem    *newDevicegroupItem;
    IBOutlet SquinterToolbarItem    *devicegroupInfoItem;
    IBOutlet LoginToolbarItem       *loginAndOutItem;
    IBOutlet SquinterToolbarItem    *uploadCodeExtraItem;
    IBOutlet SquinterToolbarItem    *listCommitsItem;
    IBOutlet SquinterToolbarItem    *downloadProductItem;
    IBOutlet InspectorToolbarItem   *inspectorItem;
    IBOutlet SquinterToolbarItem    *syncItem;

    // Sheets, dialogs and windows

    #pragma mark Login Sheet

    IBOutlet NSPanel               *loginSheet;
    IBOutlet NSTextField           *usernameTextField;
    IBOutlet NSSecureTextField     *passwordTextField;
    IBOutlet NSSecureTextFieldCell *passwordTextFieldCell;
    IBOutlet NSButton              *saveDetailsCheckbox;
    IBOutlet NSButton              *showPassCheckbox;
    IBOutlet NSPopUpButton         *impCloudPopup;

    #pragma mark Open Panel

    NSOpenPanel       *openDialog;
    IBOutlet NSView   *accessoryView;
    IBOutlet NSButton *accessoryViewNewProjectCheckbox;

    IBOutlet NSView   *projectFromFilesAccessoryView;
    IBOutlet NSButton *projectFromFilesAccessoryViewCheckbox;
    IBOutlet NSButton *projectFromFilesAccessoryViewLocCheckbox;

    #pragma mark Save Panel

    NSSavePanel          *saveProjectDialog;
    IBOutlet id          saveChangesSheet;
    IBOutlet NSTextField *saveChangesSheetLabel;
    IBOutlet NSView      *saveDevicegroupFilesAccessoryView;
    IBOutlet NSButton    *saveDevicegroupFilesAccessoryViewCheckbox;

    #pragma mark New Project Sheet

    IBOutlet NSPanel     *newProjectSheet;
    IBOutlet NSTextField *newProjectNameTextField;
    IBOutlet NSTextField *newProjectNameCountField;
    IBOutlet NSTextField *newProjectDescTextField;
    IBOutlet NSTextField *newProjectDescCountField;
    IBOutlet NSTextField *newProjectLabel;
    IBOutlet NSButton    *newProjectAssociateCheckbox;
    IBOutlet NSButton    *newProjectNewProductCheckbox;

    #pragma mark Rename Project/Device Group Sheet

    IBOutlet NSPanel     *renameProjectSheet;
    IBOutlet NSTextField *renameProjectLabel;
    IBOutlet NSTextField *renameProjectTextField;
    IBOutlet NSTextField *renameProjectCountField;
    IBOutlet NSTextField *renameProjectDescTextField;
    IBOutlet NSTextField *renameProjectDescCountField;
    IBOutlet NSButton    *renameProjectLinkCheckbox;
    IBOutlet NSTextField *renameProjectHintField;

    #pragma mark Sync Project Choices Sheet

    IBOutlet NSPanel                  *syncChoiceSheet;
    IBOutlet SyncWindowViewController *sywvc;

    #pragma mark New Device Group Sheet

    IBOutlet NSPanel       *newDevicegroupSheet;
    IBOutlet NSTextField   *newDevicegroupLabel;
    IBOutlet NSTextField   *newDevicegroupNameTextField;
    IBOutlet NSTextField   *newDevicegroupNameCountField;
    IBOutlet NSTextField   *newDevicegroupDescTextField;
    IBOutlet NSTextField   *newDevicegroupDescCountField;
    IBOutlet NSButton      *newDevicegroupCheckbox;
    IBOutlet NSPopUpButton *newDevicegroupTypePopup;

    #pragma mark Select Target Sheet

    IBOutlet NSWindow                   *selectTargetSheet;
    IBOutlet SelectWindowViewController *swvc;

    #pragma mark About Sheet

    IBOutlet id aboutSheet;
    IBOutlet id aboutVersionLabel;
    IBOutlet NSButton *feedbackButton;

    #pragma mark Prefs Sheet

    IBOutlet id            preferencesSheet;
    IBOutlet NSTextField   *workingDirectoryField;
    IBOutlet NSButton      *preserveCheckbox;
    IBOutlet NSButton      *autoCompileCheckbox;
    IBOutlet NSButton      *loadModelsCheckbox;
    IBOutlet NSButton      *loadDevicesCheckbox;
    IBOutlet NSPopUpButton *fontsMenu;
    IBOutlet NSPopUpButton *sizeMenu;
    IBOutlet NSColorWell   *textColorWell;
    IBOutlet NSColorWell   *backColorWell;
    IBOutlet NSColorWell   *dev1ColorWell;
    IBOutlet NSColorWell   *dev2ColorWell;
    IBOutlet NSColorWell   *dev3ColorWell;
    IBOutlet NSColorWell   *dev4ColorWell;
    IBOutlet NSColorWell   *dev5ColorWell;
    IBOutlet NSColorWell   *dev6ColorWell;
    IBOutlet NSColorWell   *dev7ColorWell;
    IBOutlet NSColorWell   *dev8ColorWell;
    IBOutlet NSButton      *autoUpdateCheckCheckbox;
    IBOutlet NSButton      *autoLoadListsCheckbox;
    IBOutlet NSButton      *boldTestCheckbox;
    IBOutlet NSPopUpButton *locationMenu;
    IBOutlet NSPopUpButton *recentFilesCountMenu;
    IBOutlet NSPopUpButton *maxLogCountMenu;
    IBOutlet NSButton      *updateDevicesCheckbox;
    IBOutlet NSButton      *showDeviceWarnigCheckbox;

    #pragma mark Assign Device Sheet

    IBOutlet NSPanel       *assignDeviceSheet;
    IBOutlet NSPopUpButton *assignDeviceMenuDevices;
    IBOutlet NSPopUpButton *assignDeviceMenuModels;

    NSOpenPanel *choosePanel;

    #pragma mark Rename Device/Device Group/Project Sheet

    IBOutlet NSPanel       *renameSheet;
    IBOutlet NSTextField   *renameLabel;
    IBOutlet NSPopUpButton *renameMenu;
    IBOutlet NSTextField   *renameName;
    IBOutlet NSTextField   *renameNameLength;

    #pragma mark Agent or Device Code? Sheet

    IBOutlet NSPanel     *sourceTypeSheet;
    IBOutlet NSTextField *sourceTypeLabel;
    IBOutlet NSButton    *sourceTypeAgentButton;
    IBOutlet NSButton    *sourceTypeDeviceButton;

    #pragma mark Upload Code Sheet

    IBOutlet NSPanel     *uploadSheet;
    IBOutlet NSTextField *uploadDevicegroupTextField;
    IBOutlet NSTabView   *uploadTab;
    IBOutlet NSTextField *uploadCommitTextField;
    IBOutlet NSTextField *uploadCommitCountField;
    IBOutlet NSTextField *uploadOriginTextField;
    IBOutlet NSTextField *uploadOriginCountField;
    IBOutlet NSTextField *uploadTagsTextField;
    IBOutlet NSTextField *uploadTagsCountField;

    #pragma mark OTP Sheet

    IBOutlet NSPanel     *otpSheet;
    IBOutlet NSTextField *otpTextField;

    #pragma mark Set Minimum Deployment Sheet

    IBOutlet NSWindow    *commitSheet;

    #pragma mark Report a Problem Sheet

    IBOutlet NSPanel     *feedbackSheet;
    IBOutlet NSTextField *feedbackField;

    // ADDED IN 2.2.127
    #pragma mark Find Device Sheet

    IBOutlet NSPanel     *findDeviceSheet;

    #pragma mark Inspector Panel

    IBOutlet InspectorViewController *iwvc;
    
    #pragma mark Multi-device Warning Panel
    
    IBOutlet NSPanel     *multiDeviceSheet;
    IBOutlet NSTextField *multiDeviceLabel;
    
    // ADDED IN 2.3.131
    #pragma mark Environment Vars Sheet
    IBOutlet NSPanel    *envVarSheet;
    IBOutlet EnvVarWindowController *evvc;

    #pragma mark Other Sheets

    // Update Tracking

    IBOutlet SUUpdater *sparkler;

    // Commit Window

    IBOutlet CommitWindowViewController *cwvc;

    // Device Lookup ADDED IN 2.2.127

    IBOutlet DeviceLookupWindowViewController *dlvc;

    // Touch Bar

    IBOutlet NSTouchBar *appBar;
    
    // Help View
    
    IBOutlet HelpWindowViewController *hwvc;

    #pragma mark Main Properties

    BuildAPIAccess *ide;
    Project *currentProject, *creatingProject, *savingProject;
    Devicegroup *currentDevicegroup, *eiDeviceGroup;
    VDKQueue *fileWatchQueue;
    
    NSWindow *mainWindow;
    NSOperatingSystemVersion sysVer;
    NSWorkspace *nswsw;
    NSFileManager *nsfm;
    NSNotificationCenter *nsncdc;
    NSUserDefaults *defaults;
    NSDateFormatter *def, *inLogDef, *outLogDef;
    NSOperationQueue *extraOpQueue;
    NSMenu *dockMenu;
    NSTimer *refreshTimer;
    NSTimeInterval updateDevicePeriod;

    NSMutableArray *projectArray, *devicesArray, *productsArray, *recentFiles; // *downloads
    NSMutableArray *foundLibs, *foundFiles, *foundEILibs, *colors, *logColors, *saveUrls;
    NSMutableArray *deviceColourWells, *eiDeviceGroupCache, *loggedDevices, *fixtureTargets;
    NSMutableDictionary *selectedProduct, *selectedDevice;

    NSURLSessionTask *eiLibListTask, *feedbackTask;
    NSMutableData *eiLibListData;
    NSDate *eiLibListTime;

    NSColor *backColour, *textColour;
    NSFont *logFont;

    NSString *workingDirectory, *listString, *newDevicegroupName, *loginKey, *otpLoginToken;
    NSUInteger syncItemCount, logPaddingLength, deviceCheckCount, loginMode;
    NSInteger wantsToHide, accountType, lastAPIError;

    BOOL closeProjectFlag, noProjectsFlag, newDevicegroupFlag, deviceSelectFlag, newTargetsFlag;
    BOOL renameProjectFlag, saveAsFlag, credsFlag, switchingAccount, doubleSaveFlag, reconnectAfterSleepFlag;
    BOOL isLoggingIn, isBookmarkStale, isInspectorHidden;
}


// Inspector Methods
- (IBAction)showInspector:(id)sender;
- (IBAction)showProjectInspector:(id)sender;
- (IBAction)showDeviceInspector:(id)sender;


// Login Methods
- (IBAction)loginOrOut:(id)sender;
- (void)logout;
- (void)autoLogin;
- (void)showLoginWindow;
- (void)setLoginCreds;
- (IBAction)cancelLogin:(id)sender;
- (IBAction)login:(id)sender;
- (void)loginAlert:(NSString *)extra;
- (IBAction)setSecureEntry:(id)sender;
- (IBAction)switchAccount:(id)sender;
- (IBAction)signup:(id)sender;
- (void)handleLoginKey:(NSNotification *)note;
- (void)getOtp:(NSNotification *)note;
- (IBAction)setOtp:(id)sender;
- (IBAction)cancelOtpSheet:(id)sender;


// New Project Methods
- (IBAction)newProject:(id)sender;
- (IBAction)newProjectSheetCancel:(id)sender;
- (IBAction)newProjectSheetCreate:(id)sender;
- (void)newProjectSheetCreateStageTwo:(NSString *)projectName :(NSString *)projectDesc :(BOOL)make :(BOOL)associate;
- (void)newProjectSheetCreateStageThree:(Project *)newProject;
- (IBAction)newProjectCheckboxStateHandler:(id)sender;


// Existing Project Methods
- (IBAction)pickProject:(id)sender;
- (void)chooseProject:(id)sender;
- (IBAction)openProject:(id)sender;
- (IBAction)closeProject:(id)sender;
- (void)closeDevicegroupFiles:(Devicegroup *)devicegroup :(Project *)parent;
- (IBAction)renameCurrentProject:(id)sender;
- (void)renameProject:(id)sender;
- (IBAction)closeRenameProjectSheet:(id)sender;
- (IBAction)saveRenameProjectSheet:(id)sender;
- (IBAction)doUpload:(id)sender;
- (void)uploadProject:(Project *)project;
- (IBAction)doSync:(id)sender;
- (void)syncProject:(Project *)project;
- (IBAction)cancelSyncChoiceSheet:(id)sender;
- (IBAction)closeSyncChoiceSheet:(id)sender;
- (void)postSync:(Project *)project;
- (void)syncLocalDevicegroups:(NSMutableArray *)devicegroups;
- (IBAction)openRecent:(id)sender;
- (void)openRecentAll;
- (IBAction)clearRecent:(id)sender;
- (void)addToRecentMenu:(NSString *)filename :(NSString *)path;


// Product Methods
- (void)chooseProduct:(id)sender;
- (IBAction)getProductsFromServer:(id)sender;
- (IBAction)deleteProduct:(id)sender;
- (IBAction)downloadProduct:(id)sender;
- (IBAction)linkProjectToProduct:(id)sender;


// New Device Group Methods
- (IBAction)newDevicegroup:(id)sender;
- (IBAction)newDevicegroupSheetCancel:(id)sender;
- (IBAction)newDevicegroupSheetCreate:(id)sender;
- (NSUInteger)checkDUTTargets:(NSUInteger)groupType;
- (NSUInteger)checkProdTargets:(NSUInteger)groupType;
- (NSUInteger)checkTargets:(NSString *)groupPrefix;
- (void)createFilesForDevicegroup:(NSString *)filename :(NSString *)filetype;
- (void)saveDevicegroupfiles:(NSURL *)saveDirectory :(NSString *)newFileName :(NSInteger)action;
- (void)newDevicegroupSheetCreateStageTwo:(Devicegroup *)devicegroup :(Project *)project :(BOOL)makeNewFiles :(NSMutableArray *)anyTargets;
- (void)showSelectTarget:(Devicegroup *)devicegroup :(BOOL)andMakeNewFiles :(NSInteger)targetType;
- (IBAction)cancelSelectTarget:(id)sender;
- (IBAction)selectTarget:(id)sender;


// Existing Device Group Methods
- (void)chooseDevicegroup:(id)sender;
- (IBAction)incrementCurrentDevicegroup:(id)sender;
- (IBAction)decrementCurrentDevicegroup:(id)sender;
- (IBAction)deleteDevicegroup:(id)sender;
- (IBAction)renameDevicegroup:(id)sender;
- (IBAction)uploadCode:(id)sender;
- (IBAction)uploadCodeExtraCancel:(id)sender;
- (IBAction)uploadCodeExtraSkip:(id)sender;
- (IBAction)uploadCodeExtraUpload:(id)sender;
- (IBAction)removeSource:(id)sender;
- (IBAction)getCommits:(id)sender;
- (IBAction)updateCode:(id)sender;
- (IBAction)setMinimumDeployment:(id)sender;
- (IBAction)chooseProductionTarget:(id)sender;
- (IBAction)chooseDUTTarget:(id)sender;
- (void)chooseTarget:(NSInteger)type;
- (IBAction)showTestBlessedDevices:(id)sender;
// ADDED IN 2.3.130
- (IBAction)logAllDevices:(id)sender;
- (IBAction)closeAllDeviceLogs:(id)sender;
// ADDED IN 2.3.131
- (IBAction)editEnvVariables:(id)sender;
- (IBAction)cancelEnvVarSheet:(id)sender;
- (IBAction)saveEnvVarSheet:(id)sender;



// Existing Device Methods
- (void)selectFirstDevice;
- (IBAction)updateDevicesStatus:(id)sender;
- (IBAction)keepDevicesStatusUpdated:(id)sender;
- (void)deviceStatusCheck;
- (IBAction)restartDevice:(id)sender;
- (IBAction)restartDevices:(id)sender;
- (IBAction)unassignDevice:(id)sender;
- (IBAction)assignDevice:(id)sender;
- (IBAction)assignDeviceSheetCancel:(id)sender;
- (IBAction)assignDeviceSheetAssign:(id)sender;
- (IBAction)renameDevice:(id)sender;
- (IBAction)closeRenameSheet:(id)sender;
- (IBAction)saveRenameSheet:(id)sender;
- (IBAction)chooseDevice:(id)sender;
- (IBAction)deleteDevice:(id)sender;
- (IBAction)getLogs:(id)sender;
- (IBAction)streamLogs:(id)sender;
// ADDED IN 2.2.127
- (IBAction)findDevice:(id)sender;
- (IBAction)cancelFindDeviceSheet:(id)sender;
- (IBAction)useFindDeviceSheet:(id)sender;


// Log and Logging Methods
- (IBAction)printLog:(id)sender;
- (IBAction)showProjectInfo:(id)sender;
- (IBAction)showDeviceGroupInfo:(id)sender;
- (IBAction)showDeviceInfo:(id)sender;
- (IBAction)logDeviceCode:(id)sender;
- (IBAction)logAgentCode:(id)sender;
- (IBAction)clearLog:(id)sender;

- (void)compileDevicegroupInfo:(Devicegroup *)devicegroup :(NSUInteger)inset :(NSMutableArray *)otherLines;
- (void)compileModelInfo:(Model *)model :(NSUInteger)inset :(NSMutableArray *)otherLines;
- (void)printDone:(NSPrintOperation *)printOperation success:(BOOL)success contextInfo:(void *)contextInfo;

- (void)writeLinesToLog:(NSMutableArray *)lines;
- (void)writeStringToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeErrorToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeWarningToLog:(NSString *)string :(BOOL)addTimestamp;
- (void)writeNoteToLog:(NSString *)string :(NSColor *)colour :(BOOL)addTimestamp;
- (void)writeStyledStringToLog:(NSAttributedString *)string :(BOOL)addTimestamp;

- (void)listCode:(NSString *)code :(NSUInteger)from :(NSUInteger)to :(NSUInteger)at :(NSUInteger)col;
- (void)logCode;
- (void)logLogs:(NSString *)logLine;
// ADDED IN 2.3.128
- (void)logModelCode:(NSString *)codeType;



// Squint Methods
- (IBAction)squint:(id)sender;


// External Editor Methods
- (IBAction)externalOpen:(id)sender;
- (IBAction)externalLibOpen:(id)sender;
- (IBAction)externalFileOpen:(id)sender;
- (IBAction)externalOpenAll:(id)sender;
- (IBAction)openAgentURL:(id)sender;
- (IBAction)showProjectInFinder:(id)sender;
- (IBAction)showModelFilesInFinder:(id)sender;
- (void)externalOpenItem:(id)sender :(BOOL)isLibrary;
- (void)externalOpenItems:(BOOL)areLibraries;
- (void)switchToEditor:(Model *)model;


// Web Access Methods
- (IBAction)showReleaseNotesPage:(id)sender;
- (IBAction)showAuthor:(id)sender;
- (IBAction)showWebHelp:(id)sender;
- (IBAction)showPrefsHelp:(id)sender;
- (void)showEILibsPage;
- (void)launchOwnSite:(NSString *)anchor;
- (void)launchWebSite:(NSString *)url;
// FROM 2.3.130
- (IBAction)showOfflineHelp:(id)sender;


// About Sheet Methods
- (IBAction)showAboutSheet:(id)sender;
- (IBAction)viewSquinterSite:(id)sender;
- (IBAction)closeAboutSheet:(id)sender;


// Preferences Sheet Methods
- (IBAction)showPrefs:(id)sender;
- (IBAction)cancelPrefs:(id)sender;
- (IBAction)setPrefs:(id)sender;
- (IBAction)selectFontName:(id)sender;
- (IBAction)chooseWorkingDirectory:(id)sender;


// Report a Problem Sheet Methods
- (IBAction)showFeedbackSheet:(id)sender;
- (IBAction)cancelFeedbackSheet:(id)sender;
- (IBAction)sendFeedback:(id)sender;
- (void)sendFeedbackError;


// Check Electric Imp Libraries Methods
- (IBAction)checkElectricImpLibraries:(id)sender;
- (void)checkElectricImpLibs:(Devicegroup *)devicegroup;
- (void)compareElectricImpLibs:(Devicegroup *)devicegroup;


// Pasteboard Methods
- (IBAction)copyAgentURL:(id)sender;
- (IBAction)copyDeviceCodeToPasteboard:(id)sender;
- (IBAction)copyAgentCodeToPasteboard:(id)sender;
- (void)copyCodeToPasteboard:(NSString *)type;


// VDKQueueDelegate Methods methods
- (void)VDKQueue:(VDKQueue *)queue receivedNotification:(NSString*)noteName forPath:(NSString*)fpath;


@property (assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) NSTouchBar *touchBar;



@end
