
//  Created by Tony Smith on 02/05/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"


@interface AppDelegate(AppDelegateUI)


// UI Update Methods

// Projects menu
- (void)refreshProjectsMenu;
- (void)refreshOpenProjectsMenu;
- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle :(Project *)aProject;
- (void)refreshProductsMenu;
- (void)setProductsMenuTick;

// Device Groups menu
- (void)refreshDevicegroupMenu;
- (void)refreshDevicegroupByType:(NSString *)type;
- (void)refreshMainDevicegroupsMenu;
- (void)defaultExternalMenus;
- (void)refreshDevicesMenus;
- (void)setDevicesMenusTicks;
- (void)refreshLibraryMenus;
- (void)libAdder:(NSMutableArray *)libs :(BOOL)isEILib;
- (void)addLibraryToMenu:(File *)lib :(BOOL)isEILib :(BOOL)isActive;
- (void)refreshFilesMenu;
- (void)fileAdder:(NSMutableArray *)models;
- (void)addFileToMenu:(File *)file :(BOOL)isActive;
- (void)addItemToFileMenu:(NSString *)text :(BOOL)isActive;

// Device menu
- (void)refreshDeviceMenu;
- (void)refreshDevicesPopup;
- (void)setDevicesPopupTick;
- (NSImage *)menuImage:(NSMutableDictionary *)device;
- (void)refreshUnassignedDevicesMenu;
- (void)setUnassignedDevicesMenuTick;

// View menu
- (void)refreshViewMenu;
- (void)refreshRecentFilesMenu;
- (IBAction)showHideToolbar:(id)sender;

// Toolbar
- (void)setToolbar;


// Dock Menu Methods
- (void)dockMenuAction:(id)sender;


@end
