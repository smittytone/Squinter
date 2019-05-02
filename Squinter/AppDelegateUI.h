
//  Created by Tony Smith on 02/05/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"


@interface AppDelegate(AppDelegateUI)


// UI Update Methods

// Projects menu
- (void)refreshProjectsMenu;
- (void)refreshOpenProjectsMenu;
- (void)refreshProductsMenu;
- (void)setProductsMenuTick;
- (BOOL)addProjectMenuItem:(NSString *)menuItemTitle :(Project *)aProject;

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
- (void)refreshUnassignedDevicesMenu;
- (void)setUnassignedDevicesMenuTick;
- (NSImage *)menuImage:(NSMutableDictionary *)device;

// View menu
- (IBAction)showHideToolbar:(id)sender;
- (void)refreshViewMenu;
- (void)refreshRecentFilesMenu;

// Toolbar
- (void)setToolbar;


// Dock Menu Methods
- (void)dockMenuAction:(id)sender;


@end
