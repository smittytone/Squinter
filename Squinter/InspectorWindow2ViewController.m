

//  Created by Tony Smith on 15/05/2015.
//  Copyright (c) 2017-18 Tony Smith. All rights reserved.


#import "InspectorWindow2ViewController.h"

@interface InspectorWindow2ViewController ()

@end

@implementation InspectorWindow2ViewController

@synthesize project, device, products, devices, mainWindowFrame, tabIndex;


#pragma mark - ViewController Methods


- (void)viewDidLoad
{
	[super viewDidLoad];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(appWillBecomeActive)
												 name:NSApplicationWillBecomeActiveNotification
											   object:nil];
	
	// Clear the content arrays:
	// 'projectKeys' are the left column contents
	// 'projectValues' are the right column contents
	// 'deviceKeys' are the left column contents
	// 'deviceValues' are the middle column contents
	
	projectKeys = [[NSMutableArray alloc] init];
	projectValues = [[NSMutableArray alloc] init];
	deviceKeys = [[NSMutableArray alloc] init];
	deviceValues = [[NSMutableArray alloc] init];
	
	// Set up date handling
	
	inLogDef = [[NSDateFormatter alloc] init];
	inLogDef.dateFormat = @"yyyy-MM-dd'T'HH:mm:ss.SSSZZZZZZ";
	inLogDef.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
	
	outLogDef = [[NSDateFormatter alloc] init];
	outLogDef.dateFormat = @"yyyy-MM-dd\nHH:mm:ss.SSS ZZZZZ";
	outLogDef.timeZone = [NSTimeZone localTimeZone];
	
	nswsw = NSWorkspace.sharedWorkspace;
	
	// Stop the HUD panel from floating above all windows
	
	NSPanel *panel = (NSPanel *)self.view.window;
	[panel setFloatingPanel:NO];
}



- (void)viewWillAppear
{
	[super viewWillAppear];
	
	// Hide the tables when there's nothing to show
	
	deviceOutlineView.hidden = YES;
	deviceOutlineView.delegate = self;
	//deviceOutlineView.gridStyleMask = NSTableViewSolidVerticalGridLineMask | NSTableViewSolidHorizontalGridLineMask;
	
	// Set up the tabs
	
	panelSelector.selectedSegment = 0;
	field.stringValue = @"No project selected";
}



- (void)positionWindow
{
	// Position the window to the right of screen
	
	NSScreen *ms = [NSScreen mainScreen];
	NSRect wframe = self.view.window.frame;
	
	if (ms.frame.size.width - (mainWindowFrame.origin.x + mainWindowFrame.size.width) > 340)
	{
		// There's room to put the inspector next to the main window
		
		wframe.origin.x = mainWindowFrame.origin.x + mainWindowFrame.size.width + 1;
	}
	else
	{
		// No room next to the main window, so put the panel above it
		
		wframe.origin.x = ms.frame.size.width - 340;
	}
	
	wframe.origin.y = mainWindowFrame.origin.y + mainWindowFrame.size.height - wframe.size.height;
	
	[self.view.window setFrame:wframe display:NO];
}



- (void)appWillBecomeActive
{
	if (self.view.window.isVisible) [self.view.window makeKeyAndOrderFront:self];
}



#pragma mark - Button Action Methods


- (IBAction)link:(id)sender
{
	// Project path buttons in the Inspector panel come here when clicked
	
	NSButton *linkButton = (NSButton *)sender;
	InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;
	NSString *path = [projectValues objectAtIndex:cellView.row];
	
	if (cellView.row < 5)
	{
		// This will be the location of the project file, which is already open,
		// so just reveal it in Finder...
		
		[nswsw selectFile:[NSString stringWithFormat:@"%@/%@", project.path, project.filename] inFileViewerRootedAtPath:project.path];
		return;
	}
	
	// ...otherwise open the file
	
	[nswsw openFile:path];
}



- (IBAction)goToURL:(id)sender
{
	// Agent URL buttons in the Inspector panel come here when clicked
	
	NSButton *linkButton = (NSButton *)sender;
	InspectorDataCellView *cellView = (InspectorDataCellView *)linkButton.superview;
	
	// Open the URL
	
	[nswsw openURL:[NSURL URLWithString:[deviceValues objectAtIndex:cellView.row]]];
}



