

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegateUtilities.h"

@implementation AppDelegate(AppDelegateUtilities)


#pragma mark - NSToolbarDelegate Methods


- (void)toolbarWillAddItem:(NSNotification *)notification
{
    // This method is called when certain toolbar items are added to the toolbar,
    // to ensure their state is correctly reflected at that point.
    // log-streaming and logging, allowing the toolbar item to indicate progress.
    // Stream items will go dark green while we are adding them to the log stream
    // (which may require the creation of a new log stream, which takes time) and
    // then black when streaming is taking place. We make sure we apply the correct
    // state for the currently selected device and update as the selection changes.
    // Login items show an indicator when the user is logged in, and hide that
    // indicator when the user is not logged in
    
    id item = [notification.userInfo objectForKey:@"item"];

	if ([item isKindOfClass:[LoginToolbarItem class]])
	{
		LoginToolbarItem *ltbi = (LoginToolbarItem *)item;
		ltbi.isLoggedIn = ide.isLoggedIn;
		[ltbi validate];
		loginAndOutItem = ltbi;
	}

	if ([item isKindOfClass:[StreamToolbarItem class]])
	{
		StreamToolbarItem *stbi = (StreamToolbarItem *)item;
		stbi.state = kStreamToolbarItemStateOff;

		if (selectedDevice != nil)
		{
			NSString *did = [selectedDevice objectForKey:@"id"];

			if (ide.isLoggedIn && [ide isDeviceLogging:did]) stbi.state = kStreamToolbarItemStateOn;
		}

		[stbi validate];
		streamLogsItem = stbi;
	}
}



- (void)toolbarDidRemoveItem:(NSNotification *)notification
{
	// This method is called when certain toolbar items are removed from the toolbar,
    // to ensure their state is correctly reset at that point
    
    id item = [notification.userInfo objectForKey:@"item"];

	if ([item isKindOfClass:[StreamToolbarItem class]])
	{
		StreamToolbarItem *stbi = (StreamToolbarItem *)item;
		stbi.state = kStreamToolbarItemStateOff;
		[stbi validate];
		streamLogsItem = stbi;
	}
}



#pragma mark - File Path Methods


- (NSString *)getDisplayPath:(NSString *)path
{
    // Convert a path string to the format required by the user's preference
    
    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];

	if (index == 0) path = [self getAbsolutePath:currentProject.path :path];

	if (index == 2)
	{
		path = [self getAbsolutePath:currentProject.path :path];
		path = [self getRelativeFilePath:[@"~/" stringByStandardizingPath] :[path stringByDeletingLastPathComponent]];
	}

	return path;
}



- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath
{
    // This method takes an absolute location ('filePath') and returns a location relative
    // to another location ('basePath'). Typically, this is the path to the host
    // project

    basePath = [basePath stringByStandardizingPath];
    filePath = [filePath stringByStandardizingPath];

    NSString *theFilePath = filePath;

    NSInteger nf = [self numberOfFoldersInPath:theFilePath];
    NSInteger nb = [self numberOfFoldersInPath:basePath];

    if (nf > nb) // theFilePath.length > basePath.length
    {
        // The file path is longer than the base path
        
        NSRange r = [theFilePath rangeOfString:basePath];

        if (r.location != NSNotFound)
        {
            // The file path contains the base path, eg.
            // '/Users/smitty/documents/github/squinter/files'
            // contains
            // '/Users/smitty/documents/github/squinter'

            theFilePath = [theFilePath substringFromIndex:r.length];
            //theFilePath = [theFilePath stringByAppendingFormat:@"/%@", theFileName];
        }
        else
        {
            // The file path does not contain the base path, eg.
            // '/Users/smitty/downloads'
            // doesn't contain
            // '/Users/smitty/documents/github/squinter'

            theFilePath = [self getPathDelta:basePath :theFilePath];
            //theFilePath = [theFilePath stringByAppendingString:theFileName];
        }
    }
    else if (nf < nb) // theFilePath.length < basePath.length
    {
        NSRange r = [basePath rangeOfString:theFilePath];

        if (r.location != NSNotFound)
        {
            // The base path contains the file path, eg.
            // '/Users/smitty/documents/github/squinter/files'
            // contains
            // '/Users/smitty/documents'

            theFilePath = [basePath substringFromIndex:r.length];
            NSArray *filePathParts = [theFilePath componentsSeparatedByString:@"/"];
            //theFilePath = theFileName;

            // Add in '../' for each directory in the base path but not in the file path

            for (NSInteger i = 0 ; i < filePathParts.count - 1 ; ++i)
            {
                theFilePath = [@"../" stringByAppendingString:theFilePath];
            }
        }
        else
        {
            // The base path doesn't contains the file path, eg.
            // '/Users/smitty/documents/github/squinter/files'
            // doesn't contain
            // '/Users/smitty/downloads'

            theFilePath = [self getPathDelta:basePath :theFilePath];
            //theFilePath = [theFilePath stringByAppendingString:theFileName];
        }
    }
    else
    {
        // The two paths are the same length

        if ([theFilePath compare:basePath] == NSOrderedSame)
        {
            // The file path and the base patch are the same, eg.
            // '/Users/smitty/documents/github/squinter'
            // matches
            // '/Users/smitty/documents/github/squinter'

            theFilePath = @"";
        }
        else
        {
            // The file path and the base patch are not the same, eg.
            // '/Users/smitty/documents/github/squinter'
            // matches
            // '/Users/smitty/downloads/archive/nofiles'

            theFilePath = [self getPathDelta:basePath :theFilePath];
            //theFilePath = [theFilePath stringByAppendingString:theFileName];
        }
    }

    return theFilePath;
}



- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath
{
    // Return as a string (in the form '../../') of the path 'filePath'
    // relative to 'basePath'
    
    NSInteger location = -1;
    NSArray *fileParts = [filePath componentsSeparatedByString:@"/"];
    NSArray *baseParts = [basePath componentsSeparatedByString:@"/"];

    for (NSUInteger i = 0 ; i < fileParts.count ; ++i)
    {
        // Compare the two paths, directory by directory, starting at the left
        // then break when they no longer match

        NSString *filePart = [fileParts objectAtIndex:i];
        NSString *basePart = [baseParts objectAtIndex:i];

        if ([filePart compare:basePart] != NSOrderedSame)
        {
            location = i;
            break;
        }
    }

    NSString *path = @"";

    for (NSUInteger i = location ; i < baseParts.count ; ++i)
    {
        // Add a '../' for every non-matching base path directory

        path = [path stringByAppendingString:@"../"];
    }

    for (NSUInteger i = location ; i < fileParts.count ; ++i)
    {
        // Then add the actual file path directries from the no matching part

        path = [path stringByAppendingFormat:@"%@/", [fileParts objectAtIndex:i]];
    }

    // Remove the final /

    path = [path substringToIndex:(path.length - 1)];

    return path;
}



- (NSInteger)numberOfFoldersInPath:(NSString *)path
{
    // Count the number of directories in a path
    
    NSArray *parts = [path componentsSeparatedByString:@"/"];
    return (parts.count - 1);
}



- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath
{
    // Expand a relative path that is relative to the base path to an absolute path

    NSString *absolutePath = [basePath stringByAppendingFormat:@"/%@", relativePath];
    absolutePath = [absolutePath stringByStandardizingPath];
    return absolutePath;
}



- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath
{
    // Takes an absolute path to a project and a file path relative to that same project,
    // and returns the user's preferred style of path for printing

    NSInteger pathType = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];

    switch (pathType)
    {
        case 0:
            // Absolute Path
            return [self getAbsolutePath:projectPath :filePath];
        case 1:
            // Path relative to project DEFAULT
            return filePath;
            break;

        default:
            // Path relative to home
            return [@"~" stringByAppendingString:[self getRelativeFilePath:@"~" :[self getAbsolutePath:projectPath :filePath]]];
            break;
    }
}



