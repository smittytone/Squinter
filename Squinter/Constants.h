

//  Created by Tony Smith on 30/06/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.
//  Issued under MIT licence



#ifndef SquinterContants_h
#define SquinterContants_h

#define kSquinterCurrentVersion             @"3.2"  // This is PROJECT version, not app version
#define kSquinterAppVersion                 @"2.3"  // This is APP version

#define kActionNewDGBothFiles               6
#define kActionNewDGAgentFile               5
#define kActionNewDGDeviceFile              4

#define kActionOpenSquirrelProject          3
#define kActionOpenWithAddFiles             2
#define kActionNewFiles                     1

#define kMaxNumberOfOpenProjects            64
#define kMaxNumberOfRecentFiles             5

#define kCodeTypeNoFile                     0
#define kCodeTypeAgent                      1
#define kCodeTypeDevice                     2

#define kLightRed                           0
#define kLightGreen                         1

#define kInitialFontSize                    9
#define kStatusIndicatorWidth               2

#define kAllLogs                            0
#define kStreamLogs                         -1
#define kMaxLogStreamDevices                8
#define kMaxLogStreamDevicesText            @"eight"
#define kMaxLogStreams                      8

#define kOfflineTag                         @" (offline)"

#define kEILibCheckInterval                 -3600

#define kErrorMessageNoSelectedDevice       1
#define kErrorMessageNoSelectedDevicegroup  2
#define kErrorMessageNoSelectedProject      3
#define kErrorMessageNoSelectedProduct      4
#define kErrorMessageMalformedOperation     5

#define kDoneChecking                       9999999

// Login

#define kLoginResultCodeSuccess             0
#define kLoginResultCodeNetFail             1
#define kLoginResultCodeCredFail            2

#define kImpCloudTypeAWS                    0
#define kImpCloudTypeAzure                  1

#define kLoginModeNone                      0
#define kLoginModeMain                      1
#define kLoginModeAlt                       2

// Squinted

#define kDeviceCodeSquinted                 0x01
#define kAgentCodeSquinted                  0x02
#define kBothCodeSquinted                   0x03

// StreamToolbarItem

#define kStreamToolbarItemStateOff          0
#define kStreamToolbarItemStateMid          1
#define kStreamToolbarItemStateOn           2

// Inspector Tabs

#define kInspectorTabProject                0
#define kInspectorTabDevice                 1

// ADDED 2.3.127
// Target Device Group types

#define kTargetDeviceGroupTypeNone          0
#define kTargetDeviceGroupTypeProd          1
#define kTargetDeviceGroupTypeDUT           2

// ADDED 2.3.128
// Account type
#define kElectricImpAccountTypeNone         0
#define kElectricImpAccountTypeFree         1
#define kElectricImpAccountTypePaid         2

#endif