#pragma mark - Data Setter Methods


- (void)setProject:(Project *)aProject
{
	// This is the 'project' property setter, which we use to populate
	// the two content arrays and trigger regeneration of the table view

	// Record the current project for comparison at the end of the method

	Project *oProject = project;
	project = aProject;

	// Clear the data arrays

	[projectKeys removeAllObjects];
	[projectValues removeAllObjects];
	
	// If project does equal nil, we ignore the content creation section
	// and reload the table with empty data
	
	if (project != nil)
	{
		[projectKeys addObject:@"Project Information"];
		[projectValues addObject:@""];
		
		[projectKeys addObject:@"Project Name"];
		[projectValues addObject:project.name];
		
		if (project.description != nil && project.description.length > 0)
		{
			[projectKeys addObject:@"Description"];
			[projectValues addObject:project.description];
		}
		
		if (products == nil || products.count == 0 || project.pid == nil)
		{
			[projectKeys addObject:@"ID"];
			[projectValues addObject:(project.pid != nil ? project.pid : @"Project not linked to a product")];
		}
		else
		{
			for (NSDictionary *product in products)
			{
				NSString *apid = [product objectForKey:@"id"];
				
				if ([apid compare:project.pid] == NSOrderedSame)
				{
					[projectKeys addObject:@"Product"];
					[projectValues addObject:[product valueForKeyPath:@"attributes.name"]];
				}
			}
		}
		
		[projectKeys addObject:@"Path"];
		
		if (project.path != nil)
		{
			[projectValues addObject:[NSString stringWithFormat:@"%@/%@", project.path, project.filename]];
		}
		else
		{
			[projectValues addObject:@"Project has not yet been saved"];
		}
		
		[projectKeys addObject:@"Device Group Information"];
		[projectValues addObject:@""];
		
		if (project.devicegroups != nil && project.devicegroups.count > 0)
		{
			NSUInteger dgcount = 1;
			
			for (Devicegroup *devicegroup in project.devicegroups)
			{
				if (dgcount > 1)
				{
					[projectKeys addObject:@" "];
					[projectValues addObject:@" "];
				}
				
				[projectKeys addObject:[NSString stringWithFormat:@"Device Group %li", (long)dgcount]];
				[projectValues addObject:devicegroup.name];
				[projectKeys addObject:@"ID"];
				
				if (devicegroup.did != nil && devicegroup.did.length > 0)
				{
					[projectValues addObject:devicegroup.did];
				}
				else
				{
					[projectValues addObject:@"Not uploaded"];
				}
				
				[projectKeys addObject:@"Type"];
				[projectValues addObject:[self convertDevicegroupType:devicegroup.type :NO]];
				
				if (devicegroup.description != nil && devicegroup.description.length > 0)
				{
					[projectKeys addObject:@"Description"];
					[projectValues addObject:devicegroup.description];
				}
				
				if (devicegroup.models.count > 0)
				{
					NSUInteger modcount = 1;
					
					for (Model *model in devicegroup.models)
					{
						NSString *typeString = [model.type compare:@"agent"] == NSOrderedSame ? @"Agent" : @"Device";
						
						if ([typeString compare:@"Agent"] == NSOrderedSame)
						{
							[projectKeys addObject:@"Agent Code Information"];
						}
						else
						{
							[projectKeys addObject:@"Device Code Information"];
						}
						
						[projectValues addObject:@""];
						
						[projectKeys addObject:[NSString stringWithFormat:@"%@ Code File", typeString]];
						[projectValues addObject:model.filename];
						[projectKeys addObject:@"Path "];
						[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :model.path], model.filename]];
						
						[projectKeys addObject:@"Uploaded"];
						NSString *date = model.updated;
						
						if (date != nil && date.length > 0)
						{
							date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
							date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
							date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
							[projectValues addObject:date];
						}
						else
						{
							[projectValues addObject:@"No code uploaded"];
						}
						
						[projectKeys addObject:@"SHA"];
						[projectValues addObject:(model.sha != nil && model.sha.length > 0 ? model.sha : @"No code uploaded")];
						
						if (model.libraries != nil && model.libraries.count > 0)
						{
							NSUInteger libcount = 1;
							
							for (File *library in model.libraries)
							{
								[projectKeys addObject:[NSString stringWithFormat:@"Library %li", (long)libcount]];
								[projectValues addObject:library.filename];
								[projectKeys addObject:@"Path"];
								[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :library.path], library.filename]];
								
								++libcount;
							}
						}
						else
						{
							[projectKeys addObject:@"Libraries"];
							[projectValues addObject:@"No local libraries imported"];
						}
						
						if (model.files != nil && model.files.count > 0)
						{
							NSUInteger filecount = 1;
							
							for (File *file in model.files)
							{
								[projectKeys addObject:[NSString stringWithFormat:@"File %li", (long)filecount]];
								[projectValues addObject:file.filename];
								[projectKeys addObject:@"Path "];
								[projectValues addObject:[NSString stringWithFormat:@"%@/%@", [self getAbsolutePath:project.path :file.path], file.filename]];
								
								++filecount;
							}
						}
						else
						{
							[projectKeys addObject:@"Files"];
							[projectValues addObject:@"No local files imported"];
						}
						
						++modcount;
					}
				}
				
				++dgcount;
			}
		}
		else
		{
			[projectKeys addObject:@"Device Groups"];
			[projectValues addObject:@"None"];
		}
	}

	if (panelSelector.selectedSegment == 0)
	{
		// The Project 'tab' is already selected, so update
		// the NSOutlineView to reflect the new project

		[deviceOutlineView reloadData];
		[deviceOutlineView setNeedsDisplay];

		if (oProject != nil && aProject != nil && deviceOutlineView.isHidden)
		{
			// Only show the NSOutlineView if it is already hidden
			// AND both the old and new projects are not nil, ie. only if the
			// change is nil -> project, project -> nil or project -> project
			deviceOutlineView.hidden = NO;
			field.hidden = YES;
		}
	}
}