#pragma mark - Boookmark Methods


// The following two methods convert URLs <-> bookmark records

- (NSData *)bookmarkForURL:(NSURL *)url
{
    NSError *error = nil;
    NSData *bookmark = [url bookmarkDataWithOptions: NSURLBookmarkCreationSuitableForBookmarkFile
                     includingResourceValuesForKeys: nil
                                      relativeToURL: nil
                                              error: &error];

    if (error != nil) return nil;
    return bookmark;
}



- (NSURL *)urlForBookmark:(NSData *)bookmark
{
    NSError *error = nil;
    BOOL isStale = NO;

    NSURL *url = [NSURL URLByResolvingBookmarkData: bookmark
                                           options: NSURLBookmarkResolutionWithoutUI
                                     relativeToURL: nil
                               bookmarkDataIsStale: &isStale
                                             error: &error];

    // There was an error, so return 'nil' as a warning

	if (error != nil)
	{
		stale = YES;
		return nil;
	}

	stale = isStale;
    return url;
}



#pragma mark - Network Activity Progress Indicator Methods


// The following two methods are called to start and stop the main window's progress
// indicator by adding an operation to the main Grand Central Dispatch queue.
// It's done this way because these methods may be triggered from other queues

- (void)startProgress
{
	NSOperationQueue *main = [NSOperationQueue mainQueue];
	[main addOperationWithBlock:^{
		[connectionIndicator startAnimation:self];
		connectionIndicator.hidden = NO;
	}];
}



- (void)stopProgress
{
	NSOperationQueue *main = [NSOperationQueue mainQueue];
	[main addOperationWithBlock:^{
		[connectionIndicator stopAnimation:self];
		connectionIndicator.hidden = YES;
	}];
}



#pragma mark - Logging Utility Methods


- (void)parseLog
{
    // Scan the log view text for certain entities,
    // primarily agent URLs
    
    logTextView.editable = YES;
    [logTextView checkTextInDocument:nil];
    logTextView.editable = NO;
}



- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold
{
	// Set the log window's basic text settings based on preferences

	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font;

	font = isBold
	? [fontManager fontWithFamily:fontName traits:NSBoldFontMask weight:10 size:fontSize]
	: [NSFont fontWithName:fontName size:fontSize];

	return font;
}



- (void)setColours
{
	// Populate the 'colors' array with a set of colours for logging different devices

	NSString *start = @"com.bps.squinter.dev";

	if (colors.count > 0) [colors removeAllObjects];

	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

	for (NSUInteger i = 1 ; i < 6 ; ++i)
	{
		NSString *key = [start stringByAppendingFormat:@"%li.red", (long)i];
		NSNumber *red = [defaults objectForKey:key];
		key = [start stringByAppendingFormat:@"%li.green", (long)i];
		NSNumber *green = [defaults objectForKey:key];
		key = [start stringByAppendingFormat:@"%li.blue", (long)i];
		NSNumber *blue = [defaults objectForKey:key];

		[colors addObject:[NSColor colorWithSRGBRed:red.floatValue
											  green:green.floatValue
											   blue:blue.floatValue
											  alpha:1.0]];
	}

	/*
	 [colors addObject:[NSColor colorWithSRGBRed:1.0 green:0.2 blue:0.6 alpha:1.0]]; // Strawberry (138)
	 [colors addObject:[NSColor colorWithSRGBRed:1.0 green:0.8 blue:0.5 alpha:1.0]]; // Tangerine (213)
	 [colors addObject:[NSColor colorWithSRGBRed:0.4 green:0.9 blue:0.5 alpha:1.0]]; // Flora (green) (200)
	 [colors addObject:[NSColor colorWithSRGBRed:1.0 green:1.0 blue:1.0 alpha:1.0]]; // White (255)
	 [colors addObject:[NSColor colorWithSRGBRed:0.0 green:0.0 blue:0.0 alpha:1.0]]; // Black (0)
	 [colors addObject:[NSColor colorWithSRGBRed:0.5 green:0.5 blue:0.5 alpha:1.0]]; // Mid-grey (127)
	 [colors addObject:[NSColor colorWithSRGBRed:0.8 green:0.8 blue:0.8 alpha:1.0]]; // Light-grey (204)
	 [colors addObject:[NSColor colorWithSRGBRed:0.3 green:0.3 blue:0.3 alpha:1.0]]; // Dark-grey (76)
	 [colors addObject:[NSColor colorWithSRGBRed:1.0 green:0.9 blue:0.5 alpha:1.0]]; // Banana ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.6 green:0.2 blue:1.0 alpha:1.0]]; // Grape ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.0 green:0.6 blue:1.0 alpha:1.0]]; // Aqua ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.5 green:0.8 blue:1.0 alpha:1.0]]; // Sky ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.8 green:0.5 blue:1.0 alpha:1.0]]; // Lavender ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.0 green:0.6 blue:0.6 alpha:1.0]]; // Teal ()
	 [colors addObject:[NSColor colorWithSRGBRed:0.3 green:0.6 blue:0.0 alpha:1.0]]; // Fern ()
	 */
}



