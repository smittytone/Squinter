
//  Created by Tony Smith on 02/05/2019.
//  Copyright © 2020 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"


@interface AppDelegate(AppDelegateUI)


// Projects menu
- (void)refreshProjectsMenu;
- (void)refreshOpenProjectsSubmenu;
- (void)refreshProductsMenu;
- (void)setProductsMenuTick;
- (BOOL)addOpenProjectsMenuItem:(NSString *)title :(Project *)aProject;

// Device Groups menu
- (void)refreshDeviceGroupsSubmenu;
- (void)refreshDevicegroupByType:(NSString *)type;
- (void)refreshDeviceGroupsMenu;
- (void)defaultExternalMenus;
- (void)refreshDeviceGroupSubmenuDevices;
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
- (void)setInspectorMenuItemState:(BOOL)state;

// Toolbar
- (void)setToolbar;

// Dock Menu Methods
- (void)dockMenuAction:(id)sender;


@end