- (void)setDevice:(NSMutableDictionary *)aDevice
{
	// This is the 'device' property setter, which we use to populate
	// the two content arrays and trigger regeneration of the table view

	// Record the current device for comparison at the end of the method
	
	NSMutableDictionary *oDevice = device;
	device = aDevice;

	// Clear the data arrays

	[deviceKeys removeAllObjects];
	[deviceValues removeAllObjects];
	
	// If device does equal nil, we ignore the content creation section
	// and reload the table with empty data
	
	if (device != nil)
	{
		[deviceKeys addObject:@"Device Information"];
		[deviceValues addObject:@""];
		[deviceKeys addObject:@"Name "];
		[deviceValues addObject:[device valueForKeyPath:@"attributes.name"]];
		[deviceKeys addObject:@"ID "];
		[deviceValues addObject:[device objectForKey:@"id"]];
		
		NSString *type = [device valueForKeyPath:@"attributes.imp_type"];
		if ((NSNull *)type == [NSNull null]) type = nil;
		if (type != nil )
		{
			[deviceKeys addObject:@"Type "];
			[deviceValues addObject:type];
		}
		
		NSString *version = [device valueForKeyPath:@"attributes.swversion"];
		if ((NSNull *)version == [NSNull null]) version = nil;
		[deviceKeys addObject:@"impOS "];
		if (version != nil )
		{
			NSArray *parts = [version componentsSeparatedByString:@" - "];
			parts = [[parts objectAtIndex:1] componentsSeparatedByString:@"-"];
			
			[deviceValues addObject:[parts objectAtIndex:1]];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}
		
		NSNumber *number = [device valueForKeyPath:@"attributes.free_memory"];
		if ((NSNull *)number == [NSNull null]) number = nil;
		[deviceKeys addObject:@"Free RAM "];
		[deviceValues addObject:(number != nil ? [NSString stringWithFormat:@"%@KB", number] : @"Unknown")];
		
		[deviceKeys addObject:@"Network Information"];
		[deviceValues addObject:@""];
		
		NSString *mac = [device valueForKeyPath:@"attributes.mac_address"];
		mac = [mac stringByReplacingOccurrencesOfString:@":" withString:@""];
		[deviceKeys addObject:@"MAC "];
		[deviceValues addObject:mac];
		
		NSNumber *boolean = [device valueForKeyPath:@"attributes.device_online"];
		NSString *string = (boolean.boolValue) ? @"Online" : @"Offline";
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:string];
		[deviceKeys addObject:@"IP "];
		
		if ([string compare:@"Online"] == NSOrderedSame)
		{
			NSNumber *ip = [device valueForKeyPath:@"attributes.ip_address"];
			if ((NSNull *)ip == [NSNull null]) ip = nil;
			[deviceValues addObject:(ip != nil ? ip : @"Unknown")];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}
		
		[deviceKeys addObject:@"Agent Information"];
		[deviceValues addObject:@""];
		
		boolean = [device valueForKeyPath:@"attributes.agent_running"];
		string = (boolean.boolValue) ? @"Online" : @"Offline";
		[deviceKeys addObject:@"Status "];
		[deviceValues addObject:string];
		
		string = [device valueForKeyPath:@"attributes.agent_id"];
		if ((NSNull *)string == [NSNull null]) string = nil;
		[deviceKeys addObject:@"Agent URL "];
		[deviceValues addObject:(string != nil ? [@"https://agent.electricimp.com/" stringByAppendingString:string] : @"No agent")];
		
		[deviceKeys addObject:@"BlinkUp Information"];
		[deviceValues addObject:@""];
		
		NSString *date = [device valueForKeyPath:@"attributes.last_enrolled_at"];
		if ((NSNull *)date == [NSNull null]) date = nil;
		[deviceKeys addObject:@"Last Enrolled "];
		
		if (date != nil)
		{
			date = [outLogDef stringFromDate:[inLogDef dateFromString:date]];
			date = [date stringByReplacingOccurrencesOfString:@"GMT" withString:@""];
			date = [date stringByReplacingOccurrencesOfString:@"Z" withString:@"+00:00"];
			[deviceValues addObject:date];
		}
		else
		{
			[deviceValues addObject:@"Unknown"];
		}
		
		[deviceKeys addObject:@"Device Group Information"];
		[deviceValues addObject:@""];
		
		NSDictionary *dg = [device valueForKeyPath:@"relationships.devicegroup"];
		if ((NSNull *)dg == [NSNull null]) dg = nil;
		if (dg != nil)
		{
			NSString *dgid = [dg objectForKey:@"id"];
			BOOL got = NO;
			
			for (Devicegroup *devicegroup in project.devicegroups)
			{
				if ([devicegroup.did compare:dgid] == NSOrderedSame)
				{
					[deviceKeys addObject:@"Name "];
					[deviceValues addObject:devicegroup.name];
					got = YES;
					break;
				}
			}
			
			if (!got)
			{
				[deviceKeys addObject:@"ID "];
				[deviceValues addObject:dgid];
			}
		}
		else
		{
			[deviceKeys addObject:@"ID "];
			[deviceValues addObject:@"Unassigned"];
		}
	}
	
	if (panelSelector.selectedSegment == 1)
	{
		// The Device 'tab' is already selected, so update
		// the NSOutlineView to reflect the new device

		[deviceOutlineView reloadData];
		[deviceOutlineView setNeedsDisplay];

		if (oDevice != nil && aDevice != nil && deviceOutlineView.isHidden)
		{
			// Only show the NSOutlineView if it is already hidden
			// AND both the old and new projects are not nil, ie. only if the
			// change is nil -> device, device -> nil or device -> device
			deviceOutlineView.hidden = NO;
			field.hidden = YES;
		}
	}
}