- (void)setLoggingColours
{
	// Pick colours from the 'colours' array that are darker/lighter than the log background
	// as approrpriate

	[logColors removeAllObjects];

	NSInteger back = [self perceivedBrightness:backColour];
	// NSInteger fore = [self perceivedBrightness:textColour];

	if (back > 200)
	{
		// Background is light

		for (NSColor *colour in colors)
		{
			NSInteger stock = [self perceivedBrightness:colour];

			if (back - stock > 100)
			{
				// Colour is dark enough to use against this background
				// But is it too close to the text colour ?

				[logColors addObject:colour];
			}
		}
	}
	else
	{
		// Background is dark

		for (NSColor *colour in colors)
		{
			NSInteger stock = [self perceivedBrightness:colour];

			if (stock - back > 100) [logColors addObject:colour];
		}
	}
}



#pragma mark - Preferences Panel Subsidiary Methods


// The following seven methods apply the colour chosen in the picker to the relevant colorWell

- (void)showPanelForText { [textColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForBack { [backColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev1 { [dev1ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev2 { [dev2ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev3 { [dev3ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev4 { [dev4ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev5 { [dev5ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }



#pragma mark - Sleep/Wake Methods


- (void)receiveSleepNote:(NSNotification *)note
{
    [self writeStringToLog:@"Device sleeping..." :YES];

    if (ide.isLoggedIn)
    {
        // We're logged in when the device is about to sleep, so kill all connections
        // but remain logged in — we will reconnect on wake

        [ide killAllConnections];

        reconnectAfterSleepFlag = YES;
    }
}



- (void)receiveWakeNote:(NSNotification *)note
{
    [self writeStringToLog:@"Device woken" :YES];

    if (reconnectAfterSleepFlag)
    {
        if (!ide.isLoggedIn)
        {
            [self loginOrOut:nil];
        }
        else
        {
            reconnectAfterSleepFlag = NO;
        }
    }
}



#pragma mark - Utility Methods


- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key
{
    NSDictionary *rd = nil;

    // This extracts the required key, wherever it is in the source (API) data
    // We also check here for null values, converting them to true nil

    if ([key compare:@"id"] == NSOrderedSame) return [apiDict objectForKey:@"id"];
    if ([key compare:@"type"] == NSOrderedSame) return [apiDict objectForKey:@"type"];

    // Attributes General properties

    if ([key compare:@"created_at"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.created_at"];
    if ([key compare:@"updated_at"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.updated_at"];

    if ([key compare:@"name"] == NSOrderedSame)
    {
        NSString *name = [apiDict valueForKeyPath:@"attributes.name"];
        if ((NSNull *)name == [NSNull null]) return nil;
        return name;
    }

    if ([key compare:@"description"] == NSOrderedSame)
    {
        NSString *desc = [apiDict valueForKeyPath:@"attributes.description"];
        if ((NSNull *)desc == [NSNull null]) return nil;
        return desc;
    }

    // Attributes Device properties

    if ([key compare:@"device_online"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.device_online"];
    if ([key compare:@"mac_address"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.mac_address"];
    if ([key compare:@"imp_type"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.imp_type"];
    if ([key compare:@"agent_id"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.agent_id"];
    if ([key compare:@"agent_running"] == NSOrderedSame) return [NSNumber numberWithBool:[[apiDict valueForKeyPath:@"attributes.agent_running"] boolValue]];
    if ([key compare:@"swversion"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.swversion"];

	if ([key compare:@"device_state_changed_at"] == NSOrderedSame) return [self convertTimestring:[apiDict valueForKeyPath:@"attributes.device_state_changed_at"]];

	if ([key compare:@"ip_address"] == NSOrderedSame)
	{
		NSString *ip = [apiDict valueForKeyPath:@"attributes.ip_address"];
		if ((NSNull *)ip == [NSNull null]) return nil;
		return ip;
	}

	if ([key compare:@"last_enrolled_at"] == NSOrderedSame)
	{
		NSString *date = [apiDict valueForKeyPath:@"attributes.last_enrolled_at"];
		if ((NSNull *)date == [NSNull null]) return nil;
		return [self convertTimestring:date];
	}

    // Attributes Deployment properties - non-nullable

    if ([key compare:@"flagged"] == NSOrderedSame) return [NSNumber numberWithBool:[[apiDict valueForKeyPath:@"attributes.flagged"] boolValue]];
    if ([key compare:@"sha"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.sha"];

    // Attributes Deployment properties - nullable

    if ([key compare:@"agent_code"] == NSOrderedSame)
    {
        NSString *ac = [apiDict valueForKeyPath:@"attributes.agent_code"];
        if ((NSNull *)ac == [NSNull null]) return nil;
        return ac;
    }

    if ([key compare:@"device_code"] == NSOrderedSame)
    {
        NSString *dc = [apiDict valueForKeyPath:@"attributes.device_code"];
        if ((NSNull *)dc == [NSNull null]) return nil;
        return dc;
    }

    if ([key compare:@"origin"] == NSOrderedSame)
    {
        NSString *or = [apiDict valueForKeyPath:@"attributes.origin"];
        if ((NSNull *)or == [NSNull null]) return nil;
        return or;
    }

    if ([key compare:@"tags"] == NSOrderedSame)
    {
        NSArray *tags = [apiDict valueForKeyPath:@"attributes.tags"];
        if ((NSNull *)tags == [NSNull null]) return nil;
        return tags;
    }

	if ([key compare:@"free_memory"] == NSOrderedSame) {
		NSNumber *num = [apiDict valueForKeyPath:@"attributes.free_memory"];
		if ((NSNull *)num == [NSNull null]) return nil;
		return num;
	}

	if ([key compare:@"rssi"] == NSOrderedSame) {
		NSNumber *num = [apiDict valueForKeyPath:@"attributes.rssi"];
		if ((NSNull *)num == [NSNull null]) return nil;
		return num;
	}

	if ([key compare:@"plan_id"] == NSOrderedSame) {
		NSString *plan = [apiDict valueForKeyPath:@"plan_id"];
		if ((NSNull *)plan == [NSNull null]) return nil;
		return plan;
	}

    // Relationships properties

    if ([key compare:@"product"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.product"];
    if ([key compare:@"devicegroup"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.devicegroup"];
	if ([key compare:@"min_supported_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.min_supported_deployment"];
	if ([key compare:@"production_target"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.production_target"];
    if ([key compare:@"min_supported_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.min_supported_deployment"];
	if ([key compare:@"current_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.current_deployment"];

    if ((NSNull *)rd == [NSNull null]) return nil;
    return rd;
}



- (void)updateDevicegroup:(Devicegroup *)devicegroup
{
    // Update the information held locally about a device group
    
    if (devicegroup != nil)
	{
		NSDictionary *dict = @{ @"action" : @"updatedevicegroup",
							    @"devicegroup" : devicegroup };

		[ide getDevicegroup:devicegroup.did :dict];

		// Pick up the action at **updateCodeStageTwo:**
	}
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
    // Exchange device group names Squinter <-> API
    // if 'back' is YES, we return the API name, otherwise the Squinter name
    
    NSArray *dgtypes = @[ @"production_devicegroup", @"factoryfixture_devicegroup", @"development_devicegroup",
                          @"pre_factoryfixture_devicegroup", @"pre_production_devicegroup"];
    NSArray *dgnames = @[ @"Production", @"Factory Fixture", @"Development", @"Factory Test", @"Production Test"];

    for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
    {
        NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];

        if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
    }

    if (!back) return @"Unknown";
    return @"development_devicegroup";
}



- (Project *)getParentProject:(Devicegroup *)devicegroup
{
    // Iterate through the open projects and return the project to which
    // the specified device group belongs
    
    for (Project *ap in projectArray)
    {
        if (ap.devicegroups.count > 0)
        {
            for (Devicegroup *adg in ap.devicegroups)
            {
                if (adg == devicegroup) return ap;
            }
        }
    }

    return nil;
}



- (NSDate *)convertTimestring:(NSString *)dateString
{
    // Return an NSDate object the represents the date and time specified in the input string
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-DD'T'hh:mm:ss.sZ"];
    NSLog(@"convertTimestring: %@", dateString);
    return [inLogDef dateFromString:dateString];
}



- (NSString *)formatTimestamp:(NSString *)timestamp
{
	// The input string, which records a date and time, to meet Squinter's requirements
    
    timestamp = [outLogDef stringFromDate:[inLogDef dateFromString:timestamp]];
	timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
	timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
	return timestamp;
}



- (NSString *)getErrorMessage:(NSUInteger)index
{
    // Return an error message string for a specific error code
    
    switch (index)
    {
        case kErrorMessageNoSelectedDevice:
            return @"[ERROR] You have not selected a device. Choose one from the 'Current Device' pop-up below.";

        case kErrorMessageNoSelectedDevicegroup:
            return @"[ERROR] You have not selected a device group. Go to 'Device Groups'  > 'Project's Device Groups' to select one.";

        case kErrorMessageNoSelectedProject:
            return @"[ERROR] You have not selected a project. Go to 'Projects' > 'Open Projects' to select one.";

        case kErrorMessageNoSelectedProduct:
            return @"[ERROR] You have not selected a product. Go to 'Projects' > 'Current Products' to select one.";

        case kErrorMessageMalformedOperation:
            return @"[ERROR] Malformed action request - no action specified.";
    }

    return @"No Error";
}



- (NSArray *)displayDescription:(NSString *)description :(NSInteger)maxWidth :(NSString *)spaces
{
    // Takes a device group or project description, adds a caption, and formats it as a series
    // of lines up to the specified length 'maxWidth', breaking at spaces not mid-word
    // Used by the 'showProjectInfo:' and 'showDevicegroupInfo:' methods

    description = [NSString stringWithFormat:@"Description: %@", description];

    NSInteger count = 0;
    NSMutableArray *lines = [[NSMutableArray alloc] init];

    while (count < description.length)
    {
        NSRange range = NSMakeRange(count, maxWidth);

        if (count + maxWidth > description.length) range = NSMakeRange(count, description.length - count);

        NSString *line = [description substringWithRange:range];
        NSInteger back = 1;
        BOOL done = NO;

        if (line.length == maxWidth)
        {
            // Only process a line if it's the full width

            do
            {
                // Work back from the list line character

                range = NSMakeRange(line.length - back, 1);
                NSString *last = [line substringWithRange:range];

                if ([last compare:@" "] == NSOrderedSame)
                {
                    // Found a space

                    done = YES;
                    line = [line substringToIndex:line.length - back];
                }
                else
                {
                    back++;
                }

            }
            while (!done);
        }

        [lines addObject:[spaces stringByAppendingString:line]];

        count = count + line.length + 1;
    }

    return lines;
}



- (void)setDevicegroupDevices:(Devicegroup *)devicegroup
{
    // Ensure the specified device group's 'devices' property references all of the
    // devices that have been assigned to the specified device group
    // This is typically performed after loading a project, as we don't store
    // this information
    
    if (devicesArray.count > 0)
    {
        for (NSMutableDictionary *device in devicesArray)
        {
            NSDictionary *dg = [self getValueFrom:device withKey:@"devicegroup"];
            NSString *dgid = [self getValueFrom:dg withKey:@"id"];

            if (devicegroup.did != nil && devicegroup.did.length > 0 && ([devicegroup.did compare:dgid] == NSOrderedSame))
            {
                if (devicegroup.devices == nil) devicegroup.devices = [[NSMutableArray alloc] init];

                BOOL flag = NO;

                NSString *dvn = [self getValueFrom:device withKey:@"name"];

                if (dvn == nil) dvn = [self getValueFrom:device withKey:@"id"];

                for (NSString *dgdevice in devicegroup.devices)
                {
                    if ([dvn compare:dgdevice] == NSOrderedSame)
                    {
                        // Device is already on the list

                        flag = YES;
                        break;
                    }
                }

                // Add the name to the list of device group devices as it's not already present

                if (!flag && dvn != nil) [devicegroup.devices addObject:dvn];
            }
        }
    }
}



- (void)setWorkingDirectory:(NSArray *)urls
{
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    workingDirectoryField.stringValue = path;
}



- (NSString *)getFontName:(NSInteger)index
{
    // Return the font name from an index in a font list pop-up
    
    NSString *fontName = @"";

    switch (index)
    {
        case 0:
            fontName = @"Andale Mono";
            break;

        case 1:
            fontName = @"Courier";
            break;

        case 2:
            fontName = @"Menlo";
            break;

        case 3:
            fontName = @"Monaco";
            break;

        case 4:
            fontName = @"Source Code Pro";
            break;

        default:
            fontName = @"Menlo";
            break;
    }

    return fontName;
}



- (NSInteger)perceivedBrightness:(NSColor *)colour
{
    // Returns the perceived brightness of the specified colour
    // Used to pick colours that will stand out against the log's background color

    CGFloat red, blue, green, alpha;
    [colour colorUsingColorSpace:[NSColorSpace deviceRGBColorSpace]];
    [colour getRed:&red green:&green blue:&blue alpha:&alpha];
    red = red * 255;
    blue = blue * 255;
    green = green * 255;
    return (NSInteger)sqrt((red * red * .241) + (green * green * .691) + (blue * blue * .068));
}



- (NSString *)getCloudName:(NSInteger)cloudCode
{
    // Return the actual name of the impCloud for a given code number
    
    if (cloudCode == 0) return @"AWS ";
    if (cloudCode == 1) return @"Azure ";
    return @"";
}



- (NSString *)recodeLogTags:(NSString *)string
{
    // Parse the input string for standard log tags and replace them with Squinter's own

    string = [string stringByReplacingOccurrencesOfString:@"[server.log]" withString:@"[Device]"];
    string = [string stringByReplacingOccurrencesOfString:@"[server.error]" withString:@"[Device]"];
    string = [string stringByReplacingOccurrencesOfString:@"[server.sleep]" withString:@"[Device]"];
    string = [string stringByReplacingOccurrencesOfString:@"[agent.log]" withString:@"[Agent]"];
    string = [string stringByReplacingOccurrencesOfString:@"[agent.error]" withString:@"[Agent]"];
    string = [string stringByReplacingOccurrencesOfString:@"[status]" withString:@"[Server]"];
    string = [string stringByReplacingOccurrencesOfString:@"[lastexitcode]" withString:@"[Exit Code]"];

    return string;
}


@end
