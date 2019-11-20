

//  Created by Tony Smith on 09/02/2015.
//  Copyright (c) 2015-18 Tony Smith. All rights reserved.


#import "AppDelegateUtilities.h"


@implementation AppDelegate(AppDelegateUtilities)


#pragma mark - File Path Manipulation and Presentation Methods


- (NSString *)getDisplayPath:(NSString *)filePath
{
    // Convert a path string to the format required by the user's preference
    // NOTE This assumes we are dealing the the current project
    // NOTE Called by 'InspectorView.m' - can we convert to 'getPrintPath:'
    
    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];

	if (index == 0 || index == 2) filePath = [self getAbsolutePath:currentProject.path :filePath];
	if (index == 2) filePath = [self getRelativeFilePath:[@"~/" stringByStandardizingPath] :[filePath stringByDeletingLastPathComponent]];

	return filePath;
}



- (NSString *)getPrintPath:(NSString *)projectPath :(NSString *)filePath
{
    // Takes an absolute path to a project and a file path relative to that same project,
    // and returns the user's preferred style of path for printing
    
    NSInteger index = [[defaults objectForKey:@"com.bps.squinter.displaypath"] integerValue];
    
    if (index == 0 || index == 2) filePath = [self getAbsolutePath:projectPath :filePath];
    if (index == 2) filePath = [@"~" stringByAppendingString:[self getRelativeFilePath:@"~" :filePath]];
    
    return filePath;
}