#pragma mark - Misc Methods


- (void)setTab:(NSUInteger)aTab
{
	// This is the 'tabIndex' setter method, which we trap in order
	// to trigger a switch to the implicitly requested tab
	
	if (aTab > panelSelector.segmentCount || aTab == panelSelector.selectedSegment) return;
	panelSelector.selectedSegment = aTab;
	[self switchTable:nil];
}



- (IBAction)switchTable:(id)sender
{
	// This method is called when the user clicks on the NSSegmentedControl, or code
	// calls setTab: (in which case 'sender' is nil
	
	NSInteger aTab = panelSelector.selectedSegment;
	tabIndex = aTab;
	
	if (aTab == 0)
	{
		// This is the project panel. If it is empty, just show the message
		
		if (project == nil || projectKeys.count == 0)
		{
			deviceOutlineView.hidden = YES;
			field.stringValue = @"No project selected";
			field.hidden = NO;
		}
		else
		{
			[deviceOutlineView reloadData];
			[deviceOutlineView setNeedsDisplay];

			deviceOutlineView.hidden = NO;
			field.hidden = YES;
		}
	}
	else
	{
		// This is the project panel. If it is empty, just show the message
		
		if (device == nil || deviceKeys.count == 0)
		{
			deviceOutlineView.hidden = YES;
			field.stringValue = @"No device selected";
			field.hidden = NO;
		}
		else
		{
			[deviceOutlineView reloadData];
			[deviceOutlineView setNeedsDisplay];

			deviceOutlineView.hidden = NO;
			field.hidden = YES;
		}
	}
}



