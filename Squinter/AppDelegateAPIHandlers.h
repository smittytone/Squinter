
//  Created by Tony Smith on 02/05/2019.
//  Copyright © 2019 Tony Smith. All rights reserved.


#import "AppDelegate.h"
#import "AppDelegateUtilities.h"
#import "AppDelegateUI.h"


@interface AppDelegate(AppDelegateAPIHandlers)


// Configuration Methods

- (void)configureNotifications;


// API Response Handler Methods

// API Called Account Methods
- (void)gotMyAccount:(NSNotification *)note;
- (void)gotAnAccount:(NSNotification *)note;
- (void)loggedIn:(NSNotification *)note;
- (void)loggedInStageTwo;
- (void)loginRejected:(NSNotification *)note;
- (void)loggedOut:(NSNotification *)note;

// API Called Project Methods
- (void)uploadProjectStageThree:(Project *)project;

// Called Products Methods
- (void)listProducts:(NSNotification *)note;
- (void)productToProjectStageTwo:(NSNotification *)note;
- (void)productToProjectStageThree:(NSNotification *)note;
- (void)productToProjectStageFour:(Project *)project;
- (void)getCurrentDeployment:(NSDictionary *)data;
- (void)createProductStageTwo:(NSNotification *)note;
- (void)deleteProductStageTwo:(NSMutableDictionary *)productToDelete;
- (void)deleteProductStageThree:(NSNotification *)note;
- (void)updateProductStageTwo:(NSNotification *)note;

// API Called Device Group Methods
- (void)updateDevicegroupStageTwo:(NSNotification *)note;
- (void)deleteDevicegroupStageTwo:(NSNotification *)note;
- (void)createDevicegroupStageTwo:(NSNotification *)note;
- (void)syncLocalDevicegroupsStageTwo:(Devicegroup *)devicegroup;
- (void)uploadDevicegroupCode:(Devicegroup *)devicegroup :(Project *)project;

// API Called Code Methods
- (void)updateCodeStageTwo:(NSNotification *)note;
- (void)uploadCodeStageTwo:(NSNotification *)note;
- (void)showCodeErrors:(NSNotification *)note;

// API Called Device Methods
- (void)listDevices:(NSNotification *)note;
- (void)listBlessedDevices:(NSArray *)devices :(Devicegroup *)devicegroup;
- (void)updateDevice:(NSNotification *)note;
- (void)restarted:(NSNotification *)note;
- (void)reassigned:(NSNotification *)note;
- (void)renameDeviceStageTwo:(NSNotification *)note;
- (void)deleteDeviceStageTwo:(NSNotification *)note;
- (void)setMinimumDeploymentStageTwo:(NSNotification *)note;

// API Called Misc Methods
- (void)displayError:(NSNotification *)note;
- (void)listCommits:(NSNotification *)note;
- (void)listLogs:(NSNotification *)note;
- (void)gotLibraries:(NSNotification *)note;

// API Called Logging Methods
- (void)loggingStarted:(NSNotification *)note;
- (void)loggingStopped:(NSNotification *)note;
- (void)presentLogEntry:(NSNotification *)note;
- (void)endLogging:(NSNotification *)note;


@end