- (NSString *)getRelativeFilePath:(NSString *)basePath :(NSString *)filePath
{
    // This method takes an absolute location ('filePath') and returns a location relative
    // to another location ('basePath'). Typically, this is the path to the host project

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
            // The file path is present in the base path, eg.
            // '/Users/smitty/documents/github/squinter' contains '/Users/smitty/documents/github/squinter/files'

            theFilePath = [theFilePath substringFromIndex:r.length];
        }
        else
        {
            // The file path does not contain the base path, eg.
            // '/Users/smitty/downloads' doesn't contain '/Users/smitty/documents/github/squinter'

            theFilePath = [self getPathDelta:basePath :theFilePath];
        }
    }
    else if (nf < nb)
    {
        // filePath length < basePath length, ie.
        // file is ABOVE the project in the directory structure
        
        NSRange r = [basePath rangeOfString:theFilePath];

        if (r.location != NSNotFound)
        {
            // The base path fully contains the file path, eg.
            // '/Users/smitty/documents/github/squinter/files' contains '/Users/smitty/documents'
            
            // Get the path section between the base and the file, ie. the section not common to both, eg.
            // 'github/squinter/files'

            NSString *extraFilePath = [basePath substringFromIndex: r.length + 1];
            NSArray *extraFilePathParts = [extraFilePath componentsSeparatedByString:@"/"];
            
            // The filePath IS the common component, so just clear it...
            
            theFilePath = @"";

            // ...and add '../' for each directory in the base path but not in the file path

            for (NSInteger i = 0 ; i < extraFilePathParts.count ; ++i)
            {
                theFilePath = [@"../" stringByAppendingString:theFilePath];
            }
            
            // Remove the final / (it will be added later, with the filename)
            
            theFilePath = [theFilePath substringToIndex:(theFilePath.length - 1)];
        }
        else
        {
            // The base path doesn't contains the file path, eg.
            // '/Users/smitty/documents/github/squinter/files' doesn't contain '/Users/smitty/downloads'

            theFilePath = [self getPathDelta:basePath :theFilePath];
        }
    }
    else
    {
        // The two paths are the same length

        if ([theFilePath compare:basePath] == NSOrderedSame)
        {
            // The file path and the base patch are the same, eg.
            // '/Users/smitty/documents/github/squinter' matches '/Users/smitty/documents/github/squinter'

            theFilePath = @"";
        }
        else
        {
            // The file path and the base patch are not the same, eg.
            // '/Users/smitty/documents/github/squinter' matches '/Users/smitty/downloads/archive/nofiles'

            theFilePath = [self getPathDelta:basePath :theFilePath];
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



#pragma mark - File Watch Methods


- (BOOL)checkAndWatchFile:(NSString *)filePath
{
    // This method takes an ABSOLUTE file path and checks first that the file exists at that path
    // If if doesn't, it returns NO, otherwise it attempts to add the file to the watch queue, in
    // which case it returns YES

    if (filePath == nil || filePath.length == 0) return NO;

    BOOL result = [nsfm fileExistsAtPath:filePath];

    if (result)
    {
        // Instantiate the file watch queue if it hasn't been instantiated already

        if (fileWatchQueue == nil)
        {
            fileWatchQueue = [[VDKQueue alloc] init];
            [fileWatchQueue setDelegate:self];
        }

        // Add the file to the queue

        [fileWatchQueue addPath:filePath
                 notifyingAbout:VDKQueueNotifyAboutWrite | VDKQueueNotifyAboutDelete | VDKQueueNotifyAboutRename];
    }

    return result;
}



- (void)watchfiles:(Project *)project
{
    // Work through project's files and add them to the file watch queue
    // This is usually called only after opening an existing project

    NSString *aPath = [NSString stringWithFormat:@"%@/%@", project.path, project.filename];
    BOOL wasAdded = [self checkAndWatchFile:aPath];

    if (project.devicegroups.count > 0)
    {
        // The project contains one or more deviece groups so run through them
        // and add their component files to the watch queue

        for (Devicegroup *devicegroup in project.devicegroups)
        {
            if (devicegroup.models.count > 0)
            {
                // The device group contains one or more models (code representation objects)

                for (Model *model in devicegroup.models)
                {
                    aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", model.path, model.filename]];
                    wasAdded = [self checkAndWatchFile:aPath];

                    if (model.libraries.count > 0)
                    {
                        // The model code references one or more imported libraries

                        for (File *library in model.libraries)
                        {
                            aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", library.path, library.filename]];
                            wasAdded = [self checkAndWatchFile:aPath];
                        }
                    }

                    if (model.files.count > 0)
                    {
                        // The model code references one or more imported files

                        for (File *file in model.files)
                        {
                            aPath = [self getAbsolutePath:project.path :[NSString stringWithFormat:@"%@/%@", file.path, file.filename]];
                            wasAdded = [self checkAndWatchFile:aPath];
                        }
                    }
                }
            }
        }
    }

    if (!wasAdded) NSLog(@"Some files couldn't be added");
}



#pragma mark - Bookmark Handling Methods


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
		isStale = YES;
		return nil;
	}

	isStale = isStale;
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
    // Scan the log view text for certain entities, primarily agent URLs
    
    logTextView.editable = YES;
    [logTextView checkTextInDocument:nil];
    logTextView.editable = NO;
}



- (NSFont *)setLogViewFont:(NSString *)fontName :(NSInteger)fontSize :(BOOL)isBold
{
	// Return a suitable font for displaying entries in the log, based on user preference
    // NOTE Not sure this actually works to display bold fonts!
    
	NSFontManager *fontManager = [NSFontManager sharedFontManager];
	NSFont *font;

	font = isBold
	? [fontManager fontWithFamily:fontName traits:NSBoldFontMask weight:10 size:fontSize]
	: [NSFont fontWithName:fontName size:fontSize];

	return font;
}