- (BOOL)isLinkRow:(NSInteger)row
{
	// Does the title column of content row being displayed
	// include the word 'path'? If so the content is a link
	// so we return YES so that the table data source method knows
	// which type of NSTableCellView to use
	
	NSString *key = [projectKeys objectAtIndex:row];
	NSString *value = [projectValues objectAtIndex:row];
	if ([key containsString:@"Path"] && value.length > 1 ) return YES;
	return NO;
}



- (BOOL)isURLRow:(NSInteger)row
{
	// Does the content column of content row being displayed
	// include the word 'http:'? If so the content is a link
	// so we return YES so that the table data source method knows
	// which type of NSTableCellView to use
	
	NSString *value = [deviceValues objectAtIndex:row];
	if ([value containsString:@"https:"]) return YES;
	return NO;
}



#pragma mark - NSOutlineView Delegate and DataSource Methods


- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item
{
	// Nothing is expandable
	
	return NO;
}



- (BOOL)outlineView:(NSOutlineView *)outlineView shouldSelectItem:(id)item
{
	// Nothing is selectable
	
	return NO;
}



- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item
{
	// This will always be the number of items in the root item, ie.
	// the number of items in the appropriate data set
	
	return (item == nil ? (tabIndex == 0 ? projectKeys.count : deviceKeys.count) : 0);
}



- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item
{
	// We use 'item' as a proxy for row number by converting 'index' (which
	// is the row number) to an NSNumber so it can be referenced via 'item'
	
	return [NSNumber numberWithInteger:index];
}



- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn byItem:(nullable id)item
{
	// This needs to be here or the NSOutlineView viewForColumn: method is never called
	
	return (panelSelector.selectedSegment == 1 ? @"DD" : @"PP");
}



- (NSView *)outlineView:(NSOutlineView *)outlineView viewForTableColumn:(nullable NSTableColumn *)tableColumn item:(nonnull id)item
{
	id cellView = nil;
	
	// Retrieve the row number encoded as an NSNumber referenced by 'item'
	
	NSNumber *num = (NSNumber *)item;
	NSInteger row = num.integerValue;
	
	// Use 'valueArray' and 'keyArray' as proxies for the appropriate data set
	// (project or device)
	
	NSMutableArray *valueArray = nil;
	NSMutableArray *keyArray = nil;
	
	if (panelSelector.selectedSegment == 1)
	{
		keyArray = deviceKeys;
		valueArray = deviceValues;
	}
	else
	{
		keyArray = projectKeys;
		valueArray = projectValues;
	}
	
	NSString *key = [keyArray objectAtIndex:row];
	NSString *value = [valueArray objectAtIndex:row];
			
	if (value.length == 0)
	{
		// This is a Header row
		
		NSTableCellView *cv = [outlineView makeViewWithIdentifier:@"header.cell" owner:self];
		cv.textField.stringValue = [key uppercaseString];
		cellView = cv;
	}
	else
	{
		// Data row
		
		InspectorDataCellView *cv = [outlineView makeViewWithIdentifier:@"data.cell" owner:self];
		cv.title.stringValue = key;
		cv.data.stringValue = value;
		
		if (panelSelector.selectedSegment == 1)
		{
			// This is a device
			
			if ([self isURLRow:row])
			{
				// If data is a URL, make sure there's an active button at the end of the row
				
				[cv.goToButton setTarget:self];
				[cv.goToButton setAction:@selector(goToURL:)];
				[cv.goToButton setHidden:NO];
				cv.row = row;
			}
			else
			{
				[cv.goToButton setHidden:YES];
			}
		}
		else
		{
			// This is a project
			
			if ([self isLinkRow:row])
			{
				// If data is a file path, make sure there's an active button at the end of the row
				
				[cv.goToButton setTarget:self];
				[cv.goToButton setAction:@selector(link:)];
				[cv.goToButton setHidden:NO];
				cv.row = row;
			}
			else
			{
				[cv.goToButton setHidden:YES];
			}
		}
		
		cellView = cv;
	}
	
	return cellView;
}



