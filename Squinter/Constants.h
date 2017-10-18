

//  Created by Tony Smith on 30/06/2015.
//  Copyright (c) 2015-17 Tony Smith. All rights reserved.
//  Issued under MIT licence



#ifndef SquinterContants_h
#define SquinterContants_h

#define kSquinterCurrentVersion				@"3.0"

#define kActionNewDGBothFiles				6
#define kActionNewDGAgentFile				5
#define kActionNewDGDeviceFile				4

#define kActionOpenSquirrelProject			3
#define kActionOpenWithAddFiles				2
#define kActionNewFiles						1

#define kMaxNumberOfOpenProjects			64
#define kMaxNumberOfRecentFiles				5

#define kCodeTypeNoFile						0
#define kCodeTypeAgent						1
#define kCodeTypeDevice						2

#define kLightRed							0
#define kLightGreen							1

#define kInitialFontSize					9
#define kStatusIndicatorWidth				2

#define kAllLogs							0
#define kStreamLogs							-1

#define kOfflineTag							@" (offline)"

#define kEILibCheckInterval					-3600

#define kErrorMessageNoSelectedDevice		1
#define kErrorMessageNoSelectedDevicegroup	2
#define kErrorMessageNoSelectedProject		3
#define kErrorMessageNoSelectedProduct		4
#define kErrorMessageMalformedOperation		5

#define kDoneChecking						9999999

// Login

#define kLoginResultCodeSuccess				0
#define kLoginResultCodeNetFail				1
#define kLoginResultCodeCredFail			2

// Squinted

#define kDeviceCodeSquinted					0x01
#define kAgentCodeSquinted					0x02
#define kBothCodeSquinted					0x03


#endif
