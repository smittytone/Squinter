

//  Created by Tony Smith on 15/09/2014.
//  Copyright (c) 2014-17 Tony Smith. All rights reserved.


#import <Foundation/Foundation.h>


@interface Devicegroup : NSObject <NSCoding>

// Data structure for Projects, which is NSCoding-compliant for saving

// Properties that ARE saved

@property (nonatomic, strong) NSString *name;				// Device Group's name
@property (nonatomic, strong) NSString *description;		// Device Group's description
@property (nonatomic, strong) NSString *did;				// ID of Device Group's API equivalent
@property (nonatomic, strong) NSString *type;				// The Device Group's type, eg. 'development_devicegroup'
@property (nonatomic, strong) NSMutableArray *models;		// The Device Group's source code as models
@property (nonatomic, strong) NSMutableArray *devices;		// The Device Group's associated devices

// Properties that are NOT saved

@property (nonatomic, strong) NSMutableDictionary *data;	// The API representation
@property (nonatomic, strong) NSArray *history;			// The device group's deployment history
@property (nonatomic, readwrite) char squinted;			// Has the Device Group's code (if any) been compiled + other status
														// Bit		Meaning
														//  1		Device Code compiled
														//  2		Agent Code compiled
														//  3		Each model's code fields need saving (product to project)
														//  4        Model has just been uploaded successfully


@end