- (CGFloat)outlineView:(NSOutlineView *)outlineView heightOfRowByItem:(id)item
{
	// Return the appropriate height of the row, set by the deepest of the row's elements
	// This should be the main data field
	
	// Get the row we're working on
	
	NSNumber *num = (NSNumber *)item;
	NSInteger index = num.integerValue;
	
	// Set 'keyArray' and 'valueArray' as proxies for whichever data set (projects or
	// devices) that we are working with
	
	NSMutableArray *valueArray = nil;
	NSMutableArray *keyArray = nil;
	
	if (panelSelector.selectedSegment == 1)
	{
		keyArray = deviceKeys;
		valueArray = deviceValues;
	}
	else
	{
		keyArray = projectKeys;
		valueArray = projectValues;
	}
	
	NSString *key = [keyArray objectAtIndex:index];
	NSString *value = [valueArray objectAtIndex:index];
	
	// Spacer row — ie. 'key' and 'value' equal a single space
	
	if (key.length == 1 && value.length == 1) return 10;
	
	// Information row - but is it a header ('value' equals zero-length
	// string) or a data row?
	
	if (value.length > 1)
	{
		// Get the rendered height of the data text - it's drawn into
		// an area as wide as the data column
		
		CGFloat renderHeight = [self renderedHeightOfString:value];
		
		// 20 is the height of one standard line
		if (renderHeight < 20) renderHeight = 20;
		
		// Calculate the maximum, dealing with a fudge factor
		if (renderHeight > 20 && fmod(renderHeight, 20) > 0)
		{
			renderHeight = renderHeight - fmod(renderHeight, 20) + 20;
		}
		
		return renderHeight;
	}
	
	// Return the height of a header row
	
	return 30;
}



#pragma mark - Path Manipulation Methods


- (NSString *)getAbsolutePath:(NSString *)basePath :(NSString *)relativePath
{
	// Expand a relative path that is relative to the base path to an absolute path
	
	NSString *absolutePath = [basePath stringByAppendingFormat:@"/%@", relativePath];
	absolutePath = [absolutePath stringByStandardizingPath];
	return absolutePath;
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
			// The file path contains the base path, eg.
			// '/Users/smitty/documents/github/squinter/files'
			// contains
			// '/Users/smitty/documents/github/squinter'
			
			theFilePath = [theFilePath substringFromIndex:r.length];
		}
		else
		{
			// The file path does not contain the base path, eg.
			// '/Users/smitty/downloads'
			// doesn't contain
			// '/Users/smitty/documents/github/squinter'
			
			theFilePath = [self getPathDelta:basePath :theFilePath];
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
		}
	}
	
	return theFilePath;
}



- (NSString *)getPathDelta:(NSString *)basePath :(NSString *)filePath
{
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
	NSArray *parts = [path componentsSeparatedByString:@"/"];
	return (parts.count - 1);
}



- (CGFloat)renderedHeightOfString:(NSString *)string
{
	NSTextField *nstf = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 172, 400)];
	nstf.cell.wraps = YES;
	nstf.cell.lineBreakMode = NSLineBreakByWordWrapping; //NSLineBreakByCharWrapping;
	NSFont *font = [NSFont systemFontOfSize:11];
	NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName, nil];
	nstf.attributedStringValue = [[NSAttributedString alloc] initWithString:string attributes:attributes];
	return [nstf.cell cellSizeForBounds:nstf.bounds].height;
}



- (NSString *)convertDevicegroupType:(NSString *)type :(BOOL)back
{
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


@end