- (void)setColours
{
    // Populate the array 'colors', which holds a series of NSColors that are
    // used to colour device log entries during streaming

    NSArray *savedColours = [defaults objectForKey:@"com.bps.squinter.devicecolours"];

    if (colors.count > 0) [colors removeAllObjects];

    if (savedColours.count != 0)
    {
        // If we have saved colours, use these to populate the array 'colors',
        // which is the array of NSColors from which device log entries are coloured

        for (NSArray *colour in savedColours)
        {
            [colors addObject:[NSColor colorWithSRGBRed:[[colour objectAtIndex:0] floatValue]
                                                  green:[[colour objectAtIndex:1] floatValue]
                                                   blue:[[colour objectAtIndex:2] floatValue]
                                                  alpha:1.0]];
        }
    }
    else
    {
        // If we have no saved colours, use the prefs panel colour wells to populate
        // the array 'colors'

        for (NSColorWell *colourWell in deviceColourWells)
        {
            [colors addObject:[NSColor colorWithSRGBRed:(float)colourWell.color.redComponent
                                                  green:(float)colourWell.color.blueComponent
                                                   blue:(float)colourWell.color.greenComponent
                                                  alpha:1.0]];
        }
    }

    /*
     Sample colours
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



#pragma mark - Preferences Panel Subsidiary Methods


// The following seven methods apply the colour chosen in the picker to the relevant colorWell
// on the Preferences panel's 'Log' tab

- (void)showPanelForText { [textColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForBack { [backColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev1 { [dev1ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev2 { [dev2ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev3 { [dev3ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev4 { [dev4ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev5 { [dev5ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev6 { [dev6ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev7 { [dev7ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }
- (void)showPanelForDev8 { [dev8ColorWell setColor:[NSColorPanel sharedColorPanel].color]; }



- (void)setWorkingDirectory:(NSArray *)urls
{
    // Set the path to the Working Directory on the Preferences panel's 'General' tab
    
    NSURL *url = [urls objectAtIndex:0];
    NSString *path = [url path];
    workingDirectoryField.stringValue = path;
}



- (NSString *)getFontName:(NSInteger)index
{
    // Return the font name from an index in the font list pop-up on the Preferences panel's 'Log' tab
    
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



#pragma mark - Sleep/Wake Methods


- (void)receiveSleepNote:(NSNotification *)note
{
    // Computer is about to sleep, so quickly display a note in the log
    // TODO Make this do something useful: correctly suspend logging and restart on wake
    
    if (ide.isLoggedIn)
    {
        // We're logged in when the device is about to sleep, so kill all connections
        // but remain logged in — we will reconnect on wake

        [self writeStringToLog:@"Mac sleeping - closing active connections..." :YES];
        [ide killAllConnections];

        reconnectAfterSleepFlag = YES;
    }
}



- (void)receiveWakeNote:(NSNotification *)note
{
    [self writeStringToLog:@"Mac woken" :YES];

    if (reconnectAfterSleepFlag)
    {
        reconnectAfterSleepFlag = NO;
        
        if (!ide.isLoggedIn) [self loginOrOut:nil];
    }
}



#pragma mark - API Data Extraction Methods


- (id)getValueFrom:(NSDictionary *)apiDict withKey:(NSString *)key
{
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
        return [self checkForNull:name];
    }

    if ([key compare:@"description"] == NSOrderedSame)
    {
        NSString *desc = [apiDict valueForKeyPath:@"attributes.description"];
        return [self checkForNull:desc];
    }

    // Attributes Device Group properties

    if ([key compare:@"env_vars"] == NSOrderedSame)
    {
        NSDictionary *envVars = [apiDict valueForKeyPath:@"attributes.env_vars"];
        return [self checkForNull:envVars];
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
		return [self checkForNull:ip];
	}

	if ([key compare:@"last_enrolled_at"] == NSOrderedSame)
	{
		NSString *date = [apiDict valueForKeyPath:@"attributes.last_enrolled_at"];
		date = [self checkForNull:date];
        return [self convertTimestring:date];
	}

    // Attributes Deployment properties - non-nullable

    if ([key compare:@"flagged"] == NSOrderedSame) return [NSNumber numberWithBool:[[apiDict valueForKeyPath:@"attributes.flagged"] boolValue]];
    if ([key compare:@"sha"] == NSOrderedSame) return [apiDict valueForKeyPath:@"attributes.sha"];

    // Attributes Deployment properties - nullable

    if ([key compare:@"agent_code"] == NSOrderedSame)
    {
        NSString *ac = [apiDict valueForKeyPath:@"attributes.agent_code"];
        return [self checkForNull:ac];
    }

    if ([key compare:@"device_code"] == NSOrderedSame)
    {
        NSString *dc = [apiDict valueForKeyPath:@"attributes.device_code"];
        return [self checkForNull:dc];
    }

    if ([key compare:@"origin"] == NSOrderedSame)
    {
        NSString *or = [apiDict valueForKeyPath:@"attributes.origin"];
        return [self checkForNull:or];
    }

    if ([key compare:@"tags"] == NSOrderedSame)
    {
        NSArray *tags = [apiDict valueForKeyPath:@"attributes.tags"];
       return [self checkForNull:tags];
    }

	if ([key compare:@"free_memory"] == NSOrderedSame)
    {
		NSNumber *num = [apiDict valueForKeyPath:@"attributes.free_memory"];
		return [self checkForNull:num];
	}

	if ([key compare:@"rssi"] == NSOrderedSame)
    {
		NSNumber *num = [apiDict valueForKeyPath:@"attributes.rssi"];
		return [self checkForNull:num];
	}

	if ([key compare:@"plan_id"] == NSOrderedSame)
    {
		NSString *plan = [apiDict valueForKeyPath:@"plan_id"];
		return [self checkForNull:plan];
	}

    // FROM 2.3.132
    
    if ([key compare:@"agent_url"] == NSOrderedSame) {
        NSString *url = [apiDict valueForKeyPath:@"attributes.agent_url"];
        return [self checkForNull:url];
    }

    // Relationships properties

    NSDictionary *rd = nil;
    
    if ([key compare:@"product"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.product"];
    if ([key compare:@"devicegroup"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.devicegroup"];
	if ([key compare:@"min_supported_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.min_supported_deployment"];
	if ([key compare:@"production_target"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.production_target"];
    if ([key compare:@"dut_target"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.dut_target"];
    if ([key compare:@"min_supported_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.min_supported_deployment"];
	if ([key compare:@"current_deployment"] == NSOrderedSame) rd = [apiDict valueForKeyPath:@"relationships.current_deployment"];

    return [self checkForNull:rd];
}



- (id)checkForNull:(id)value
{
    // Convert an input formal null value to nil
    
    return ((NSNull *)value == [NSNull null] ? nil : value);
}



#pragma mark - Device Group Utility Methods


- (void)updateDevicegroup:(Devicegroup *)devicegroup
{
    // Update the information held locally about a device group
    
    if (devicegroup != nil)
	{
		NSDictionary *dict = @{ @"action" : @"updatedevicegroup",
							    @"devicegroup" : devicegroup };

		[ide getDevicegroup:devicegroup.did :dict];

		// Pick up the action at 'updateCodeStageTwo:'
	}
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
    // Exchange device group names Squinter <-> API
    // if 'back' is YES, we return the API name, otherwise the Squinter name
    
    NSArray *dgtypes = @[ @"production_devicegroup", @"factoryfixture_devicegroup", @"dut_devicegroup", @"development_devicegroup",
                          @"pre_production_devicegroup", @"pre_factoryfixture_devicegroup", @"pre_dut_devicegroup"];
    NSArray *dgnames = @[ @"Production", @"Fixture", @"DUT", @"Development",
                          @"Test Production", @"Test Fixture", @"Test DUT"];

    for (NSUInteger i = 0 ; i < dgtypes.count ; ++i)
    {
        NSString *dgtype = back ? [dgnames objectAtIndex:i] : [dgtypes objectAtIndex:i];

        if ([dgtype compare:type] == NSOrderedSame) return (back ? [dgtypes objectAtIndex:i] : [dgnames objectAtIndex:i]);
    }

    if (!back) return @"Unknown";
    return @"development_devicegroup";
}



- (bool)checkDevicegroupName:(NSString *)name
{
    // Determine whether the supplied device group name is already taken within
    // the current project. The API allows groups to have the same name, but saving
    // files (ie. the OS) does not

    if (currentProject != nil)
    {
        if (currentProject.devicegroups.count > 0)
        {
            for (Devicegroup *dg in currentProject.devicegroups)
            {
                if ([name compare:dg.name] == NSOrderedSame) return YES;
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



- (Project *)getParentProject:(Devicegroup *)devicegroup
{
    // Iterate through the open projects and return the project to which
    // the specified device group belongs
    
    for (Project *project in projectArray)
    {
        if (project.devicegroups.count > 0)
        {
            for (Devicegroup *aDevicegroup in project.devicegroups)
            {
                if (aDevicegroup == devicegroup) return project;
            }
        }
    }

    return nil;
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
                
                NSString *dvn = [self getValueFrom:device withKey:@"id"]; // [self getValueFrom:device withKey:@"name"];
                
                if (devicegroup.devices.count > 0)
                {
                    for (NSString *dgdevice in devicegroup.devices)
                    {
                        if ([dvn compare:dgdevice] == NSOrderedSame)
                        {
                            // Device is already on the list
                            
                            flag = YES;
                            break;
                        }
                    }
                }
                
                // Add the name to the list of device group devices as it's not already present
                
                if (!flag && dvn != nil) [devicegroup.devices addObject:dvn];
            }
        }
    }
}



#pragma mark - Device Utility Methods


- (NSDictionary *)deviceWithID:(NSString *)devID
{
    for (NSDictionary *aDevice in devicesArray)
    {
        if ([(NSString *)[aDevice valueForKey:@"id"] compare:devID] == NSOrderedSame) return aDevice;
    }
    
    return nil;
}



#pragma mark - Date and Time Conversion Methods


- (NSDate *)convertTimestring:(NSString *)dateString
{
    // Return an NSDate object the represents the date and time specified in the input string
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-mm-DD'T'hh:mm:ss.sZ"];
    NSLog(@"convertTimestring: %@", dateString);
    return [inLogDef dateFromString:dateString];
}



- (NSString *)convertDate:(NSDate *)date
{
    // Convert an incoming date string to Squinter style
    
    NSString *dateString = [def stringFromDate:date];
    return dateString;
}



- (NSString *)formatTimestamp:(NSString *)timestamp
{
	// Update the input string, which records a date and time, to meet Squinter's requirements
    
    timestamp = [outLogDef stringFromDate:[inLogDef dateFromString:timestamp]];
	timestamp = [timestamp stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
	timestamp = [timestamp stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
	return timestamp;
}



#pragma mark - Alert Methods


- (void)projectAccountAlert:(Project *)project :(NSString *)action :(NSWindow *)sheetWindow
{
    // Warn that the project isn't in the current account
    
    [self accountAlert:[NSString stringWithFormat:@"Project “%@” is not associated with the current account", project.name]
                      :[NSString stringWithFormat:@"To %@ this project, you need to log out of your current account and log into the account it is associated with (ID %@)", action, project.aid]
                      :sheetWindow];
}


- (void)devicegroupAccountAlert:(Devicegroup *)devicegroup :(NSString *)action :(NSWindow *)sheetWindow
{
    // Warn that the device group isn't in the current account
    
    Project *project = [self getParentProject:devicegroup];
    
    [self accountAlert:[NSString stringWithFormat:@"Device group “%@” is not associated with the current account", devicegroup.name]
                      :[NSString stringWithFormat:@"To %@ this device group, you need to log out of your current account and log into the account it is associated with (ID %@)", action, project.aid]
                      :sheetWindow];
}



- (void)accountAlert:(NSString *)head :(NSString *)body :(NSWindow *)sheetWindow
{
    // Present a generic 'wrong account' warning
    
    NSAlert *alert = [[NSAlert alloc] init];
    alert.messageText = head;
    alert.informativeText = body;
    [alert addButtonWithTitle:@"OK"];
    [alert beginSheetModalForWindow:sheetWindow completionHandler:nil];
}


- (void)unsavedAlert:(NSString *)name :(NSString *)message :(NSWindow *)sheetWindow
{
    // FROM 2.3.128
    // Display a warning if the project is unsaved
    
    NSString *head= [NSString stringWithFormat:@"Project “%@” has not been saved", name];
    NSString *msg = [NSString stringWithFormat:@"Please save this project before %@.", message];
    [self accountAlert:head :msg :sheetWindow];
    
}



#pragma mark - Misc Methods


- (NSString *)getErrorMessage:(NSUInteger)index
{
    // Return an error message string for a specific error code
    
    switch (index)
    {
        case kErrorMessageNoSelectedDevice:
            return @"You have not selected a device. Choose one from the 'Current Device' pop-up below.";

        case kErrorMessageNoSelectedDevicegroup:
            return @"You have not selected a device group. Go to 'Device Groups'  > 'Project's Device Groups' to select one.";

        case kErrorMessageNoSelectedProject:
            return @"You have not selected a project. Go to 'Projects' > 'Open Projects' to select one.";

        case kErrorMessageNoSelectedProduct:
            return @"You have not selected a product. Go to 'Projects' > 'Current Products' to select one.";

        case kErrorMessageMalformedOperation:
            return @"Malformed action request - no action specified.";
    }

    return @"No Error";
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



- (BOOL)isCorrectAccount:(Project *)project
{
    // Returns YES or NO depending on whether the user is signed into the correct account

    return (project.aid.length > 0 && [project.aid compare:ide.currentAccount] != NSOrderedSame) ? NO : YES;
}



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



#pragma mark - NSSplitViewDelegate Methods


- (CGFloat)splitView:(NSSplitView *)splitView constrainSplitPosition:(CGFloat)proposedPosition ofSubviewAt:(NSInteger)dividerIndex
{
    // Position of split is full width (inspector hidden) or full width - 340 (inspector visible)
 
    CGFloat viewWidth = splitView.frame.size.width;
    
    if (isInspectorHidden)
    {
        // Inspector is hidden; does it want to show? If so allow it
        
        if (wantsToHide == 1 || proposedPosition < viewWidth)
        {
            wantsToHide = 0;
            isInspectorHidden = NO;
            return viewWidth - 340 - splitView.dividerThickness;
        }
        
        // Otherwise, disallow
        
        return viewWidth;
    }
    else
    {
        // Inspector is not hidden; does it want to hide? If so allow it
        
        if (wantsToHide == -1 || proposedPosition > (viewWidth - 340.0 - splitView.dividerThickness))
        {
            wantsToHide = 0;
            isInspectorHidden = YES;
            return viewWidth;
        }
        
        // Otherwise disallow;
        
        return viewWidth - 340.0 - splitView.dividerThickness;
    }
}


- (void)splitViewDidResizeSubviews:(NSNotification *)notification
{
#ifdef DEBUG
    NSLog(@"L: %.1f R: %.1f P: %.1f", logTextView.frame.size.width, iwvc.view.frame.size.width, splitView.frame.size.width);
#endif
}

/*
 
- (CGFloat)splitView:(NSSplitView *)splitView constrainMinCoordinate:(CGFloat)proposedMinimumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return 340.0 + splitView.dividerThickness;
}



- (CGFloat)splitView:(NSSplitView *)splitView constrainMaxCoordinate:(CGFloat)proposedMaximumPosition ofSubviewAt:(NSInteger)dividerIndex
{
    return splitView.frame.size.width - 340.0 - splitView.dividerThickness;
}

*/

- (BOOL)splitView:(NSSplitView *)splitView canCollapseSubview:(NSView *)subview
{
    NSView *rightView = [splitView.subviews objectAtIndex:1];
    if (rightView == iwvc.view) return YES;
    return NO;
}



- (BOOL)splitView:(NSSplitView *)splitView shouldHideDividerAtIndex:(NSInteger)dividerIndex
{
    return !isInspectorHidden;
}



@end
